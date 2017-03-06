package processing.test.orbitsimulator;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.core.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class OrbitSimulator extends PApplet {




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

public void setup()
{
  // setup screen and graphics
  orientation(LANDSCAPE);
  background(255);
  
  
  
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
public void draw()
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

public void controlEvent(ControlEvent e)
{
    if(ui != null) ui.correctSliderDisplayValues();
}

// Helper Methods
// ---------------------------------------------------

public int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

public void updateRunTimeValues()
{
  b1.radius = b1Radius;
  b2.radius = b2Radius;
}

public void updateOrbitalStateValues()
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
  
public void updateOrbit()
{
  orbit.update(timeStep, 5);
  b2Position.setValue(b2.position.x, b2.position.y);
  b2Velocity.setValue(b2.velocity.x, b2.velocity.y);
}
class Body
{
  int[] fill, stroke;
  PVector position, velocity, acceleration;
  float mass, radius;
  
  public Body(PVector position, PVector velocity, PVector acceleration, float mass, float radius, int[] fill, int[] stroke)
  {
    this.position = new PVector(); this.position.set(position);
    this.velocity = new PVector(); this.velocity.set(velocity);
    this.acceleration = new PVector(); this.acceleration.set(acceleration);
    this.mass = mass;
    this.radius = radius;
    this.fill = fill;
    this.stroke = stroke;
  }
  
  public void applyForce(PVector force)
  {
    PVector appliedAcceleration = new PVector();
    appliedAcceleration.set(force);
    appliedAcceleration.div(mass);
    acceleration.add(appliedAcceleration);
  }
  
  public void draw()
  {
    fill(fill[0], fill[1], fill[2]);
    stroke(stroke[0], stroke[1], stroke[2]);
    strokeWeight(1);
    ellipse(position.x, position.y, radius*2.0f, radius*2.0f);
    stroke(0, 0, 255); strokeWeight(2);
    line(position.x, position.y, position.x + velocity.x, position.y + velocity.y);
  }
  
  public void update(float time)
  {
    // use a modified euler's method with average change over interval
    // => correct result for constant acceleration systems
    System.out.println(position);
    PVector dist = new PVector();
    dist.set(velocity);
    dist.mult(time);
    position.add(dist);
    System.out.println(position);
    
    //zero acc for next tick
    velocity.add(acceleration);
    acceleration = new PVector(0,0);
  }
}
class Orbit
{  
  Body b1, b2;
  PGraphics orbitalPath;
  
  // constant orbital elements
  float mu, eccentricity, semiMajorAxis, semiMinorAxis, semiLactusRectum, speed, period, periapsis, apoapsis;
  PVector angularMomentum = new PVector();
  PVector eccentricityVector = new PVector();
  PVector initialSatelliteVelocity = new PVector();
  PVector initialRadius = new PVector();
  float argumentOfPeriapsis, direction;

  // changing orbital elements
  PVector radius = new PVector();
  float trueAnomaly, eccentricAnomaly, meanAnomaly, tangentialVelocity, radialVelocity;

  // Constructors 
  // ---------------------------------------------------------------------

  public Orbit(Body b1, Body b2)
  {
    this.b1 = b1;
    this.b2 = b2;
    orbitalPath = createGraphics(displayWidth, displayHeight, P2D); 
    calculateInitialOrbitalElements();
    printOrbitalElements();
  }
  
  // Methods
  // ---------------------------------------------------------------------

  public void calculateInitialOrbitalElements()
  {
    // calculate mu, radius, angularMomentum and direction of orbit
    mu = gravitationalConstant * b1.mass;
  
    radius.set(b2.position);
    radius.sub(b1.position);
    
    angularMomentum.set(radius);
    angularMomentum.cross(b2.velocity, angularMomentum);
    
    direction = signum(angularMomentum.z);
  
    // calculate eccentricity
    eccentricityVector = new PVector(); eccentricityVector.set(b2.velocity);
    eccentricityVector.cross(angularMomentum, eccentricityVector);
    eccentricityVector.div(mu);
    temp.set(radius); temp.normalize();
    eccentricityVector.sub(temp);
  
    eccentricity = eccentricityVector.mag();
    
    // calculate semi-major axis, semi-minor axis, periapsis, apoapsis, and semi-lactus rectum for the orbit
    semiMajorAxis = angularMomentum.mag() * angularMomentum.mag() / (mu * (1 - eccentricity * eccentricity)); 
    semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);    
    semiMinorAxis = semiMajorAxis * sqrt((1 - eccentricity*eccentricity));    
    periapsis = semiMajorAxis * (1 - eccentricity);    
    apoapsis = 2 * semiMajorAxis - periapsis;
  
    // calculate angular displacement from x/y plane where top of screen is x-axis
    argumentOfPeriapsis = atan2(eccentricityVector.y, eccentricityVector.x);
    
    // calculate angular anomalies
    trueAnomaly = signum(eccentricityVector.cross(radius).z) * acos(radius.dot(eccentricityVector)/(radius.mag() * eccentricity));     
    eccentricAnomaly = atan2(sqrt(1 - eccentricity*eccentricity) * sin(trueAnomaly), (eccentricity + cos(trueAnomaly))); 
    meanAnomaly = eccentricAnomaly - eccentricity * sin(eccentricAnomaly);
  
    // calculate radial and tangential velocities
    radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin(trueAnomaly); 
    tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));
    
    // calculate orbital period
    period = sqrt((4.0f * PI * PI * pow(semiMajorAxis, 3) / mu));
    
    // gen orbit path rendering
    generateOrbitalPath();
  }

  public void generateOrbitalPath()
  {
    // plot 360*8 points evenly spaced in angular terms
    // for one revolution of the ellipse
    float r, angle, x, y;
    orbitalPath.beginDraw();
    orbitalPath.fill(0); orbitalPath.stroke(0); orbitalPath.strokeWeight(1);
    orbitalPath.background(255);
    for(int j = 0; j < 360*8; j++)
    {
      angle = (float) j / (16.0f * PI);
      r = semiLactusRectum / (1.0f + eccentricity * cos (angle - argumentOfPeriapsis));
      x = r * cos(angle) + b1.position.x; y = r * sin(angle) + b1.position.y;
      orbitalPath.point(x, y);
    }
    
    // draw semi-major axis
    orbitalPath.stroke(255, 0, 0); orbitalPath.strokeWeight(2);
    temp.set(cos(argumentOfPeriapsis), sin(argumentOfPeriapsis));
    temp.mult(periapsis);
    orbitalPath.line(b1.position.x, b1.position.y, b1.position.x + temp.x, b1.position.y + temp.y);
    temp.normalize();
    temp.mult(-apoapsis);
    orbitalPath.line(b1.position.x, b1.position.y, b1.position.x + temp.x, b1.position.y + temp.y);
    
    orbitalPath.endDraw();
  }

  public void update(float deltaTime, int iterations)
  {
    // calculate next meanAnomaly given the time step
    meanAnomaly = (direction * deltaTime * sqrt(mu / pow(semiMajorAxis,3)) + meanAnomaly) % (2.0f * PI);
  
    // use newton's method for the defined number of iterations to solve numerically for the eccentric anomaly
    // there is no analytical solution
    for(int i = 0; i < iterations; i++)
      eccentricAnomaly = eccentricAnomaly - (eccentricAnomaly - eccentricity * sin (eccentricAnomaly) - meanAnomaly)
                           / (1 - eccentricity * cos(eccentricAnomaly));
  
    // solve for the new radius vector and update position
    trueAnomaly = 2.0f * atan2(sqrt(1 + eccentricity) * sin (eccentricAnomaly / 2.0f), sqrt(1 - eccentricity) * cos(eccentricAnomaly / 2.0f));
    float r = semiLactusRectum / (1.0f + eccentricity * cos (trueAnomaly));
    radius.set(r*cos(trueAnomaly + argumentOfPeriapsis), r*sin(trueAnomaly + argumentOfPeriapsis));
    b2.position.set(b1.position);
    b2.position.add(radius);
  
    // update radial and tangential velocity
    radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin (trueAnomaly);
    tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos (trueAnomaly));
  
    // get the speed form the tangential and radial components with respect to the radius vector
    speed = sqrt(radialVelocity * radialVelocity + tangentialVelocity * tangentialVelocity);
    
    // get the velocity components with respect to the semi-major axis
    b2.velocity.set(radialVelocity * cos(trueAnomaly) - tangentialVelocity * sin (trueAnomaly),
                   radialVelocity * sin(trueAnomaly) + tangentialVelocity * cos (trueAnomaly));
    // apply a rotation to put the velocity vector in the cartesian plane with respect to
    // the top of the screen as the x-axis
    b2.velocity.rotate(argumentOfPeriapsis);
    // adjust the direction of the velocity vector for the given direction of revolution
    b2.velocity.mult(direction);
  }

  public void printOrbitalElements()
  {
    System.out.println("mu: " + mu);
    System.out.println("Radius: " + radius);
    System.out.println("Angular Momentum: " + angularMomentum);
    System.out.println("Eccentricity Vector: " + eccentricityVector);
    System.out.println("Eccentricity: " + eccentricity);
    System.out.println("Semi-Major Axis: " + semiMajorAxis);
    System.out.println("Semi-Lactus Rectum: " + semiLactusRectum);
    System.out.println("True Anomaly: " + trueAnomaly);
    System.out.println("Eccentric Anomaly: " + eccentricAnomaly);
    System.out.println("Mean Anomaly: " + meanAnomaly);
    System.out.println("Tangential Velocity: " + tangentialVelocity);
    System.out.println("Radial Velocity: " + radialVelocity);
    System.out.println("Satellite Velocity Vector: " + b2.velocity);
    System.out.println("Satellite Speed: " + speed);
  }
  
  public void draw()
  {
    // draw orbital path and orbital bodies
    image(orbitalPath, 0, 0);
    b1.draw(); b2.draw();
    
    // plot a radial line from the fixed body to the satellite
    fill(255, 0, 255); stroke(255, 0, 255); strokeWeight(2);
    line(b1.position.x, b1.position.y, b2.position.x, b2.position.y);
    
    // plot true anomaly
    noFill(); stroke(0, 155, 91);
    float angle = atan2(radius.y, radius.x);
    if (angle < argumentOfPeriapsis) angle += 2.0f * PI;
    if(direction > 0) arc(displayWidth / 2, displayHeight / 2, (int) periapsis, (int) periapsis, argumentOfPeriapsis, angle);
    else arc(displayWidth / 2, displayHeight / 2, (int) periapsis, (int) periapsis, angle, argumentOfPeriapsis + 2.0f * PI);
  }
}
class UI
{
  long startTime, time;
  PGraphics constantOrbitData;
  int frames;
  
