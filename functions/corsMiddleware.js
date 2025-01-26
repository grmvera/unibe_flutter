const cors = require("cors");

const allowedOrigins = [
  "http://localhost:51221", 
  "https://controlacceso-403b0.web.app"
];

const corsMiddleware = cors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error("No autorizado por política CORS"));
    }
  },
  methods: ["GET", "POST", "OPTIONS"],
  allowedHeaders: ["Authorization", "Content-Type"],
});

module.exports = corsMiddleware;
