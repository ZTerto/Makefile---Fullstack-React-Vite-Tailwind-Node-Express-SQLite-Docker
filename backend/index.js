import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// --- Inicializar SQLite solo si NO_SQLITE !== true ---
let db = null;
if (process.env.NO_SQLITE !== 'true') {
  const Database = (await import('better-sqlite3')).default;
  db = new Database(process.env.DATABASE_PATH);
  console.log('SQLite activado ✔️');
} else {
  console.log('SQLite desactivado en Docker ❌');
}

app.get('/ping', (req, res) => {
  console.log(''); // salto de línea en terminal
  console.log('Petición recibida en /ping');
  res.json({ message: 'Backend funcionando 🎉' });
});

const PORT = process.env.BACKEND_PORT;
app.listen(PORT, () => {
  console.log('Backend escuchando en puerto ' + PORT);
});
