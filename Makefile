.PHONY: up down reload upFrontend upBackend fclean db build fclean

# Levantar entorno docker
up:
	docker-compose down --volumes --remove-orphans || true
	docker-compose up -d
	cd backend && node index.js &

# Levantar entorno docker
upFrontend:
	docker-compose up frontend

# Levantar entorno docker
upBackend:
	docker-compose up backend

Backend:
	cd backend && node index.js

down:
	@echo "🛑 Deteniendo contenedores Docker..."
	@docker-compose down

	@echo "🛑 Apagando backend en segundo plano..."
	@if [ -f backend.pid ]; then \
		pid=$$(cat backend.pid); \
		echo "   - Terminando proceso backend PID $$pid"; \
		kill $$pid 2>/dev/null || true; \
		rm -f backend.pid; \
	else \
		echo "   - No hay backend.pid, no hay backend en segundo plano."; \
	fi

	@echo "✨ Entorno detenido completamente."


# Reiniciar
reload: down up

fclean:
	@echo "🧹 Limpiando entorno del frontend..."
	rm -rf frontend
	rm -f docker-compose.yml
	rm -f frontend/.env

	@echo "🧹 Limpiando entorno del backend..."
	rm -rf backend
	rm -rf mongo-data
	rm -f backend/.env

	@echo "🧹 Eliminando .env global..."
	rm -f .env

	@echo "✅ Limpieza completa."

db:
	@echo "📘 Tutorial de SQLite:"
	@echo "  • .tables           -> muestra todas las tablas"
	@echo "  • .schema <tabla>   -> muestra la estructura de una tabla"
	@echo "  • SELECT * FROM <tabla>; -> muestra todos los valores"
	@echo "  • .exit             -> salir"
	@echo ""
	@echo "📋 Listado de tablas en la base de datos:"
	@sqlite3 backend/db/data.db ".tables"
	@echo ""
	@sqlite3 backend/db/data.db


# Verificar entorno
build:
	@echo "🧪 Verificando entorno..."

	@# Verificar make
	@if ! command -v make > /dev/null; then \
		echo "❌ make no está instalado. Instálalo con: sudo apt install make"; \
		exit 1; \
	else \
		echo "✅ make instalado"; \
	fi

	@# Verificar node
	@if ! command -v node > /dev/null; then \
		echo "❌ Node.js no está instalado. Instálalo con: sudo apt install nodejs"; \
		exit 1; \
	else \
		echo "✅ Node.js instalado: $$(node -v)"; \
	fi

	@# Verificar npm
	@if ! command -v npm > /dev/null; then \
		echo "❌ npm no está instalado. Instálalo con: sudo apt install npm"; \
		exit 1; \
	else \
		echo "✅ npm instalado: $$(npm -v)"; \
	fi

	@# Verificar docker
	@if ! command -v docker > /dev/null; then \
		echo "❌ Docker no está instalado. Instálalo con: sudo apt install docker.io"; \
		exit 1; \
	else \
		echo "✅ Docker instalado: $$(docker --version)"; \
	fi

	@# Verificar docker-compose
	@if ! command -v docker-compose > /dev/null; then \
		echo "❌ docker-compose no está instalado. Instálalo con: sudo apt install docker-compose"; \
		exit 1; \
	else \
		echo "✅ docker-compose instalado: $$(docker-compose --version)"; \
	fi

	@echo "🎉 Todos los requisitos están satisfechos."


