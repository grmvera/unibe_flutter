const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");

exports.updateCyclesAndUsers = functions.pubsub.schedule('0 0 * * *').timeZone('America/Guayaquil').onRun(async (context) => {
    console.log("Ejecutando función programada para actualizar ciclos y usuarios...");

    const now = new Date();
    try {
        const cyclesSnapshot = await admin.firestore()
            .collection('cycles')
            .where('isActive', '==', true)
            .where('endDate', '<=', now.toISOString())
            .get();

        if (cyclesSnapshot.empty) {
            console.log("No hay ciclos vencidos para procesar.");
            return null;
        }

        const batch = admin.firestore().batch();

        for (const cycleDoc of cyclesSnapshot.docs) {
            const cycleId = cycleDoc.id;
            batch.update(cycleDoc.ref, { isActive: false });

            const usersSnapshot = await admin.firestore()
                .collection('users')
                .where('cycleId', '==', cycleId)
                .get();

            for (const userDoc of usersSnapshot.docs) {
                batch.update(userDoc.ref, { status: false });
            }
        }

        await batch.commit();
        console.log("Ciclos y usuarios actualizados correctamente.");
        return null;
    } catch (error) {
        console.error("Error al actualizar ciclos y usuarios:", error);
        throw new functions.https.HttpsError('internal', 'Error al procesar los ciclos vencidos', error.message);
    }
});
