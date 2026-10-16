# Lost

[Deutsch](#deutsch) · [English](#english)

---

## Deutsch

### Worum es geht

Ein Kind, allein in einem Wald, den die Welt vergessen hat. Kahle Bäume, Nebel, Stille.
Doch der Wald schläft nur. Kleine Begegnungen wecken ihn Schritt für Schritt, bis er wieder zu blühen beginnt.

*Lost* ist ein ruhiges, atmosphärisches 2D-Spiel ohne Zeitdruck und ohne Kämpfe. Man geht,
schaut, lauscht — und lässt die Welt antworten.

### Herunterladen

Alle Versionen stehen unter **[Releases](https://github.com/mcbernie/game_lost_release/releases)**. Wähle das Paket für dein System:

| System | Datei |
|---|---|
| Windows 10/11 (64 Bit) | `Lost-<version>-windows-x86_64.zip` |
| macOS 11 oder neuer (Apple Silicon und Intel) | `Lost-<version>-macos.zip` |
| Linux (64 Bit) und **Steam Deck** | `Lost-<version>-linux-x86_64-steamdeck.tar.gz` |

Zu jedem Release gehört `SHA256SUMS.txt` zum Prüfen der Downloads.

### Steuerung

| Taste | Aktion |
|---|---|
| A / D oder ← / → | gehen |
| Umschalt (gedrückt halten) | rennen |
| Leertaste | springen |
| E | greifen, aufsteigen, pusten — alles, was man berühren kann |
| S oder ↓ | hocken, ablegen, absteigen |
| Alt + F4 (Windows/Linux), ⌘ + Q (macOS) | beenden |

Gamepad-Steuerung ist in Arbeit. Bis dahin bildet man auf dem Steam Deck die Tasten mit
Steam Input ab (siehe unten).

### Systemvoraussetzungen

- Windows 10/11 64 Bit, macOS 11+ oder ein aktuelles 64-Bit-Linux (glibc 2.35 oder neuer)
- Grafikkarte mit Vulkan, DirectX 12 oder Metal
- 4 GB Arbeitsspeicher, etwa 200 MB freier Speicher

### Installation

**Windows**

1. ZIP herunterladen, Rechtsklick → *Alle extrahieren…*
2. Im entpackten Ordner `lost.exe` starten.
3. Zeigt Windows „Der Computer wurde durch Windows geschützt“ (SmartScreen): *Weitere
   Informationen* → *Trotzdem ausführen*. Das Spiel ist nicht kommerziell signiert.

**macOS**

1. ZIP herunterladen und öffnen (Doppelklick entpackt es).
2. `Lost.app` in den Ordner *Programme* ziehen.
3. Beim ersten Start meldet macOS, dass der Entwickler nicht verifiziert ist. Dann:
   *Systemeinstellungen* → *Datenschutz & Sicherheit* → bei „Lost“ *Dennoch öffnen*.
   Alternativ im Terminal: `xattr -dr com.apple.quarantine /Applications/Lost.app`

**Linux**

1. Paket entpacken: `tar -xzf Lost-<version>-linux-x86_64-steamdeck.tar.gz`
2. Starten: `./Lost-<version>-linux-x86_64-steamdeck/lost.sh`
3. Optional einen Menüeintrag anlegen: `./lost.sh --install-desktop`

**Steam Deck**

1. In den **Desktop-Modus** wechseln (Steam-Taste → *Ein/Aus* → *Zum Desktop wechseln*).
2. Das Linux-Paket (`…-linux-x86_64-steamdeck.tar.gz`) im Browser herunterladen.
3. Im Dateimanager (Dolphin) einen Ordner anlegen, z. B. `/home/deck/Games`, das Paket dorthin
   verschieben und per Rechtsklick → *Entpacken* → *Hierher entpacken, Unterordner automatisch
   erkennen* entpacken.
4. Steam öffnen → *Spiele* → *Ein Nicht-Steam-Spiel zu meiner Bibliothek hinzufügen…* →
   *Durchsuchen…* → Dateityp *Alle Dateien* → `lost.sh` im entpackten Ordner wählen →
   *Ausgewählte Programme hinzufügen*.
5. In der Bibliothek Rechtsklick auf `lost.sh` → *Eigenschaften*:
   - Name auf `Lost` ändern.
   - *Ausführen in* muss der entpackte Ordner sein (wird normalerweise automatisch gesetzt).
   - Startoptionen (optional, für ruhigere Bildrate): `LW_QUALITY=medium %command%`
     (oder `low`).
6. **Steam Input** (Controller-Einstellungen des Spiels): Vorlage *Tastatur (WASD) und Maus*
   wählen und so anpassen:
   - linker Stick / Steuerkreuz → A / D (gehen), unten → S (hocken)
   - A → Leertaste (springen)
   - X → E (greifen, aufsteigen, pusten)
   - B → S (ablegen, absteigen)
   - R1 oder R2 → Umschalt (rennen)
7. Zurück in den **Spielmodus** (Desktop-Verknüpfung *Return to Gaming Mode*). *Lost* steht
   jetzt in der Bibliothek unter *Nicht-Steam*.

### Fehlerbehebung

- **Schwarzes Fenster oder Absturz beim Start:** Grafiktreiber aktualisieren. Unter Linux muss
  Vulkan installiert sein (z. B. Paket `mesa-vulkan-drivers` bzw. `vulkan-radeon`).
- **Kein Ton:** Unter Linux prüfen, ob PipeWire oder PulseAudio läuft.
- **Ruckeln:** Mit `LW_QUALITY=medium` oder `LW_QUALITY=low` starten, z. B.
  `LW_QUALITY=low ./lost.sh`; unter Windows in der Eingabeaufforderung
  `set LW_QUALITY=low && lost.exe`.
- **macOS: „Lost ist beschädigt und kann nicht geöffnet werden“:** den `xattr`-Befehl aus der
  Installation ausführen.
- **Fehlende Grafiken oder Klänge:** Der Ordner `assets` muss neben dem Spiel liegen (bei macOS
  steckt er in `Lost.app`). Das Paket immer vollständig entpacken.

### Mitwirkende und Lizenzen

- Schrift: *Cormorant Garamond* — SIL Open Font License 1.1 (`credits/FONT-OFL.txt` im Paket)
- Klänge: Waldatmosphäre nach freesound.org #405140 von *mjeno*; alle Nachweise in `CREDITS.md`
  (im Paket unter `credits/`)
- Lizenz des Spiels: *wird noch festgelegt.*

---

## English

### About

A child, alone in a forest the world has forgotten. Bare trees, fog, silence. But the forest is
only asleep. Small encounters wake it step by step until it
begins to bloom again.

*Lost* is a calm, atmospheric 2D game with no time pressure and no combat. You walk, look,
listen — and let the world answer.

### Download

All versions are on the **[Releases](https://github.com/mcbernie/game_lost_release/releases)** page:

| System | File |
|---|---|
| Windows 10/11 (64-bit) | `Lost-<version>-windows-x86_64.zip` |
| macOS 11 or later (Apple Silicon and Intel) | `Lost-<version>-macos.zip` |
| Linux (64-bit) and **Steam Deck** | `Lost-<version>-linux-x86_64-steamdeck.tar.gz` |

Every release includes `SHA256SUMS.txt` to verify the downloads.

### Controls

| Key | Action |
|---|---|
| A / D or ← / → | walk |
| Shift (hold) | run |
| Space | jump |
| E | grab, climb on, blow — anything you can touch |
| S or ↓ | crouch, put down, climb off |
| Alt + F4 (Windows/Linux), ⌘ + Q (macOS) | quit |

Gamepad support is on its way. Until then, map the keys with Steam Input on the Steam Deck
(see below).

### System requirements

- Windows 10/11 64-bit, macOS 11+ or a current 64-bit Linux (glibc 2.35 or newer)
- Graphics with Vulkan, DirectX 12 or Metal
- 4 GB RAM, about 200 MB free disk space

### Installation

**Windows:** extract the ZIP (right-click → *Extract All…*) and run `lost.exe`. If SmartScreen
shows "Windows protected your PC": *More info* → *Run anyway* (the game is not commercially
signed).

**macOS:** open the ZIP, drag `Lost.app` into *Applications*. On first launch macOS says the
developer cannot be verified: *System Settings* → *Privacy & Security* → *Open Anyway* next to
"Lost". Or in Terminal: `xattr -dr com.apple.quarantine /Applications/Lost.app`

**Linux:** `tar -xzf Lost-<version>-linux-x86_64-steamdeck.tar.gz`, then run `./lost.sh` inside the
folder. `./lost.sh --install-desktop` adds a menu entry.

**Steam Deck:**

1. Switch to **Desktop Mode** (Steam button → *Power* → *Switch to Desktop*).
2. Download the Linux package (`…-linux-x86_64-steamdeck.tar.gz`) in the browser.
3. In the file manager (Dolphin) create a folder such as `/home/deck/Games`, move the package
   there and extract it (right-click → *Extract* → *Extract archive here, autodetect subfolder*).
4. Open Steam → *Games* → *Add a Non-Steam Game to My Library…* → *Browse…* → file type
   *All files* → pick `lost.sh` in the extracted folder → *Add Selected Programs*.
5. In the library, right-click `lost.sh` → *Properties*:
   - rename it to `Lost`;
   - *Start In* must be the extracted folder (normally set automatically);
   - launch options (optional, for a steadier frame rate): `LW_QUALITY=medium %command%`
     (or `low`).
6. **Steam Input** (the game's controller settings): choose the *Keyboard (WASD) and Mouse*
   template and adjust it:
   - left stick / d-pad → A / D (walk), down → S (crouch)
   - A → Space (jump)
   - X → E (grab, climb on, blow)
   - B → S (put down, climb off)
   - R1 or R2 → Shift (run)
7. Return to **Gaming Mode** (desktop shortcut *Return to Gaming Mode*). *Lost* is now in the
   library under *Non-Steam*.

### Troubleshooting

- **Black window or crash on start:** update your graphics drivers. On Linux, Vulkan must be
  installed (e.g. `mesa-vulkan-drivers` or `vulkan-radeon`).
- **No sound:** on Linux, check that PipeWire or PulseAudio is running.
- **Stutter:** start with `LW_QUALITY=medium` or `LW_QUALITY=low`, e.g. `LW_QUALITY=low ./lost.sh`;
  on Windows in a command prompt `set LW_QUALITY=low && lost.exe`.
- **macOS: "Lost is damaged and can't be opened":** run the `xattr` command from the
  installation steps.
- **Missing graphics or sounds:** the `assets` folder must stay next to the game (on macOS it
  lives inside `Lost.app`). Always extract the whole package.

### Credits and licenses

- Font: *Cormorant Garamond* — SIL Open Font License 1.1 (`credits/FONT-OFL.txt` in the package)
- Sounds: forest ambience based on freesound.org #405140 by *mjeno*; all credits in `CREDITS.md`
  (in the package under `credits/`)
- License of the game: *to be decided.*
