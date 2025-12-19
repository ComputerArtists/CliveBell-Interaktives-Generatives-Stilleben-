# Interaktives Generatives Stilleben in Processing

Ein einfaches, aber faszinierendes Processing-Skript, das ein abstraktes Stilleben aus geometrischen Formen (Kreise, Rechtecke, Dreiecke) erzeugt. Das Besondere: Du kannst live die Farbpalette reduzieren und wieder verfeinern – ein spielerischer Weg, um den Effekt von Farbquantisierung und Farbkomplexität zu erkunden.


## Features

- Zufällig generierte geometrische Objekte auf einem Tisch
- Jede Form hat eine eigene „Originalfarbe“
- Eine `HashMap` ordnet Originalfarben dynamisch den aktuell dargestellten Farben zu
- Interaktive Steuerung:
  - **↑** : Splitte die am häufigsten genutzte Farbe in zwei neue Varianten → Palette wird komplexer (bis max. 36 Farben)
  - **↓** : Reduziere die Palette auf weniger Farben (bessere Zuordnung zur nächstgelegenen Farbe)
  - **+** oder **=** : Füge eine neue zufällige Form hinzu
  - **-** : Entferne die zuletzt hinzugefügte Form
  - **s** : Speichere das aktuelle Bild als PNG (mit Timestamp im Dateinamen)
- Anzeige der aktuellen Farbanzahl und Formanzahl
- In der verbesserten Version (siehe unten): Palette als Swatches, leichte Schatten, HSB-Farbmodus für natürlichere Töne

## Steuerung

| Taste          | Funktion                              |
|----------------|---------------------------------------|
| ↑              | Farbpalette verfeinern (splitten)     |
| ↓              | Farbpalette reduzieren                |
| + oder =       | Neue Form hinzufügen                  |
| -              | Letzte Form entfernen                 |
| s              | Bild speichern                        |

## Installation & Ausführen

1. Lade und installiere [Processing](https://processing.org/download/) (empfohlen: aktuelle Version 4.x).
2. Erstelle ein neues Sketch.
3. Kopiere den unten stehenden Code (entweder die Original- oder die verbesserte Version) in die `.pde`-Datei.
4. Starte das Sketch mit **Run** (Strg+R / Cmd+R).

## Code-Varianten
Es gibt eine Überarbeitung
