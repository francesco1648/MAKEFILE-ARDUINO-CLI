#  Guida all’utilizzo del Makefile per Raspberry Pi Pico / Pico W

Questo documento spiega come **compilare**, **caricare** e **monitorare** uno sketch su **Raspberry Pi Pico** o **Raspberry Pi Pico W** utilizzando `make` e `arduino-cli`.  
In questo modo puoi gestire tutto da terminale, senza aprire l’IDE Arduino.

---

##  Requisiti

Assicurati di avere installato e configurato:

- **Arduino CLI**
  ```bash
  arduino-cli version 
  ```

Supporto per Raspberry Pi Pico

  ```bash
arduino-cli core install rp2040:rp2040
  ```

##  Struttura del progetto
  ```bash
my_project/              ← cartella principale (SKETCH_PATH)
├── my_project.ino       ← file principale
├── include/             ← eventuali header .h
├── lib/                 ← eventuali librerie custom
│   ├── libA/
│   │   └── src/
│   │       ├── file.cpp
│   │       └── file.h
│   └── libB/
│       └── src/
│           ├── file.cpp
│           └── file.h
├── Makefile             ← questo file
└── build/               ← (verrà creata automaticamente)
  ```

# 2️⃣ Scelta della board
Nel Makefile è presente la variabile:

  ```make
BOARD_FQBN ?= rp2040:rp2040:rpipico
  ```
In base alla scheda che stai usando, puoi modificare così:

- Raspberry Pi Pico --> rp2040:rp2040:rpipico
- Raspberry Pi Pico W   --> rp2040:rp2040:rpipicow

Per cambiarla, apri il Makefile e sostituisci la riga:

  ```bash
BOARD_FQBN ?= rp2040:rp2040:rpipico
  ```
con:

  ```bash
BOARD_FQBN ?= rp2040:rp2040:rpipicow
  ```
---

# Comandi principali
Spostati nella cartella del progetto:

  ```bash
cd percorso/del/progetto
  ```
##  Compilare il progetto

```bash
make compile
```

Compila lo sketch e genera i file `.bin` e `.uf2` nella cartella `build/output`.

- Compilare una variante specifica:

```bash
make compile MODULE_DEFINE="MK2_MOD2"
```

- Compilazione veloce (senza librerie aggiuntive):

```bash
make compile_fast
```

- Compilare tutte le varianti:

```bash
make compile_all
```

Compila due versioni (es. MK2_MOD1 e MK2_MOD2) in cartelle separate (`out_MK2_MOD1` e `out_MK2_MOD2`).


##  Caricare il programma sul Pico
Dopo la compilazione, puoi caricare il programma in due modi diversi:

### Metodo 1: Upload in modalità BOOTSEL
Questo metodo utilizza il file .uf2 e non richiede la porta seriale.

Procedura:

- Premi e tieni premuto il pulsante BOOTSEL (l’unico sulla scheda).
- Collega il Pico al PC tramite USB mantenendo premuto BOOTSEL.
- Rilascia il pulsante: il PC riconoscerà il Pico come unità esterna (es. E:).
- Apri “Questo PC” e verifica la lettera dell’unità.
- Apri il Makefile e cerca questa riga:

```bash
DESTINATION ?= 'D:\'
```

! Sostituisci D: con la lettera corretta (es. 'E:\').
Questa operazione va fatta solo una volta: il PC riconoscerà sempre la stessa unità.

Caricamento:

```bash
make upload_bootsel
```
Il file .uf2 verrà copiato automaticamente sul Pico e il programma partirà subito.

Per i caricamenti successivi:
Metti il Pico in BOOTSEL (premendo il tasto prima di collegarlo) e lancia nuovamente:

```bash
make upload_bootsel
```

### Metodo 2: Upload tramite porta seriale (COM)
Questo metodo usa la porta seriale del Pico collegato al PC in modalità normale.

Procedura:

- Collega il Pico al PC (senza premere BOOTSEL).
- Visualizza le porte COM disponibili:

    ```bash
    make port
    ```

Verrà mostrata una lista simile a:

```bash
COM1
COM2 (Raspberry Pi Pico)
```
Se il Pico è collegato, ad esempio, sulla COM2, esegui:

```bash
make upload PORT=COM2
```
Il Makefile utilizzerà il file .bin generato dalla compilazione e lo caricherà automaticamente.

## Aprire il monitor seriale
Per visualizzare i messaggi Serial.print o Serial.println del tuo programma:

Collega il Pico al PC.

Trova la porta COM:
```bash
make port
```
Apri il monitor seriale specificando la porta:

```bash
make monitor PORT=COM2
```
Il baud rate predefinito è 115200.

## Pulizia dei file di compilazione
Pulizia completa della cartella di build:


```bash
make clean_all
```
Pulizia parziale (solo la cartella di output):

```bash
make clean_output

```
## Elenco completo dei comandi
|Comando	|Descrizione|
|------|------|
|make compile	|Compila il progetto|
|make compile_fast|	Compilazione rapida|
make compile_all	|Compila entrambe le versioni (MK2_MOD1 e MK2_MOD2)|
make upload	|Carica tramite porta seriale (COM)|
make upload_bootsel	|Carica in modalità BOOTSEL (unità USB)|
make monitor	|Apre il monitor seriale|
make port|	Mostra le porte COM disponibili|
make auto_com_port|	Rileva automaticamente la COM del Pico|
make clean_all	|Rimuove tutti i file di build|
make clean_output	|Rimuove solo i file di output|
make help	|Mostra la guida dei comandi|

## Suggerimenti utili
Dopo il primo caricamento in BOOTSEL, non serve più modificare DESTINATION.

Se hai più Pico collegati, verifica sempre quale COM viene assegnata.

Puoi concatenare i comandi:

bash
Copia codice
make compile && make upload PORT=COM2
Su Linux o macOS, sostituisci:

rd /s /q → rm -rf

findstr → grep

⚠️ Troubleshooting
Problema	Possibile causa	Soluzione
Il Pico non appare tra le porte COM	Driver non installato	Installa i driver USB per Pico oppure usa la modalità BOOTSEL
Il comando make upload fallisce	Porta COM errata	Controlla con make port e aggiorna PORT=COMx
Il Pico non compare come unità esterna in BOOTSEL	Non hai tenuto premuto il pulsante BOOTSEL	Premi e tieni premuto il tasto prima di collegare il Pico
Compilazione fallita	Librerie mancanti	Assicurati che tutte le librerie siano presenti nella cartella lib/ o installate tramite arduino-cli
Il monitor seriale non mostra nulla	Baud rate errato o porta sbagliata	Verifica che nel codice e nel Makefile sia impostato 115200 e la porta corretta

✅ Ora sei pronto a compilare, caricare e monitorare il tuo codice su Raspberry Pi Pico o Pico W direttamente dal terminale!