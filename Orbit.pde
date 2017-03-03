class Orbit
{  
  public Body b1, b2;
  
  public Orbit(Body b1, Body b2)
  {
    this.b1 = b1;
    this.b2 = b2;
    calculateInitialOrbitalElements();
    printOrbitalElements();
  }
  
  // constant orbital elements
  float mu, eccentricity, semiMajorAxis, semiLactusRectum, speed;
  PVector angularMomentum = new PVector();
  PVector eccentricityVector = new PVector();
  PVector initialSatelliteVelocity = new PVector();
  PVector initialRadius = new PVector();
  float argumentOfPeriapsis, initialEccentricAnomaly, initialMeanAnomaly, initialTangentialVelocity, initialRadialVelocity, direction;

  // changing orbital elements
  PVector radius = new PVector();
  float trueAnomaly, eccentricAnomaly, meanAnomaly, tangentialVelocity, radialVelocity, period;


  void calculateInitialOrbitalElements()
  {
    // Calculate orbital elements 
    mu = gravitationalConstant * b1.mass;
  
    radius.set(b2.position);
    radius.sub(b1.position);
    
    angularMomentum.set(radius);
    angularMomentum.cross(b2.velocity, angularMomentum);
    
    direction = signum(angularMomentum.z);
  
    eccentricityVector = new PVector(); eccentricityVector.set(b2.velocity);
    eccentricityVector.cross(angularMomentum, eccentricityVector);
    eccentricityVector.div(mu);
    temp.set(radius); temp.normalize();
    eccentricityVector.sub(temp);
  
    eccentricity = eccentricityVector.mag();
    
    semiMajorAxis = angularMomentum.mag() * angularMomentum.mag() / (mu * (1 - eccentricity * eccentricity));
  
    semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);
  
    argumentOfPeriapsis = atan2(eccentricityVector.y, eccentricityVector.x);
    
    trueAnomaly = signum(eccentricityVector.cross(radius).z) * acos(radius.dot(eccentricityVector)/(radius.mag() * eccentricity));
    
    eccentricAnomaly = atan2(sqrt(1 - eccentricity*eccentricity) * sin(trueAnomaly), (eccentricity + cos(trueAnomaly)));
    initialEccentricAnomaly = eccentricAnomaly;
  
    meanAnomaly = eccentricAnomaly - eccentricity * sin(eccentricAnomaly);
    initialMeanAnomaly = meanAnomaly;
  
    radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin(trueAnomaly);
    initialRadialVelocity = radialVelocity;
  
    tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));
    initialTangentialVelocity = tangentialVelocity; 
  }

  void plotOrbitalPath()
  {
    // set drawing  params
    color(0); stroke(0);
    // plot 360*8 points evenly spaced in angular terms
    // for one revolution of the ellipse
    float r, angle;
    for(int j = 0; j < 360*8; j++)
    {
      angle = (float) j / (16.0f * PI);
      r = semiLactusRectum / (1.0f + eccentricity * cos (angle - argumentOfPeriapsis));
      point(r * cos(angle) + b1.position.x, r * sin(angle) + b1.position.y);
    }
  }

  void update(float deltaTime, int iterations)
  {
    // calculate next meanAnomaly given the time step
    meanAnomaly = (direction * deltaTime * sqrt(mu / pow(semiMajorAxis,3)) + meanAnomaly) % (2.0f * PI);
  
    // use newton's method for the defined number of iterations to solve numerically for the eccentric anomaly
    // there is no analytical solution
    for(int i = 0; i < iterations; i++)
    {
      eccentricAnomaly = eccentricAnomaly - (eccentricAnomaly - eccentricity * sin (eccentricAnomaly) - meanAnomaly)
                           / (1 - eccentricity * cos(eccentricAnomaly));
    }
  
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
    System.out.println("Satellite Speed: " + speed);
  }
  
  void draw()
  {
    plotOrbitalPath();
    b1.draw(); b2.draw();
    
    // plot a radial line from the fixed body to the satellite
    fill(255, 0, 255); stroke(255, 0, 255);
    line(b1.position.x, b1.position.y, b2.position.x, b2.position.y);
  }
}