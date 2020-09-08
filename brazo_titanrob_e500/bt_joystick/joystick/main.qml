import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5

import Ros 1.0

ApplicationWindow {
    id: background
    visible: true
    width: joystick.width
    height: joystick.height + gripButton.height
    title: qsTr("Controller")

    property int i: 1

    Image {
        id: joystick

        property real angle : 0
        property real distance : 0

        source: "background.png"
        x: 0
        y: 0

        Rectangle {
            id: rect1
            width: 80
            height: 80
            x: joystick.width *0.5
            y: joystick.height * 0.5
            color: "transparent"

        }

        ParallelAnimation {
            id: returnAnimation
            NumberAnimation { target: thumb1.anchors; property: "horizontalCenterOffset";
                to: 0; duration: 200; easing.type: Easing.OutSine }
            NumberAnimation { target: thumb1.anchors; property: "verticalCenterOffset";
                to: 0; duration: 200; easing.type: Easing.OutSine }
            onFinished: joypose1.publish()
        }

        MouseArea {
            id: mouse
            property real fingerAngle : Math.atan2(mouseX, mouseY)
            property int mcx : mouseX - joystick.width * 0.5
            property int mcy : mouseY - joystick.height * 0.5
            property bool fingerInBounds : fingerDistance2 < distanceBound2
            property real fingerDistance2 : mcx * mcx + mcy * mcy
            property real distanceBound : joystick.width * 0.5 - thumb1.width * 0.5
            property real distanceBound2 : distanceBound * distanceBound

            property double signal_x : (mouseX - joystick.width/2) / distanceBound
            property double signal_y : -(mouseY - joystick.height/2) / distanceBound

            anchors.centerIn: parent
            width: thumb1.width
            height: thumb1.height

            onPressed: {
                returnAnimation.stop();
            }

            onReleased: {
                returnAnimation.restart();
            }

            onPositionChanged: {
                if (i == 1){
                    if (fingerInBounds) {
                        thumb1.anchors.horizontalCenterOffset = mcx
                        thumb1.anchors.verticalCenterOffset = mcy
                    } else {
                        var angle = Math.atan2(mcy, mcx)
                        thumb1.anchors.horizontalCenterOffset = Math.cos(angle) * distanceBound
                        thumb1.anchors.verticalCenterOffset = Math.sin(angle) * distanceBound
                    }

                    // Fire the signal to indicate the joystick has moved
                    angle = Math.atan2(signal_y, signal_x)

                    joypose1.publish();
                }

            }
        }

        Image {
            id: thumb1
            source: "joystick1.png"
            anchors.centerIn: parent

            Rectangle{
                id: joy1
                width: 40
                height: 40
                x: thumb1.width * 0.5
                y: thumb1.width * 0.5
                color: "transparent"

                RosPosePublisher{
                    id: joypose1
                    target: joy1
                    origin: rect1
                    frame: "joy_frame_1"
                    topic: "/joy_pose_1"
                }

            }

            ParallelAnimation {
                id: returnAnimation1
                NumberAnimation { target: thumb2.anchors; property: "horizontalCenterOffset";
                    to: 0; duration: 200; easing.type: Easing.OutSine }
                NumberAnimation { target: thumb2.anchors; property: "verticalCenterOffset";
                    to: 0; duration: 200; easing.type: Easing.OutSine }
                onFinished: joypose2.publish()
            }

            MouseArea {
                id: mouse2
                property real fingerAngle : Math.atan2(mouseX, mouseY)
                property int mcx : mouseX - thumb1.width * 0.5
                property int mcy : mouseY - thumb1.height * 0.5
                property bool fingerInBounds : fingerDistance2 < distanceBound2
                property real fingerDistance2 : mcx * mcx + mcy * mcy
                property real distanceBound : thumb1.width * 0.5 - thumb2.width * 0.5
                property real distanceBound2 : distanceBound * distanceBound

                property double signal_x : (mouseX - joystick.width/2) / distanceBound
                property double signal_y : -(mouseY - joystick.height/2) / distanceBound

                anchors.centerIn: parent
                width: thumb2.width
                height: thumb2.height

                onPressed: {
                    returnAnimation1.stop();
                    i == 2;
                }

                onReleased: {
                    returnAnimation1.restart();
                    i == 1;
                }

                onPositionChanged: {
                    if (fingerInBounds) {
                        thumb2.anchors.horizontalCenterOffset = mcx
                        thumb2.anchors.verticalCenterOffset = mcy
                    } else {
                        var angle = Math.atan2(mcy, mcx)
                        thumb2.anchors.horizontalCenterOffset = Math.cos(angle) * distanceBound
                        thumb2.anchors.verticalCenterOffset = Math.sin(angle) * distanceBound
                    }

                    // Fire the signal to indicate the joystick has moved
                    angle = Math.atan2(signal_y, signal_x)

                    joypose2.publish();

                }
            }

            Image {
                id: thumb2
                source: "joystick2.png"
                anchors.centerIn: thumb1

                Rectangle{
                    id: joy2
                    width: 20
                    height: 20
                    x: thumb2.width * 0.5 + 0.5
                    y: thumb2.width * 0.5 + 0.5
                    color: "transparent"

                    RosPosePublisher{
                        id: joypose2
                        target: joy2
                        origin: joy1
                        frame: "joy_pose_2"
                        topic: "/joy_pose_2"
                    }

                }
            }

        }

    }

    Button {
        id: gripButton
        y: parent.height-gripButton.height
        width: parent.width

        text: "Open/Close Grip"
        property int order: 1

        RosStringPublisher {
            id: gripPublisher
            topic: "/joy_pose_grip"
        }

        onPressed: {
            gripPublisher.text = gripButton.order
            gripButton.order = gripButton.order * -1

        }

    }

}
