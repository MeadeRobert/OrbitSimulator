import processing.core.*;

public static final float GRAVITATIONAL_CONSTANT = 6.67e-11;

class Body
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass;
  
  public Body(PVector position, PVector velocity, PVector acceleration, float mass)
  {
    this.position = new PVector().set(position);
    this.velocity = new PVector().set(velocity);
    this.acceleration = new PVector().set(acceleration);
    this.mass = mass;
  }
  
  public void applyForce(PVector force)
  {
    PVector appliedAcceleration = new PVector().set(force);
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
    PVector dist = new PVector().set(velocity);
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

// app core
// -----------------

int width = 800;
int height = 400;

Body b1 = new Body(new PVector(.5f * width, .5f * height), new PVector(0,0), new PVector(0,0), 1.0f);
Body b2 = new Body(new PVector(.5f * width + 20, .5f * height), new PVector(0,1/(float)Math.sqrt(20)), new PVector(0,0), 1.0f);

void setup()
{
  PVector temp = new PVector();
  size(800, 600);
  background(155);
  
  float mu = GRAVITATIONAL_CONSTANT * b1.mass;
  
  PVector radius = new PVector().set(b2.position);
  radius.sub(b1.position);
  
  PVector angularMomentum = b2.velocity;
  angularMomentum.cross(radius);
  
  PVector nodeVector = new PVector(0, 0, 1);
  nodeVector.cross(angularMomentum);
  
  PVector eccentricityVector = new PVector().set(radius);
  eccentricityVector.mult(b2.velocity.mag()*b2.velocity.mag()-mu/radius.mag());
  temp.set(radius);
  temp.cross(b2.velocity);
  temp.mult(b2.velocity.mag());
  eccentricityVector.sub(temp);
  eccentricityVector.div(mu);
  
  float eccentricity = eccentricityVector.mag();
  
  float specificMechanicalEnergy = b2.velocity.mag() * b2.velocity.mag() / 2 - mu / radius.mag();
  
  float semiMajorAxis = -mu / 2 / specificMechanicalEnergy;
  
  float semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);
  
  float i = acos(angularMomentum.z/angularMomentum.mag());
  float bigOmega = acos(nodeVector.x/nodeVector.mag());
  temp = nodeVector; temp.cross(eccentricityVector);
  float littleOmega = acos(temp.mag()/(nodeVector.mag() * eccentricity));
  temp = radius; temp.cross(eccentricityVector);
  float trueAnomyly = acos(temp.mag()/(eccentricity * radius.mag()));
  
  
  
  
  //b1.applyForce(new PVector(5,0));
}

void draw()
{
  //b2.applyForce(b2.gravitationalForceFrom(b1));
  //b1.applyForce(b1.gravitationalForceFrom(b2));
  b1.update(1f);
  b2.update(1f);
  b1.draw();
  b2.draw();
  
}