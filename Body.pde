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