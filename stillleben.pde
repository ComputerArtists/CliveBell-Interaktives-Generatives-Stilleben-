import java.util.HashMap;
import java.util.ArrayList;

// HashMap: originale Farbe → aktuelle darstellende Farbe
HashMap<Integer, Integer> colorMap = new HashMap<Integer, Integer>();

class Shape {
  float x, y, size;
  int type;
  color originalCol;
  
  Shape(float x, float y, float size, int type, color col) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.type = type;
    this.originalCol = col;
  }
}

ArrayList<Shape> shapes = new ArrayList<Shape>();

int colorPaletteSize = 6;
final int MAX_COLORS = 36;

int numShapes = 12; // Start mit weniger, damit man schön inkrementieren kann

void setup() {
  size(800, 600);
  generateInitialStillLife();
}

void draw() {
  background(240);
  
  // Tisch
  fill(150, 100, 50);
  rect(0, height - 100, width, 100);
  
  // Shapes zeichnen
  for (Shape s : shapes) {
    Integer displayedInt = colorMap.get((int)s.originalCol);
    color displayedCol = (displayedInt != null) ? displayedInt : s.originalCol;
    
    fill(displayedCol);
    noStroke();
    
    if (s.type == 0) ellipse(s.x, s.y, s.size, s.size);
    else if (s.type == 1) rect(s.x - s.size/2, s.y - s.size/2, s.size, s.size);
    else if (s.type == 2) {
      triangle(s.x, s.y - s.size/2, 
               s.x - s.size/2, s.y + s.size/2, 
               s.x + s.size/2, s.y + s.size/2);
    }
  }
  
  fill(0);
  textSize(16);
  text("Farben: " + colorPaletteSize + " / " + MAX_COLORS + " (↑ splitte | ↓ reduziere)", 20, 30);
  text("Formen: " + shapes.size() + " (← -1 | → +1)", 20, 60);
  text("Drücke 's' zum Speichern", 20, 90);
}

// Initiales Stillleben (einmalig)
void generateInitialStillLife() {
  shapes.clear();
  for (int i = 0; i < numShapes; i++) {
    addRandomShape();
  }
  updatePaletteForReduction(); // Initiale Zuweisung
}

// Fügt genau eine neue zufällige Form hinzu
void addRandomShape() {
  float x = random(50, width - 50);
  float y = random(50, height - 150);
  float size = random(50, 120);
  int type = int(random(3));
  color original = color(random(255), random(255), random(255));
  
  shapes.add(new Shape(x, y, size, type, original));
  
  if (!colorMap.containsKey((int)original)) {
    colorMap.put((int)original, (int)original);
  }
}

// Bei DOWN: Palette reduzieren
void updatePaletteForReduction() {
  color[] palette = generatePalette(colorPaletteSize);
  for (Integer original : colorMap.keySet()) {
    int index = int(random(palette.length));
    colorMap.put(original, (int)palette[index]);
  }
}

// Bei UP: Einen Farbton splitten
void splitAndExpandPalette() {
  ArrayList<Integer> currentColors = new ArrayList<Integer>();
  HashMap<Integer, Integer> countMap = new HashMap<Integer, Integer>();
  
  for (Shape s : shapes) {
    Integer col = colorMap.get((int)s.originalCol);
    if (col != null) {
      countMap.put(col, countMap.getOrDefault(col, 0) + 1);
    }
  }
  
  int maxCount = 0;
  int chosenColor = 0;
  for (Integer c : countMap.keySet()) {
    int cnt = countMap.get(c);
    if (cnt > maxCount) {
      maxCount = cnt;
      chosenColor = c;
    }
  }
  
  color base = chosenColor;
  float h = hue(base);
  float s = saturation(base);
  float b = brightness(base);
  
  color new1 = color((h + random(-15, 15)) % 360, constrain(s * random(0.8, 1.2), 0, 100), constrain(b * random(0.9, 1.1), 0, 100));
  color new2 = color((h + random(-25, 25)) % 360, constrain(s * random(0.7, 1.3), 0, 100), constrain(b * random(0.8, 1.2), 0, 100));
  
  for (Integer original : colorMap.keySet()) {
    if (colorMap.get(original) == chosenColor) {
      colorMap.put(original, (int) (random(1) < 0.5 ? new1 : new2));
    }
  }
  
  colorPaletteSize++;
}

color[] generatePalette(int n) {
  color[] palette = new color[n];
  for (int i = 0; i < n; i++) {
    palette[i] = color(random(255), random(255), random(255));
  }
  return palette;
}

void keyPressed() {
  if (key == '-') { // Formen -1
    if (shapes.size() > 5) {
      shapes.remove(shapes.size() - 1); // Entferne die letzte (sauberer)
    }
  } else if (key == '+') { // Formen +1
    if (shapes.size() < 50) { // Obergrenze, damit es nicht explodiert
      addRandomShape();
    }
  } else if (keyCode == UP) {
    if (colorPaletteSize < MAX_COLORS) {
      splitAndExpandPalette();
    }
  } else if (keyCode == DOWN) {
    if (colorPaletteSize > 1) {
      colorPaletteSize--;
      updatePaletteForReduction();
    }
  } else if (key == 's' || key == 'S') {
    saveFrame("stillleben_" + year() + nf(month(),2) + nf(day(),2) + "_" + nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".png");
    println("Bild gespeichert!");
  }
}
