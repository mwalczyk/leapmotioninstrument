class Particle {
  color c;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float startRadius;
  float radius;
  boolean isDead;
  
  Particle(PVector position_, color c_, float radius_) {
    c = c_;
    position = position_;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    startRadius = radius_;
    radius = radius_;
    isDead = false;
  }  
  
  void applyForce(PVector force) {
    PVector f = PVector.div(force, radius);
    acceleration.add(force);  
  }
  
  void display() {
    noStroke();
    fill(c);
    pushMatrix();
      translate(position.x, position.y);
      ellipse(0, 0, radius, radius);
    popMatrix();  
  }
  
  void update() {
    radius--; 
    if (radius <= 0) {
      isDead = true; 
    } 
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }
  
}
