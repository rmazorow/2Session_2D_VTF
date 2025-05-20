/* TactorGlove.pde
 *
 * This code allows serial port command processing for the 12 channel Tactor Glove
 * Based onL http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1251426835
 *
 * R. Scheidt PhD
 * 03/31/12
 * Adapted by Alexis Krueger
 * 01/08/15
 */
 
 // Maybe change to add ability to send 4 values in a row (all nums, x+ x- y+ y- respectively)

#define MAX_COMMAND_LEN             (10)
#define MAX_PARAMETER_LEN           (10)
#define MAX_LOOP_COUNT              (1000)
#define MAX_TACTOR_VALUE            (200)

//In ms

#define NUM_TACTORS 4

int Tctr[NUM_TACTORS] = {6,7,11,10};  /* Define Pins {3,5,6,9} */
char* TctrAlias[NUM_TACTORS] = {"XP","XN","YP","YN"}; /* Pin Names */

char gParam1Buffer[MAX_PARAMETER_LEN + 1];
char gParam2Buffer[MAX_PARAMETER_LEN + 1];
char gParam3Buffer[MAX_PARAMETER_LEN + 1];
char gParam4Buffer[MAX_PARAMETER_LEN + 1];
long gParam1Value;
long gParam2Value;
long gParam3Value;
long gParam4Value;
long gLoopCounter;
long gParam1Value_old;
long gParam2Value_old;
long gParam3Value_old;
long gParam4Value_old;

long oldTime;
long newTime;

typedef struct {
  char const    *name;
  void          (*function)(void);
} command_t;
 
/**********************************************************************
 * Function:    cliBuildCommand
 * Description: Put received characters into the command buffer or the
 *              parameter buffer. Once a complete command is received
 *              return true.
 * Notes:       
 * Returns:     true if a command is complete, otherwise false.
 **********************************************************************/
int cliBuildCommand(char nextChar) {
  static uint8_t Parm1Indx = 0; //index for parameter buffer
  static uint8_t Parm2Indx = 0; //index for parameter buffer
  static uint8_t Parm3Indx = 0; //index for parameter buffer
  static uint8_t Parm4Indx = 0; //index for parameter buffer
  enum { PARAM1, PARAM2, PARAM3, PARAM4};
  static uint8_t state = PARAM1;
  
  if ((nextChar == '\n') || (nextChar == ' ') || (nextChar == '\t') || (nextChar == '\r'))  /* Don't store any new line characters or spaces. */
    return false;

  if (nextChar == ';') { /* The completed command has been received. */
    gParam1Buffer[Parm1Indx] = '\0';
    gParam2Buffer[Parm2Indx] = '\0';
    gParam3Buffer[Parm3Indx] = '\0';
    gParam4Buffer[Parm4Indx] = '\0';
    Parm1Indx = 0; Parm2Indx = 0; Parm3Indx = 0; Parm4Indx = 0;
    state = PARAM1;
    return true;
  }

  if (nextChar == ',') {
    if (state == PARAM1){
      state = PARAM2;
      return false;
    }
    else if (state == PARAM2){
      state = PARAM3;
      return false;
    }
    else if (state == PARAM3){
      state = PARAM4;
      return false;
    }
  }

  if (state == PARAM1) {
    gParam1Buffer[Parm1Indx] = nextChar;    /* Store the received character in the parameter buffer. */
    Parm1Indx++;
    if (Parm1Indx > MAX_PARAMETER_LEN) {     /* If the command is too long, reset the index and process the current parameter buffer. */
      Parm1Indx = 0;
      return true;
    }
  }
  if (state == PARAM2) {
    gParam2Buffer[Parm2Indx] = nextChar;    /* Store the received character in the parameter buffer. */
    Parm2Indx++;
    if (Parm2Indx > MAX_PARAMETER_LEN) {     /* If the command is too long, reset the index and process the current parameter buffer. */
      Parm2Indx = 0;
      return true;
    }
  }
  if (state == PARAM3) {
    gParam3Buffer[Parm3Indx] = nextChar;    /* Store the received character in the parameter buffer. */
    Parm3Indx++;
    if (Parm3Indx > MAX_PARAMETER_LEN) {     /* If the command is too long, reset the index and process the current parameter buffer. */
      Parm3Indx = 0;
      return true;
    }
  }
  if (state == PARAM4) {
    gParam4Buffer[Parm4Indx] = nextChar;    /* Store the received character in the parameter buffer. */
    Parm4Indx++;
    if (Parm4Indx > MAX_PARAMETER_LEN) {     /* If the command is too long, reset the index and process the current parameter buffer. */
      Parm4Indx = 0;
      return true;
    }
  }
  return false;
}


/**********************************************************************
 * Function:    commandSetFour
 * Description: This 
 *              this.
 * Notes:       
 * Returns:     None.
 **********************************************************************/
void setFour(void) {
  
  gParam1Value = strtol(gParam1Buffer, NULL, 0);  /* Convert the parameter to an integer value.  If the parameter is empty, gParamValue becomes 0. */
  gParam2Value = strtol(gParam2Buffer, NULL, 0);  /* Convert the parameter to an integer value.  If the parameter is empty, gParamValue becomes 0. */
  gParam3Value = strtol(gParam3Buffer, NULL, 0);  /* Convert the parameter to an integer value.  If the parameter is empty, gParamValue becomes 0. */
  gParam4Value = strtol(gParam4Buffer, NULL, 0);  /* Convert the parameter to an integer value.  If the parameter is empty, gParamValue becomes 0. */    
   gParam1Value = scaleValue(gParam1Value);
   gParam2Value = scaleValue(gParam2Value);
   gParam3Value = scaleValue(gParam3Value);
   gParam4Value = scaleValue(gParam4Value);
    analogWrite(Tctr[0], gParam1Value);
    analogWrite(Tctr[1], gParam2Value);
    analogWrite(Tctr[2], gParam3Value);
    analogWrite(Tctr[3], gParam4Value);
}


// Converts from percentage to tactor range (linearly)
int scaleValue(int val){
  
  // Range tactors is 40-255  
  // For input of percent, use around offset = 40, scale = 2.15
  
  int scale = 1;
  int offset = 0;
  
  if(val > 0){
    val = (int)(val)*scale + offset;
  }
  if(val > 255){
    val = 255;
  }
  //if(val < 50){
    //val = 50;
  //}
  return val;
  
}


void setup() {
  int idx;
  Serial.begin(115200);
  for (idx=0; idx<NUM_TACTORS; idx++)
  {
    pinMode(Tctr[idx], OUTPUT);   // sets the pin as output
  }
  oldTime=0;
  newTime=0;
  gLoopCounter=0;
}

void loop() {
  char rcvChar;
  int  bCommandReady = false;
  int  idx;
  char finalChar;
  static int TactorLoopIdx = 0;

  if (Serial.available() > 0) {
    rcvChar = Serial.read();    /* Wait for a character. */
    finalChar = rcvChar;
    bCommandReady = cliBuildCommand(finalChar);    /* Build a new command. */
    oldTime=newTime;
  }

  if (bCommandReady == true) {  /* Call the CLI command processing routine to verify the command entered */
    bCommandReady = false;      /* and call the command function; then output a new prompt. */
    setFour();
  }
}

