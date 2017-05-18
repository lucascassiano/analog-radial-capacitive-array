import org.gicentre.utils.stat.*;
// Displays a simple line chart representing a time series.

import processing.serial.*;
import controlP5.*;

ControlP5 cp5;

Serial myPort = null;  // Create object from Serial class
String portName = "/dev/cu.usbmodem1411"; //For OSX or Linux

int lf = 10;    // Linefeed in ASCII
String receivedString = null;

//UI Elements

DropdownList d_port, d_speed;
int cnt = 0;
String devs[];
Chart chart0, chart1, chart2, chart3, chart4, chart5;

PImage background;
PImage background_arrows;
PImage s0, s1, s2, s3, s4, s5;
PImage legend_1;
PImage image_iso;

color colorLow = color(0, 0, 255);
color colorHigh = color(255, 0, 0);

float val0, val1, val2, val3, val4, val5;
float max = 800;
float min = 0;
String label_s0, label_s1, label_s2, label_s3, label_s4, label_s5;


void setup() {
  size(1400, 800);
  //fullScreen();
  cp5 = new ControlP5(this);

  // List all the available serial ports
  printArray(Serial.list());

  //Init Charts
  int yCharts = 110;
  int xCharts = 780;
  chart0 = cp5.addChart("chart0").setPosition(xCharts, yCharts).setLabel("SENSOR 0");
  chart1 = cp5.addChart("chart1").setPosition(xCharts, yCharts +100).setLabel("SENSOR 1");
  chart2 = cp5.addChart("chart2").setPosition(xCharts, yCharts +200).setLabel("SENSOR 2");
  chart3 = cp5.addChart("chart3").setPosition(xCharts, yCharts+300).setLabel("SENSOR 3");
  chart4 = cp5.addChart("chart4").setPosition(xCharts, yCharts+400).setLabel("SENSOR 4");
  chart5 = cp5.addChart("chart5").setPosition(xCharts, yCharts+500).setLabel("SENSOR 5");

  customizeChart(chart0);
  customizeChart(chart1);
  customizeChart(chart2);
  customizeChart(chart3);
  customizeChart(chart4);
  customizeChart(chart5);

  background = loadImage("img/BACKGROUND.png");
  background_arrows = loadImage("img/BACKGROUND_arrows.png");
  image_iso = loadImage("img/image_iso.png");

  s0 = loadImage("img/S0.png");
  s1 = loadImage("img/S1.png");
  s2 = loadImage("img/S2.png");
  s3 = loadImage("img/S3.png");
  s4 = loadImage("img/S4.png");
  s5 = loadImage("img/S5.png");

  label_s0 = "null";
  label_s1 = "null";
  label_s2 = "null";
  label_s3 = "null";
  label_s4 = "null";
  label_s5 = "null";

  val0 = 0;
  val1 = 0;
  val2 = 0;
  val3 = 0;
  val4 = 0;
  val5 = 0;

  legend_1 = loadImage("img/Legend_1.png");

  Connect();
}

int imgSize = 800;

void draw() {
  background(0);
  image(background, 0, 0, imgSize, imgSize);
  image(background_arrows, 0, 0, imgSize, imgSize);
  //image(image_iso, 400, 200);
  textAlign(LEFT);
  textSize(24);
  text("Capacitance Tomography", 20, 30);
  textSize(14);
  text("MIT - Media Lab - Spring 2017", 20, 50);

  DrawSensor(s0, val0);
  DrawSensor(s1, val1);
  DrawSensor(s2, val2);
  DrawSensor(s3, val3);
  DrawSensor(s4, val4);
  DrawSensor(s5, val5);
  image(legend_1, 0, height- 210, 100, 210);

  //Label _ red_to_blue
  textAlign(LEFT);
  textSize(14);
  text("+4V", 75, 615);
  text("0V", 75, 785);
  // println(mouseX + ", "+ mouseY);

  //Labels Arrows
  /*Sensors arrows positions _ pixels
   s0 460, 80
   s1 700, 240
   s2 700, 555
   s3 350, 690
   s4 115, 555
   s5 97, 240
   */
  textSize(14);
  textAlign(LEFT);
  text(label_s0, 460, 80);
  text(label_s1, 700, 240);
  text(label_s2, 695, 555);
  textAlign(RIGHT);
  text(label_s3, 353, 697);
  text(label_s4, 115, 555);
  text(label_s5, 97, 240);
  textAlign(LEFT);
  //Data INPUT
  if (myPort!=null)
    text("Connected: "+portName, 780, 20);
  else
    text("NO Connection", 780, 12);
  if (receivedString!=null)
    text("[" + hour() + ":" + minute() + ":" + second()+"] | " + receivedString, 780, 40 );
  //Read Data
  if (myPort!=null)
    ReadDevice();
}


void customizeChart(Chart chart) {
  //Init Charts
  chart.setSize(600, 80)
    .setRange(min, max)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(15)
    .setColorCaptionLabel(color(40))
    .setColorLabel(color(255)) 
    .setColorBackground(color(30, 30, 30))
    .setColorActive(color(255, 255, 255))

    ;

  chart.addDataSet("incoming");
  chart.setData("incoming", new float[100]);
}

void DrawSensor(PImage s, float value) {
  color interA = lerpColor(colorLow, colorHigh, value);
  tint(red(interA), green(interA), blue(interA));
  image(s, 0, 0, imgSize, imgSize);
  noTint();
}

void DrawSensor(PImage s, int r, int g, int b) {
  tint(r, g, b);
  image(s, 0, 0, imgSize, imgSize);
  noTint();
}

void Connect() {
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, portName, 115200);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  receivedString = myPort.readStringUntil(lf);
  receivedString = null;
}


void ReadDevice() {
  while (myPort.available() > 0) {
    receivedString = myPort.readStringUntil(lf);
    if (receivedString != null) {
      try {
        println(receivedString);
        int[] sensors = int(split(receivedString, ','));
        chart0.push("incoming", sensors[0]);
        chart1.push("incoming", sensors[1]);
        chart2.push("incoming", sensors[2]);
        chart3.push("incoming", sensors[3]);
        chart4.push("incoming", sensors[4]);
        chart5.push("incoming", sensors[5]);
        val0 = map(float(sensors[0]), min, max, 0.0, 1.0);
        val1 = map(float(sensors[1]), min, max, 0.0, 1.0);
        val2 = map(float(sensors[2]), min, max, 0.0, 1.0);
        val3 = map(float(sensors[3]), min, max, 0.0, 1.0);
        val4 = map(float(sensors[4]), min, max, 0.0, 1.0);
        val5 = map(float(sensors[5]), min, max, 0.0, 1.0);
        println(sensors[5]);
        //Labels
        label_s0 = "#S0: "+nf(val0*5, 1, 2)+" V";
        label_s1 = "#S1: "+nf(val1*5, 1, 2)+" V";
        label_s2 = "#S2: "+nf(val2*5, 1, 2)+" V";
        label_s3 = "#S3: "+nf(val3*5, 1, 2)+" V";
        label_s4 = "#S4: "+nf(val4*5, 1, 2)+" V";
        label_s5 = "#S5: "+nf(val5*5, 1, 2)+" V";
      } 
      catch (Exception e) {
        //e.printStackTrace();
        //line = null;
        println("ERROR READING SERIAL...");
      }
    }
  }
}


void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    int selected = (int) theEvent.getController().getValue();
    portName = devs[selected];
    Connect();
  }
}

//float map(float x, float in_min, float in_max, float out_min, float out_max)