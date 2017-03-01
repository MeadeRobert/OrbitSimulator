import processing.core.*;

public static final float GRAVITATIONAL_CONSTANT = 1.0;//6.67e11;

class Body
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  
  public Body(PVector position, PVector velocity, PVector acceleration, float mass)
  {
    this.position = new PVector(); this.position.set(position);
    this.velocity = new PVector(); this.velocity.set(velocity);
    this.acceleration = new PVector(); this.acceleration.set(acceleration);
    this.mass = mass;
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
    color(0);
    stroke(0);
    ellipse(position.x, position.y, 10f, 10f);
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
  
  public PVector gravitationalForceFrom(Body other)
  {
    PVector unitDirection = other.position;
    unitDirection.sub(this.position);
    float dist = unitDirection.mag();
    unitDirection.normalize();
    unitDirection.mult((mass*other.mass*GRAVITATIONAL_CONSTANT)/(dist*dist));
    return unitDirection;
  }
}

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

// app core
// -----------------

//int width = 1024;
//int height = 768;

Body b1, b2;

PVector temp = new PVector();

// constant orbital elements
float mu, eccentricity, semiMajorAxis, semiLactusRectum;
PVector angularMomentum = new PVector();
PVector eccentricityVector = new PVector();
PVector initialSatelliteVelocity = new PVector();
PVector initialRadius = new PVector();
float initialTrueAnomaly, initialEccentricAnomaly, initialMeanAnomaly, initialTangentialVelocity, initialRadialVelocity, direction;

// changing orbital elements
PVector radius = new PVector();
float trueAnomaly, eccentricAnomaly, meanAnomaly, tangentialVelocity, radialVelocity;


void calculateInitialOrbitalElements()
{
  // Calculate orbital elements 
  mu = GRAVITATIONAL_CONSTANT * b1.mass;
  
  radius.set(b2.position);
  radius.sub(b1.position);
  
  angularMomentum.set(radius);
  angularMomentum.cross(b2.velocity, angularMomentum);
  
  eccentricityVector = new PVector(); eccentricityVector.set(b2.velocity);
  eccentricityVector.cross(angularMomentum, eccentricityVector);
  eccentricityVector.div(mu);
  temp.set(radius); temp.normalize();
  eccentricityVector.sub(temp);
  
  eccentricity = eccentricityVector.mag();
  
  semiMajorAxis = angularMomentum.mag() * angularMomentum.mag() / (mu * (1 - eccentricity * eccentricity));
  
  semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);
  
  trueAnomaly = atan2(eccentricityVector.y, eccentricityVector.x);
  initialTrueAnomaly = trueAnomaly;
  
  eccentricAnomaly = atan(sqrt(1 - eccentricity*eccentricity) * sin(trueAnomaly) / (eccentricity + cos(trueAnomaly)));
  initialEccentricAnomaly = eccentricAnomaly;
  
  meanAnomaly = eccentricAnomaly - eccentricity * sin(eccentricAnomaly);
  initialMeanAnomaly = meanAnomaly;
  
  radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin(trueAnomaly);
  initialRadialVelocity = radialVelocity;
  
  tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));
  initialTangentialVelocity = tangentialVelocity;
  
  radius.cross(b2.velocity, temp);
  direction = signum(temp.z);
}

void plotOrbitalPath()
{
  color(0); stroke(0);
  for(int j = 0; j < 360*8; j++)
  {
    float angle = (float) j / (16.0f * PI);
    float r = semiLactusRectum / (1.0f + eccentricity * cos (angle + initialTrueAnomaly));
    point(r * cos(angle) + b1.position.x, r * sin(angle) + b1.position.y);
  }
}

void updateOrbit(float deltaTime, int iterations)
{
  // calculate next meanAnomaly
  meanAnomaly = direction * deltaTime * sqrt(GRAVITATIONAL_CONSTANT * (b1.mass + b2.mass) / pow(semiMajorAxis,3)) + meanAnomaly;
  
  //System.out.println(nextEccentricAnomaly);
  // use newton's method to solve for the eccentric anomaly at this time
  for(int i = 0; i < iterations; i++)
  {
    eccentricAnomaly = eccentricAnomaly - (eccentricAnomaly - eccentricity * sin (eccentricAnomaly) - meanAnomaly)
                           / (1 - eccentricity * cos(eccentricAnomaly));
  }
  
  // solve for the radius vector and update position
  trueAnomaly = 2.0f * atan2(sqrt(1 + eccentricity) * sin (eccentricAnomaly / 2.0f), sqrt(1 - eccentricity) * cos(eccentricAnomaly / 2.0f));
  float r = semiLactusRectum / (1.0f + eccentricity * cos (trueAnomaly));
  radius.set(r*cos(trueAnomaly - initialTrueAnomaly), r*sin(trueAnomaly - initialTrueAnomaly));
  b2.position.set(b1.position);
  b2.position.add(radius);
  
  // update other orbital params
  radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin (trueAnomaly);
  tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos (trueAnomaly));
  
  float speed = sqrt(radialVelocity * radialVelocity + tangentialVelocity * tangentialVelocity);
  b2.velocity.set(-direction * speed * sin(trueAnomaly - initialTrueAnomaly), direction * speed * cos (trueAnomaly - initialTrueAnomaly));
  
  eccentricityVector = new PVector(); eccentricityVector.set(b2.velocity);
  eccentricityVector.cross(angularMomentum, eccentricityVector);
  eccentricityVector.div(mu);
  temp.set(radius); temp.normalize();
  eccentricityVector.sub(temp);
}

void printOrbitalElements()
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
  System.out.println("Satellite Speed: " + b2.velocity.mag());
}
  
void overlayOrbitInfo()
{
  textSize(14);
  text("mu: " + mu, width - width / 3, height / 16);
  text("Radius: " + radius, width - width / 3, height / 16 * 2);
  text("Angular Momentum: " + angularMomentum, width - width / 3, height / 16 * 3);
  text("Eccentricity Vector: " + eccentricityVector, width - width / 3, height / 16 * 4);
  text("Eccentricity: " + eccentricity, width - width / 3, height / 16 * 5);
  text("Semi-Major Axis: " + semiMajorAxis, width - width / 3, height / 16 * 6);
  text("Semi-Lactus Rectum: " + semiLactusRectum, width - width / 3, height / 16 * 7);
  text("True Anomaly: " + trueAnomaly, width - width / 3, height / 16 * 8);
  text("Mean Anomaly: " + meanAnomaly, width - width / 3, height / 16 * 9);
  text("Radial Velocity: " + radialVelocity, width - width / 3, height / 16 * 10);
  text("Satellite Velocity Vector: " + b2.velocity, width - width / 3, height / 16 * 11);
  text("Satellite Speed: " + b2.velocity.mag(), width - width / 3, height / 16 * 12);
}


void setup()
{
  background(155);
  size(1024, 768);
  b1 = new Body(new PVector(.5f * width, .5f * height), new PVector(0,0,0), new PVector(0,0,0), 50000.0f);
  b2 = new Body(new PVector(.5f * width + 20, .5f * height), new PVector(40,55,0), new PVector(0,0,0), 1.0f);
  calculateInitialOrbitalElements();
}

void draw()
{
  background(155);
  fill(0, 255, 0);
  stroke(0, 255, 0);
  b1.draw();
  fill(255, 0, 0);
  stroke(255, 0, 0);
  b2.draw();
  
  printOrbitalElements();
  overlayOrbitInfo();
  plotOrbitalPath();
  updateOrbit(.1f, 2);
  delay(12);
}