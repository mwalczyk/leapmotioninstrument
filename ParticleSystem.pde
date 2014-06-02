public static PVector gravity = new PVector(0, 0.2);

class ParticleSystem {
  ArrayList<Particle> particles;

  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }  

  void addParticle(Particle p) {
    particles.add(p); 
  }
  
  void update() {
    // Update and display the particle system
    for (Particle p: particles) {
      p.applyForce(gravity);
      p.update();
      p.display();
    }
    // Remove dead particles
    for (int i = particles.size() - 1; i >= 0; i--) {
      if (particles.get(i).isDead) {
        particles.remove(i);
      }
    }
  }
}

