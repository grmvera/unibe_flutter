const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const { Buffer } = require("buffer");

exports.webUploadProfileImage = functions.https.onCall(async (data, context) => {
  console.log("Datos recibidos en la función:", data);

  if (!context.auth) {
    console.error("Solicitud no autenticada.");
    throw new functions.https.HttpsError(
      "unauthenticated",
      "La solicitud debe estar autenticada."
    );
  }

  const userId = context.auth.uid;
  const { imageData } = data;

  if (!imageData || imageData.length < 10) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "El parámetro imageData es demasiado pequeño o está vacío."
    );
  }
  console.log(`Tamaño de imageData recibido: ${imageData.length}`);

  try {
    // Convertir imagen de Base64 a buffer
    console.log("Convirtiendo imagen de Base64 a buffer...");
    const buffer = Buffer.from(imageData, "base64");
    if (!buffer || buffer.length === 0) {
      throw new Error("El buffer es inválido o está vacío.");
    }
    console.log("Buffer generado correctamente.");

    const filePath = `profile_images/${userId}.png`;
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);

    console.log("Guardando archivo en Firebase Storage...");
    await file.save(buffer, {
      metadata: {
        contentType: "image/png",
      },
    });

    console.log("Haciendo público el archivo...");
    await file.makePublic();

    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;
    console.log("URL pública generada:", publicUrl);

    await admin.firestore().collection("users").doc(userId).update({
      profileImage: publicUrl,
    });

    return { imageUrl: publicUrl };
  } catch (error) {
    console.error("Error al procesar la imagen:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Ocurrió un error al procesar la imagen.",
      error.message
    );
  }
});
