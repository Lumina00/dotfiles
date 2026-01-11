import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import qs.theme 

Rectangle {
    id: root

    property int percent: 100
    property bool charging: false
    property bool drawerOpen: false

    signal hoverEntered()
    signal hoverExited()

    radius: 25
    color: "transparent"

    readonly property color _levelColor: {
        if (root.charging) return ThemeGradient.dark.start;
        if (root.percent <= 15) return ThemeGradient.light.end;
        if (root.percent <= 30) return ThemeGradient.light.mid;
		if (root.percent == 100) return ThemeGradient.dark.end;
        return ThemeGradient.light.start;
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: root.hoverEntered()
        onExited: root.hoverExited()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 4

        // BAT icon
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 24
            Layout.preferredHeight: 32

            // BAT main 
            Rectangle {
                id: batteryBody
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 20
                height: 26
                radius: 4
                color: "transparent"
                border.color: ThemeGradient.light.mid
                border.width: 1.5

                // BAT progress bar
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3
                    height: Math.max(2, (parent.height - 6) * (root.percent / 100.0))
                    radius: 2
                    color: root._levelColor

                    Behavior on height {
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
            }

            // BAT Top
            Rectangle {
                anchors.bottom: batteryBody.top
                anchors.bottomMargin: -1
                anchors.horizontalCenter: parent.horizontalCenter
                width: 8
                height: 4
                radius: 2
                color: ThemeGradient.light.mid
            }

            // BAT charing icon
            Shape {
                anchors.centerIn: batteryBody
                width: 12
                height: 16
                visible: root.charging
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeColor: "transparent"
                    fillColor: ThemeGradient.bgDark

                    PathMove { x: 7; y: 0 }
                    PathLine { x: 2; y: 9 }
                    PathLine { x: 6; y: 9 }
                    PathLine { x: 5; y: 16 }
                    PathLine { x: 10; y: 7 }
                    PathLine { x: 6; y: 7 }
                    PathLine { x: 7; y: 0 }
                }
            }
        }

        // view perc
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.percent + "%"
            color: root._levelColor
            font.family: "Proxima Nova"
            font.pixelSize: 10
            font.bold: true
        }
    }
}
