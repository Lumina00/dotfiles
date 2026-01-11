import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import qs.theme

Item {
    id: root

    property string currentProfile: "balanced"

    signal profileSelected(string profile)

    readonly property var profiles: [
        { key: "power-saver",   label: "Power saver",  icon: "leaf",   desc: "バッテリーの持ちを優先" },
        { key: "balanced",      label: "Balanced",  icon: "scale",  desc: "性能と電力のバランス" },
        { key: "performance",   label: "Performance",  icon: "bolt",   desc: "最高のパフォーマンス" }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Title
        Text {
            text: "Power profiles"
            color: ThemeGradient.light.start
            font.pixelSize: 14
            font.bold: true
            Layout.bottomMargin: 2
        }

        // Power profiles btn
        Repeater {
            model: root.profiles

            Rectangle {
                id: profileBtn
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                radius: 12

                property bool isActive: root.currentProfile === modelData.key
                property bool isHovered: btnMouse.containsMouse

                color: {
                    if (isActive) return ThemeGradient.bgSurface;
                    if (isHovered) return Qt.darker(ThemeGradient.bgSurface, 1.3);
                    return "transparent";
                }

                border.color: isActive ? ThemeGradient.dark.start : "transparent"
                border.width: isActive ? 1.5 : 0

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.profileSelected(modelData.key)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    // icon bg radius
                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 14
                        gradient: profileBtn.isActive ? ThemeGradient.dark.iconBg : null
                        color: profileBtn.isActive ? "transparent" : "transparent"

                        Shape {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            layer.enabled: true
                            layer.samples: 4

                            ShapePath {
                                strokeColor: profileBtn.isActive ? ThemeGradient.light.mid : ThemeGradient.textSecondary
                                strokeWidth: 1.8
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                joinStyle: ShapePath.RoundJoin

                                PathMove {
                                    x: modelData.icon === "leaf" ? 3 :
                                       modelData.icon === "scale" ? 10 : 8
                                    y: modelData.icon === "leaf" ? 17 :
                                       modelData.icon === "scale" ? 2 : 1
                                }
                                PathLine {
                                    x: modelData.icon === "leaf" ? 10 :
                                       modelData.icon === "scale" ? 10 : 5
                                    y: modelData.icon === "leaf" ? 3 :
                                       modelData.icon === "scale" ? 6 : 8
                                }
                                PathLine {
                                    x: modelData.icon === "leaf" ? 17 :
                                       modelData.icon === "scale" ? 2 : 10
                                    y: modelData.icon === "leaf" ? 3 :
                                       modelData.icon === "scale" ? 10 : 8
                                }
                                PathLine {
                                    x: modelData.icon === "leaf" ? 10 :
                                       modelData.icon === "scale" ? 18 : 15
                                    y: modelData.icon === "leaf" ? 17 :
                                       modelData.icon === "scale" ? 10 : 8
                                }
                                PathLine {
                                    x: modelData.icon === "leaf" ? 3 :
                                       modelData.icon === "scale" ? 10 : 12
                                    y: modelData.icon === "leaf" ? 17 :
                                       modelData.icon === "scale" ? 14 : 1
                                }
                            }
                        }
                    }

                    // Text
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: modelData.label
                            color: profileBtn.isActive ? ThemeGradient.light.start : ThemeGradient.textSecondary
                            font.pixelSize: 13
                            font.bold: profileBtn.isActive
                        }
                        Text {
                            text: modelData.desc
                            color: ThemeGradient.textSecondary
                            font.pixelSize: 10
                            opacity: 0.7
                        }
                    }

                    // Active dot
                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: ThemeGradient.dark.mid
                        visible: profileBtn.isActive
                    }
                }
            }
        }
    }
}