  // Constructors
  // ------------------------------------------------------
  
  public UI()
  {
    startTime = System.currentTimeMillis();
    constantOrbitData = createGraphics(displayWidth, displayHeight, P2D);
    generateConstantOrbitData();
    initControls();
    initOverlay();
  }
  
  // Methods
  // ------------------------------------------------------
  
  public void generateConstantOrbitData()
  {
    constantOrbitData = createGraphics(displayWidth, displayHeight, P2D);
    constantOrbitData.beginDraw();
    constantOrbitData.textFont(font);
    
    constantOrbitData.fill(0);
    constantOrbitData.text("mu: " + orbit.mu, displayWidth / 4 * 3, displayHeight / 32 * 2);
    constantOrbitData.text("Angular Momentum: " + (-orbit.angularMomentum.mag() * orbit.direction), displayWidth / 4 * 3, displayHeight / 32 * 3);
    constantOrbitData.text("Eccentricity: " + orbit.eccentricity, displayWidth / 4 * 3, displayHeight / 32 * 4);
    
    constantOrbitData.fill(255, 0, 0);
    constantOrbitData.text("Semi-Major Axis: " + orbit.semiMajorAxis, displayWidth / 4 * 3, displayHeight / 32 * 5);
    constantOrbitData.fill(0);
    
    constantOrbitData.text("Semi-Minor Axis: " + orbit.semiMinorAxis, displayWidth / 4 * 3, displayHeight / 32 * 6);
    constantOrbitData.text("Semi-Lactus Rectum: " + orbit.semiLactusRectum, displayWidth / 4 * 3, displayHeight / 32 * 7);
    constantOrbitData.text("Periapsis: " + orbit.periapsis, displayWidth / 4 * 3, displayHeight / 32 * 8);
    constantOrbitData.text("Apoapsis: " + orbit.apoapsis, displayWidth / 4 * 3, displayHeight / 32 * 9);
    constantOrbitData.text("Argument of Periapsis: " + (-orbit.argumentOfPeriapsis * 180f / PI) + "\u00b0", displayWidth / 4 * 3, displayHeight / 32 * 10);
    constantOrbitData.text("Orbital Period: " + orbit.period, displayWidth / 4 * 3, displayHeight / 32 * 11);
    constantOrbitData.endDraw();
  }
  
