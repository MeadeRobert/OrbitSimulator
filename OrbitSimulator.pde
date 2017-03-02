import processing.core.*;

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

// app core
// --------------------------------------------

import controlP5.*;
ControlP5 cp5;
Body b1, b2;
Orbit orbit;

float gravitationalConstant = 1.0f;
PVector temp = new PVector();
int b1Radius = 0;
int b2Radius = 0;
int b1Mass = 50000;
int b2Mass = 1;
Slider2D b2Velocity;
Slider2D b2Position;
boolean startStop = false;
boolean recalculate = false;


void setup()
{
  // setup screen
  background(155);
  size(displayWidth, displayHeight);
  
  // init orbit
  b1 = new Body(new PVector(.5f * displayWidth, .5f * displayHeight), new PVector(0,0,0), new PVector(0,0,0), 50000.0f, displayWidth/150, new int[]{0, 255, 0}, new int[]{0, 0, 0});
  b2 = new Body(new PVector(.6f * displayWidth, .5f * displayHeight - 50), new PVector(displayWidth/100,displayWidth/100,0), new PVector(0,0,0), 1.0f, displayWidth/150,new int[]{255, 0, 0}, new int[]{0, 0, 0});
  orbit = new Orbit(b1, b2);
  
  // init controls
  cp5 = new ControlP5(this);
  
  cp5.addSlider("b1Radius").setPosition(100, displayHeight/32 * 2).setRange(0, 50).setValue(5).setWidth(displayWidth/4).setHeight(displayHeight/64);
  cp5.addSlider("b2Radius").setPosition(100, displayHeight/32 * 3).setRange(0, 50).setValue(5).setWidth(displayWidth/4).setHeight(displayHeight/64);
  cp5.addSlider("b1Mass").setPosition(100, displayHeight/32 * 4).setRange(0, 50).setValue(5).setWidth(displayWidth/4).setHeight(displayHeight/64).setValue(b1.mass);
  cp5.addSlider("b2Mass").setPosition(100, displayHeight/32 * 5).setRange(0, 50).setValue(5).setWidth(displayWidth/4).setHeight(displayHeight/64).setValue(b2.mass);
  
  b2Velocity = cp5.addSlider2D("b2Velocity")
         .setPosition(100,400)
         .setSize(100,100)
         .setMinMax(-50,-50,50,50)
         .setValue(b2.velocity.x,b2.velocity.y);
         
  b2Position = cp5.addSlider2D("b2Position")
         .setPosition(300,400)
         .setSize(100,100)
         .setMinMax(displayWidth / 4,displayHeight / 4,displayWidth * 3 / 4,displayHeight * 3 / 4)
         .setValue(b2.position.x,b2.position.y);
         
  cp5.addToggle("startStop")
     .setPosition(40,250)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     ;
     
  cp5.addToggle("recalculate")
     .setPosition(100,250)
     .setSize(50,20)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     ;
}

void draw()
{
  background(155);
  
  if(startStop)
  {
    orbit.draw();
    orbit.update(.1f, 15);
    orbit.overlayOrbitInfo();
    b2Position.setValue(b2.position.x, b2.position.y);
    b2Velocity.setValue(b2.velocity.x, b2.velocity.y);
  }
  else
  {
    
    //b1.mass = b1Mass;
    //b2.mass = b2Mass;
    b2.position.set(b2Position.getArrayValue()[0], b2Position.getArrayValue()[1]);
    b2.velocity.set(b2Velocity.getArrayValue()[0], b2Velocity.getArrayValue()[1]);
    if(recalculate) orbit.calculateInitialOrbitalElements();
    orbit.overlayOrbitInfo();
    orbit.draw();
  }
  
  b1.radius = b1Radius;
  b2.radius = b2Radius;
  
 
  
  // wait for next frame (lock 60fps)
  delay(12);
}