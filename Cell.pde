class Cell {
  PVector position;
  float w, h;
  float alpha;
  
  Cell(PVector position_, float w_, float h_) {
    position = position_;
    w = w_;
    h = h_;
    alpha = 0;    
  }
  
  void highlight(float newAlpha) {
    alpha = newAlpha;
  }
  
  void display() {
    stroke(140, 140, 140, alpha);
    noFill();
    rect(position.x, position.y, w, h);  
  }
  
  void update() {
    if (alpha > 0) {
      alpha *= 0.95; 
    } 
  }
}
