import QtQuick
import Quickshell.Io
import Qt5Compat.GraphicalEffects

import qs.theme

Item {
    id: root
    width: 22
    height: 60

    property real brightness: 0.5
    property int maxBrightness: 100

    Process {
        id: getBrightness
        command: ["brightnessctl", "get"]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                var current = parseInt(line.trim());
                if (!isNaN(current)) {
                    root.brightness = current / root.maxBrightness;
                }
            }
        }
    }

    Process {
        id: getMaxBrightness
        command: ["brightnessctl", "max"]
        running: true

        stdout: SplitParser {
            onRead: (line) => {
                var val = parseInt(line.trim());
                if (!isNaN(val) && val > 0) {
                    root.maxBrightness = val;
                    getBrightness.running = true;
                }
            }
        }
    }

    Process {
        id: setBrightness
        command: ["brightnessctl", "set", Math.round(root.brightness * root.maxBrightness).toString()]
    }

    // Sync 3s
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: getBrightness.running = true
    }

    // ── pill mask ──
    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: width / 2
        visible: false
    }

    // ── bg + gauge ──
    Rectangle {
        id: container
        anchors.fill: parent
        color: ThemeGradient.bgCard

        // pill gauge
        Item {
            id: fillClip
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * root.brightness
            clip: true

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }

            Rectangle {
                width: container.width
                height: container.height
                anchors.bottom: parent.bottom
                gradient: ThemeGradient.light.vertical
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskRect
        }
    }

    // icon + text 
    Column {
        anchors.centerIn: parent
        spacing: 3
        z: 10

        // radius icon bg
        Rectangle {
            width: 18
            height: 18
            radius: 9
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: ThemeGradient.dark.iconBg

            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Symbols Nerd Font"
                font.pixelSize: 11
                color: ThemeGradient.textPrimary

                text: {
					if (root.brightness < 0.15) return "󰃞";
                    if (root.brightness < 0.4) return "󰃝";
                    if (root.brightness < 0.7) return "󰃟";
                    return "󰃠";
                }
            }
        }

        // brightness perc
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(root.brightness * 100)
            font.pixelSize: 9
            font.bold: true
            color: ThemeGradient.textSecondary
        }
    }

    // ── mouse action ──
    MouseArea {
        anchors.fill: parent

        onWheel: (wheel) => {
            var delta = wheel.angleDelta.y > 0 ? 0.02 : -0.02;
            var newVal = root.brightness + delta;
            if (newVal > 1.0) newVal = 1.0;
            if (newVal < 0.0) newVal = 0.0;

            root.brightness = newVal;
            setBrightness.running = true;
        }
    }
}
