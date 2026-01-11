import Quickshell
import QtQuick
import QtQuick.Layouts

import "timedate"
import "mpris"
import "battery"
import "weather"
import "network"
import "notifications"
import "bluetooth"

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            property var modelData
			screen: modelData

			signal barClicked()

            anchors {
                left: true
                top: true
                bottom: true
            }

            color: "#e01e1e2e"

			implicitWidth: 55


			MouseArea {
       			anchors.fill: parent
        		z: -1
        		onClicked: panel.barClicked()
    		}

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Top

                Notifications {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    //barWidth: sidebar.width
                    Layout.alignment: Qt.AlignHCenter
                }
                WorkspaceWidget {
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    Layout.topMargin: 5
                }

                // middle
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }


                MprisWidget {
                    id: mpris
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    parentWindow: panel
                }

                // bottom
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

				SystemTrayIcon {
    				Layout.alignment: Qt.AlignHCenter
					Layout.preferredWidth: 36
    				Layout.preferredHeight: implicitHeight
    				parentWindow: panel
				}

                WeatherWidget {
                    Layout.alignment: Qt.AlignHCenter
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4

                    Brightness {
                        id: brightnessWidget
                    }

                    Volume {
                        id: volumeWidget
                    	parentWindow: panel
                    }
                }

                BluetoothWidget {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    parentWindow: panel
                }

                NetworkWidget {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    parentWindow: panel
                }

                Battery {
                    id: batteryWidget
                    Layout.alignment: Qt.AlignHCenter
                }

                TimeWidget {
                    Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }
}
