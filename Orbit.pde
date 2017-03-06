/**
 * An object to hold orbital data.
 * @author Robert Meade
 * @version 1.2
 */
class Orbit
{

  /** The fixed body */
  Body b1;
  /** The satellite body */
  Body b2;

  /** The orbital path. */
  PGraphics orbitalPath;

  /** The product of G and the mass of the fixed body. */
  float mu;

  /** The eccentricity. */
  float eccentricity;

  /** The semi major axis. */
  float semiMajorAxis;

  /** The semi minor axis. */
  float semiMinorAxis;

  /** The semi lactus rectum. */
  float semiLactusRectum;

  /** The speed. */
  float speed;

  /** The period. */
  float period;

  /** The periapsis. */
  float periapsis;

  /** The apoapsis. */
  float apoapsis;

  /** The angular momentum. */
  PVector angularMomentum = new PVector();

  /** The eccentricity vector. */
  PVector eccentricityVector = new PVector();

  /** The initial satellite velocity. */
  PVector initialSatelliteVelocity = new PVector();

  /** The initial radius. */
  PVector initialRadius = new PVector();

  /** The direction. */
  float argumentOfPeriapsis, direction;

  /** The radius. */
  PVector radius = new PVector();

  /** The radial velocity. */
  float trueAnomaly;

  /** The eccentric anomaly. */
  float eccentricAnomaly;

  /** The mean anomaly. */
  float meanAnomaly;

  /** The tangential velocity. */
  float tangentialVelocity;

  /** The radial velocity. */
  float radialVelocity;

  // Constructors
  // ---------------------------------------------------------------------

  /**
   * Instantiates a new orbit.
   * @param b1 the fixed body
   * @param b2 the satellite
   */
  public Orbit(Body b1, Body b2)
  {
    this.b1 = b1;
    this.b2 = b2;
    orbitalPath = createGraphics(displayWidth, displayHeight, P2D);
    calculateInitialOrbitalElements();
    System.out.println(orbit);
  }

  // Methods
  // ---------------------------------------------------------------------

  /**
   * Calculate initial orbital elements.
   */
  void calculateInitialOrbitalElements()
  {
    // calculate mu, radius, angularMomentum and direction of orbit
    mu = gravitationalConstant * b1.mass;

    radius.set(b2.position);
    radius.sub(b1.position);

    angularMomentum.set(radius);
    angularMomentum.cross(b2.velocity, angularMomentum);

    direction = Math.signum(angularMomentum.z);

    // calculate eccentricity
    eccentricityVector = new PVector();
    eccentricityVector.set(b2.velocity);
    eccentricityVector.cross(angularMomentum, eccentricityVector);
    eccentricityVector.div(mu);
    temp.set(radius);
    temp.normalize();
    eccentricityVector.sub(temp);

    eccentricity = eccentricityVector.mag();

    // calculate semi-major axis, semi-minor axis, periapsis, apoapsis,
    // and semi-lactus rectum for the orbit
    semiMajorAxis = angularMomentum.mag() * angularMomentum.mag() / (mu * (1 - eccentricity * eccentricity));
    semiLactusRectum = semiMajorAxis * (1 - eccentricity * eccentricity);
    semiMinorAxis = semiMajorAxis * sqrt((1 - eccentricity * eccentricity));
    periapsis = semiMajorAxis * (1 - eccentricity);
    apoapsis = 2 * semiMajorAxis - periapsis;

    // calculate angular displacement from x/y plane where top of screen
    // is x-axis
    argumentOfPeriapsis = atan2(eccentricityVector.y, eccentricityVector.x);

    // calculate angular anomalies
    trueAnomaly = Math.signum(eccentricityVector.cross(radius).z)
        * acos(radius.dot(eccentricityVector) / (radius.mag() * eccentricity));
    eccentricAnomaly = atan2(sqrt(1 - eccentricity * eccentricity) * sin(trueAnomaly),
        (eccentricity + cos(trueAnomaly)));
    meanAnomaly = eccentricAnomaly - eccentricity * sin(eccentricAnomaly);

    // calculate radial and tangential velocities
    radialVelocity = sqrt(mu / semiLactusRectum) * eccentricity * sin(trueAnomaly);
    tangentialVelocity = sqrt(mu / semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));

    // calculate orbital period
    period = sqrt((4.0f * PI * PI * pow(semiMajorAxis, 3) / mu));

