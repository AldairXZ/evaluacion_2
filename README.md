# IndieHub - Ecosistema Multiplataforma (Evaluación 2)

Este repositorio contiene la integración de 3 dispositivos (Smart TV, Smartphone y Wear OS) conectados en tiempo real mediante WebSockets y Supabase.

## Instrucciones de ejecución

Para probar el ecosistema simultáneamente, sigue este orden estricto:

### 1. Servidor Backend (Node.js)

1. Entrar a la carpeta del backend.
2. Crear un archivo `.env` en la raíz del backend con las variables `SUPABASE_URL` y `SUPABASE_KEY`.
3. Ejecutar `npm install` para las dependencias.
4. Iniciar el servidor con `node index.js` (Correrá en el puerto 3001).

### 2. Pantalla Inteligente (Smart TV - PWA)

1. Abrir la carpeta `indie_smart_tv`.
2. Lanzar la aplicación usando Live Server en el puerto 5500.
3. Configurar el emulador del navegador a una resolución de 1920x1080.

### 3. Teléfono Inteligente (Flutter)

1. Abrir la carpeta `indie_phone_app`.
2. Ejecutar `flutter run` seleccionando un emulador de teléfono.

### 4. Reloj Inteligente (Wear OS - Flutter)

1. Abrir la carpeta `indie_wearable_app`.
2. Ejecutar `flutter run` seleccionando un emulador de Wear OS.
