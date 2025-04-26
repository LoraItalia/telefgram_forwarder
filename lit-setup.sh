#!/bin/bash

set -e

# Configurazione
INSTALL_DIR="/opt/telegram_forwarder"
SCRIPT_URL="https://raw.githubusercontent.com/LoraItalia/telefram_forwarder/refs/heads/main/lit_telegram_fwd.py"
SCRIPT_NAME="lit_telegram_fwd.py"
SERVICE_NAME="telegram_forwarder.service"
ENV_FILE="$INSTALL_DIR/.env"
VENV_DIR="$INSTALL_DIR/venv"

# Funzione per leggere input con default
ask() {
    local prompt default reply
    prompt=$1
    default=$2

    if [ -n "$default" ]; then
        prompt="$prompt [$default]"
    fi

    read -p "$prompt: " reply
    echo "${reply:-$default}"
}

# Controlla se è eseguito da root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Questo script deve essere eseguito come root. Usa: sudo $0"
    exit 1
fi

# Funzione installazione
install() {
    echo "🔧 Installazione Telegram Forwarder"

    TELEGRAM_TOKEN=$(ask "Inserisci il TOKEN del bot Telegram")
    CHAT_ID=$(ask "Inserisci il CHAT ID a cui inviare i messaggi")
    SERIAL_PORT=$(ask "Inserisci la porta seriale" "/dev/ttyUSB0")

    echo "📁 Creazione directory $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"

    echo "⬇️ Download dello script da GitHub..."
    curl -L "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"

    echo "📝 Creazione file di configurazione .env..."
    cat <<EOF > "$ENV_FILE"
# Configurazione Telegram Forwarder
TELEGRAM_TOKEN=$TELEGRAM_TOKEN
TELEGRAM_CHAT_ID=$CHAT_ID
SERIAL_PORT=$SERIAL_PORT
EOF

    # Verifica se python3-venv è installato
    if ! dpkg -s python3-venv >/dev/null 2>&1; then
        echo "📦 Installazione python3-venv..."
        apt update
        apt install -y python3-venv
    fi

    # Crea virtualenv
    echo "🐍 Creazione ambiente virtuale Python..."
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"

    echo "📦 Installazione dipendenze Python..."
    pip install --upgrade pip
    pip install meshtastic requests python-dotenv

    deactivate

    echo "🛡 Creazione servizio systemd..."
    cat <<EOF > "/etc/systemd/system/$SERVICE_NAME"
[Unit]
Description=Telegram Forwarder Bot
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/$SCRIPT_NAME
EnvironmentFile=$ENV_FILE
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF

    echo "🔄 Abilitazione servizio systemd..."
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    systemctl start "$SERVICE_NAME"

    echo ""
    echo "✅ Installazione completata!"
    echo "👉 Controlla il servizio con: sudo systemctl status $SERVICE_NAME"
}

# Funzione rimozione
remove() {
    echo "🗑 Rimozione Telegram Forwarder"

    read -p "Sei sicuro di voler rimuovere tutto? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "🚫 Annullato."
        exit 0
    fi

    echo "🛑 Stop del servizio..."
    systemctl stop "$SERVICE_NAME" || true
    systemctl disable "$SERVICE_NAME" || true

    echo "🧹 Rimozione file di servizio..."
    rm -f "/etc/systemd/system/$SERVICE_NAME"
    systemctl daemon-reload

    echo "🧹 Rimozione directory di installazione..."
    rm -rf "$INSTALL_DIR"

    echo "✅ Rimozione completata."
}

# Funzione aggiornamento
upgrade() {
    echo "⬆️ Upgrade dipendenze Telegram Forwarder"

    if [ ! -d "$VENV_DIR" ]; then
        echo "❌ Virtualenv non trovato in $VENV_DIR"
        exit 1
    fi

    source "$VENV_DIR/bin/activate"

    echo "📦 Aggiornamento pip..."
    pip install --upgrade pip

    echo "📦 Aggiornamento dipendenze..."
    pip install --upgrade meshtastic requests python-dotenv

    deactivate

    echo "🔄 Riavvio del servizio..."
    systemctl restart "$SERVICE_NAME"

    echo "✅ Upgrade completato!"
}

# Menu principale
case "$1" in
    install)
        install
        ;;
    remove)
        remove
        ;;
    upgrade)
        upgrade
        ;;
    *)
        echo "Usage: $0 {install|remove|upgrade}"
        exit 1
        ;;
esac