    // gen orbit path rendering
    generateOrbitalPath();
  }

  /**
   * Generate orbital path.
   */
  void generateOrbitalPath()
  {
    // plot 360*8 points evenly spaced in angular terms
    // for one revolution of the ellipse
    float r, angle, x, y;
    orbitalPath.beginDraw();
    orbitalPath.fill(0);
    orbitalPath.stroke(0);
    orbitalPath.strokeWeight(1);
    orbitalPath.background(255);
    for (int j = 0; j < 360 * 8; j++)
    {
      angle = (float) j / (16.0f * PI);
      r = semiLactusRectum / (1.0f + eccentricity * cos(angle - argumentOfPeriapsis));
      x = r * cos(angle) + b1.position.x;
      y = r * sin(angle) + b1.position.y;
      orbitalPath.point(x, y);
    }

    // draw semi-major axis
    orbitalPath.stroke(255, 0, 0);
    orbitalPath.strokeWeight(2);
    temp.set(cos(argumentOfPeriapsis), sin(argumentOfPeriapsis));
    temp.mult(periapsis);
    orbitalPath.line(b1.position.x, b1.position.y, b1.position.x + temp.x, b1.position.y + temp.y);
    temp.normalize();
    temp.mult(-apoapsis);
    orbitalPath.line(b1.position.x, b1.position.y, b1.position.x + temp.x, b1.position.y + temp.y);

    orbitalPath.endDraw();
  }

  /**
   * Update the orbital state.
   * @param deltaTime the delta time
   * @param iterations the iterations
   */
  void update(float deltaTime, int iterations)
  {
    // calculate next meanAnomaly given the time step
    meanAnomaly = (direction * deltaTime * sqrt(mu / pow(semiMajorAxis, 3)) + meanAnomaly) % (2.0f * PI);

    // use newton's method for the defined number of iterations to solve
    // numerically for the eccentric anomaly
    // there is no analytical solution
    for (int i = 0; i < iterations; i++)
      eccentricAnomaly = eccentricAnomaly
          - (eccentricAnomaly - eccentricity * sin(eccentricAnomaly) - meanAnomaly)
              / (1 - eccentricity * cos(eccentricAnomaly));

    // solve for the new radius vector and update position
    trueAnomaly = 2.0f * atan2(sqrt(1 + eccentricity) * sin(eccentricAnomaly / 2.0f),
        sqrt(1 - eccentricity) * cos(eccentricAnomaly / 2.0f));
    float r = semiLactusRectum / (1.0f + eccentricity * cos(trueAnomaly));
    radius.set(r * cos(trueAnomaly + argumentOfPeriapsis), r * sin(trueAnomaly + argumentOfPeriapsis));
    b2.position.set(b1.position);
    b2.position.add(radius);

    // update radial and tangential velocity
    radialVelocity = sqrt(mu / semiLactusRectum) * eccentricity * sin(trueAnomaly);
    tangentialVelocity = sqrt(mu / semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));

    // get the speed form the tangential and radial components with
    // respect to the radius vector
    speed = sqrt(radialVelocity * radialVelocity + tangentialVelocity * tangentialVelocity);

    // get the velocity components with respect to the semi-major axis
    b2.velocity.set(radialVelocity * cos(trueAnomaly) - tangentialVelocity * sin(trueAnomaly),
        radialVelocity * sin(trueAnomaly) + tangentialVelocity * cos(trueAnomaly));
    // apply a rotation to put the velocity vector in the cartesian
    // plane with respect to
    // the top of the screen as the x-axis
    b2.velocity.rotate(argumentOfPeriapsis);
    // adjust the direction of the velocity vector for the given
    // direction of revolution
    b2.velocity.mult(direction);
  }

  /*
   * (non-Javadoc)
   * @see java.lang.Object#toString()
   */
  @Override
  public String toString()
  {
    return "mu: " + mu + "\nRadius: " + radius + "\nAngular Momentum: " + angularMomentum
        + "\nEccentricity Vector: " + eccentricityVector + "\nEccentricity: " + eccentricity
        + "\nSemi-Major Axis: " + semiMajorAxis + "\nSemi-Lactus Rectum: " + semiLactusRectum
        + "\nPeriapsis" + periapsis + "\nApoapsis" + apoapsis + "\nTrue Anomaly: " + trueAnomaly
        + "\nEccentric Anomaly: " + eccentricAnomaly + "\nMean Anomaly: " + meanAnomaly
        + "\nTangential Velocity: " + tangentialVelocity + "\nRadial Velocity: " + radialVelocity
        + "\nSatellite Velocity Vector: " + b2.velocity + "\nSatellite Speed: " + speed;
  }

  /**
   * Draw the orbit object.
   */
  void draw()
  {
    // draw orbital path and orbital bodies
    image(orbitalPath, 0, 0);
    b1.draw();
    b2.draw();

    // plot a radial line from the fixed body to the satellite
    fill(255, 0, 255);
    stroke(255, 0, 255);
    strokeWeight(2);
    line(b1.position.x, b1.position.y, b2.position.x, b2.position.y);

    // plot true anomaly
    noFill();
    stroke(0, 155, 91);
    float angle = atan2(radius.y, radius.x);
    if (angle < argumentOfPeriapsis)
      angle += 2.0f * PI;
    if (direction > 0)
      arc(displayWidth / 2, displayHeight / 2, (int) periapsis, (int) periapsis, argumentOfPeriapsis, angle);
    else
      arc(displayWidth / 2, displayHeight / 2, (int) periapsis, (int) periapsis, angle,
          argumentOfPeriapsis + 2.0f * PI);
  }
}