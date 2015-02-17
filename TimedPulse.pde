// import libraries

import oscP5.*;
import netP5.*;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;




class TimedPulse {
  
// within the class we will form a constructor which will handle
// getting information of selected object ('ball' in this case)
// the pulse cycle (timer & timerBlink), selecting valid pairs (ellipsoidPair), 
// sending sounds to max(oscP5 & max),


  OscMessage pulse;
  Shape3D ball;
  Timer timer;
  Timer timerBlink;
  OscP5 oscP5;
  NetAddress max;
  int c;
  int time;
  EllipsoidPair[] ellipsoidPair;


  // constructor sends rgb values of selected spheres to max, and repeats it periodically
  TimedPulse(Shape3D shape, OscP5 inputOsc, NetAddress inputMax, EllipsoidPair[] inputPair) {

    ellipsoidPair = inputPair;
    oscP5 = inputOsc;
    max = inputMax;
    ball = shape;
//    time = 1000;
    
   

// get the shape's color information
    c = ball.fill();
    float r = red(c);
    float g = green(c);
    float b = blue(c);


    println(red(c), green(c), blue(c));
    
// construct a message with color information ready to send to max
    pulse = new OscMessage("/snd");
    pulse.add(r);
    pulse.add(g);
    pulse.add(b);

    timerFinished();
  }


// update function runs in the main sketch's draw()
  void update(EllipsoidPair[] inputPair, int inputTime) { 

    // checking new pairs and any change in the UI
    ellipsoidPair = inputPair;
    time = inputTime;
    if (timer.isFinished()) {

      timerFinished();
    }

    // each pulse is visualized with a blink which starts and restarts with 'timer'
    if (timerBlink != null && timerBlink.isFinished()) {
      timerBlink = null;
      ball.fill(c);

    
      chooseNextBall();
    }
  }

// after the blink, we search for pairs which contain the current shape
  void chooseNextBall() {

// start with zero
    int possibleNum = 0;
    Shape3D[] possibleEllipsoid = new Shape3D[possibleNum];

    for (int i = 0; i < ellipsoidPair.length; i++) {

      EllipsoidPair current = ellipsoidPair[i]; 

// if the shape has a pair:
      if ( current.ellipsoid1 == ball) {
        
        //expand the array and include new pair
        possibleNum++;
        possibleEllipsoid = (Shape3D[]) expand(possibleEllipsoid, possibleNum);

        possibleEllipsoid[possibleNum -1] = current.ellipsoid2;
      }
      
// same thing repeated here, for ellipsoid2
      if ( current.ellipsoid2 == ball) {
        possibleNum++;
        possibleEllipsoid = (Shape3D[]) expand(possibleEllipsoid, possibleNum);

        possibleEllipsoid[possibleNum -1] = current.ellipsoid1;
      }
    }
    
// check valid pairs  
    if (possibleNum > 0) {
      
     // randomly select one destination
      int p = (int) random(possibleNum);
      ball = possibleEllipsoid[p];

     // get color information from new detination 
      c = ball.fill();
      float r = red(c);
      float g = green(c);
      float b = blue(c);

      // prepare to send it to max when timer begins
      pulse = new OscMessage("/snd");
      pulse.add(r);
      pulse.add(g);
      pulse.add(b);
    }
  }

  void timerFinished() {

    oscP5.send(pulse, max);
// white color when blinking
    ball.fill(255);
    //println(ball);

// restart timers
    timer = new Timer(time);
    timer.start();

// you may have notices the blinking time is seperate and one tenth the amount of pulse period
    timerBlink = new Timer(time/100);
    timerBlink.start();
  }

 
}

