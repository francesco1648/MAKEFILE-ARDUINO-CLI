# Descrizione

Sviluppo di un Makefile in grado di gestire l’intero processo di compilazione e caricamento (sia in modalità BOOTSEL che tramite porta seriale) di un progetto Arduino IDE.
In questo esempio viene utilizzato il codice relativo alla scheda PicoLowLevel, ma lo stesso Makefile può essere adattato facilmente per compilare qualsiasi altro sketch .ino.

# 🔹 Nota importante:
Il nome della cartella principale deve essere identico al nome del file .ino principale (top header) che si desidera compilare.
Inoltre, la struttura del progetto deve rispettare il seguente formato:
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
