import "dart:developer";

import "package:at_at_mobile/constants.dart";
import "package:at_at_mobile/provider/bluetooth_state.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class RobotActionButton extends StatefulWidget {
  const RobotActionButton({
    super.key, 
    required this.iconSize,
    required this.isActive,
    required this.buttonType,
    required this.onPressCallback});
  
  final double iconSize;
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
      onPressed: Provider.of<MyBluetoothState>(context).isConnected ? () {
        if (widget.isActive) {
          widget.onPressCallback(ButtonType.stop);
        } else {
          widget.onPressCallback(widget.buttonType);
        }
      } : null,
      icon: Transform.scale(
        scaleX: widget.buttonType.scaleX,
        scaleY: widget.buttonType.scaleY,
        child: ImageIcon(
          widget.buttonType.iconAsset
        ),
      ),
      iconSize: widget.iconSize,
      tooltip: widget.buttonType.tooltip,
      );
  }
}


enum ButtonType {
  up(
    scaleX: 1,
    scaleY: -1,
    tooltip: "Move forward",
    actionSignal: ActionSignal.goForward,
    iconAsset:AssetImage('assets/images/down-arrow.png')
  ),
  down(
    scaleX: 1,
    scaleY: 1,
    tooltip: "Move back",
    actionSignal: ActionSignal.goBackward,
    iconAsset:AssetImage('assets/images/down-arrow.png')),
  left(
    scaleX: -0.8,
    scaleY: -0.8,
    tooltip: "Turn left",
    actionSignal: ActionSignal.turnLeft,
    iconAsset:AssetImage('assets/images/curved-arrow.png')),
  right(
    scaleX: 0.8,
    scaleY: -0.8,
    tooltip: "Turn right",
    actionSignal: ActionSignal.turnRight,
    iconAsset:AssetImage('assets/images/curved-arrow.png')),
  stop(
    scaleX: 0,
    scaleY: 0,
    tooltip: "Stop moving",
    actionSignal: ActionSignal.stop,
    iconAsset:AssetImage('')),
  none(
    scaleX: 0,
    scaleY: 0,
    tooltip: "This button should not exist",
    actionSignal: ActionSignal.nonExistent,
    iconAsset:AssetImage('assets/images/eeror.png'));

  const ButtonType({
    required this.scaleX,
    required this.scaleY,
    required this.tooltip,
    required this.iconAsset,
    required this.actionSignal,
  });

  final double scaleX;
  final double scaleY;
  final String tooltip;
  final AssetImage iconAsset;
  final ActionSignal actionSignal;
}

// TODO: clicking a button should send stop signal to the robot, 
// to stop the movement it is currently in and then send next
// signal to change type of movement to the desired one.

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
        log("Turning off button state");
        activeButton = ButtonType.none;
      });
    } else {
      Provider.of<MyBluetoothState>(context, listen: false).sendMovementSignal(buttonType.actionSignal);
      setState(() {
        activeButton = buttonType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double directionIconSize = screenWidth / 4;
    double turnsOffset = screenWidth / 5;

    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  iconSize: directionIconSize,
                  buttonType: ButtonType.left,
                  isActive: activeButton == ButtonType.left,
                  onPressCallback: handleButtonTap,),
                SizedBox(height: turnsOffset,),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  iconSize: directionIconSize,
                  buttonType: ButtonType.up,
                  isActive: activeButton == ButtonType.up,
                  onPressCallback: handleButtonTap,),
                SizedBox(height: directionIconSize,),
                RobotActionButton(
                  iconSize: directionIconSize,
                  buttonType: ButtonType.down,
                  isActive: activeButton == ButtonType.down,
                  onPressCallback: handleButtonTap,),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RobotActionButton(
                  iconSize: directionIconSize,
                  buttonType: ButtonType.right,
                  isActive: activeButton == ButtonType.right,
                  onPressCallback: handleButtonTap,),
                SizedBox(height: turnsOffset,),
              ],
            ),
          ],
        );
  }
}