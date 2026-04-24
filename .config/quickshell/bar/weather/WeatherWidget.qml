import Quickshell
import QtQuick
import QtQuick.Layouts
import "." as Weather

import qs.theme

Item {
    id: root

    implicitWidth: 50
    implicitHeight: 60

    property bool _open: false

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root._open = false
            _popup.visible = false
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: {
            closeTimer.stop()
            root._open = true
            _popup.visible = true
        }
        onExited: closeTimer.restart()
    }

    Rectangle {
        width: 50
        height: 60
        radius: 25
        anchors.horizontalCenter: parent.horizontalCenter

        color: "transparent"
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            visible: root._open
            gradient: ThemeGradient.dark.iconBg
        }

            Text {
				id: iconText
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.topMargin: 8
				text: Weather.WeatherData.icon
				font.pixelSize: 26
				font.family: "Symbols Nerd Font"
				color: ThemeGradient.light.mid
				horizontalAlignment: Text.AlignHCenter
				leftPadding: 15
            }
            Text {
				id: tempText
				width: parent.width
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 8
				text: Weather.WeatherData.temp
				font.pixelSize: 12
				font.bold: true
				color: ThemeGradient.textPrimary
				horizontalAlignment: Text.AlignHCenter
            }
        }

    PopupWindow {
        id: _popup
        visible: false
        color: "transparent"

        implicitWidth: 320
        implicitHeight: 420

        anchor {
            window: Window.window
            item: root
            rect.x: root.width
            rect.y: root.height - _popup.height
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

        Rectangle {
            id: _bg
            anchors.fill: parent
            anchors.leftMargin: 3
            radius: 20
            color: ThemeGradient.bgCard
            opacity: 0
            scale: 0.92
            transformOrigin: Item.Left

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: ThemeGradient.glow
                opacity: 0.6
            }

            states: State {
                name: "open"
                when: _popup.visible
                PropertyChanges { target: _bg; opacity: 1; scale: 1.0 }
            }

            transitions: [
                Transition {
                    to: "open"
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.OutCubic }
                        NumberAnimation { property: "scale";   duration: 250; easing.type: Easing.OutCubic }
                    }
                },
                Transition {
                    from: "open"; to: ""
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InCubic }
                        NumberAnimation { property: "scale";   duration: 180; easing.type: Easing.InCubic }
                    }
                }
            ]

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentHeight: _col.implicitHeight
                clip: true

                ColumnLayout {
                    id: _col
                    width: parent.width
                    spacing: 12

                    WeatherCurrent {}

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: ThemeGradient.bgSurface
                    }

                    WeatherHourly {}

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: ThemeGradient.bgSurface
                    }

                    WeatherDaily {}
                }
            }
        }
    }
}

