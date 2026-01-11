import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.theme

Item {
    id: root
    width: 40
    height: 40

    required property var parentWindow

    readonly property bool hasConnected: Bluetooth.devices.count > 0
    readonly property bool adapterEnabled: Bluetooth.defaultAdapter
                                           ? Bluetooth.defaultAdapter.enabled
                                           : false

    readonly property color _inactiveBg:    "#14FFFFFF"  // rgba(255,255,255,0.08)
    readonly property color _borderColor:   "#4DD06CC0"  // dark.start @ 0.3
    readonly property color _separatorColor:"#14FFFFFF"  // rgba(255,255,255,0.08)
    readonly property color _badgeOnColor:  "#334CAF50"  // rgba(76,175,80,0.2)
    readonly property color _badgeOffColor: "#1AFFFFFF"  // rgba(255,255,255,0.1)

    function deviceIcon(iconName: string): string {
        if (iconName.indexOf("audio-head") !== -1) return "󰋋";
        if (iconName.indexOf("input-keyboard") !== -1) return "󰌌";
        if (iconName.indexOf("input-mouse") !== -1) return "󰍽";
        if (iconName.indexOf("input-gaming") !== -1) return "󰊖";
        if (iconName.indexOf("phone") !== -1) return "󰏲";
        if (iconName.indexOf("computer") !== -1) return "󰌢";
        return "";
    }

    function batteryIcon(level: real): string {
        if (level > 0.9) return "󰁹";
        if (level > 0.7) return "󰂁";
        if (level > 0.5) return "󰁿";
        if (level > 0.3) return "󰁽";
        if (level > 0.1) return "󰁻";
        return "󰂎";
    }

    function batteryColor(level: real): color {
        if (level > 0.5) return ThemeGradient.light.start;
        if (level > 0.2) return "#FFA726";
        return "#EF5350";
    }

	//bar icon
    Rectangle {
        id: iconBg
        anchors.centerIn: parent
        width: 36; height: 36; radius: 18
        gradient: root.hasConnected ? ThemeGradient.dark.iconBg : null
        color: root.hasConnected ? "transparent" : root._inactiveBg

        Text {
            anchors.centerIn: parent
            text: root.adapterEnabled ? "󰂱" : "󰂲"
            font { pixelSize: 25; family: "Material Design Icons" }
            color: root.hasConnected
                   ? ThemeGradient.light.mid
                   : ThemeGradient.textSecondary
        }

        Rectangle {
            visible: root.hasConnected
            width: 6; height: 6; radius: 3
            color: "#4CAF50"
            anchors {
                right: parent.right; bottom: parent.bottom
                rightMargin: 2; bottomMargin: 2
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                hideTimer.stop();
                hoverTimer.restart();
            } else {
                hoverTimer.stop();
                hideTimer.restart();
            }
        }
    }

    Timer {
        id: hoverTimer; interval: 300
        onTriggered: {
            if (hoverArea.containsMouse) {
                popupLoader.active = true;
                popupLoader.item.visible = true;
            }
        }
    }

    Timer {
        id: hideTimer; interval: 200
        onTriggered: {
            if (!hoverArea.containsMouse
                && (!popupLoader.item || !popupLoader.item.hovered)) {
                if (popupLoader.item) popupLoader.item.visible = false;
            }
        }
    }

	//popup
    LazyLoader {
        id: popupLoader
        loading: true

        PopupWindow {
            id: popup
            visible: false

            property bool hovered: popupHover.containsMouse

            anchor {
                item: root
                edges: Edges.Right
                gravity: Edges.Right
                adjustment: PopupAdjustment.SlideY
                margins.left: 6
            }

            implicitWidth: popupColumn.implicitWidth + 24
            implicitHeight: popupColumn.implicitHeight + 24
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: ThemeGradient.bgCard
                border { width: 1; color: root._borderColor }

                MouseArea {
                    id: popupHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        if (containsMouse) hideTimer.stop();
                        else hideTimer.restart();
                    }
                }

                ColumnLayout {
                    id: popupColumn
                    anchors { fill: parent; margins: 12 }
                    spacing: 8

					// header
                    RowLayout {
                        spacing: 6
                        Text {
                            text: root.adapterEnabled ? "" : "󰂲"
                            font { pixelSize: 14; family: "Material Design Icons" }
                            color: ThemeGradient.light.mid
                        }
                        Text {
                            text: "Bluetooth"
                            font { pixelSize: 13; family: "Proxima Nova"; bold: true }
                            color: ThemeGradient.textPrimary
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            width: statusText.implicitWidth + 12
                            height: 20; radius: 10
                            color: root.adapterEnabled
                                   ? root._badgeOnColor : root._badgeOffColor
                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: !Bluetooth.defaultAdapter
                                      ? "bug"
                                      : root.adapterEnabled ? "ON" : "OFF"
                                font { pixelSize: 10; family: "Proxima Nova" }
                                color: root.adapterEnabled
                                       ? "#4CAF50" : ThemeGradient.textSecondary
                            }
                        }
                    }

					// Sep
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1; color: root._separatorColor
                    }

					//list devices
                    Repeater {
                        model: Bluetooth.devices

                        delegate: RowLayout {
                            id: deviceDelegate
                            Layout.fillWidth: true
                            spacing: 8

                            required property var modelData

                            // delegate local cache
                            readonly property string devName:
                                modelData.name || modelData.address
                            readonly property string devIcon: modelData.icon
                            readonly property bool   devConnected: modelData.connected
                            readonly property bool   devHasBattery: modelData.batteryAvailable
                            readonly property real   devBattery: modelData.battery

                            // icon
                            Rectangle {
                                width: 28; height: 28; radius: 14
                                gradient: ThemeGradient.dark.iconBg
                                Text {
                                    anchors.centerIn: parent
                                    text: root.deviceIcon(deviceDelegate.devIcon)
                                    font { pixelSize: 14; family: "Material Design Icons" }
                                    color: ThemeGradient.light.start
                                }
                            }

                            // name + status
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: deviceDelegate.devName
                                    font { pixelSize: 12; family: "Proxima Nova"; bold: true }
                                    color: ThemeGradient.textPrimary
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 150
                                }
                                Text {
                                    text: deviceDelegate.devConnected ? "Connected" : "Disconnected"
                                    font { pixelSize: 10; family: "Proxima Nova" }
                                    color: deviceDelegate.devConnected
                                           ? "#4CAF50" : ThemeGradient.textSecondary
                                }
                            }

                            // battery info
                            RowLayout {
                                visible: deviceDelegate.devHasBattery
                                spacing: 4
                                Text {
                                    text: root.batteryIcon(deviceDelegate.devBattery)
                                    font { pixelSize: 14; family: "Material Design Icons" }
                                    color: root.batteryColor(deviceDelegate.devBattery)
                                }
                                Text {
                                    text: Math.round(deviceDelegate.devBattery * 100) + "%"
                                    font { pixelSize: 11; family: "Proxima Nova" }
                                    color: ThemeGradient.textSecondary
                                }
                            }
                        }
                    }

                    // ── blank list ──
                    Text {
                        visible: Bluetooth.devices.count === 0
                        text: "No devices"
                        font { pixelSize: 11; family: "Proxima Nova" }
                        color: ThemeGradient.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4; Layout.bottomMargin: 4
                    }
                }
            }
        }
    }
}
