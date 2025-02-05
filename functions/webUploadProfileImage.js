const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const { Buffer } = require("buffer");
const corsMiddleware = require("./corsMiddleware");

exports.uploadProfileImage = functions
  .region("us-central1") 
  .runWith({ memory: "256MB", timeoutSeconds: 60 }) 
  .https.onRequest((req, res) => {
    corsMiddleware(req, res, async () => {
      if (req.method === "OPTIONS") {
        return res.status(204).send("");
      }

      if (req.method !== "POST") {
        return res.status(405).send({ error: "Método no permitido." });
      }

      try {
        const authToken = req.headers.authorization?.split("Bearer ")[1];
        if (!authToken) {
          return res.status(401).send({ error: "Usuario no autenticado." });
        }

        const decodedToken = await admin.auth().verifyIdToken(authToken);
        const userId = decodedToken.uid;

        const { imageData } = req.body;

        if (!imageData || imageData.length < 10) {
          return res.status(400).send({
            error: "El parámetro imageData es inválido o está vacío.",
          });
        }

        console.log("Tamaño de imageData recibido:", imageData.length);

        const buffer = Buffer.from(imageData, "base64");
        if (!buffer || buffer.length === 0) {
          throw new Error("El buffer es inválido o está vacío.");
        }

        const filePath = `profile_images/${userId}.png`;
        const bucket = admin.storage().bucket();
        const file = bucket.file(filePath);

        await file.save(buffer, {
          metadata: {
            contentType: "image/png",
          },
        });

        const [url] = await file.getSignedUrl({
          action: "read",
          expires: "03-01-2500",
        });

        console.log("URL de descarga generada:", url);

        await admin.firestore().collection("users").doc(userId).update({
          profileImage: url,
        });

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
