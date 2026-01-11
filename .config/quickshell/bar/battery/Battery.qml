import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.theme

Item {
    id: root

    implicitWidth: 50
    implicitHeight: 60

    property bool showDrawer: false

    property int batteryPercent: 0
    property bool isCharging: false

    Process {
        id: capacityReader
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim(), 10);
                if (!isNaN(val)) root.batteryPercent = val;
            }
        }
    }

    Process {
        id: statusReader
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let s = data.trim().toLowerCase();
                root.isCharging = (s === "charging" || s === "full");
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            capacityReader.running = true;
            statusReader.running = true;
            profileReader.running = true;
        }
    }

    property string currentProfile: "balanced"

    Process {
        id: profileReader
        command: ["powerprofilesctl", "get"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                root.currentProfile = data.trim();
            }
        }
    }

    Process {
        id: profileSetter
        property string targetProfile: ""
        command: ["powerprofilesctl", "set", targetProfile]

        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0) {
                root.currentProfile = targetProfile;
            }
        }
    }

    function setProfile(profile) {
        profileSetter.targetProfile = profile;
        profileSetter.running = true;
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root.showDrawer = false;
            drawerPopup.visible = false;
        }
    }

    MouseArea {
        id: iconHoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: {
            closeTimer.stop();
            root.showDrawer = true;
            drawerPopup.visible = true;
        }
        onExited: {
            closeTimer.restart();
        }
    }

    BatteryIcon {
        anchors.fill: parent

        percent: root.batteryPercent
        charging: root.isCharging
        drawerOpen: root.showDrawer

        onHoverEntered: {
            closeTimer.stop();
            root.showDrawer = true;
            drawerPopup.visible = true;
        }
        onHoverExited: {
            closeTimer.restart();
        }
    }

    PopupWindow {
        id: drawerPopup
        visible: false
        color: "transparent"

        implicitWidth: 220
        implicitHeight: 330

        anchor {
            window: Window.window
            item: root
            rect.x: root.width
            rect.y: root.height - drawerPopup.height
        }

        MouseArea {
            id: popupHoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

        Rectangle {
            id: drawerBg
            anchors.fill: parent
            anchors.leftMargin: 3
            radius: 20
            color: ThemeGradient.bgCard

            opacity: 0
            scale: 0.92
            transformOrigin: Item.Left

            states: [
                State {
                    name: "open"
                    when: drawerPopup.visible
                    PropertyChanges {
                        target: drawerBg
                        opacity: 1
                        scale: 1.0
                    }
                }
            ]

            transitions: [
                Transition {
                    to: "open"
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                },
                Transition {
                    from: "open"
                    to: ""
                    ParallelAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: 150
                            easing.type: Easing.InCubic
                        }
                        NumberAnimation {
                            property: "scale"
                            duration: 180
                            easing.type: Easing.InCubic
                        }
                    }
                }
            ]

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: root.batteryPercent + "%"
                        color: ThemeGradient.textPrimary
                        font.pixelSize: 22
                        font.bold: true
                        font.family: "Monospace"
                    }

                    Text {
                        text: root.isCharging ? "Charging" : "Discharging"
                        color: root.isCharging ? ThemeGradient.light.start : ThemeGradient.textSecondary
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 2
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: ThemeGradient.bgSurface

                    Rectangle {
                        width: parent.width * (root.batteryPercent / 100.0)
                        height: parent.height
                        radius: 3
                        gradient: ThemeGradient.light.horizontal

                        Behavior on width {
                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // Sep
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    color: ThemeGradient.bgSurface
                }

                PowerProfileSelector {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    currentProfile: root.currentProfile

                    onProfileSelected: function(profile) {
                        root.setProfile(profile);
                    }
                }
            }
        }
    }
}
