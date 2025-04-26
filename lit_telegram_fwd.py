import time
import meshtastic
import meshtastic.serial_interface
from pubsub import pub
import requests
import os
import json
from dotenv import load_dotenv

load_dotenv("/opt/telegram_forwarder/.env")

BOT_TOKEN = os.getenv('TELEGRAM_TOKEN')
CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')
TELEGRAM_URL = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

def send_telegram_message(text):
    payload = {
        "chat_id": CHAT_ID,
        "text": text,
        "parse_mode": "HTML"
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

def get_node_info(nodeID, interface):
    if nodeID in interface.nodes:
        return interface.nodes[nodeID]
    else:
        return None
        
def onReceive(packet, interface):
    try:
        if 'decoded' in packet and 'text' in packet['decoded']:
            text = packet['decoded']['text']
            nodeInfo = get_node_info(packet['fromId'], interface)
            print(f"Messaggio ricevuto: {text}")

            if nodeInfo:
                longName = nodeInfo['user']['longName']
                shortName = nodeInfo['user']['shortName']
                text = f"<b>{longName} ({shortName})</b>:\n{text}"
            else:
                text = f"<b>{packet['fromId']}</b>:\n{text}"

            send_telegram_message(text)
            print("Messaggio inviato a Telegram.")
        else:
            print("Pacchetto ricevuto, ma nessun testo trovato.")
    except Exception as e:
        print(f"Errore elaborazione pacchetto: {e}")
        
def onConnection(interface, topic=pub.AUTO_TOPIC):
    print("Connesso alla radio Meshtastic.")

# Main Loop for connection and auto reconnet management
def start_interface_loop():
    while True:
        try:
            print("Tentativo di connessione alla radio Meshtastic...")
            interface = meshtastic.serial_interface.SerialInterface()

            pub.subscribe(onReceive, "meshtastic.receive")
            pub.subscribe(onConnection, "meshtastic.connection.established")

            while True:
                time.sleep(1)
                if interface.stream.closed:
                    raise Exception("Seriale chiusa, tentativo di riconnessione.")

        except Exception as e:
            print(f"Errore o disconnessione: {e}")
            print("Attendo 5 secondi prima di riprovare...")
            time.sleep(5)


if __name__ == "__main__":
    start_interface_loop()
