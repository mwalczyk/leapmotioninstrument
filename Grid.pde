class Grid {
  int tileCountX, tileCountY;
  float tileWidth;
  float w, h;
  ArrayList<Cell> gridCells;

  Grid(float tileWidth_) {
    w = width;
    h = height;
    tileWidth = tileWidth_;
    tileCountX = floor(w / tileWidth);
    tileCountY = floor(h / tileWidth);
    gridCells = new ArrayList<Cell>();
    for (int i = 0; i < tileCountY; i++) {
      for (int j = 0; j < tileCountX; j++) {
        PVector cellPosition = new PVector(j * tileWidth, i * tileWidth);
        gridCells.add(new Cell(cellPosition, tileWidth, tileWidth));
      }
    } 
    /*println("Total number of cells: " + gridCells.size());
    println("X Count: " + tileCountX);
    println("Y Count: " + tileCountY);*/
  }  

  void displayWholeGrid() {
    stroke(140, 140, 140);
    noFill();
    for (Cell c: gridCells) {
      c.update();
      c.display();
    }
  }

  void highlight(PVector screenPosition) {
    for (int i = 0; i < gridCells.size(); i++) {
      Cell c = gridCells.get(i);
      if (screenPosition.x >= c.position.x && screenPosition.x <= c.position.x + c.w) {
        if (screenPosition.y >= c.position.y && screenPosition.y <= c.position.y + c.h) {
          recursiveLight(i, 10, 255);
        }
      }
    }
  }

  void recursiveLight(int index, int level, float currAlpha) {
    int totalCells = gridCells.size();
    int leftIndex = constrain(index - 1, 0, totalCells);
    int rightIndex = constrain(index + 1, 0, totalCells);
    int topIndex = constrain(index - tileCountX, 0, totalCells);
    int bottomIndex = constrain(index + tileCountX, 0, totalCells);

    Cell current = gridCells.get(index);
    current.highlight(currAlpha);

    if (level > 0) {
      int roll = (int) random(4);
      if (roll == 0) {
        recursiveLight(leftIndex, level - 1, currAlpha * 0.90);
      }
      if (roll == 1) {
        recursiveLight(rightIndex, level - 1, currAlpha * 0.90);
      } 
      if (roll == 2) {
        recursiveLight(topIndex, level - 1, currAlpha * 0.90);
      }
      if (roll == 3) { 
        recursiveLight(bottomIndex, level - 1, currAlpha * 0.90);
      }
    }
  }
}

