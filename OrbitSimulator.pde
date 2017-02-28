class Body
{
  public static final float GRAVITATIONAL_CONSTANT = 1.0f; //6.67e-11
  
  PVector position, velocity, acceleration;
  float mass;
  
  public Body(PVector position, PVector velocity, PVector acceleration, float mass)
  {
    this.position = position.copy();
    this.velocity = velocity.copy();
    this.acceleration = acceleration.copy();
    this.mass = mass;
  }
  
  public void applyForce(PVector force)
  {
    acceleration.add(force.div(mass));
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
    position = position.add(velocity.mult(time));
    System.out.println(position);
    
    //zero acc for next tick
    velocity = velocity.add(acceleration);
    acceleration = new PVector(0,0);
  }
  
  public PVector gravitationalForceFrom(Body other)
  {
    PVector unitDirection = other.position.copy().sub(this.position);
    float dist = unitDirection.mag();
    unitDirection = unitDirection.normalize();
    
    return unitDirection.mult((mass*other.mass*GRAVITATIONAL_CONSTANT)/(dist*dist));
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
  size(800,600);
  background(155);
  //b1.applyForce(new PVector(5,0));
}

void draw()
{
  b2.applyForce(b2.gravitationalForceFrom(b1));
  b1.applyForce(b1.gravitationalForceFrom(b2));
  b1.update(1f);
  b2.update(1f);
  b1.draw();
  b2.draw();
  
}