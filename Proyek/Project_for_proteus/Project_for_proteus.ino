//Define Library
#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include <Servo.h>
#include <math.h>

LiquidCrystal_I2C lcd(0x20, 16, 2);  // set the LCD address to 0x27 for a 16 chars and 2 line display

//Analog pin input
const int sensor_temp = A0;   //the analog pin the TMP36's Vout (sense) pin is connected to
                              //the resolution is 10 mV / degree centigrade with a
                              //500 mV offset to allow for negative temperaturess
const int sensor_soil = A2;   //the analog pin the FC-28 Vout
const int sensor_light = A3;  //the analog pin the LDR Vout

//Digital pin output
#define servo_water 3
#define led_water 4
#define led_light 5
#define led_temphigh 6
#define led_normal 7
#define relay 8
#define buzzer 9

// Create a new servo object:
Servo myservo;
// Create a variable to store the servo position:
int angle = 0;

// Create char for LCD
char text_kelompok[] = "Kelompok: 1     "; //an array to print on line 0
char nama1[] = "Gesha M.C.      "; //an array to print on line 1
char nama2[] = "Yonathan L.     ";
char nama3[] = "Umar A. A.      ";

void setup()
{
  myservo.attach(servo_water);
  Serial.begin(9600);  //Start the serial connection with the computer
                       //to view the result open the serial monitor
  
  //initialize pin
  pinMode(led_water, OUTPUT);
  pinMode(led_light, OUTPUT);
  pinMode(led_temphigh, OUTPUT);
  pinMode(led_normal, OUTPUT);
  pinMode(buzzer, OUTPUT);
  pinMode(relay, OUTPUT);

  //initialize output pin
  digitalWrite(led_water, HIGH);
  digitalWrite(led_light, HIGH);
  digitalWrite(led_temphigh, HIGH);
  digitalWrite(led_normal, HIGH);
  digitalWrite(relay, LOW);
  noTone(buzzer);
  myservo.write(0);

  // initialize the lcd
  lcd.init();
  lcd.backlight();
  lcd.begin(16, 2);  //16 = Baris, 2 = kolom
  lcd.setCursor(0,0); //set cursor at top left
  lcd.print(text_kelompok);//will only print the first letter of the array
  delay(500);

  //Display opening animation
  lcd.setCursor(0, 1);
  for ( int positionCounter = 0; positionCounter < 16; positionCounter++)
  {
    lcd.print(nama1[positionCounter]); //prints a 17 character array without scrolling
    delay(150);
  }
  lcd.setCursor(0, 1);
  for ( int positionCounter = 0; positionCounter < 16; positionCounter++)
  {
    lcd.print(nama2[positionCounter]); //prints a 17 character array without scrolling
    delay(150);
  }
  lcd.setCursor(0, 1);
  for ( int positionCounter = 0; positionCounter < 16; positionCounter++)
  {
    lcd.print(nama3[positionCounter]); //prints a 17 character array without scrolling
    delay(150);
  }
  delay(500);
  lcd.clear();  //Clears the LCD screen and positions the cursor in the upper-left corner.

  //display project tittle
  lcd.setCursor(5,0);
  lcd.print("Smart");
  lcd.setCursor(2,1);
  lcd.print("Green House");
  delay(3000);
  lcd.clear();
}

void normal ()
{
  digitalWrite(led_normal, LOW);
  digitalWrite(led_water, HIGH);
  digitalWrite(led_light, HIGH);
  digitalWrite(led_temphigh, HIGH);
  noTone(buzzer);
  digitalWrite(relay, LOW);
  myservo.write(0);
}

float read_temperature (void)
{
 //temp sensor reading
 int reading_temp = analogRead(sensor_temp);
 float voltage_temp = reading_temp * 5.0;    //using 3.3v arduino
 voltage_temp /= 1024.0; 
 float temperature = (voltage_temp - 0.5) * 100 ;  //converting from 10 mv per degree wit 500 mV offset
                                                   //to degrees ((voltage - 500mV) times 100)
 
 lcd.setCursor(0,0);
 lcd.print(temperature);
 lcd.setCursor(5,0);
 lcd.print((char)223);
 lcd.setCursor(6,0);
 lcd.print("C");
 return(temperature);
}

