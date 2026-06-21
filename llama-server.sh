#!/bin/bash

# Rutas base
LLAMA_BASE="/home/paulvilla/Apps/llama.cpp"
MODELOS_DIR="/home/paulvilla/Apps/modelos"
VENV_PATH="/home/paulvilla/Apps/hermes/.venv"

clear
echo "======================================================="
echo "         SELECCIÓN DE PROCESAMIENTO (LLAMA.CPP)"
echo "======================================================="
echo " [1] Modo SOLO CPU  (Aprovechar tus 64 GB de RAM al máximo)"
echo " [2] Modo GPU Vulkan (Usar tu gráfica RX 5700 XT)"
echo " [3] Salir"
echo "======================================================="
echo ""
read -p "Selecciona una opción [1-3]: " backend_choice

if [ "$backend_choice" = "1" ]; then
    EXE_PATH="$LLAMA_BASE/build-cpu/bin/llama-server"
    # Forzamos el uso de todos los hilos del procesador para exprimir la RAM
    EXTRA_FLAGS="-t $(nproc)"
elif [ "$backend_choice" = "2" ]; then
    EXE_PATH="$LLAMA_BASE/build-gpu/bin/llama-server"
    EXTRA_FLAGS="-ngl 99"
elif [ "$backend_choice" = "3" ]; then
    exit 0
else
    echo "Opción no válida."
    exit 1
fi

if [ ! -f "$EXE_PATH" ] || [ ! -d "$MODELOS_DIR" ]; then
    echo "[ERROR] Verifica las rutas de compilación o la carpeta de modelos."
    exit 1
fi

clear
echo "======================================================="
echo "               MODELOS GGUF DISPONIBLES"
echo "======================================================="
count=0
declare -A modelos_lista

for file in "$MODELOS_DIR"/*.[gG][gG][uU][fF]; do
    [ -e "$file" ] || continue
    count=$((count + 1))
    filename=$(basename "$file")
    modelos_lista[$count]="$filename"
    echo " [$count] $filename"
done

if [ "$count" -eq 0 ]; then
    echo "[!] No hay modelos .gguf en $MODELOS_DIR"
    exit 1
fi

echo "======================================================="
echo ""
read -p "Selecciona el número del modelo: " model_choice

if [[ ! "$model_choice" =~ ^[0-9]+$ ]] || [ "$model_choice" -lt 1 ] || [ "$model_choice" -gt "$count" ]; then
    echo "Selección inválida."
    exit 1
fi

SELECTED_MODEL="${modelos_lista[$model_choice]}"
FULL_MODEL_PATH="$MODELOS_DIR/$SELECTED_MODEL"

# Inteligencia de detección de contexto corregida para evitar desbordamientos en MemGPT
MODEL_LOWER=$(echo "$SELECTED_MODEL" | tr '[:upper:]' '[:lower:]')
if [[ "$MODEL_LOWER" == *"qwen"* ]]; then
    CONTEXTO=32768
else
    # Subido a 16384 (Tus 64GB de RAM y la GPU lo manejan de sobra y MemGPT no dará error 400)
    CONTEXTO=16384
fi

clear
echo "======================================================="
echo "            ARRANCANDO MOTOR LLAMA.CPP                 "
echo "======================================================="
echo " Cargando: $SELECTED_MODEL"
echo " Contexto: $CONTEXTO tokens"
echo "======================================================="
echo ""

# 1. Arrancar llama-server en segundo plano (Puerto 8080)
echo "[+] Encendiendo llama-server en http://localhost:8080..."
"$EXE_PATH" -m "$FULL_MODEL_PATH" $EXTRA_FLAGS -c $CONTEXTO --port 8080 > llama_server.log 2>&1 &
SERVER_PID=$!

# Esperar a que responda el puerto e inicialice el modelo en la RAM/GPU
echo "⏳ Cargando modelo en memoria (esperando 8 segundos)..."
sleep 8

clear
# =====================================================================
#             ZONA DE INFORMACIÓN Y SECCIONES SOLICITADAS
# =====================================================================
echo "======================================================="
echo " 🚀 ¡MOTOR IA LOCAL LISTO Y ESCUCHANDO EN EL PUERTO 8080!"
echo "======================================================="
echo ""
echo "📝 RECORDATORIO DE PLANTILLAS"
echo " 🔹 Si usas GEMMA  -> El wrapper correcto es: llama3"
echo " 🔹 Si usas QWEN   -> El wrapper correcto es: chatml"
echo ""
echo "🛠️  Inicializar y configurar entorno venv (solo una vez)"
echo " cd /home/paulvilla/Apps/hermes"
echo " uv venv --python 3.12"
echo " source .venv/bin/activate"
echo " uv pip install pymemgpt llama-index-embeddings-huggingface \"click==8.1.7\""
echo " memgpt configure --context-window $CONTEXTO"
echo ""
echo "🏃 Arrancar entorno manualmente"
echo " cd /home/paulvilla/Apps/hermes"
echo " source .venv/bin/activate"
echo " ▶️  Crear agente nuevo (sin menús):  memgpt run --agent NombreNuevo --persona sam_pov --human basic"
echo " ▶️  Chatear con tu agente actual:  memgpt run --agent MiAgente"
echo " ▶️  Modo Servidor (GUI):           memgpt server"
echo ""
echo "💥 Borrar entornos"
echo " rm -rf ~/.memgpt"
echo " rm -rf /home/paulvilla/Apps/hermes/.venv"
echo "======================================================="
echo "⚠️  EL SERVIDOR SE ESTÁ EJECUTANDO DE FONDO."
echo "======================================================="
echo ""

# Automatización para entrar directo al Agente
read -p "🧠 ¿Quieres abrir MemGPT y chatear con 'MiAgente' ahora mismo? (s/n): " lanzar_memgpt

if [[ "$lanzar_memgpt" =~ ^[sS]$ ]]; then
    if [ -f "$VENV_PATH/bin/activate" ]; then
        echo "[+] Activando entorno virtual y conectando a MemGPT..."
        source "$VENV_PATH/bin/activate"
        memgpt run --agent MiAgente
        
        # Al salir de MemGPT, cerramos el servidor de fondo automáticamente
        echo "[+] Cerrando el servidor llama-server..."
        kill $SERVER_PID
    else
        echo "[ERROR] No se encontró el entorno virtual en $VENV_PATH"
    fi
else
    echo "📌 Perfecto. El servidor queda corriendo. Presiona Ctrl+C en esta terminal cuando quieras apagarlo."
    # Mantener el script vivo para que el usuario pueda ver los logs si no abre MemGPT aquí
    wait $SERVER_PID
fi
