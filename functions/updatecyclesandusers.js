const functions = require("firebase-functions");
const admin = require("./firebaseAdmin");

exports.updateCyclesAndUsers = functions
  .region("us-central1")
  .runWith({ memory: "256MB", timeoutSeconds: 60 })
  .pubsub.schedule('0 0 * * *') 
  .timeZone('America/Guayaquil') 
  .onRun(async (context) => {
    try {
      console.log("Inicio de la actualización de ciclos y usuarios...");

      
      const now = new Date().toISOString(); 
      console.log("Fecha actual (now):", now);

      const cyclesSnapshot = await admin.firestore()
        .collection("cycles")
        .where("isActive", "==", true)
        .where("endDate", "<=", now) 
        .get();

        console.log(`Ciclos vencidos encontrados: ${cyclesSnapshot.size}`);
      if (cyclesSnapshot.empty) {
        console.log("No hay ciclos vencidos para procesar.");
        return;
      }

      let cycleIds = [];
      let updates = [];

      cyclesSnapshot.docs.forEach((cycleDoc) => {
        const cycleId = cycleDoc.id;
        cycleIds.push(cycleId);
        updates.push({ ref: cycleDoc.ref, data: { isActive: false } });
      });

      console.log(`Ciclos a desactivar: ${cycleIds.length}`);

      const userBatches = [];
      while (cycleIds.length) {
        userBatches.push(cycleIds.splice(0, 10));
      }

      let totalUsers = 0;

      for (const batchIds of userBatches) {
        const usersSnapshot = await admin.firestore()
          .collection("users")
          .where("cycleId", "in", batchIds) 
          .get();

        console.log(`Usuarios a desactivar en este lote: ${usersSnapshot.size}`);
        totalUsers += usersSnapshot.size;

        usersSnapshot.docs.forEach((userDoc) => {
          updates.push({ ref: userDoc.ref, data: { status: false } });
        });
      }

      console.log(`Total de usuarios a desactivar: ${totalUsers}`);

      const commitBatches = async (updates) => {
        let batch = admin.firestore().batch();
        let counter = 0;

        for (let i = 0; i < updates.length; i++) {
          batch.update(updates[i].ref, updates[i].data);
          counter++;

          if (counter === 500 || i === updates.length - 1) {
            await batch.commit();
            console.log(`Batch de ${counter} operaciones ejecutado.`);
            batch = admin.firestore().batch();
            counter = 0;
          }
        }
      };

      await commitBatches(updates);

      console.log("Ciclos y usuarios actualizados correctamente.");
    } catch (error) {
      console.error("Error al actualizar ciclos y usuarios:", error);
    }
  });
