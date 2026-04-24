import QtQuick
import QtQuick.Layouts
import "." as Weather

import qs.theme
ColumnLayout {
    spacing: 6
    Layout.fillWidth: true

    Text {
        text: "時間別予報"
        font.pixelSize: 11
        font.bold: true
        color: ThemeGradient.textSecondary
    }

    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: 74
        contentWidth: _hRow.implicitWidth
        clip: true
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id: _hRow
            spacing: 14

            Repeater {
                model: Weather.WeatherData.hourly.length

                // ★ Column(ColumnLayout ❌) + width
                delegate: Column {
                    id: hourCell
                    required property int index
                    readonly property var e: Weather.WeatherData.hourly[index]
                    width: 40
                    spacing: 3

                    Text {
                        width: parent.width
                        text: hourCell.e.time
                        font.pixelSize: 9
                        color: ThemeGradient.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: parent.width
                        text: hourCell.e.icon
                        font.pixelSize: 18
                        font.family: "Symbols Nerd Font"
                        color: ThemeGradient.light.mid
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: parent.width
                        text: hourCell.e.temp + "°"
                        font.pixelSize: 10
                        font.bold: true
                        color: ThemeGradient.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: parent.width
                        text: hourCell.e.pop + "%"
                        font.pixelSize: 8
                        color: ThemeGradient.light.end
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
