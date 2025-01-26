const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const corsMiddleware = require("./corsMiddleware");

// Configurar Nodemailer
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: "geovanny00vera@gmail.com", // Tu correo Gmail
        pass: "knws qpad eohp hedz", // Contraseña de aplicación generada
    },
});

// Función para enviar correos
exports.sendEmailOnUserCreation = functions
    .region("us-central1")
    .runWith({ memory: "256MB", timeoutSeconds: 60 })
    .https.onRequest((req, res) => {
        corsMiddleware(req, res, async () => {
            const { email, displayName, idNumber } = req.body;

            if (!email || !displayName || !idNumber) {
                return res.status(400).send({ success: false, message: "Datos incompletos" });
            }

            const mailOptions = {
                from: "geovanny00vera@gmail.com",
                to: email,
                subject: "Bienvenido a nuestra plataforma",
                text: `Hola, ${displayName}!

¡Te damos la bienvenida a nuestra plataforma! Este será tu nuevo correo asociado: ${email}. 
Tu contraseña inicial será tu número de cédula: ${idNumber}.

Puedes acceder a nuestra aplicación en el siguiente enlace:
https://controlacceso-403b0.firebaseapp.com/

Por favor, cambia tu contraseña después de iniciar sesión para mantener tu cuenta segura.

¡Gracias por formar parte de nuestra comunidad!

Saludos cordiales,
Equipo de Control de Acceso`,
                html: `<strong>Hola, ${displayName}!</strong><br><br>
             ¡Te damos la bienvenida a nuestra plataforma! Este será tu nuevo correo asociado: <strong>${email}</strong>.<br>
             Tu contraseña inicial será tu número de cédula: <strong>${idNumber}</strong>.<br><br>
             Puedes acceder a nuestra aplicación en el siguiente enlace:<br>
             <a href="https://controlacceso-403b0.firebaseapp.com/">https://controlacceso-403b0.firebaseapp.com/</a><br><br>
             <strong>Por favor, cambia tu contraseña después de iniciar sesión para mantener tu cuenta segura.</strong><br><br>
             ¡Gracias por formar parte de nuestra comunidad!<br><br>
             Saludos cordiales,<br>
             Equipo de Control de Acceso`,
            };

            try {
                await transporter.sendMail(mailOptions);
                return res.status(200).send({ success: true, message: "Correo enviado exitosamente" });
            } catch (error) {
                console.error("Error al enviar el correo:", error);
                return res.status(500).send({ success: false, message: "Error al enviar el correo", error });
            }
        });
    });
