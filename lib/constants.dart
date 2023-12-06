const double bluetoothButtonsPadding = 72;

enum ActionSignal {
  ledOn,
  ledOff,
  goForward,
  goBackward,
  turnRight,
  turnLeft,
  nonExistent,
}

const Map<ActionSignal, String> actionSignals = {
  ActionSignal.ledOn: "LED ON;",
  ActionSignal.ledOff: "LED OFF;",
  ActionSignal.goForward: "GO FORWARD;",
  ActionSignal.goBackward: "GO BACKWARD;",
  ActionSignal.turnLeft: "TURN LEFT;",
  ActionSignal.turnRight: "TURN RIGHT;",
  ActionSignal.nonExistent: "SIGNAL DOES NOT EXIST;"
};