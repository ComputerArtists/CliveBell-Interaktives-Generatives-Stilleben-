import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;

HashMap<Integer, Integer> colorMap = new HashMap<Integer, Integer>();

class Shape {
  float x, y, size;
  int type; // 0=ellipse, 1=rect, 2=triangle
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
int numShapes = 12;

void setup() {
  size(800, 600);
  colorMode(HSB, 360, 100, 100);  // HSB macht Farbvariationen schöner!
  generateInitialStillLife();
}

void draw() {
  background(220, 20, 95);  // Leichtes warmes Grau/Beige
  
  // Tisch
  fill(30, 60, 50);  // Dunkleres Holz
  noStroke();
  rect(0, height - 120, width, 120);
  
  // Schatten unter Objekten
  fill(0, 0, 0, 30);
  for (Shape s : shapes) {
    ellipse(s.x + 8, s.y + s.size/2 + 10, s.size * 1.2, s.size * 0.3);
  }
  
  // Formen zeichnen
  for (Shape s : shapes) {
    Integer mapped = colorMap.get((int)s.originalCol);
    color displayed = (mapped != null) ? mapped : s.originalCol;
    
    fill(displayed);
    noStroke();
    
    pushMatrix();
    translate(s.x, s.y);
    if (s.type == 0) ellipse(0, 0, s.size, s.size);
    else if (s.type == 1) rect(-s.size/2, -s.size/2, s.size, s.size);
    else if (s.type == 2) {
      triangle(0, -s.size/2, 
               -s.size/2, s.size/2, 
               s.size/2, s.size/2);
    }
    popMatrix();
  }
  
  // UI
  fill(0);
  textSize(16);
  text("Farben: " + colorPaletteSize + " / " + MAX_COLORS + "   (↑ split | ↓ reduziere)", 20, 30);
  text("Formen: " + shapes.size() + "   (+ / - zum Hinzufügen/Entfernen)", 20, 60);
  text("Drücke 's' zum Speichern", 20, 90);
  
  // Palette anzeigen
  drawPaletteSwatches();
}

void drawPaletteSwatches() {
  ArrayList<Integer> used = new ArrayList<Integer>();
  for (Integer c : colorMap.values()) {
    if (!used.contains(c)) used.add(c);
  }
  
  int swatchSize = 30;
  int spacing = 8;
  int startX = width - (used.size() * (swatchSize + spacing) + 20);
  int y = 20;
  
  for (int i = 0; i < used.size(); i++) {
    fill(used.get(i));
    noStroke();
    rect(startX + i*(swatchSize + spacing), y, swatchSize, swatchSize);
    stroke(0);
    noFill();
    rect(startX + i*(swatchSize + spacing), y, swatchSize, swatchSize);
  }
}

void generateInitialStillLife() {
  shapes.clear();
  colorMap.clear();
  for (int i = 0; i < numShapes; i++) {
    addRandomShape();
  }
  updatePaletteForReduction();
}

void addRandomShape() {
  float x = random(100, width - 100);
  float y = random(80, height - 200);
  float size = random(60, 140);
  int type = int(random(3));
  
  // Schöne, gesättigte Farben mit guter Helligkeit
  color original = color(random(360), random(60, 100), random(70, 95));
  
  shapes.add(new Shape(x, y, size, type, original));
  colorMap.put((int)original, (int)original);  // zunächst 1:1
}

void updatePaletteForReduction() {
  color[] palette = generatePalette(colorPaletteSize);
  
  // Bessere Zuordnung: jede Originalfarbe zur nächstgelegenen Palettefarbe
  for (Integer original : new ArrayList<Integer>(colorMap.keySet())) {
    color closest = palette[0];
    float minDist = colorDistance(original, closest);
    
    for (color p : palette) {
      float d = colorDistance(original, p);
      if (d < minDist) {
        minDist = d;
        closest = p;
      }
    }
    colorMap.put(original, (int)closest);
  }
}

float colorDistance(color c1, color c2) {
  return dist(hue(c1), saturation(c1), brightness(c1),
              hue(c2), saturation(c2), brightness(c2));
}

void splitAndExpandPalette() {
  if (colorPaletteSize >= MAX_COLORS) return;
  
  // Zähle aktuelle dargestellte Farben
  HashMap<Integer, Integer> countMap = new HashMap<Integer, Integer>();
  for (Shape s : shapes) {
    Integer col = colorMap.get((int)s.originalCol);
    countMap.put(col, countMap.getOrDefault(col, 0) + 1);
  }
  
  // Finde die am häufigsten genutzte Farbe
  int chosenColor = Collections.max(countMap.entrySet(), 
    (a, b) -> a.getValue().compareTo(b.getValue())).getKey();
  
  float h = hue(chosenColor);
  float s = saturation(chosenColor);
  float b = brightness(chosenColor);
  
  // Zwei neue Varianten erzeugen
  color new1 = color((h + random(-20, 20) + 360) % 360, 
                     constrain(s + random(-15, 15), 30, 100), 
                     constrain(b + random(-10, 10), 50, 100));
  color new2 = color((h + random(-30, 30) + 360) % 360, 
                     constrain(s + random(-20, 20), 30, 100), 
                     constrain(b + random(-15, 15), 40, 100));
  
  // Alle, die bisher chosenColor hatten, bekommen jetzt new1 oder new2
  for (Integer original : new ArrayList<Integer>(colorMap.keySet())) {
    if (colorMap.get(original) == chosenColor) {
      colorMap.put(original, random(1) < 0.5 ? (int)new1 : (int)new2);
    }
  }
  
  colorPaletteSize++;
}

color[] generatePalette(int n) {
  color[] pal = new color[n];
  for (int i = 0; i < n; i++) {
    pal[i] = color(random(360), random(70, 100), random(70, 95));
  }
  return pal;
}

void keyPressed() {
  if (key == '+' || key == '=') {
    if (shapes.size() < 60) addRandomShape();
  } else if (key == '-' || key == '_') {
    if (shapes.size() > 3) shapes.remove(shapes.size()-1);
  } else if (keyCode == UP) {
    splitAndExpandPalette();
  } else if (keyCode == DOWN) {
    if (colorPaletteSize > 1) {
      colorPaletteSize--;
      updatePaletteForReduction();
    }
  } else if (key == 's' || key == 'S') {
    String filename = "stillleben_" + year() + nf(month(),2) + nf(day(),2) + "_" + 
                      nf(hour(),2) + nf(minute(),2) + nf(second(),2) + ".png";
    saveFrame(filename);
    println("Gespeichert: " + filename);
  }
}
