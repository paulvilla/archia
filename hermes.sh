#!/bin/bash

# Rutas base
VENV_PATH="/home/paulvilla/Apps/hermes/.venv"

clear
# =====================================================================
#             ZONA DE INFORMACIÓN (ENTORNO OLLAMA + MEMGPT)
# =====================================================================
echo "======================================================="
echo " 🚀 ¡ENTORNO IA CON OLLAMA DISPONIBLE EN EL PUERTO 11434!"
echo "======================================================="
echo ""
echo "📝 RECORDATORIO DE PLANTILLAS (En MemGPT Configure)"
echo " 🔹 Si seleccionas GEMMA  -> El wrapper correcto es: llama3"
echo " 🔹 Si seleccionas QWEN   -> El wrapper correcto es: chatml"
echo ""
echo "🛠️  Inicializar entorno venv (Solo si lo borras)"
echo " cd /home/paulvilla/Apps/hermes"
echo " uv venv --python 3.12"
echo " source .venv/bin/activate"
echo " uv pip install pymemgpt llama-index-embeddings-huggingface \"click==8.1.7\""
echo ""
echo "💻 CÓMO LANZAR MANUALMENTE (Desde el entorno virtual)"
echo " ▶️  Lanzar Server / API Web:     memgpt server"
echo " ▶️  Lanzar UI / Chat con Agente:  memgpt run --agent MiAgente"
echo ""
echo "🏃 Comandos útiles de Ollama para tus .gguf"
echo " ▶️  Ver tus modelos cargados:   ollama list"
echo " ▶️  Registrar un Modelfile:    ollama create nombre-modelo -f /ruta/Modelfile"
echo ""
echo "💥 Borrar entornos para empezar de cero"
echo " rm -rf ~/.memgpt"
echo " rm -rf /home/paulvilla/Apps/hermes/.venv"
echo "======================================================="
echo ""

# Verificar si el entorno virtual existe antes de continuar
if [ ! -f "$VENV_PATH/bin/activate" ]; then
    echo "[⚠️ ALERTA] No se detecta el entorno virtual en $VENV_PATH"
    echo "Deberás inicializarlo primero usando los comandos de la sección 🛠️."
    echo ""
fi

# =====================================================================
#             MENÚ INTERACTIVO DE OPCIONES SOLICITADAS
# =====================================================================
echo "🧠 ¿Qué acción deseas realizar en el entorno Hermes?"
echo " [1] Entrar al entorno virtual               💻"
echo " [2] Entrar al entorno virtual y configurar  🛠️"
echo " [3] Lanzar Server (Web)                     🌐"
echo " [4] Lanzar agente (Chat)                    💬"
echo " [5] Salir                                   ❌"
echo "======================================================="
echo ""
read -p "Selecciona una opción [1-5]: " hermes_choice

case "$hermes_choice" in
    1)
        echo "[+] Entrando al entorno virtual..."
        echo "📌 Para salir del entorno virtual cuando termines, escribe: deactivate"
        echo ""
        # Iniciamos un subshell manteniendo el venv activo para el usuario
        bash --init-file <(echo "source $VENV_PATH/bin/activate")
        ;;
        
    2)
        echo "[+] Entrando al entorno virtual y lanzando configuración..."
        source "$VENV_PATH/bin/activate"
        memgpt configure
        # Al terminar la configuración, mantiene al usuario dentro del venv
        bash --init-file <(echo "source $VENV_PATH/bin/activate")
        ;;
        
    3)
        echo "[+] Lanzando MemGPT Server (Interfaz Gráfica Web)..."
        source "$VENV_PATH/bin/activate"
        memgpt server
        ;;
        
    4)
        echo "[+] Iniciando chat con tu agente..."
        source "$VENV_PATH/bin/activate"
        memgpt run --agent MiAgente
        ;;
        
    5)
        echo "¡Hasta luego!"
        exit 0
        ;;
        
    *)
        echo "Opción no válida."
        exit 1
        ;;
esac
