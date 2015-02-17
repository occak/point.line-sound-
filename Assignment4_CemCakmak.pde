//import PeasyCam for 3D navigation, Shapes3D for drawing shapes
//ControlP5 for user interface, and OscP5 for sending sounds to Max

import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;
PeasyCam pcam;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress max;

import controlP5.*;
ControlP5 period;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;




// 64 spheres, meaning 64 sounds
Ellipsoid[] ellipsoid = new Ellipsoid[64];

// tubes will connect the spheres
int tubeNum = 0;
Tube[] tube = new Tube[tubeNum];

// this array will start the sequencer, a periodic pulse
int timedPulseNum = 0;
TimedPulse[] timedPulse = new TimedPulse[timedPulseNum];

// in order to make the pulse move from one sphere to another, we need a list of 'pairs'
int pairNum = 0;
EllipsoidPair[] ellipsoidPair = new EllipsoidPair[pairNum];

// we need to pick shapes with the mouse, when clicked, boolean will change
// and they will contain the shape's information
Shape3D picked1 = null;
Shape3D picked2 = null;
Shape3D pickedS = null;

// this will specify position vectors for picked objects
PVector startPos, endPos;

float radius, d = 800;

void setup() {
  size(1000, 750, P3D);
  frameRate(100);
  colorMode(RGB);

  // create new UI, camera and sound port  
  oscP5 = new OscP5(this, 5001);
  max = new NetAddress("127.0.0.1", 5001);
  pcam = new PeasyCam(this, 500);
  period = new ControlP5(this);
  period.addSlider("period", 30, 4000, 2000, 20, height - 40, 200, 20);
  period.setAutoDraw(false);

  cursor(CROSS);

  // draw and spread 64 spheres when run
  // give them random colors and radius
  for (int i = 0; i < ellipsoid.length; i++) {
    radius = 40 + (int)random(60);
    ellipsoid[i] = new Ellipsoid(this, 50, 50);
    ellipsoid[i].setRadius(radius);
    ellipsoid[i].moveTo(random(-d, d), random(-d, d), random(-d, d));
    ellipsoid[i].fill(randomColor());
    ellipsoid[i].stroke(color(220, 25));
    ellipsoid[i].strokeWeight(0.2);
    ellipsoid[i].drawMode(S3D.SOLID | S3D.WIRE);
    ellipsoid[i].tag = "Ellipsoid " + i;
  }
}



void draw() {
  background(220);

  pushMatrix();

  // if there is an object where the mouse cursor is located, 
  // it will be selected when the key 'a' is pressed
  if (mousePressed && mouseButton == RIGHT) {

    picked1 = Ellipsoid.pickShape(this, mouseX, mouseY);

    if ( picked1 != null ) {
      PVector pickedv1 = picked1.getPosVec();
      startPos = new PVector(pickedv1.x, pickedv1.y, pickedv1.z);
      println(startPos);
    }
  }

  // the second shape will be selected in the same way  
  if (mousePressed && mouseButton == LEFT && startPos != null) {

    picked2 = Ellipsoid.pickShape(this, mouseX, mouseY);

    if ( picked2 != null) {
      PVector pickedv2 = picked2.getPosVec();
      endPos = new PVector(pickedv2.x, pickedv2.y, pickedv2.z);
      println(endPos);
    }
  }


  if (startPos != null && endPos != null) {

    // if both objects are picked draw a tube from one to another    
    tubeNum++;
    pairNum++;

    // expand arrays
    tube = (Tube[]) expand(tube, tubeNum);     
    ellipsoidPair = (EllipsoidPair[]) expand(ellipsoidPair, pairNum);
    // define new tube and pair
    tube[tubeNum - 1] = new Tube(this, 30, 30);
    ellipsoidPair[pairNum - 1] = new EllipsoidPair();

    //draw tube
    tube[tubeNum - 1].setSize(10, 10, 10, 10);
    tube[tubeNum - 1].fill(color(11, 72, 107));
    tube[tubeNum - 1].setWorldPos(startPos, endPos);

    // add to pair list
    ellipsoidPair[pairNum - 1].ellipsoid1 = picked1;
    ellipsoidPair[pairNum - 1].ellipsoid2 = picked2;

    // empty the vectors
    startPos = null;
    endPos = null;
  }



  // to start a sound pulse, we pick a sphere with key q
  if ( keyPressed && key == ' ') {

    pickedS = Shape3D.pickShape(this, mouseX, mouseY);

    if ( pickedS != null) {


      timedPulseNum++;
      // expand pulse array, add new pulse
      timedPulse = (TimedPulse[]) expand(timedPulse, timedPulseNum);

      timedPulse[timedPulseNum - 1] = new TimedPulse(pickedS, oscP5, max, ellipsoidPair);
    }
  }


  // update period value and pairs on every array member
  for (int i = 0; i < timedPulse.length; i++)
    timedPulse[i].update(ellipsoidPair, (int)period.getController("period").getValue());

  // draw every tube and sphere member in draw rate
  for (int i = 0; i < tube.length; i++)
    tube[i].draw();

  for (int i = 0; i < ellipsoid.length; i++)
    ellipsoid[i].draw();

  popMatrix();

  // this is a function to detach UI element from camera movements
  gui();
}

// sphere colors
int randomColor() {
  float x;
  float x1 = random(255);
  if (x1<125)
    x = random(40, 70);
  else x = random(105, 255);

  return color(x, random(85, 110), random(140, 160));
}

// I found this as an online example to detach GUI elemnts from peasycam movement
void gui() {
  hint(DISABLE_DEPTH_TEST);
  pcam.beginHUD();
  period.draw();
  pcam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

