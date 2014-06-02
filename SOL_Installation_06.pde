// GIF animation
import gifAnimation.*;

// OSC
import oscP5.*;
import netP5.*;

// Arduino
import processing.serial.*;
import org.firmata.*;
import cc.arduino.*;

// Minim audio
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

// Leap Motion control
import de.voidplus.leapmotion.*;
import development.*;

// Global variables
Gif stublisherLogo;

OscP5 osc;
NetAddress myRemoteLocation;

Arduino arduino;
color off = color(4, 79, 111);
color on = color(84, 145, 158);
Serial port;

Minim minim;
AudioOutput out;

// Notes of the C-Major scale (two octaves)
float tones[] = {
  880.0, 783.99, 698.46, 659.26, 587.33, 523.25, 493.88, 
  1760, 1567.98, 1396.91, 1318.51, 1174.66, 1046.50, 987.77
};

LeapMotion leap;

ParticleSystem particles;
Grid grid;
boolean showGrid = false;

void setup() {
  // Display resolution and renderer
  size(720, 450, P3D);
  //size(displayWidth, displayHeight, P3D); 
  background(255);
  
  // GIF animation player
  stublisherLogo = new Gif(this, "stublisher-small.gif");
  stublisherLogo.ignoreRepeat();
  
  // OSC communication to PD
  osc = new OscP5(this, 9001);
  myRemoteLocation = new NetAddress("127.0.0.1", 9001);
  
  // Arduino serial connection object
  println(Serial.list());
  if (Serial.list().length > 4) {
    port = new Serial(this, Serial.list()[5], 57600);
  }

  // Minim objects
  minim = new Minim(this); 
  out = minim.getLineOut(Minim.STEREO);
  tones = sort(tones);
  
  // Leap Motion Control object
  leap = new LeapMotion(this).withGestures("screen_tap, key_tap");

  // An empty array of particles
  particles = new ParticleSystem();
  grid = new Grid(40);
}

void draw() {
  fill(255, 100);
  rect(0, 0, width, height);
  
  image(stublisherLogo, width - 100, height - 100);
  
  // What is this for?
  int fps = leap.getFrameRate();

  // Hands
  if (leap.hasHands()) {
    if (port != null) {
      port.write('H');
    }
    //println("Wrote 'H' to port");
    beginShape(TRIANGLE_FAN);
    
    for (Hand hand : leap.getHands()) {  
      // Fingers
      for (Finger finger : hand.getFingers()) {
        //finger.draw();
        //finger.drawDirection();
        int     finger_id         = finger.getId();
        PVector finger_position   = finger.getPosition();
        PVector finger_stabilized = finger.getStabilizedPosition();
        PVector finger_velocity   = finger.getVelocity();
        PVector finger_direction  = finger.getDirection();
        float   finger_time       = finger.getTimeVisible();
        
        noStroke();
        fill(140, 140, 140);
        ellipse(finger_position.x, finger_position.y, 20, 20);
      }
    }
  }
  else {
    if (port != null) {
      port.write('L');
    }
    //println("Wrote 'L' to port");
  }
  
  if (showGrid) {
    grid.displayWholeGrid();
  }
  particles.update();
}

/*boolean sketchFullScreen() {
 return true;
 }*/

void leapOnInit() {
  // println("Leap Motion Init");
}
void leapOnConnect() {
  // println("Leap Motion Connect");
}
void leapOnFrame() {
  // println("Leap Motion Frame");
}
void leapOnDisconnect() {
  // println("Leap Motion Disconnect");
}
void leapOnExit() {
  // println("Leap Motion Exit");
}

// Key tap gesture callback function
void leapOnKeyTapGesture(KeyTapGesture g) {
  int       id               = g.getId();
  Finger    finger           = g.getFinger();
  PVector   position         = g.getPosition();
  PVector   direction        = g.getDirection();
  long      duration         = g.getDuration();
  float     duration_seconds = g.getDurationInSeconds();

  float red = map(position.x, 0, width, 0, 255);
  float blue = map(position.y, 0, width, 0, 255);
  float green = dist(position.x, position.y, width/2, height/2);  
  color c = color(red, green, blue, 255);

  particles.addParticle(new Particle(new PVector(position.x, position.y), c, 100 + random(-10, 10)));
  if (showGrid) {
    grid.highlight(position);
  }
  for (int i = 0; i <= 10; i++) {
    // Create 10 smaller particles around the hit position
    PVector displacedPosition = new PVector(
    constrain(position.x + random(-50, 50), 0, width), 
    constrain(position.y + random(-50, 50), 0, height));

    float displacedRed = map(displacedPosition.x, 0, width, 0, 255);
    float displacedBlue = map(displacedPosition.y, 0, width, 0, 255);
    float displacedGreen = dist(displacedPosition.x, displacedPosition.y, width/2, height/2);  
    color displacedC = color(displacedRed, displacedGreen, displacedBlue, 255);
    particles.addParticle(new Particle(displacedPosition, displacedC, random(10, 50)));
  }

  // Pick a note and play it for 1s
  playScaledNote(position);
}

// Circle gesture callback function
void leapOnCircleGesture(CircleGesture g, int state) {
  int       id               = g.getId();
  Finger    finger           = g.getFinger();
  PVector   position_center  = g.getCenter();
  float     radius           = g.getRadius();
  float     progress         = g.getProgress();
  long      duration         = g.getDuration();
  float     duration_seconds = g.getDurationInSeconds();

  //displayCircleGestureUI(position_center, radius, progress);

  switch(state) {
  case 1: // Start
    fill(255,0,0);
    noStroke();
    ellipse(position_center.x, position_center.y, 15, 15);
    break;
  case 2: // Update
    break;
  case 3: // Stop
    println("CircleGesture: "+id);
    break;
  }
}

// Helper functions for choosing notes within the C-Major scale
float pickRandomNote() {
  int index = floor(random(tones.length));
  return tones[index];
}

void playScaledNote(PVector screenPosition) {
  int index = floor(map(screenPosition.x, 0, width, 0, tones.length));
  float frequency = tones[index];
  float duration = map(screenPosition.y, 0, height, 0.50, 3);
  out.playNote(0.0, duration, frequency);
  //out.playNote(0.0, duration, new ToneInstrument(frequency, 0.25f, 0.5f));
}


void displayCircleGestureUI(PVector center, float radius, float progress) {
  noStroke();
  fill(140, 140, 140, 100);
  arc(center.x, center.y, radius, radius, 0, progress * TWO_PI);
}

// Close our Minim objects when we're done using them
void stop()
{
  out.close();
  minim.stop();
  super.stop();
}

void mousePressed() {
  // Play the animated GIF once
  stublisherLogo.play();
  
  OscMessage myMessage = new OscMessage("/note");
  myMessage.add((float)mouseX);
  
  osc.send(myMessage, myRemoteLocation); 
  
  OscMessage myMessage2 = new OscMessage("/on");
  osc.send(myMessage2, myRemoteLocation); 
}

void mouseReleased() {
  OscMessage myMessage = new OscMessage("/mute");

  osc.send(myMessage, myRemoteLocation);   
}

void keyPressed() {
  if(key == 'G' || key == 'g') {
    showGrid = !showGrid;
  }  
}