int read_soil_moist()
{
 //Soil moisture sensor reading
 int reading_soil= analogRead(sensor_soil); //Read analog sensor value
 int soil = map(reading_soil,550,250,0,100); //wet: 550, dry: 50, mapping= 0-100%

 lcd.setCursor(8,0);
 lcd.print(soil);
 lcd.setCursor(11,0);
 lcd.print("%");
 return(soil);
}

int read_brightness()
{
 int light= analogRead(sensor_light);   //low: 200

 lcd.setCursor(13,0);
 lcd.print(light);
 return(light);

}

void mode_normal()
{
  if (digitalRead(led_normal) == HIGH)
    {
      tone(buzzer, 1000); 
      delay(250);
      noTone(buzzer);
      delay(250);
      tone(buzzer, 1000);
      delay(250);
      noTone(buzzer);
      tone(buzzer, 1000); 
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_water_on()
{
  if (digitalRead(led_water) == HIGH)
    {
      lcd.setCursor(0,1);
      lcd.print(""); // buat clear
      lcd.print("  Mengisi Air   ");
      tone(buzzer, 630); 
      delay(250);
      tone(buzzer, 800);
      delay(250);
      tone(buzzer, 750);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_water_off()
{
  if (digitalRead(led_water) == LOW)
    {
      lcd.setCursor(0,1);
      lcd.print("");
      lcd.print("   Air Cukup   ");
      tone(buzzer, 698); 
      delay(250);
      tone(buzzer, 830);
      delay(250);
      tone(buzzer, 783);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_light_on()
{
  if (digitalRead(led_light) == HIGH)
    {
      lcd.setCursor(0,1);
      lcd.print("");
      lcd.print("  Lampu Nyala   ");
      tone(buzzer, 1000); 
      delay(250);
      tone(buzzer, 600);
      delay(250);
      tone(buzzer, 1000);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_light_off()
{
  if (digitalRead(led_light) == LOW)
    {
      lcd.setCursor(0,1);
      lcd.print("");
      lcd.print(" Cahaya Cukup  ");
      tone(buzzer, 987); 
      delay(250);
      tone(buzzer, 783);
      delay(250);
      tone(buzzer, 880);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_temp_high()
{
  if (digitalRead(led_temphigh) == HIGH)
    {
      lcd.setCursor(0,1);
      lcd.print("");
      lcd.print("Suhu Tinggi...! ");
      tone(buzzer, 900); 
      delay(250);
      tone(buzzer, 600);
      delay(250);
      tone(buzzer, 800);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void mode_temp_ok()
{
  if (digitalRead(led_temphigh) == LOW)
    {
      lcd.setCursor(0,1);
      lcd.print("");
      lcd.print("  Suhu Cukup   ");
      tone(buzzer, 698); 
      delay(250);
      tone(buzzer, 1396);
      delay(250);
      tone(buzzer, 880);
      delay(250);
      noTone(buzzer);     
    } 
    else 
    {
      noTone(buzzer);
    }
}

void loop()
{
lcd.clear();

int soil = read_soil_moist();
int light = read_brightness();
float temperature = read_temperature();

  if (soil >= 40 && light >= 300 && temperature <= 30)          //normal
  {
    lcd.setCursor(0,1);
    lcd.print("");
    lcd.print("     NORMAL     ");
    mode_normal();
    normal();
    delay(1500);
  }
  else 
  {
    digitalWrite(led_normal, HIGH);
    if (soil < 40)
    {
      mode_water_on();
      myservo.write(90);
      digitalWrite(led_water, LOW);
      delay(1500);
    }
    else 
    {
      myservo.write(0);
      mode_water_off();
      digitalWrite(led_water, HIGH);
      delay(1500);
    }
    
    if (light < 300)
    {
      mode_light_on();
      digitalWrite(relay, HIGH);
      digitalWrite(led_light, LOW);
      delay(1500);
    }
    else 
    {
      mode_light_off();
      digitalWrite(led_light, HIGH);
      digitalWrite(relay, LOW);
      delay(1500);
    }

    if (temperature > 30)
    {
      mode_temp_high();
      digitalWrite(led_temphigh, LOW);
      delay(1500);
    }
    else 
    { 
      mode_temp_ok();
      digitalWrite(led_temphigh, HIGH);
      delay(1500);
    }
  }
  delay(1000); 
}
