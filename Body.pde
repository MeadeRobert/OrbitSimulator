/**
 * 2D physics body implementation.
 * @author Robert Meade
 * @version 1.2
 */
class Body
{

  /** The stroke. */
  int[] stroke;

  /** The fill *. */
  int[] fill;

  /** The velocity. */
  PVector velocity;

  /** The position. */
  PVector position;

  /** The acceleration. */
  PVector acceleration;

  /** The radius. */
  float mass, radius;

  /**
   * Instantiates a new body.
   * @param position the position
   * @param velocity the velocity
   * @param acceleration the acceleration
   * @param mass the mass
   * @param radius the radius
   * @param fill the fill
   * @param stroke the stroke
   */
  public Body(PVector position, PVector velocity, PVector acceleration, float mass, float radius, int[] fill,
      int[] stroke)
  {
    this.position = new PVector();
    this.position.set(position);
    this.velocity = new PVector();
    this.velocity.set(velocity);
    this.acceleration = new PVector();
    this.acceleration.set(acceleration);
    this.mass = mass;
    this.radius = radius;
    this.fill = fill;
    this.stroke = stroke;
  }

  /**
   * Apply force.
   * @param force applied force
   */
  public void applyForce(PVector force)
  {
    PVector appliedAcceleration = new PVector();
    appliedAcceleration.set(force);
    appliedAcceleration.div(mass);
    acceleration.add(appliedAcceleration);
  }

  /**
   * Draw the body.
   */
  public void draw()
  {
    fill(fill[0], fill[1], fill[2]);
    stroke(stroke[0], stroke[1], stroke[2]);
    strokeWeight(1);
    ellipse(position.x, position.y, radius * 2.0f, radius * 2.0f);
    stroke(0, 0, 255);
    strokeWeight(2);
    line(position.x, position.y, position.x + velocity.x, position.y + velocity.y);
  }

  /**
   * Update the bodies's velocity and position.
   * @param timeStep the time step
   */
  public void update(float timeStep)
  {
    // use a modified euler's method with average change over interval
    // => correct result for constant acceleration systems
    System.out.println(position);
    PVector dist = new PVector();
    dist.set(velocity);
    dist.mult(timeStep);
    position.add(dist);
    System.out.println(position);

    // zero acc for next tick
    velocity.add(acceleration);
    acceleration = new PVector(0, 0);
  }
}