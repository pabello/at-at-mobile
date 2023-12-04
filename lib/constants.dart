const double directionIconSize = 112;  // size of the "go direction" icon
const double turnsOffset = 96;  // "size of the smaller SizedBox to offset the "turn left/right" buttons
//  TODO: set both to percentage values of the screen width

enum RobotAction {
  ledOn,
  ledOff,
  goForward,
  goBackward,
  turnRight,
  turnLeft,
}

const Map<RobotAction, String> actionMessages = {
  RobotAction.ledOn: "LED ON;",
  RobotAction.ledOff: "LED OFF;",
  RobotAction.goForward: "GO FORWARD;",
  RobotAction.goBackward: "GO BACKWARD;",
  RobotAction.turnLeft: "TURN LEFT",
  RobotAction.turnRight: "TURN RIGHT;",
};