# Construir entorno docker con Vite y TailwindCSS + instalación del frontend
build0:
	@echo "📁 Creando carpeta frontend..."
	@mkdir -p frontend

	@echo "📝 Creando archivo .env..."
	@echo "FRONTEND_PORT=8080" > .env
	@echo "BACKEND_PORT=3000" >> .env

	@echo "🐳 Construyendo contenedores (si existen)..."
	@docker-compose build >/dev/null 2>&1 || true

	@echo "📝 Generando docker-compose.yml..."
	@echo "services:" > docker-compose.yml
	@echo "  frontend:" >> docker-compose.yml
	@echo "    image: node:20" >> docker-compose.yml
	@echo "    working_dir: /app" >> docker-compose.yml
	@echo "    env_file: .env" >> docker-compose.yml
	@echo "    volumes:" >> docker-compose.yml
	@echo "      - ./frontend:/app" >> docker-compose.yml
	@echo '    command: ["npm", "run", "dev", "--", "--host", "--port", "8080"]' >> docker-compose.yml
	@echo "    ports:" >> docker-compose.yml
	@echo '      - "8080:8080"' >> docker-compose.yml
	@echo "" >> docker-compose.yml
	@echo "networks:" >> docker-compose.yml
	@echo "  app-network:" >> docker-compose.yml
	@echo "    driver: bridge" >> docker-compose.yml

	@echo "🔧 Modificando docker-compose.yml para usar variables del .env..."
	@sed -i 's/8080:8080/$${FRONTEND_PORT}:$${FRONTEND_PORT}/' docker-compose.yml
	@sed -i 's/"8080"/"$${FRONTEND_PORT}"/' docker-compose.yml

	@echo "⚙️  Ejecutando instalación de Vite dentro de frontend..."
	@cd frontend && npm create vite@latest

	@echo "🎉 build0 completado: entorno Vite + Docker creado correctamente."


# https://tailwindcss.com/docs/installation/using-vite
# Instalar Tailwind, configurar Vite, Router, SPA base y Dockerfile
build1:
	@echo "📝 Creando archivo .env en frontend..."
	@cd frontend && \
		echo "FRONTEND_PORT=8080" > .env && \
		echo "VITE_API_URL=http://localhost:3000" >> .env

	@echo "🧩 Configurando Tailwind, Vite y dependencias del frontend..."
	@cd frontend && \
		npm install -D vite >/dev/null 2>&1 && \
		npm install tailwindcss @tailwindcss/vite >/dev/null 2>&1 && \
		npm install react-router-dom @types/react-router-dom >/dev/null 2>&1 && \
		npm install jwt-decode >/dev/null 2>&1

	@echo "📝 Generando vite.config.ts..."
	@cd frontend && \
		echo "import { defineConfig } from 'vite'" > vite.config.ts && \
		echo "import tailwindcss from '@tailwindcss/vite'" >> vite.config.ts && \
		echo "" >> vite.config.ts && \
		echo "export default defineConfig({" >> vite.config.ts && \
		echo "  plugins: [" >> vite.config.ts && \
		echo "    tailwindcss()," >> vite.config.ts && \
		echo "  ]," >> vite.config.ts && \
		echo "})" >> vite.config.ts

	@echo "🎨 Generando index.css..."
	@cd frontend && \
		echo "@tailwind base;" > src/index.css && \
		echo "@tailwind components;" >> src/index.css && \
		echo "@tailwind utilities;" >> src/index.css && \
		echo '@import "tailwindcss";' >> src/index.css

	@echo "📁 Creando estructura de páginas..."
	@cd frontend && mkdir -p src/pages

	@echo "📝 Creando Home.tsx..."
	@cd frontend && \
		echo "export default function Home() {" > src/pages/Home.tsx && \
		echo "  return (" >> src/pages/Home.tsx && \
		echo "    <div className='p-6'>" >> src/pages/Home.tsx && \
		echo "      <h1 className='text-3xl font-bold'>Home Page</h1>" >> src/pages/Home.tsx && \
		echo "      <p>Bienvenido a tu aplicación React + Vite + Tailwind 🎉</p>" >> src/pages/Home.tsx && \
		echo "    </div>" >> src/pages/Home.tsx && \
		echo "  );" >> src/pages/Home.tsx && \
		echo "}" >> src/pages/Home.tsx

	@echo "📝 Creando Login.tsx..."
	@cd frontend && \
		echo "export default function Login() {" > src/pages/Login.tsx && \
		echo "  return (" >> src/pages/Login.tsx && \
		echo "    <div className='p-6'>" >> src/pages/Login.tsx && \
		echo "      <h1 className='text-3xl font-bold'>Login</h1>" >> src/pages/Login.tsx && \
		echo "      <p>Aquí gestionaremos el login más adelante.</p>" >> src/pages/Login.tsx && \
		echo "    </div>" >> src/pages/Login.tsx && \
		echo "  );" >> src/pages/Login.tsx && \
		echo "}" >> src/pages/Login.tsx

	@echo "🧰 Creando carpeta utils..."
	@cd frontend && mkdir -p src/utils

	@echo "🐳 Generando Dockerfile para el frontend..."
	@cd frontend && \
		echo "# Etapa de desarrollo" > Dockerfile && \
		echo "FROM node:20" >> Dockerfile && \
		echo "" >> Dockerfile && \
		echo "WORKDIR /app" >> Dockerfile && \
		echo "" >> Dockerfile && \
		echo "COPY package*.json ./" >> Dockerfile && \
		echo "RUN npm install" >> Dockerfile && \
		echo "COPY . ." >> Dockerfile && \
		echo "EXPOSE 8080" >> Dockerfile && \
		echo 'CMD ["npm", "run", "dev", "--", "--host", "--port", "8080"]' >> Dockerfile

	@echo "🔧 Ajustando Dockerfile para usar variables del .env..."
	@cd frontend && \
		sed -i 's/EXPOSE 8080/EXPOSE $${FRONTEND_PORT}/' Dockerfile && \
		sed -i 's/"8080"/"$${FRONTEND_PORT}"/' Dockerfile

	@echo "✅ Frontend configurado correctamente (Tailwind + Router + Home + Login + utils + Dockerfile dinámico)"


