const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const cors = require("cors")({ origin: true });
const { updateEmailsInBulk } = require("./bulkFunctions");
const { sendEmailOnUserCreation } = require("./emailService");

// Exportar la función de actualización masiva
exports.updateEmailsInBulk = updateEmailsInBulk;
exports.sendEmailOnUserCreation = sendEmailOnUserCreation;

// Función para actualizar un único correo
exports.updateUserEmail = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { uid, newEmail } = req.body;

      // Validar los parámetros
      if (!uid || !newEmail) {
        res.status(400).send({ error: "Faltan parámetros uid o newEmail." });
        return;
      }

      // Actualizar el correo
      await admin.auth().updateUser(uid, { email: newEmail });
      res.status(200).send({ message: "Correo actualizado exitosamente." });
    } catch (error) {
      console.error("Error actualizando el correo:", error);
      res.status(500).send({ error: error.message });
    }
  });
});
