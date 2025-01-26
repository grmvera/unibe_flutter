const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const cors = require("cors")({ origin: true });
const { updateEmailsInBulk } = require("./bulkFunctions");
const { sendEmailOnUserCreation } = require("./emailService");
const deleteUser = require("./deleteuser");
const updateCyclesAndUsers = require("./updatecyclesandusers");
const webUploadProfileImage = require("./webUploadProfileImage");

// Exportar la función de actualización masiva
exports.webUploadProfileImage = webUploadProfileImage.webUploadProfileImage;
exports.deleteUser = deleteUser.deleteUser;
exports.updateEmailsInBulk = updateEmailsInBulk;
exports.sendEmailOnUserCreation = sendEmailOnUserCreation;
exports.updateCyclesAndUsers = updateCyclesAndUsers.updateCyclesAndUsers;

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
