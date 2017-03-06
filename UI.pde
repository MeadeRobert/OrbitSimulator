/**
 * An object to hold UI data.
 * @author Robert Meade
 * @version 1.2
 */
class UI
{

  /** start of fps time. */
  long startTime;

  /** end of fps time *. */
  long time;

  /** The constant orbit data. */
  PGraphics constantOrbitData;

  /** frames in time period. */
  int frames;

  // Constructors
  // ------------------------------------------------------

  /**
   * Instantiates a new UI object.
   */
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

  /**
   * Generate constant orbit data.
   */
  void generateConstantOrbitData()
  {
    constantOrbitData = createGraphics(displayWidth, displayHeight, P2D);
    constantOrbitData.beginDraw();
    constantOrbitData.textFont(font);

    constantOrbitData.fill(0);
    constantOrbitData.text("mu: " + orbit.mu, displayWidth / 4 * 3, displayHeight / 32 * 2);
    constantOrbitData.text("Angular Momentum: " + (-orbit.angularMomentum.mag() * orbit.direction),
        displayWidth / 4 * 3, displayHeight / 32 * 3);
    constantOrbitData.text("Eccentricity: " + orbit.eccentricity, displayWidth / 4 * 3, displayHeight / 32 * 4);

    constantOrbitData.fill(255, 0, 0);
    constantOrbitData.text("Semi-Major Axis: " + orbit.semiMajorAxis, displayWidth / 4 * 3,
        displayHeight / 32 * 5);
    constantOrbitData.fill(0);

    constantOrbitData.text("Semi-Minor Axis: " + orbit.semiMinorAxis, displayWidth / 4 * 3,
        displayHeight / 32 * 6);
    constantOrbitData.text("Semi-Lactus Rectum: " + orbit.semiLactusRectum, displayWidth / 4 * 3,
        displayHeight / 32 * 7);
    constantOrbitData.text("Periapsis: " + orbit.periapsis, displayWidth / 4 * 3, displayHeight / 32 * 8);
    constantOrbitData.text("Apoapsis: " + orbit.apoapsis, displayWidth / 4 * 3, displayHeight / 32 * 9);
    constantOrbitData.text("Argument of Periapsis: " + (-orbit.argumentOfPeriapsis * 180f / PI) + "\u00b0",
        displayWidth / 4 * 3, displayHeight / 32 * 10);
    constantOrbitData.text("Orbital Period: " + orbit.period, displayWidth / 4 * 3, displayHeight / 32 * 11);
    constantOrbitData.endDraw();
  }

