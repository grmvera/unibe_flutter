const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const cors = require("cors")({ origin: true });

exports.updateEmailsInBulk = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { users } = req.body;

      // Validar que el body contenga un array de usuarios
      if (!users || !Array.isArray(users)) {
        res.status(400).send({ error: "Faltan parámetros o formato inválido." });
        return;
      }

      // Iterar sobre los usuarios y actualizar sus correos
      const results = [];
      for (const user of users) {
        const { uid, newEmail } = user;

        if (!uid || !newEmail) {
          // Saltar usuarios con datos incompletos
          results.push({ uid, status: "skipped", message: "Datos incompletos." });
          continue;
        }

        try {
          await admin.auth().updateUser(uid, { email: newEmail });
          results.push({ uid, status: "success", message: "Correo actualizado." });
        } catch (error) {
          results.push({ uid, status: "error", message: error.message });
        }
      }

      res.status(200).send({
        message: "Proceso de actualización completado.",
        results,
      });
    } catch (error) {
      console.error("Error en actualización masiva:", error);
      res.status(500).send({ error: error.message });
    }
  });
});
