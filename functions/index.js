const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors")({ origin: true });

admin.initializeApp();

exports.updateUserEmail = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        try {
            const { uid, newEmail } = req.body;
            if (!uid || !newEmail) {
                res.status(400).send({ error: "Faltan parámetros uid o newEmail." });
                return;
            }

            // Actualizar el correo en Authentication
            await admin.auth().updateUser(uid, { email: newEmail });
            res.status(200).send({ message: "Correo actualizado exitosamente." });
        } catch (error) {
            console.error("Error actualizando el correo:", error);
            res.status(500).send({ error: error.message });
        }
    });
});
