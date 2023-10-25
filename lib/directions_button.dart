import "package:flutter/material.dart";
import "constants.dart";

class RobotActionButton extends StatefulWidget {
  const RobotActionButton({
    super.key, 
    required this.isActive,
    required this.buttonType,
    required this.onPressCallback});
  
  final bool isActive;
  final ButtonType buttonType;
  final Function(ButtonType) onPressCallback;

  @override
  State<RobotActionButton> createState() => _RobotActionButtonState();
}

class _RobotActionButtonState extends State<RobotActionButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            // Color when the button is pressed
            return Colors.green; // Change this to the desired color
          }
          return Colors.transparent; // Use the default color when not pressed
        }),
      ),

      isSelected: widget.isActive,
      onPressed: () {
        widget.onPressCallback(widget.buttonType);
      },
      icon: Transform.scale(
        scaleX: widget.buttonType.scaleX,
        scaleY: widget.buttonType.scaleY,
        child: ImageIcon(
          widget.buttonType.iconAsset
        ),
      ),
      iconSize: directionIconSize,
      tooltip: "Move forward",
      );
  }
}


enum ButtonType {
  up(scaleX: 1, scaleY: -1, tooltip: "Move forward", iconAsset:AssetImage('assets/images/down-arrow.png')),
  down(scaleX: 1, scaleY: 1, tooltip: "Move back", iconAsset:AssetImage('assets/images/down-arrow.png')),
  left(scaleX: -0.8, scaleY: -0.8, tooltip: "Turn left", iconAsset:AssetImage('assets/images/curved-arrow.png')),
  right(scaleX: 0.8, scaleY: -0.8, tooltip: "Turn right", iconAsset:AssetImage('assets/images/curved-arrow.png')),
  none(scaleX: 0, scaleY: 0, tooltip: "This button should not exist", iconAsset:AssetImage('assets/images/eeror.png'));

  const ButtonType({
    required this.scaleX,
    required this.scaleY,
    required this.tooltip,
    required this.iconAsset,
  });

  final double scaleX;
  final double scaleY;
  final String tooltip;
  final AssetImage iconAsset;
}

// TODO: clicking a button should send stop signal to the robot, 
//to stop the movement it is currently in and then send next
//signal to change type of movement to the desired one.

class SteeringButtons extends StatefulWidget {
  const SteeringButtons({super.key});

  @override
  State<SteeringButtons> createState() => _SteeringButtonsState();
}

class _SteeringButtonsState extends State<SteeringButtons> {
  ButtonType activeButton = ButtonType.none;

  void handleButtonTap(ButtonType buttonType) {
    if (buttonType == activeButton) {
      setState(() {
        activeButton = ButtonType.none;
      });
    } else {
      setState(() {
        activeButton = buttonType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  buttonType: ButtonType.left,
                  isActive: activeButton == ButtonType.left,
                  onPressCallback: handleButtonTap,),
                const SizedBox(height: turnsOffset,),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  buttonType: ButtonType.up,
                  isActive: activeButton == ButtonType.up,
                  onPressCallback: handleButtonTap,),
                const SizedBox(height: directionIconSize,),
                RobotActionButton(
                  buttonType: ButtonType.down,
                  isActive: activeButton == ButtonType.down,
                  onPressCallback: handleButtonTap,),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  buttonType: ButtonType.right,
                  isActive: activeButton == ButtonType.right,
                  onPressCallback: handleButtonTap,),
                const SizedBox(height: turnsOffset,),
              ],
            ),
          ],
        );
  }
}