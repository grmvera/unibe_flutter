const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");
const corsMiddleware = require("./corsMiddleware");

exports.updateCyclesAndUsers = functions
    .region("us-central1")
    .runWith({ memory: "256MB", timeoutSeconds: 60 })
    .https.onRequest((req, res) => {
        corsMiddleware(req, res, async () => {
            try {
                console.log("Inicio de la actualización de ciclos y usuarios...");

                const now = admin.firestore.Timestamp.now();

                const cyclesSnapshot = await admin.firestore()
                    .collection("cycles")
                    .where("isActive", "==", true)
                    .where("endDate", "<=", now)
                    .get();

                if (cyclesSnapshot.empty) {
                    console.log("No hay ciclos vencidos para procesar.");
                    return res.status(200).send({ message: "No hay ciclos vencidos para actualizar." });
                }

                const batch = admin.firestore().batch();
                const cycleIds = [];

                cyclesSnapshot.docs.forEach((cycleDoc) => {
                    const cycleId = cycleDoc.id;
                    cycleIds.push(cycleId);
                    batch.update(cycleDoc.ref, { isActive: false }); 
                });

                console.log(`Ciclos a desactivar: ${cycleIds.length}`);

                const usersSnapshot = await admin.firestore()
                    .collection("users")
                    .where("cycleId", "in", cycleIds)
                    .get();

                console.log(`Usuarios a desactivar: ${usersSnapshot.size}`);

                usersSnapshot.docs.forEach((userDoc) => {
                    batch.update(userDoc.ref, { status: false });
                });

                await batch.commit();

                console.log("Ciclos y usuarios actualizados correctamente.");
                return res.status(200).send({ message: "Ciclos y usuarios actualizados correctamente." });
            } catch (error) {
                console.error("Error al actualizar ciclos y usuarios:", error);
                return res.status(500).send({
                    error: "Error interno al procesar la actualización.",
                    message: error.message,
                });
            }
        });
    });
