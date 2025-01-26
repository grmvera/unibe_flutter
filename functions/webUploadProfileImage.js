const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const { Buffer } = require("buffer");
const corsMiddleware = require("./corsMiddleware");

exports.uploadProfileImage = functions
  .region("us-central1") // Especificar región
  .runWith({ memory: "256MB", timeoutSeconds: 60 }) // Ajustar recursos
  .https.onRequest((req, res) => {
    corsMiddleware(req, res, async () => {
      // Manejo de solicitudes preflight
      if (req.method === "OPTIONS") {
        return res.status(204).send("");
      }

      // Solo permitir POST
      if (req.method !== "POST") {
        return res.status(405).send({ error: "Método no permitido." });
      }

      try {
        // Verificar token de autenticación
        const authToken = req.headers.authorization?.split("Bearer ")[1];
        if (!authToken) {
          return res.status(401).send({ error: "Usuario no autenticado." });
        }

        const decodedToken = await admin.auth().verifyIdToken(authToken);
        const userId = decodedToken.uid;

        const { imageData } = req.body;

        // Validar que imageData no esté vacío o sea inválido
        if (!imageData || imageData.length < 10) {
          return res.status(400).send({
            error: "El parámetro imageData es inválido o está vacío.",
          });
        }

        console.log("Tamaño de imageData recibido:", imageData.length);

        // Convertir Base64 a buffer
        const buffer = Buffer.from(imageData, "base64");
        if (!buffer || buffer.length === 0) {
          throw new Error("El buffer es inválido o está vacío.");
        }

        // Configurar ruta del archivo y subir al bucket
        const filePath = `profile_images/${userId}.png`;
        const bucket = admin.storage().bucket(); // Bucket debe estar configurado en firebaseAdmin.js
        const file = bucket.file(filePath);

        await file.save(buffer, {
          metadata: {
            contentType: "image/png",
          },
        });

        // Crear URL firmada para acceso seguro
        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2500", // Fecha de expiración
        });

        console.log("URL de descarga generada:", url);

        // Guardar la URL en Firestore
        await admin.firestore().collection("users").doc(userId).update({
          profileImage: url,
        });

        // Respuesta exitosa
        return res.status(200).send({ imageUrl: url });
      } catch (error) {
        console.error("Error al procesar la solicitud:", error);
        return res.status(500).send({
          error: "Error interno al procesar la imagen.",
          message: error.message,
        });
      }
    });
  });
