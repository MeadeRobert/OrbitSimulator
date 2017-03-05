import processing.core.*;
import controlP5.*;

float gravitationalConstant = 1.0f, timeStep = .1f, b1Mass = 50000f;
boolean startStop = false, recalculate = false;
PFont font;
long frameTime;
int b1Radius = 0, b2Radius = 0;;
PVector temp = new PVector();

ControlP5 cp5;
Body b1, b2;
Orbit orbit;
Slider2D b2Velocity, b2Position;
UI ui;


// --------------------------------

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

// --------------------------------

void setup()
{
  // setup screen
  orientation(LANDSCAPE);
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
  cp5 = new ControlP5(this);
  Label.setUpperCaseDefault(false);
  font = createFont("Arial", 16, true);
  ui = new UI(cp5);
}

// run app
void draw()
{
  // refresh screen
  background(255);

  // simulate or change the orbit
  if (startStop) updateOrbit();
  else updateOrbitalStateValues();

  // draw the orbit
  orbit.draw();

  // overlay orbit info
  ui.draw();

  // update simulation run-time characteristics
  updateRunTimeValues();
}

void updateRunTimeValues()
{
  b1.radius = b1Radius;
  b2.radius = b2Radius;
}
  
void updateOrbitalStateValues()
{
  b1.mass = b1Mass * 1000;
  b2.position.set(b2Position.getArrayValue()[0], b2Position.getArrayValue()[1]);
  b2.velocity.set(b2Velocity.getArrayValue()[0], b2Velocity.getArrayValue()[1]);
  if (recalculate) orbit.calculateInitialOrbitalElements();
}
  
void updateOrbit()
{
  orbit.update(timeStep, 5);
  b2Position.setValue(b2.position.x, b2.position.y);
  b2Velocity.setValue(b2.velocity.x, b2.velocity.y);
}