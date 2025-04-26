# 🚀 Telegram Forwarder

Telegram Forwarder è uno script leggero che inoltra i messaggi ricevuti da un dispositivo Meshtastic collegato via seriale direttamente a un utente Telegram, utilizzando semplici chiamate HTTP.

---

## 📦 Installazione

Per installare **Telegram Forwarder**:

1. 📥 Scarica lo script di installazione:
    ```bash
    wget https://raw.githubusercontent.com/LoraItalia/telegram_forwarder/refs/heads/main/lit-setup.sh
    ```

2. 🔒 Rendi eseguibile il file scaricato:
    ```bash
    chmod +x lit-setup.sh
    ```

3. 🚀 Avvia l'installazione come root:
    ```bash
    sudo ./lit-setup.sh install
    ```

⚙️ Lo script ti guiderà nella configurazione dei parametri necessari (TOKEN del bot Telegram, chat ID, porta seriale, ecc.) e installerà automaticamente il servizio systemd.

---

## 🛠 Funzionalità di `lit-setup.sh`

Lo script `lit-setup.sh` supporta tre modalità operative:

| Comando                  | Descrizione                                              |
|---------------------------|----------------------------------------------------------|
| `install`                 | Installa tutto (script, virtualenv, servizio systemd)     |
| `remove`                  | Rimuove completamente l'installazione                    |
| `upgrade`                 | Aggiorna pip e le dipendenze dentro il virtualenv         |

### Esempi:
```bash
sudo ./lit-setup.sh install
sudo ./lit-setup.sh upgrade
sudo ./lit-setup.sh remove
```

---

## 🤖 Creazione del bot Telegram e recupero delle credenziali

1. **Crea un bot Telegram**:
    - Cerca **@BotFather** su Telegram.
    - Scrivi `/newbot` e segui le istruzioni.
    - Al termine riceverai il tuo **TOKEN API**.

2. **Recupera il tuo Chat ID**:
    - Avvia il bot **@ChatIdInfoBot** su Telegram.
    - Ti mostrerà subito il tuo **chat ID** personale.

> 💡 Alternativa: invia un messaggio al tuo bot, poi visita:
> ```
> https://api.telegram.org/bot<TOKEN>/getUpdates
> ```
> Cerca `"chat":{"id":...}` nella risposta JSON.

---

## 📋 Requisiti

- Python 3
- pip
- Sistema operativo basato su Linux (es: Raspberry Pi OS)
- Accesso `sudo` per installazione e gestione dei servizi di sistema

---

## ⚙️ Configurazione

Durante l'installazione ti verranno richiesti:

- Il **Token** del bot Telegram
- Il **Chat ID** del destinatario
- La **porta seriale** del dispositivo Meshtastic (es. `/dev/ttyUSB0`)
- Il **baudrate** di comunicazione (default: 921600)

🔐 Le impostazioni verranno salvate automaticamente nel file `.env` dentro `/opt/telegram_forwarder/`.

---

## 🖥 Gestione del servizio systemd

Una volta installato, il servizio `telegram_forwarder` verrà gestito tramite systemd.

- 🔎 Controllare lo stato:
    ```bash
    sudo systemctl status telegram_forwarder
    ```

- 🔄 Riavviare il servizio:
    ```bash
    sudo systemctl restart telegram_forwarder
    ```

- 📜 Visualizzare i log in tempo reale:
    ```bash
    sudo journalctl -u telegram_forwarder -f
    ```

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

**Enjoy your mesh-to-telegram forwarding!** 🚀🎉