const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

const mockJuegos = [
    { id: 0, title: "Hollow Knight", developer: "Team Cherry", price: "15.00", bg: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=800&q=80" },
    { id: 1, title: "Celeste", developer: "Maddy Makes Games", price: "19.99", bg: "https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=800&q=80" },
    { id: 2, title: "Hades", developer: "Supergiant Games", price: "24.99", bg: "https://images.unsplash.com/photo-1552820728-8b83bb6b773f?auto=format&fit=crop&w=800&q=80" },
    { id: 3, title: "Stardew Valley", developer: "ConcernedApe", price: "14.99", bg: "https://images.unsplash.com/photo-1534423861386-85a16f5d13fd?auto=format&fit=crop&w=800&q=80" }
];

app.get('/api/juegos', (req, res) => {
    res.json(mockJuegos);
});

io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    if (token === "indiehub-tv-client-token" || token === "indiehub-phone-client-token" || token === "indiehub-wearable-token") {
        return next();
    }
    return next(new Error("Denegada"));
});

io.on('connection', (socket) => {
    socket.on('sync_wearable_data', (data) => {
        socket.broadcast.emit('sync_wearable_data', data);
    });

    socket.on('tv_purchase_attempt', (data) => {
        io.emit('2fa_request', { mensaje: `Aprobar compra: ${data.juego}` });
    });

    socket.on('2fa_approved', () => {
        io.emit('2fa_approved_success', { mensaje: 'Compra autorizada' });
    });

    socket.on('phone_purchase', (juego) => {
        socket.broadcast.emit('juego_comprado', juego);
        socket.broadcast.emit('tv_actualizar_biblioteca', { mensaje: `¡${juego.title} adquirido!` });
    });

    socket.on('phone_action', (data) => {
        if (data && typeof data.mensaje === 'string') {
            socket.broadcast.emit('tv_actualizar_biblioteca', { mensaje: data.mensaje });
        }
    });

    socket.on('wearable_alert', (data) => {
        if (data && typeof data.mensaje === 'string' && typeof data.tipo === 'string') {
            socket.broadcast.emit('tv_alerta_wearable', { mensaje: data.mensaje });
        }
    });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {});