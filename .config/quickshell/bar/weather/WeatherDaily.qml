import QtQuick
import QtQuick.Layouts
import "." as Weather   // WeatherData

import qs.theme

ColumnLayout {
    id: root

    property var dailyModel: Weather.WeatherData.daily
    property bool showTitle: true
    property int  titlePixelSize: 11
    property int  rowSpacing: 8

    spacing: 6
    Layout.fillWidth: true

    Text {
        visible: root.showTitle
        text: "日別予報"
        font.pixelSize: root.titlePixelSize
        font.bold: true
        color: ThemeGradient.textSecondary
    }

    Repeater {
        model: root.dailyModel ? root.dailyModel.length : 0

        delegate: RowLayout {
            id: dayRow
            required property int index
            readonly property var e: root.dailyModel[index]
            spacing: root.rowSpacing
            Layout.fillWidth: true

            Text {
                text: dayRow.e.day + " " + dayRow.e.date
                font.pixelSize: 10
                color: ThemeGradient.textSecondary
                Layout.preferredWidth: 55
            }

            Text {
                text: dayRow.e.icon
                font.pixelSize: 16
                font.family: "Symbols Nerd Font"
                color: ThemeGradient.light.mid
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: dayRow.e.pop + "%"
                font.pixelSize: 9
                color: ThemeGradient.light.end
                Layout.preferredWidth: 30
                horizontalAlignment: Text.AlignRight
            }

            // temp bar
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 14

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 4
                    radius: 2
                    color: ThemeGradient.bgSurface
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    height: 4
                    radius: 2
                    readonly property real lo: Math.max(0, (dayRow.e.tempMin + 10) / 50)
                    readonly property real hi: Math.min(1, (dayRow.e.tempMax + 10) / 50)
                    x: parent.width * lo
                    width: Math.max(4, parent.width * (hi - lo))
                    gradient: ThemeGradient.dark.horizontal
                }
            }

            Text {
                text: dayRow.e.tempMin + "°"
                font.pixelSize: 9
                color: ThemeGradient.light.end
                Layout.preferredWidth: 28
                horizontalAlignment: Text.AlignRight
            }

            Text {
                text: dayRow.e.tempMax + "°"
                font.pixelSize: 9
                color: ThemeGradient.dark.start
                Layout.preferredWidth: 28
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}