  public void overlayOrbitData()
  {
    image(constantOrbitData, 0, 0);
    fill(0, 155, 91);
    text("True Anomaly: " + (-orbit.trueAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3, displayHeight / 32 * 12);
    fill(0);
    
    text("Eccentric Anomaly: " + (-orbit.eccentricAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3, displayHeight / 32 * 13);
    text("Mean Anomaly: " + (-orbit.meanAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3, displayHeight / 32 * 14);
    
    fill(255, 0, 255);
    text("Orbital Radius: " + orbit.radius.mag(), displayWidth / 4 * 3, displayHeight / 32 * 15);
    fill(0);
    
    fill(0, 0, 255);
    text("Satellite Speed: " + orbit.speed, displayWidth / 4 * 3, displayHeight / 32 * 16);
  }
  
  public void initOverlay()
  {
    textFont(font);
  }
  
  public void initControls()
  {
  
    initSliders();
    initButtons();
  }
  
    public void initSliders()
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

  public void initButtons()
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
  
  public void overlayFPS()
  {
    if(frames > 50)
    {
      frames = 25;
      startTime = System.currentTimeMillis() - time / 2;
      time = time / 2;
    }
    else 
    {
      time = System.currentTimeMillis() - startTime;
      frames++;
    }
    
    stroke(0); fill(0);
    if(time != 0) text("FPS: " + (int) (((float) frames / (float) time) * 1000f), displayWidth / 4 * 3, displayHeight / 32 * 31);
  }
  
  public void correctSliderDisplayValues()
  {
    b2Position.setValueLabel("" + (int) b2.position.x + ", " + (displayHeight - (int) b2.position.y));
    b2Velocity.setValueLabel("" + (int) b2.velocity.x + ", " + (int) -b2.velocity.y);
  }
  
  public void draw()
  {
    overlayFPS();
    overlayOrbitData();
    correctSliderDisplayValues();
  }
}
  public void settings() {  fullScreen(P2D, 1);  smooth(0); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "OrbitSimulator" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
