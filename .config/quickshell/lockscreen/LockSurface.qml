import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../bar/timedate"
import "../bar/notifications"

Rectangle {
    id: root
    required property LockContext context

    readonly property color colBg: "#2B2030"
    readonly property color colAccent: "#F0D0E8"
    readonly property color colHighlight: "#55405D"
    readonly property color colDim: "#887090"
    readonly property color colRain: "#88B0D0"
    readonly property color colError: "#E06070"

    color: "#14101A"

    Image {
        id: wallpaperImg
        anchors.fill: parent
        source: Qt.resolvedUrl("../wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }

    MultiEffect {
        anchors.fill: wallpaperImg
        source: wallpaperImg
        blurEnabled: true
        blurMax: 64
        blur: 1.0
        brightness: -0.15
        saturation: -0.2
    }

    Rectangle {
        anchors.fill: parent
        color: "#60000000"
    }

    // Clock
    property date currentDate: new Date()
    Timer {
        running: true; repeat: true; interval: 1000
        onTriggered: root.currentDate = new Date()
    }

    property string wIcon: ""
    property string wTemp: ""
    property string wDesc: ""
    property real   wFeels: 0
    property int    wHumidity: 0
    property real   wWind: 0
    property var    wHourly: []

    // weather.rb 스크립트 경로 (bar/weather/ 기준)
    readonly property string weatherScript: Qt.resolvedUrl("../bar/weather/weather.rb").toString().replace("file://", "")

    function parseWeather(line) {
        try {
            var d = JSON.parse(line)
            var c = d.current
            root.wIcon     = c.icon  || ""
            root.wTemp     = c.temp + "℃"
            root.wDesc     = c.desc  || ""
            root.wFeels    = c.feels || 0
            root.wHumidity = c.humidity || 0
            root.wWind     = c.wind  || 0
            root.wHourly   = d.hourly || []
        } catch(e) {
            console.warn("Weather parse error:", e)
        }
    }

    // 캐시가 900초 이내면 cat, 아니면 ruby 스크립트 재실행
    Process {
        id: weatherProc
        command: ["sh", "-c",
            "CACHE=/tmp/weather_full.json; " +
            "if [ -f \"$CACHE\" ] && " +
                "[ $(( $(date +%s) - $(stat -c %Y \"$CACHE\") )) -lt 900 ]; then " +
                "cat \"$CACHE\"; " +
            "else " +
                "ruby '" + root.weatherScript + "'; " +
            "fi"
        ]
        running: true

        stdout: SplitParser {
            onRead: function(line) { root.parseWeather(line) }
        }

        onExited: function(exitCode, exitStatus) {
            weatherRefreshTimer.start()
        }
    }

    Component.onCompleted: weatherProc.running = true

    Timer {
        id: weatherRefreshTimer
        interval: 900000
        repeat: true
        onTriggered: weatherProc.running = true
    }

    // main content
    Item {
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 820)
        height: Math.min(parent.height - 60, 700)

        ColumnLayout {
            anchors.fill: parent
            spacing: 16

            // Clock & date
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        let h = root.currentDate.getHours().toString().padStart(2, '0')
                        let m = root.currentDate.getMinutes().toString().padStart(2, '0')
                        return h + ":" + m
                    }
                    color: root.colAccent
                    font.family: "Proxima Nova"
                    font.pixelSize: 56
                    font.weight: Font.Bold
                    renderType: Text.NativeRendering
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentDate, "dddd, MMMM dd")
                    color: root.colDim
                    font.pixelSize: 14
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1.1
                    radius: 20
                    color: root.colBg

                    NotificationCenter {
                        anchors.fill: parent
                        colBg: root.colBg
                        colAccent: root.colAccent
                        colHighlight: root.colHighlight
                        colDim: root.colDim
                        notifCount: 0
                        onClearAll: { }
                        onDismissNotification: (index) => { }
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.minimumHeight: 350
                        Layout.preferredHeight: 370
                        radius: 20
                        color: root.colBg

                        Calendar {
                            anchors.fill: parent
                            colBg: "transparent"
                            colAccent: root.colAccent
                            colHighlight: root.colHighlight
                            colDim: root.colDim
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 110
                        Layout.maximumHeight: 150
                        radius: 20
                        color: root.colBg

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                spacing: 10
                                Layout.fillWidth: true

                                Text {
                                    text: root.wIcon
                                    font.pixelSize: 32
                                    font.family: "Symbols Nerd Font"
                                    color: root.colAccent
                                }
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: root.wTemp || "--"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: root.colAccent
                                    }
                                    Text {
                                        text: root.wDesc
                                        font.pixelSize: 11
                                        color: root.colDim
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "体感温度 " + root.wFeels + "℃"
                                        font.pixelSize: 10
                                        color: root.colDim
                                    }
                                    Text {
                                        text: "湿度 " + root.wHumidity + "%"
                                        font.pixelSize: 10
                                        color: root.colDim
                                    }
                                    Text {
                                        text: "風速 " + root.wWind + "m/s"
                                        font.pixelSize: 10
                                        color: root.colDim
                                    }
                                }
                            }

                            // Sep
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.colHighlight
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: hourlyRow.implicitWidth
                                clip: true
                                flickableDirection: Flickable.HorizontalFlick

                                Row {
                                    id: hourlyRow
                                    spacing: 14

                                    Repeater {
                                        model: root.wHourly.length
                                        delegate: ColumnLayout {
                                            required property int index
                                            property var entry: root.wHourly[index]
                                            spacing: 3

                                            Text {
                                                text: entry ? entry.time : ""
                                                font.pixelSize: 9
                                                color: root.colDim
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: entry ? entry.icon : ""
                                                font.pixelSize: 18
                                                font.family: "Symbols Nerd Font"
                                                color: root.colAccent
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: entry ? Math.round(entry.temp) + "°" : ""
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: root.colAccent
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            Text {
                                                text: entry ? Math.round(entry.pop) + "%" : ""
                                                font.pixelSize: 8
                                                color: root.colRain
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // password box
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Shape {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 18
                        Layout.alignment: Qt.AlignVCenter
                        layer.enabled: true
                        layer.samples: 4
                        ShapePath {
                            strokeColor: root.colDim
                            strokeWidth: 1.5
                            fillColor: "transparent"
                            capStyle: ShapePath.RoundCap
                            joinStyle: ShapePath.RoundJoin
                            PathMove { x: 2; y: 8 }
                            PathLine { x: 14; y: 8 }
                            PathLine { x: 14; y: 17 }
                            PathLine { x: 2; y: 17 }
                            PathLine { x: 2; y: 8 }
                            PathMove { x: 4; y: 8 }
                            PathLine { x: 4; y: 5 }
                            PathArc { x: 12; y: 5; radiusX: 4; radiusY: 4 }
                            PathLine { x: 12; y: 8 }
                        }
                    }

                    TextField {
                        id: passwordBox
                        implicitWidth: 280
                        padding: 10

                        focus: true
                        enabled: !root.context.unlockInProgress
                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData
                        placeholderText: root.context.unlockInProgress ? "Authenticating..." : "Input Password"

                        background: Rectangle {
                            radius: 20
                            color: root.colHighlight
                            border.color: root.context.showFailure ? root.colError
                                : (passwordBox.activeFocus ? root.colAccent : root.colDim)
                            border.width: 1.5
                        }

                        color: root.colAccent
                        placeholderTextColor: root.colDim
                        font.pixelSize: 14

                        onTextChanged: root.context.currentText = this.text
                        onAccepted: root.context.tryUnlock()

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                passwordBox.text = root.context.currentText
                            }
                        }
                    }

                    Button {
                        text: "→"
                        padding: 10
                        focusPolicy: Qt.NoFocus
                        enabled: !root.context.unlockInProgress && root.context.currentText !== ""
                        onClicked: root.context.tryUnlock()

                        background: Rectangle {
                            radius: 20
                            color: parent.enabled ? root.colHighlight : Qt.darker(root.colHighlight)
                        }
                        contentItem: Text {
                            text: parent.text
                            color: root.colAccent
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.context.showFailure
                    text: "Wrong Password"
                    color: root.colError
                    font.pixelSize: 12
                }
            }
        }
    }
}