# Crear backend, instalar dependencias y preparar SQLite
build2:
	@echo "🛠️  Creando estructura del backend..."
	@mkdir -p backend
	@mkdir -p backend/images
	@mkdir -p backend/db

	@echo "📝 Creando archivo .env en backend..."
	@cd backend && \
		echo "BACKEND_PORT=3000" > .env && \
		echo "DATABASE_PATH=./db/data.db" >> .env && \
		echo "NO_SQLITE=false" >> .env

	@echo "📄 Creando archivo de base de datos vacío..."
	@touch backend/db/data.db

	@echo "🔧 Instalando SQLite3 (requiere permisos de superusuario)..."
	@sudo apt update >/dev/null 2>&1 && sudo apt install -y sqlite3 >/dev/null 2>&1
	@echo "✅ SQLite3 instalado correctamente."

	@echo "📦 Inicializando npm en backend (ESM activado)..."
	@cd backend && npm init -y >/dev/null 2>&1

	@echo "🔧 Corrigiendo package.json a ES Modules..."
	@cd backend && sed -i 's/"type": "commonjs"/"type": "module"/' package.json

	@echo "🔧 Instalando build-essential y dependencias nativas..."
	@sudo apt install -y build-essential python3 python3-dev libsqlite3-dev >/dev/null 2>&1

	@echo "📦 Instalando dependencias del backend (Express + SQLite + JWT + Bcrypt)..."
	@cd backend && npm install \
		express axios fs-extra cors better-sqlite3 jsonwebtoken bcryptjs dotenv

	@echo "📄 Generando index.js básico para backend (SQLite opcional)..."
	@cd backend && \
		echo "import express from 'express';" > index.js && \
		echo "import cors from 'cors';" >> index.js && \
		echo "import dotenv from 'dotenv';" >> index.js && \
		echo "dotenv.config();" >> index.js && \
		echo "" >> index.js && \
		echo "const app = express();" >> index.js && \
		echo "app.use(cors());" >> index.js && \
		echo "app.use(express.json());" >> index.js && \
		echo "" >> index.js && \
		echo "// --- Inicializar SQLite solo si NO_SQLITE !== true ---" >> index.js && \
		echo "let db = null;" >> index.js && \
		echo "if (process.env.NO_SQLITE !== 'true') {" >> index.js && \
		echo "  const Database = (await import('better-sqlite3')).default;" >> index.js && \
		echo "  db = new Database(process.env.DATABASE_PATH);" >> index.js && \
		echo "  console.log('SQLite activado ✔️');" >> index.js && \
		echo "} else {" >> index.js && \
		echo "  console.log('SQLite desactivado en Docker ❌');" >> index.js && \
		echo "}" >> index.js && \
		echo "" >> index.js && \
		echo "app.get('/ping', (req, res) => {" >> index.js && \
		echo "  res.json({ message: 'Backend funcionando 🎉' });" >> index.js && \
		echo "});" >> index.js && \
		echo "" >> index.js && \
		echo "const PORT = process.env.BACKEND_PORT || 3000;" >> index.js && \
		echo "app.listen(PORT, () => {" >> index.js && \
		echo "  console.log('Backend escuchando en puerto ' + PORT);" >> index.js && \
		echo "});" >> index.js

	@echo "🐳 Creando Dockerfile para backend..."
	@cd backend && \
		echo "FROM node:20" > Dockerfile && \
		echo "" >> Dockerfile && \
		echo "WORKDIR /app" >> Dockerfile && \
		echo "" >> Dockerfile && \
		echo "COPY package*.json ./" >> Dockerfile && \
		echo "RUN npm install" >> Dockerfile && \
		echo "COPY . ." >> Dockerfile && \
		echo "" >> Dockerfile && \
		echo "EXPOSE 3000" >> Dockerfile && \
		echo 'CMD ["node", "index.js"]' >> Dockerfile

	@echo "🗑️  Eliminando docker-compose.yml anterior..."
	@rm -f docker-compose.yml

	@echo "🐳 Generando nuevo docker-compose.yml..."
	@echo "services:" >> docker-compose.yml

	@echo "  frontend:" >> docker-compose.yml
	@echo "    image: node:20" >> docker-compose.yml
	@echo "    working_dir: /app" >> docker-compose.yml
	@echo "    env_file: ./frontend/.env" >> docker-compose.yml
	@echo "    volumes:" >> docker-compose.yml
	@echo "      - ./frontend:/app" >> docker-compose.yml
	@echo '    command: ["npm", "run", "dev", "--", "--host", "--port", "8080"]' >> docker-compose.yml
	@echo "    ports:" >> docker-compose.yml
	@echo '      - "8080:8080"' >> docker-compose.yml
	@echo "" >> docker-compose.yml

	@echo "  backend:" >> docker-compose.yml
	@echo "    build:" >> docker-compose.yml
	@echo "      context: ./backend" >> docker-compose.yml
	@echo "      dockerfile: Dockerfile" >> docker-compose.yml
	@echo "    working_dir: /app" >> docker-compose.yml
	@echo "    env_file: ./backend/.env" >> docker-compose.yml
	@echo "    environment:" >> docker-compose.yml
	@echo "      - NO_SQLITE=true" >> docker-compose.yml
	@echo '    command: ["node", "index.js"]' >> docker-compose.yml
	@echo "    volumes:" >> docker-compose.yml
	@echo "      - ./backend:/app" >> docker-compose.yml
	@echo "      - /app/node_modules" >> docker-compose.yml
	@echo "    ports:" >> docker-compose.yml
	@echo '      - "3000:3000"' >> docker-compose.yml
	@echo "" >> docker-compose.yml

	@echo "networks:" >> docker-compose.yml
	@echo "  app-network:" >> docker-compose.yml
	@echo "    driver: bridge" >> docker-compose.yml

	@echo "🔧 Aplicando variables dinámicas a docker-compose.yml..."
	@sed -i 's/8080/$${FRONTEND_PORT}/g' docker-compose.yml
	@sed -i 's/3000/$${BACKEND_PORT}/g' docker-compose.yml

	@echo "🎉 Backend listo"
