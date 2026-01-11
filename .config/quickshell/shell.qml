import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "bar"
import "lockscreen"

ShellRoot {
    id: shellRoot

    // BackgroundImage ──
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            aboveWindows: false
            exclusionMode: ExclusionMode.Ignore
            color: "black"

            BackgroundImage {
                anchors.fill: parent
                screen: modelData
            }
		}
	}
    Bar {}

    LockContext {
        id: lockContext

        onUnlocked: {
            sessionLock.locked = false
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: false

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    // Lock trigger

    function doLock() {
        lockContext.currentText = ""
        lockContext.showFailure = false
        sessionLock.locked = true
    }

    //IPC — qs ipc call lockscreen lock
    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            shellRoot.doLock()
        }
    }

    Process {
        id: lockListener
        command: [
            "gdbus", "monitor", "--system",
            "--dest", "org.freedesktop.login1"
        ]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                if (line.indexOf(".Lock ()") !== -1) {
                    shellRoot.doLock()
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            restartListener.start()
        }
    }

    Timer {
        id: restartListener
        interval: 2000
        onTriggered: lockListener.running = true
    }

}
