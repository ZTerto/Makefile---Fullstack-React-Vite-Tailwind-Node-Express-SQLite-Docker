# 🚀 Proyecto Fullstack: React + Vite + Tailwind + Node + Express + SQLite + Docker

Este repositorio contiene un entorno completo de desarrollo **fullstack**, totalmente automatizado mediante un **Makefile**, con:
- **Frontend:** React + Vite + TypeScript + TailwindCSS  
- **Backend:** Node.js + Express + SQLite (better-sqlite3)  
- **Contenedores:** Docker + Docker Compose  
- **Base de datos:** SQLite con acceso desde línea de comandos  
- **Scripts automáticos:** Generación de carpetas, `.env`, Dockerfiles, dependencias, etc.

El objetivo es poder levantar un entorno completo de desarrollo en pocos segundos usando:
make build0
make build1
make build2
make up

---

# 📦 Requisitos

Antes de comenzar, asegúrate de tener instalado:
- `make`
- `node` y `npm`
- `docker`
- `docker-compose`
- `sqlite3`

Puedes verificarlo ejecutando:
make build

---

# 🗂️ Estructura del proyecto

```bash
.
├── frontend/
│ ├── src/
│ │ ├── pages/
│ │ │ ├── Home.tsx
│ │ │ └── Login.tsx
│ │ └── utils/
│ ├── Dockerfile
│ └── .env
│
├── backend/
│ ├── index.js
│ ├── db/
│ │ └── data.db
│ ├── images/
│ ├── Dockerfile
│ └── .env
│
├── docker-compose.yml
└── Makefile
```

---

# ⚙️ Comandos principales del Makefile

### ▶️ **Levantar todo el entorno**
make up

Esto hace:

- Detiene contenedores previos  
- Levanta `frontend` y `backend` con Docker  
- Lanza el backend en segundo plano (modo desarrollo fuera del contenedor)

---

### ▶️ **Levantar solo el frontend**
make upFrontend


---

### ▶️ **Levantar solo el backend (Docker)**
make upBackend


---

### ⏹️ **Detener todo**
make down



Hace:

- `docker-compose down`
- Apaga el backend en segundo plano si existe

---

### ♻️ **Reiniciar todo**
make reload


---

### 🗑️ **Eliminar todo por completo**
make fclean


Esto borra:
- frontend/
- backend/
- docker-compose.yml  
- todos los `.env`  
- datos temporales  

---

# 🗄️ Base de datos SQLite
Puedes listar y consultar la base de datos con:
make db


Luego abre una consola interactiva de SQLite.

---

# 🏗️ Construcción del proyecto
La creación del entorno está dividida en fases.

### **1️⃣ build0 — Crear base del frontend + docker-compose minimal**
make build0

Crea:
- carpeta `frontend/`
- `.env`
- `docker-compose.yml` inicial
- Vite

---

### **2️⃣ build1 — Configurar Tailwind, Router, Pages y Dockerfile del frontend**
make build1

Incluye:
- Tailwind
- Router
- Pages: Home y Login
- utils/
- Dockerfile dinámico (puerto desde .env)

---

### **3️⃣ build2 — Crear backend, instalar dependencias, generar Dockerfile**
make build2


Instala:

- Express  
- SQLite (better-sqlite3)  
- JWT  
- Bcrypt  
- dotenv  

Genera:

- backend/index.js funcional  
- Dockerfile  
- docker-compose.yml completo  

---

# 🧪 Comprobación rápida

Ejecuta:

Debe devolver:

```json
{ "message": "Backend funcionando 🎉" }
```

Y el frontend estará en:
```json
http://localhost:8080
```
