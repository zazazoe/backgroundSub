import ch.bildspur.realsense.*;
import java.awt.Rectangle;
import gab.opencv.*;
import controlP5.*;

ControlP5 cp5;

RealSenseCamera camera = new RealSenseCamera(this);
ArrayList<Contour> contours;
boolean displayContours = false;

PImage background, contoursImage;
boolean isBackgroundSave;
OpenCV opencv;
int threshold=0;
int blobSizeThreshold=0;

void setup()
{
  size(480, 270); 
  frameRate(30);
  // width, height, fps, depth-stream, color-stream
  camera.start(480, 270, 30, true, false);
  opencv = new OpenCV(this, 480, 270);
  isBackgroundSave = false;
  
  cp5 = new ControlP5(this);
  cp5.addSlider("threshold")
     .setRange(0, 200)
     .setValue(10)
     .setPosition(20, 20)
     .setSize(100, 10)
     ;
  cp5.addSlider("blobSizeThreshold")
     .setRange(0, 200)
     .setValue(5)
     .setPosition(20, 40)
     .setSize(100, 10)
     ;
}

void draw()
{
  background(0);
  if(camera.isCameraAvailable()){
    
    // read frames
    camera.readFrames();
    camera.createDepthImage(0, 2500);
    opencv.loadImage(camera.getDepthImage());

    //currentImage = camera.getDepthImage();
    // show color image
     //<>//
    if(isBackgroundSave)
    {
      //opencv.diff(currentImage); //<>//
      //opencv.blur(10);
      opencv.diff(background);
      opencv.threshold(threshold);
      //opencv.dilate();
      // opencv.erode();
      
      image(opencv.getSnapshot(), 0, 0);
      contours();
      //image(background, 0, 0);
      text("inside",10,10);
    }
    else
    {
      image(opencv.getSnapshot(), 0, 0);
     // contours();
    }
  }
}

void keyPressed()
{
  if(key=='a'){
    //opencv.blur(10);
    //opencv.dilate();
    //opencv.erode();
    opencv = new OpenCV(this, 480, 270);
    opencv.loadImage(camera.getDepthImage());
    background = opencv.getSnapshot();
    isBackgroundSave = true;
    println("background set");
  }
  
  if(key=='s'){
    if(isBackgroundSave){
      background.save("BGcapture.jpg");
    }
  }
}


void contours(){
  contours = opencv.findContours(true, true);
  
  // Save snapshot for display
  contoursImage = opencv.getSnapshot();
  
  // Draw
  displayContours();
  displayContoursBoundingBoxes();
}

void displayContours() {
  for (int i=0; i<contours.size(); i++) {
    Contour contour = contours.get(i);
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    contour.draw();
  }
}

void displayContoursBoundingBoxes() {
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if (//(contour.area() > 0.9 * src.width * src.height) ||
        (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;
    
    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    rect(r.x, r.y, r.width, r.height);
    fill(255, 255, 0);
    ellipse(r.x+(r.width/2), r.y+(r.height/2), 10,10);
  }
}
