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
    orbitalPath = createGraphics(displayWidth, displayHeight); 
    calculateInitialOrbitalElements();
    printOrbitalElements();
  }
  
  // Methods
  // ---------------------------------------------------------------------

  void calculateInitialOrbitalElements()
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
    // a = H^2 / (mu * (1 - e)
    semiMajorAxis = angularMomentum.mag() * angularMomentum.mag() / (mu * (1 - eccentricity * eccentricity));
  
    // p = a * (1 - e^2)
    semiLactusRectum = semiMajorAxis * (1 - eccentricity*eccentricity);
    
    // b = a(sqrt(1-e^2)
    semiMinorAxis = semiMajorAxis * sqrt((1 - eccentricity*eccentricity));
    
    // q = a(1 - e)
    periapsis = semiMajorAxis * (1 - eccentricity);
    
    apoapsis = 2 * semiMajorAxis - periapsis;
  
    // calculate angular displacement from x/y plane where top of screen is x-axis
    // tan (omega) = e.y / e.x
    argumentOfPeriapsis = atan2(eccentricityVector.y, eccentricityVector.x);
    
    // calculate angular anomalies
    // cos (true anomaly) = (R dot E) / (r*e) 
    trueAnomaly = signum(eccentricityVector.cross(radius).z) * acos(radius.dot(eccentricityVector)/(radius.mag() * eccentricity));
     
    eccentricAnomaly = atan2(sqrt(1 - eccentricity*eccentricity) * sin(trueAnomaly), (eccentricity + cos(trueAnomaly)));
  
    meanAnomaly = eccentricAnomaly - eccentricity * sin(eccentricAnomaly);
  
    // calculate radial and tangential velocities
    radialVelocity = sqrt(mu/semiLactusRectum) * eccentricity * sin(trueAnomaly);
  
    tangentialVelocity = sqrt(mu/semiLactusRectum) * (1 + eccentricity * cos(trueAnomaly));
    
    // calculate orbital period
    period = sqrt((4.0f * PI * PI * pow(semiMajorAxis, 3) / mu));
    
    // gen orbit path
    generateOrbitalPath();
  }

  void generateOrbitalPath()
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