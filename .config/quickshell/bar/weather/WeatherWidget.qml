import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: 50
    implicitHeight: 60

    readonly property color colBg:        "#2B2030"
    readonly property color colAccent:    "#F0D0E8"
    readonly property color colHighlight: "#55405D"
    readonly property color colDim:       "#887090"
    readonly property color colRain:      "#A0A0E0"
    readonly property color colWarm:      "#E8A0C0"

    property bool _open: false

    QtObject {
        id: _d
        property string icon: ""
        property string temp: ""
        property string desc: ""
        property real   feels: 0
        property int    humidity: 0
        property real   wind: 0
        property var    hourly: []
        property var    daily: []
    }

    // ── 데이터 로드 ──
    readonly property string _script: Qt.resolvedUrl("weather.rb").toString().replace("file://", "")

    Process {
        id: _proc
        command: ["sh", "-c",
            "C=/tmp/weather_full.json;" +
            "[ -f \"$C\" ]&&[ $(($(date +%s)-$(stat -c%Y \"$C\"))) -lt 900 ]&&cat \"$C\"||" +
            "ruby '" + root._script + "'"
        ]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                try {
                    var d = JSON.parse(line), c = d.current
                    _d.icon     = c.icon || ""
                    _d.temp     = c.temp + "℃"
                    _d.desc     = c.desc || ""
                    _d.feels    = c.feels || 0
                    _d.humidity = c.humidity || 0
                    _d.wind     = c.wind || 0
                    _d.hourly   = d.hourly || []
                    _d.daily    = d.daily || []
                } catch(e) { console.warn("Weather:", e) }
            }
        }
        onExited: _timer.start()
    }

    Timer {
        id: _timer
        interval: 900000
        repeat: true
        onTriggered: _proc.running = true
    }

    // ── 닫기 딜레이 타이머 (root 레벨 — Battery 패턴) ──
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: {
            root._open = false
            _popup.visible = false
        }
    }

    // ── 메인 아이콘 호버 (root 레벨 — Battery 패턴) ──
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: {
            closeTimer.stop()
            root._open = true
            _popup.visible = true
        }
        onExited: {
            closeTimer.restart()
        }
    }

    // ── Bar 아이콘 ──
    Rectangle {
        width: 50
        height: 60
        radius: 25
        color: root._open ? colHighlight : "transparent"
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            anchors.centerIn: parent
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: _d.icon
                font.pixelSize: 25
                font.family: "Symbols Nerd Font"
                color: colAccent
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: _d.temp
                font.pixelSize: 12
                font.bold: true
                color: colAccent
            }
        }
    }

    // ── 팝업 드로어 (Battery 패턴과 동일) ──
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
            color: colBg
            opacity: 0
            scale: 0.92
            transformOrigin: Item.Left

            states: [
                State {
                    name: "open"
                    when: _popup.visible
                    PropertyChanges {
                        target: _bg
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

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentHeight: _col.implicitHeight
                clip: true

                ColumnLayout {
                    id: _col
                    width: parent.width
                    spacing: 12

                    // ━━ 현재 날씨 ━━
                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true

                        Text {
                            text: _d.icon
                            font.pixelSize: 36
                            font.family: "Symbols Nerd Font"
                            color: colAccent
                        }
                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: _d.temp
                                font.pixelSize: 22
                                font.bold: true
                                color: colAccent
                            }
                            Text {
                                text: _d.desc
                                font.pixelSize: 11
                                color: colDim
                            }
                        }
                        Item { Layout.fillWidth: true }
                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: "体感温度 " + _d.feels + "℃"
                                font.pixelSize: 10
                                color: colDim
                            }
                            Text {
                                text: "湿度 " + _d.humidity + "%"
                                font.pixelSize: 10
                                color: colDim
                            }
                            Text {
                                text: "風速 " + _d.wind + "m/s"
                                font.pixelSize: 10
                                color: colDim
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: colHighlight
                    }

                    // ━━ 시간별 ━━
                    Text {
                        text: "時間別予報"
                        font.pixelSize: 11
                        font.bold: true
                        color: colDim
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
                                model: _d.hourly.length
                                delegate: ColumnLayout {
                                    required property int index
                                    readonly property var e: _d.hourly[index]
                                    spacing: 3

                                    Text {
                                        text: e.time
                                        font.pixelSize: 9
                                        color: colDim
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        text: e.icon
                                        font.pixelSize: 18
                                        font.family: "Symbols Nerd Font"
                                        color: colAccent
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        text: e.temp + "°"
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: colAccent
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    Text {
                                        text: e.pop + "%"
                                        font.pixelSize: 8
                                        color: colRain
                                        horizontalAlignment: Text.AlignHCenter
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: colHighlight
                    }

                    // ━━ 일별 ━━
                    Text {
                        text: "日別予報"
                        font.pixelSize: 11
                        font.bold: true
                        color: colDim
                    }

                    Repeater {
                        model: _d.daily.length
                        delegate: RowLayout {
                            required property int index
                            readonly property var e: _d.daily[index]
                            spacing: 8
                            Layout.fillWidth: true

                            Text {
                                text: e.day + " " + e.date
                                font.pixelSize: 10
                                color: colDim
                                Layout.preferredWidth: 55
                            }
                            Text {
                                text: e.icon
                                font.pixelSize: 16
                                font.family: "Symbols Nerd Font"
                                color: colAccent
                                Layout.preferredWidth: 24
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text {
                                text: e.pop + "%"
                                font.pixelSize: 9
                                color: colRain
                                Layout.preferredWidth: 30
                                horizontalAlignment: Text.AlignRight
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 14

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 4
                                    radius: 2
                                    color: colHighlight
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 4
                                    radius: 2
                                    readonly property real lo: Math.max(0, (e.tempMin + 10) / 50)
                                    readonly property real hi: Math.min(1, (e.tempMax + 10) / 50)
                                    x: parent.width * lo
                                    width: Math.max(4, parent.width * (hi - lo))
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: colRain }
                                        GradientStop { position: 1.0; color: colWarm }
                                    }
                                }
                            }

                            Text {
                                text: e.tempMin + "°"
                                font.pixelSize: 9
                                color: colRain
                                Layout.preferredWidth: 28
                                horizontalAlignment: Text.AlignRight
                            }
                            Text {
                                text: e.tempMax + "°"
                                font.pixelSize: 9
                                color: colWarm
                                Layout.preferredWidth: 28
                                horizontalAlignment: Text.AlignLeft
                            }
                        }
                    }
                }
            }
        }
    }
}
