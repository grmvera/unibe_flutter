const functions = require
("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.deleteUser = functions.firestore
    .document("users/{userId}")
    .onDelete(async (snap, context) => {
        const userId = context.params.userId;
        try {
            await admin.auth().deleteUser(userId);
            console.log("Usuario eliminado de Authentication:", userId);
        } catch (error) {
            console.error("Error al eliminar usuario de Authentication:", error);
        }
    });