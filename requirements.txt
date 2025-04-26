import time
import meshtastic
import meshtastic.serial_interface
from pubsub import pub
import requests
import os
import json

# Configurazione (puoi mettere questi in variabili di ambiente o in un file)
BOT_TOKEN = os.getenv('TELEGRAM_TOKEN')
CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')

TELEGRAM_URL = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

# Funzione per inviare un messaggio a Telegram
def send_telegram_message(text):
    payload = {
        "chat_id": CHAT_ID,
        "text": text
    }
    headers = {
        "Content-Type": "application/json"
    }
    try:
        response = requests.post(TELEGRAM_URL, headers=headers, data=json.dumps(payload))
        if not response.ok:
            print(f"Errore invio Telegram: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Eccezione invio Telegram: {e}")

# Funzione chiamata alla ricezione di un pacchetto
def onReceive(packet, interface):
    # Estrarre il testo dal pacchetto
    try:
        text = packet['decoded']['text']
        print(f"Messaggio ricevuto: {text}")
        send_telegram_message(text)
    except KeyError:
        print("Pacchetto ricevuto, ma nessun testo trovato.")

# Funzione opzionale alla connessione
def onConnection(interface, topic=pub.AUTO_TOPIC):
    print("Connesso alla radio Meshtastic!")

# Sottoscrivi agli eventi
pub.subscribe(onReceive, "meshtastic.receive")
pub.subscribe(onConnection, "meshtastic.connection.established")

# Connessione al dispositivo Meshtastic via seriale
interface = meshtastic.serial_interface.SerialInterface()  # oppure meshtastic.tcp_interface.TCPInterface(hostname="...")

print("In ascolto dei messaggi...")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("Chiusura...")
    interface.close()
