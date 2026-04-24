import QtQuick
import QtQuick.Layouts
import "." as Weather

import qs.theme

RowLayout {
    spacing: 10
    Layout.fillWidth: true

    Text {
        text: Weather.WeatherData.icon
        font.pixelSize: 36
        font.family: "Symbols Nerd Font"
        color: ThemeGradient.light.mid
    }

    ColumnLayout {
        spacing: 2
        Text {
            text: Weather.WeatherData.temp
            font.pixelSize: 22
            font.bold: true
            color: ThemeGradient.textPrimary
        }
        Text {
            text: Weather.WeatherData.desc
            font.pixelSize: 11
            color: ThemeGradient.textSecondary
        }
    }

    Item { Layout.fillWidth: true }

    ColumnLayout {
        spacing: 2
        Text {
            text: "体感温度 " + Weather.WeatherData.feels + "℃"
            font.pixelSize: 10
            color: ThemeGradient.textSecondary
        }
        Text {
            text: "湿度 " + Weather.WeatherData.humidity + "%"
            font.pixelSize: 10
            color: ThemeGradient.textSecondary
        }
        Text {
            text: "風速 " + Weather.WeatherData.wind + "m/s"
            font.pixelSize: 10
            color: ThemeGradient.textSecondary
        }
    }
}
