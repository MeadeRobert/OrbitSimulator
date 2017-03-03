import processing.core.*;
import controlP5.*;

ControlP5 cp5;
Body b1, b2;
Orbit orbit;

float gravitationalConstant = 1.0f, timeStep = .1f;
PVector temp = new PVector();
int b1Radius = 0;
int b2Radius = 0;
float b1Mass = 50000f;
Slider2D b2Velocity;
Slider2D b2Position;
boolean startStop = false;
boolean recalculate = false;
PFont font;
long frameTime;

// --------------------------------

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

void initSliders()
{
  cp5.addSlider("b1Radius")
    .setPosition(displayWidth / 16, displayHeight / 16)
    .setRange(0, displayWidth / 50).setValue(5)
    .setWidth(displayWidth / 4)
    .setHeight(displayHeight / 64 * 3)
    .setColorLabel(color(0, 0, 0))
    .setFont(font)
    .setCaptionLabel("Fixed Body Radius")
    ;

  cp5.addSlider("b2Radius")
    .setPosition(displayWidth / 16, displayHeight / 16 * 2)
    .setRange(0, displayWidth / 50).setValue(5)
    .setWidth(displayWidth / 4)
    .setHeight(displayHeight / 64 * 3)
    .setColorLabel(color(0, 0, 0))
    .setFont(font)
    .setCaptionLabel("Satellite Radius")
    ;

  cp5.addSlider("gravitationalConstant")
    .setPosition(displayWidth / 16, displayHeight / 16 * 3)
    .setRange(0, 50).setValue(5)
    .setWidth(displayWidth / 4)
    .setHeight(displayHeight / 64 * 3)
    .setValue(1.0f)
    .setColorLabel(color(0, 0, 0))
    .setFont(font)
    .setCaptionLabel("Gravitational Constant")
    ;

  cp5.addSlider("b1Mass")
    .setPosition(displayWidth / 16, displayHeight / 16 * 4)
    .setColorLabel(color(0, 0, 0))
    .setRange(0, 50)
    .setWidth(displayWidth / 4)
    .setHeight(displayHeight / 64 * 3)
    .setValue(b1.mass / 1000f)
    .setFont(font)
    .setCaptionLabel("Fixed Body Mass")
    ;
    
  cp5.addSlider("timeStep")
    .setPosition(displayWidth / 16, displayHeight / 16 * 5)
    .setColorLabel(color(0, 0, 0))
    .setRange(0, 1)
    .setValue(timeStep)
    .setWidth(displayWidth / 4)
    .setHeight(displayHeight / 64 * 3)
    .setValue(timeStep)
    .setFont(font)
    .setCaptionLabel("Time Step")
    ;
    
  b2Velocity = cp5.addSlider2D("b2Velocity")
    .setCaptionLabel("Velocity")
    .setPosition(displayWidth / 8 - displayWidth / 16, displayHeight / 3 * 2)
    .setSize(displayWidth / 8, displayWidth / 8)
    .setColorLabel(color(0, 0, 0))
    .setColorValue(color(0, 0, 0))
    .setMinMax(-50, -50, 50, 50)
    .setValue(b2.velocity.x, b2.velocity.y)
    .setFont(font)
    ;

  b2Position = cp5.addSlider2D("b2Position")
    .setCaptionLabel("Position")
    .setPosition(displayWidth / 4, displayHeight / 3 * 2)
    .setSize(displayWidth / 8, displayWidth / 8)
    .setColorLabel(color(0, 0, 0))
    .setColorValue(color(0, 0, 0))
    .setMinMax(displayWidth / 4, displayHeight / 4, displayWidth * 3 / 4, displayHeight * 3 / 4)
    .setValue(b2.position.x, b2.position.y)
    .setFont(font)
    ;
}

void initButtons()
{
  cp5.addToggle("startStop")
    .setPosition(displayWidth / 16, displayHeight / 2)
    .setSize(displayWidth / 8, displayHeight / 16)
    .setColorLabel(color(0, 0, 0))
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setFont(font)
    .setCaptionLabel("Start/Stop")
    ;

  cp5.addToggle("recalculate")
    .setPosition(displayWidth / 4, displayHeight / 2)
    .setSize(displayWidth / 8, displayHeight / 16)
    .setColorLabel(color(0, 0, 0))
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setFont(font)
    .setCaptionLabel("Recalculate")
    ;
}

void initControls()
{
  Label.setUpperCaseDefault(false);
  font = createFont("Arial", 16, true);
  cp5 = new ControlP5(this);
  
  initSliders();
  initButtons();
}

// ------------------------------------------------

void setup()
{
  orientation(LANDSCAPE);
  
  // setup screen
  background(255);
  size(displayWidth, displayHeight, P2D);

  // create orbital bodies
  b1 = new Body(new PVector(.5f * displayWidth, .5f * displayHeight), 
    new PVector(0, 0, 0), 
    new PVector(0, 0, 0), 
    50000.0f, 
    displayWidth/150, 
    new int[]{0, 255, 0}, 
    new int[]{0, 0, 0}
    );
  b2 = new Body(new PVector(.6f * displayWidth, 0.5f * displayHeight - 50), 
    new PVector(displayWidth/100, displayWidth/100, 0), 
    new PVector(0, 0, 0), 
    1.0f, 
    displayWidth/150, 
    new int[]{255, 0, 0}, 
    new int[]{0, 0, 0}
    );

  // create orbit
  orbit = new Orbit(b1, b2);

  // initialize ui
  initControls();
}

void overlayOrbitData()
{
  
}

// run app
void draw()
{
  // refresh screen
  background(255);

  if (startStop) // run Simulation if applicable
  {
    orbit.draw();
    orbit.update(timeStep, 5);
    b2Position.setValue(b2.position.x, b2.position.y);
    b2Velocity.setValue(b2.velocity.x, b2.velocity.y);
  } else // update values that cannot be changed while running
  {
    b1.mass = b1Mass * 1000;
    b2.position.set(b2Position.getArrayValue()[0], b2Position.getArrayValue()[1]);
    b2.velocity.set(b2Velocity.getArrayValue()[0], b2Velocity.getArrayValue()[1]);
    if (recalculate) orbit.calculateInitialOrbitalElements();

    orbit.draw();
  }

  // overlay data
  overlayOrbitData();

  // update values that can be changed during simulation
  b1.radius = b1Radius;
  b2.radius = b2Radius;

  // wait for next frame (lock 60fps)
  stroke(0); fill(0);
  text("frameDelay: " + (System.currentTimeMillis() - frameTime) + " ms", displayWidth / 10 * 9, displayHeight / 32 * 31);
  frameTime = System.currentTimeMillis();
  //delay(12);
}