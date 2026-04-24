pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick


QtObject {
    id: root

    property string icon: ""
    property string temp: ""
    property string desc: ""
    property real   feels: 0
    property int    humidity: 0
    property real   wind: 0
    property var    hourly: []
    property var    daily: []

    readonly property string _script:
        Qt.resolvedUrl("weather.rb").toString().replace("file://", "")

    property Process _proc: Process {
        command: ["sh", "-c",
            "C=/tmp/weather_full.json;" +
            "[ -f \"$C\" ]&&[ $(($(date +%s)-$(stat -c%Y \"$C\"))) -lt 900 ]&&cat \"$C\"||" +
            "ruby '" + root._script + "'"
        ]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                try {
                    const d = JSON.parse(line)
                    const c = d.current
                    root.icon     = c.icon || ""
                    root.temp     = (c.temp !== undefined ? c.temp : "") + "℃"
                    root.desc     = c.desc || ""
                    root.feels    = c.feels || 0
                    root.humidity = c.humidity || 0
                    root.wind     = c.wind || 0
                    root.hourly   = d.hourly || []
                    root.daily    = d.daily || []
                } catch (e) {
                    console.warn("WeatherData parse error:", e)
                }
            }
        }
        onExited: _timer.start()
    }

    property Timer _timer: Timer {
        interval: 6000
        repeat: true
        onTriggered: root._proc.running = true
    }
}
