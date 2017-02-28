import processing.core.*;

public static final float GRAVITATIONAL_CONSTANT = 1.0;//6.67e-11;

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
  
  // Calculate orbital elements
  
  float mu = GRAVITATIONAL_CONSTANT * b1.mass;
  
  PVector radius = new PVector();
  radius.set(b2.position);
  radius.sub(b1.position);
  System.out.println("Radius: " + radius);
  
  PVector angularMomentum = b2.velocity;
  angularMomentum.cross(radius);
  System.out.println("Angular Momentum: " + angularMomentum);
  
  PVector nodeVector = new PVector(0, 0, 1);
  nodeVector.cross(angularMomentum);
  System.out.println("Node Vector: " + nodeVector);
  
  PVector eccentricityVector = new PVector();
  eccentricityVector.set(b2.velocity);
  eccentricityVector.cross(angularMomentum);
  eccentricityVector.div(mu);
  //eccentricityVector.set(radius);
  //eccentricityVector.mult(b2.velocity.mag()*b2.velocity.mag()-mu/radius.mag());
  //temp.set(radius);
  //temp.cross(b2.velocity);
  //temp.mult(b2.velocity.mag());
  //eccentricityVector.sub(temp);
  //eccentricityVector.div(mu);
  System.out.println("Eccentricity Vector: " + eccentricityVector);
  
  float eccentricity = eccentricityVector.mag();
  System.out.println("Eccentricity: " + eccentricity);
  
  float specificMechanicalEnergy = b2.velocity.mag() * b2.velocity.mag() / 2 - mu / radius.mag();
  System.out.println("Specific Mechanical Energy: " + specificMechanicalEnergy);
  
  float semiMajorAxis = -mu / 2 / specificMechanicalEnergy;
  System.out.println("Semi-Major Axis: " + semiMajorAxis);
  
  float semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);
  System.out.println("Semi-Lactus Rectum: " + semiLactusRectum);
  
  float i = acos(angularMomentum.z/angularMomentum.mag());
  float bigOmega = acos(nodeVector.x/nodeVector.mag());
  temp = nodeVector; temp.cross(eccentricityVector);
  float littleOmega = acos(temp.mag()/(nodeVector.mag() * eccentricity));
  temp = radius; temp.cross(eccentricityVector);
  float trueAnomyly = acos(temp.mag()/(eccentricity * radius.mag()));
  
  
  // plot path
  color(0); stroke(0);
  for(int j = 0; j < 360; j++)
  {
    float angle = (float) j / (2.0f * PI);
    float r = semiLactusRectum / (1.0f + eccentricity * cos (angle));
    point(r * cos(angle) + b1.position.x, r * sin(angle) + b1.position.y);
  }

}

void draw()
{
  fill(0, 255, 0);
  b1.draw();
  fill(255, 0, 0);
  b2.draw();
  
}