const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const cors = require('cors')({ origin: true });

exports.deleteUser = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
        const { uid } = req.body;

        // Verificar si el UID está presente
        if (!uid) {
            console.error("El UID no fue proporcionado.");
            return res.status(400).json({
                error: {
                    message: "El UID es obligatorio.",
                    status: "INVALID_ARGUMENT",
                },
            });
        }

        console.log("UID recibido:", uid);

        try {
            // Eliminar usuario en Firebase Authentication
            await admin.auth().deleteUser(uid);
            console.log(`Usuario ${uid} eliminado de Firebase Authentication.`);

            // Eliminar documento en Firestore
            await admin.firestore().collection("users").doc(uid).delete();
            console.log(`Documento ${uid} eliminado de Firestore.`);

            return res.status(200).json({ message: "Usuario eliminado correctamente." });
        } catch (error) {
            console.error("Error al eliminar usuario:", error);
            return res.status(500).json({
                error: {
                    message: "Error al eliminar usuario.",
                    status: "UNKNOWN",
                    details: error.message, // Agregar detalles del error
                },
            });
        }
    });
});




