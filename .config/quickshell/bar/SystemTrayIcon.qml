// SystemTrayWidget.qml
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.theme

ListView {
    id: trayList
    orientation: ListView.Vertical
    spacing: 4
    model: SystemTray.items
    implicitHeight: contentHeight
    implicitWidth: 36
    interactive: false

    required property var parentWindow

    property var activePopup: null

    function closeActive() {
        if (activePopup) {
            activePopup.visible = false
            activePopup = null
        }
    }

    Component.onCompleted: {
        if (parentWindow && parentWindow.barClicked) {
            parentWindow.barClicked.connect(closeActive)
        }
    }

    delegate: Item {
        id: trayItem
        width: 36
        height: 36

        required property var modelData

        visible: trayItem.modelData.status !== Status.Passive

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: mouseArea.containsMouse
                ? Qt.rgba(ThemeGradient.dark.start.r, ThemeGradient.dark.start.g, ThemeGradient.dark.start.b, 0.3)
                : "transparent"
        }

        Image {
            anchors.centerIn: parent
            width: 20
            height: 20
            source: trayItem.modelData.icon
            sourceSize: Qt.size(20, 20)
            fillMode: Image.PreserveAspectFit
        }

        QsMenuOpener {
            id: menuOpener
            menu: trayItem.modelData.menu
        }

        PopupWindow {
            id: menuPopup
            anchor.window: trayList.parentWindow
            anchor.rect.x: trayList.parentWindow.implicitWidth + 4
            anchor.rect.y: trayItem.mapToItem(null, 0, 0).y
            color: "transparent"
            implicitWidth: 200
            implicitHeight: menuColumn.implicitHeight + 16
            visible: false

            onVisibleChanged: {
                if (!visible && trayList.activePopup === menuPopup) {
                    trayList.activePopup = null
                }
            }

            Rectangle {
                anchors.fill: parent
                color: ThemeGradient.bgCard
                radius: 10
                border.width: 1
                border.color: Qt.rgba(ThemeGradient.dark.start.r, ThemeGradient.dark.start.g, ThemeGradient.dark.start.b, 0.3)
            }

            Column {
                id: menuColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                spacing: 2

                Repeater {
                    model: menuOpener.children

                    delegate: Item {
                        id: menuEntry

                        required property var modelData

                        readonly property bool isSep: modelData.isSeparator === true

                        width: menuColumn.width
                        height: isSep ? 11 : 32

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: entryMouse.containsMouse && !menuEntry.isSep
                                ? Qt.rgba(ThemeGradient.dark.mid.r, ThemeGradient.dark.mid.g, ThemeGradient.dark.mid.b, 0.25)
                                : "transparent"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            text: menuEntry.isSep ? "" : (menuEntry.modelData.text || "")
                            color: entryMouse.containsMouse
                                ? ThemeGradient.light.start
                                : ThemeGradient.textPrimary
                            font.pixelSize: 13
                            visible: !menuEntry.isSep
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - 16
                            height: 1
                            color: ThemeGradient.bgSurface
                            visible: menuEntry.isSep
                        }

                        MouseArea {
                            id: entryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !menuEntry.isSep

                            onClicked: {
                                if (typeof menuEntry.modelData.activate === "function") {
                                    menuEntry.modelData.activate()
                                } else if (typeof menuEntry.modelData.trigger === "function") {
                                    menuEntry.modelData.trigger()
                                }
                                menuPopup.visible = false
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    trayList.closeActive()
                    trayItem.modelData.activate()
                } else if (mouse.button === Qt.RightButton) {
                    if (trayItem.modelData.hasMenu) {
                        if (trayList.activePopup === menuPopup) {
                            trayList.closeActive()
                        } else {
                            trayList.closeActive()
                            menuPopup.visible = true
                            trayList.activePopup = menuPopup
                        }
                    }
                } else if (mouse.button === Qt.MiddleButton) {
                    trayList.closeActive()
                    trayItem.modelData.secondaryActivate()
                }
            }
        }
    }
}
