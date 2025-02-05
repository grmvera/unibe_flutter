const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const corsMiddleware = require("./corsMiddleware");

exports.deleteUser = functions
    .region("us-central1") 
    .runWith({ memory: "256MB", timeoutSeconds: 60 }) 
    .https.onRequest((req, res) => {
        corsMiddleware(req, res, async () => {
            try {
                const { uid } = req.body;

                if (!uid) {
                    return res.status(400).json({
                        error: {
                            message: "El UID es obligatorio.",
                            status: "INVALID_ARGUMENT",
                        },
                    });
                }

                console.log("Eliminando usuario con UID:", uid);

                await admin.auth().deleteUser(uid);
                console.log(`Usuario ${uid} eliminado de Firebase Authentication.`);

                const userRef = admin.firestore().collection("users").doc(uid);
                await userRef.delete();
                console.log(`Documento ${uid} eliminado de Firestore.`);

                return res.status(200).json({ message: "Usuario eliminado correctamente." });
            } catch (error) {
                console.error("Error al eliminar usuario:", error);
                return res.status(500).json({
                    error: {
                        message: "Error interno al eliminar usuario.",
                        details: error.message,
                    },
                });
            }
        });
    });