  /**
   * Overlay orbit data.
   */
  void overlayOrbitData()
  {
    image(constantOrbitData, 0, 0);
    fill(0, 155, 91);
    text("True Anomaly: " + (-orbit.trueAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3,
        displayHeight / 32 * 12);
    fill(0);

    text("Eccentric Anomaly: " + (-orbit.eccentricAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3,
        displayHeight / 32 * 13);
    text("Mean Anomaly: " + (-orbit.meanAnomaly * 180f / PI) + "\u00b0", displayWidth / 4 * 3,
        displayHeight / 32 * 14);

    fill(255, 0, 255);
    text("Orbital Radius: " + orbit.radius.mag(), displayWidth / 4 * 3, displayHeight / 32 * 15);
    fill(0);

    fill(0, 0, 255);
    text("Satellite Speed: " + orbit.speed, displayWidth / 4 * 3, displayHeight / 32 * 16);
  }

  /**
   * Initialize the overlay.
   */
  void initOverlay()
  {
    textFont(font);
  }

  /**
   * Initialize the controls.
   */
  void initControls()
  {

    initSliders();
    initButtons();
  }

  /**
   * Initialize the sliders.
   */
  void initSliders()
  {
    cp5.addSlider("b1Radius").setPosition(displayWidth / 16, displayHeight / 16).setRange(0, displayWidth / 50)
        .setValue(5).setWidth(displayWidth / 4).setHeight(displayHeight / 64 * 3)
        .setColorLabel(color(0, 0, 0)).setFont(font).setCaptionLabel("Fixed Body Radius");

    cp5.addSlider("b2Radius").setPosition(displayWidth / 16, displayHeight / 16 * 2)
        .setRange(0, displayWidth / 50).setValue(5).setWidth(displayWidth / 4)
        .setHeight(displayHeight / 64 * 3).setColorLabel(color(0, 0, 0)).setFont(font)
        .setCaptionLabel("Satellite Radius");

    cp5.addSlider("gravitationalConstant").setPosition(displayWidth / 16, displayHeight / 16 * 3)
        .setRange(0, 50).setValue(5).setWidth(displayWidth / 4).setHeight(displayHeight / 64 * 3)
        .setValue(1.0f).setColorLabel(color(0, 0, 0)).setFont(font)
        .setCaptionLabel("Gravitational Constant");

    cp5.addSlider("b1Mass").setPosition(displayWidth / 16, displayHeight / 16 * 4).setColorLabel(color(0, 0, 0))
        .setRange(0, 50).setWidth(displayWidth / 4).setHeight(displayHeight / 64 * 3)
        .setValue(b1.mass / 1000f).setFont(font).setCaptionLabel("Fixed Body Mass");

    cp5.addSlider("timeStep").setPosition(displayWidth / 16, displayHeight / 16 * 5)
        .setColorLabel(color(0, 0, 0)).setRange(0, 1).setValue(timeStep).setWidth(displayWidth / 4)
        .setHeight(displayHeight / 64 * 3).setValue(timeStep).setFont(font).setCaptionLabel("Time Step");

    b2Velocity = cp5.addSlider2D("b2Velocity").setCaptionLabel("Velocity")
        .setPosition(displayWidth / 8 - displayWidth / 16, displayHeight / 3 * 2)
        .setSize(displayWidth / 8, displayWidth / 8).setColorLabel(color(0, 0, 0))
        .setColorValue(color(0, 0, 0)).setMinMax(-50, -50, 50, 50).setValue(b2.velocity.x, b2.velocity.y)
        .setFont(font);

    b2Position = cp5.addSlider2D("b2Position").setCaptionLabel("Position")
        .setPosition(displayWidth / 4, displayHeight / 3 * 2).setSize(displayWidth / 8, displayWidth / 8)
        .setColorLabel(color(0, 0, 0)).setColorValue(color(0, 0, 0))
        .setMinMax(displayWidth / 4, displayHeight / 4, displayWidth * 3 / 4, displayHeight * 3 / 4)
        .setValue(b2.position.x, b2.position.y).setFont(font);
  }

  /**
   * Initialize the buttons.
   */
  void initButtons()
  {
    cp5.addToggle("startStop").setPosition(displayWidth / 16, displayHeight / 2)
        .setSize(displayWidth / 8, displayHeight / 16).setColorLabel(color(0, 0, 0)).setValue(false)
        .setMode(ControlP5.SWITCH).setFont(font).setCaptionLabel("Start/Stop");

    cp5.addToggle("recalculate").setPosition(displayWidth / 4, displayHeight / 2)
        .setSize(displayWidth / 8, displayHeight / 16).setColorLabel(color(0, 0, 0)).setValue(false)
        .setMode(ControlP5.SWITCH).setFont(font).setCaptionLabel("Recalculate");
  }

  /**
   * Overlay FPS Info.
   */
  void overlayFPS()
  {
    if (frames > 50)
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

    stroke(0);
    fill(0);
    if (time != 0)
      text("FPS: " + (int) (((float) frames / (float) time) * 1000f), displayWidth / 4 * 3,
          displayHeight / 32 * 31);
  }

  /**
   * Correct slider display values.
   */
  void correctSliderDisplayValues()
  {
    b2Position.setValueLabel("" + (int) b2.position.x + ", " + (displayHeight - (int) b2.position.y));
    b2Velocity.setValueLabel("" + (int) b2.velocity.x + ", " + (int) -b2.velocity.y);
  }

  /**
   * Draw the UI.
   */
  void draw()
  {
    overlayFPS();
    overlayOrbitData();
    correctSliderDisplayValues();
  }
}