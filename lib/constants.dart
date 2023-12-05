const double directionIconSize = 112;  // size of the "go direction" icon
const double turnsOffset = 96;  // "size of the smaller SizedBox to offset the "turn left/right" buttons
//  TODO: set both to percentage values of the screen width

enum ActionSignal {
  ledOn,
  ledOff,
  goForward,
  goBackward,
  turnRight,
  turnLeft,
}

const Map<ActionSignal, String> actionSignals = {
  ActionSignal.ledOn: "LED ON;",
  ActionSignal.ledOff: "LED OFF;",
  ActionSignal.goForward: "GO FORWARD;",
  ActionSignal.goBackward: "GO BACKWARD;",
  ActionSignal.turnLeft: "TURN LEFT",
  ActionSignal.turnRight: "TURN RIGHT;",
};