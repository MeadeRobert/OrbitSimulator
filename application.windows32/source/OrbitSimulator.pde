import processing.core.*;
import controlP5.*;

// global variables
// ------------------------------------------------------------------

float gravitationalConstant = 1.0f, timeStep = .1f, b1Mass = 50000f;
int b1Radius, b2Radius;
boolean startStop = false, recalculate = false;
PFont font;

PVector temp = new PVector();
Slider2D b2Velocity, b2Position;
ControlP5 cp5;
Body b1, b2;
Orbit orbit;
UI ui;


// App Core 
// --------------------------------------------------------------------------

void setup()
{
  // setup screen and graphics
  orientation(LANDSCAPE);
  background(255);
  fullScreen(P2D, 1);
  smooth(0);
  
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
  font = createFont("Arial", 18, true);
  ui = new UI();
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

void controlEvent(ControlEvent e)
{
    if(ui != null) ui.correctSliderDisplayValues();
}

// Helper Methods
// ---------------------------------------------------

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
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
  if (recalculate) 
  {
    orbit.calculateInitialOrbitalElements();
    ui.generateConstantOrbitData();
  }
}
  
void updateOrbit()
{
  orbit.update(timeStep, 5);
  b2Position.setValue(b2.position.x, b2.position.y);
  b2Velocity.setValue(b2.velocity.x, b2.velocity.y);
}