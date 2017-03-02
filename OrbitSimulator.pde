import processing.core.*;

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

// app core
// --------------------------------------------

Body b1, b2;
Orbit orbit;
float gravitationalConstant = 1.0f;
PVector temp = new PVector();


void setup()
{
  background(155);
  size(displayWidth, displayHeight);
  b1 = new Body(new PVector(.5f * width, .5f * height), new PVector(0,0,0), new PVector(0,0,0), 50000.0f, displayWidth/150, new int[]{0, 255, 0}, new int[]{0, 0, 0});
  b2 = new Body(new PVector(.5f * width + 20, .5f * height), new PVector(40,55,0), new PVector(0,0,0), 1.0f, displayWidth/150,new int[]{255, 0, 0}, new int[]{0, 0, 0});
  orbit = new Orbit(b1, b2);
}

void draw()
{
  background(155);
  orbit.draw();
  orbit.update(.1f, 5);
  orbit.overlayOrbitInfo();
  delay(12);
}