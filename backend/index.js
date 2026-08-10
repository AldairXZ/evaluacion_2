const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
// CORS habilitado para permitir peticiones de tu PWA local o desplegada
app.use(cors()); 
app.use(express.json());

const server = http.createServer(app);

// Configuración de WebSockets (AU.1)
const io = new Server(server, {
    cors: {
        origin: "*", // En un entorno real, aquí validas el origin por seguridad (SA.4)
        methods: ["GET", "POST"]
    }
});

// ---------------------------------------------------------
// 1. API REST Simulada (SA.2.C - Datos Reales)
// ---------------------------------------------------------
const mockJuegos = [
    { id: 0, title: "Hollow Knight", developer: "Team Cherry", price: "15.00", bg: "https://wallpapers.com/images/featured/hollow-knight-ibq139z5e4l321n0.jpg" },
    { id: 1, title: "Celeste", developer: "Maddy Makes Games", price: "19.99", bg: "https://c4.wallpaperflare.com/wallpaper/705/734/41/celeste-video-games-madeline-celeste-mountain-wallpaper-preview.jpg" },
    { id: 2, title: "Hades", developer: "Supergiant Games", price: "24.99", bg: "https://images3.alphacoders.com/109/1096054.jpg" },
    { id: 3, title: "Stardew Valley", developer: "ConcernedApe", price: "14.99", bg: "https://images5.alphacoders.com/712/712165.jpg" }
];

app.get('/api/juegos', (req, res) => {
    res.json(mockJuegos);
});

// ---------------------------------------------------------
// 2. Autenticación Mínima del Canal WebSocket (AU.1)
// ---------------------------------------------------------
io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    // Validamos que el cliente tenga el token secreto compartido
    if (token === "indiehub-tv-client-token" || token === "indiehub-phone-client-token") {
        return next();
    }
    return next(new Error("Autenticación denegada: Token inválido"));
});

// ---------------------------------------------------------
// 3. Sincronización Bidireccional en Tiempo Real (AU.1)
// ---------------------------------------------------------
io.on('connection', (socket) => {
    console.log(`Dispositivo conectado al ecosistema: ${socket.id}`);

    // Escenario 1: El teléfono realiza una acción y la TV se actualiza en < 1 seg (AU.1)
    socket.on('phone_action', (data) => {
        // Validación de Schema / Tipo de dato (AU.1)
        if (data && typeof data.mensaje === 'string') {
            console.log('📲 Acción del teléfono recibida:', data.mensaje);
            // Retransmitimos a la TV
            socket.broadcast.emit('tv_actualizar_biblioteca', { mensaje: data.mensaje });
        } else {
            console.error('⚠️ Payload inválido en phone_action. Posible inyección de datos maliciosos (AU.2).');
        }
    });

    // Escenario 2: El wearable envía datos críticos -> teléfono -> notifica a la TV (AU.1)
    socket.on('wearable_alert', (data) => {
        // Validación estricta de tipos de datos antes de procesar (AU.1)
        if (data && typeof data.mensaje === 'string' && typeof data.ritmoCardiaco === 'number') {
            console.log(`⌚ Alerta del wearable recibida: ${data.mensaje} (${data.ritmoCardiaco} bpm)`);
            socket.broadcast.emit('tv_alerta_wearable', { mensaje: data.mensaje });
        } else {
            console.error('⚠️ Payload inválido en wearable_alert.');
        }
    });

    socket.on('disconnect', () => {
        console.log(`Dispositivo desconectado: ${socket.id}`);
    });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
    console.log(`✅ Backend de IndieHub corriendo en http://localhost:${PORT}`);
    console.log(`🔌 WebSockets escuchando en el puerto ${PORT}`);
});