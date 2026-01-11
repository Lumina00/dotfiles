import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    implicitWidth: 50
    implicitHeight: 150

    property date currentDate: new Date()
    property bool showCalendar: false

    readonly property color colBg:        "#2B2030"
    readonly property color colAccent:    "#F0D0E8"
    readonly property color colHighlight: "#55405D"
    readonly property color colDim:       "#887090"

    // ── 타이머: 다음 정각(분)까지 대기 후 60초 간격 ──
    // 시계가 HH:mm만 표시하므로 1초 → 60초로 변경 (CPU 절약)
    Timer {
        id: clockTimer
        running: true
        repeat: true
        // 최초 interval: 다음 분 0초까지 남은 밀리초
        interval: (60 - new Date().getSeconds()) * 1000
        onTriggered: {
            root.currentDate = new Date();
            // 이후부터는 60초 간격
            if (interval !== 60000) interval = 60000;
        }
    }

    Clock {
        id: clock
        anchors.fill: parent

        currentDate:  root.currentDate
        calendarOpen: root.showCalendar

        colBg:        root.colBg
        colAccent:    root.colAccent
        colHighlight: root.colHighlight
        colDim:       root.colDim

        onToggleClicked: {
            root.showCalendar = !root.showCalendar;
        }
    }

    // ── 캘린더 팝업: Loader로 지연 생성 ──
    Loader {
        id: popupLoader
        active: root.showCalendar
        sourceComponent: calendarPopupComp

        // 닫힐 때 Loader 해제 → 메모리 반환
        onActiveChanged: {
            if (!active && item) {
                item.visible = false;
            }
        }
    }

    Component {
        id: calendarPopupComp

        PopupWindow {
            id: calendarPopup
            visible: root.showCalendar
            color: "transparent"

            implicitWidth: 310
            implicitHeight: 360

            anchor {
                window: Window.window
                item: root
                rect.x: root.width + 6
                rect.y: root.height - calendarPopup.height
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                onExited:  closeTimer.restart()
                onEntered: closeTimer.stop()
            }

            Timer {
                id: closeTimer
                interval: 300
                onTriggered: root.showCalendar = false
            }

            Rectangle {
                id: calendarBg
                anchors.fill: parent
                anchors.leftMargin: 3
                radius: 20
                color: root.colBg

                opacity: 0
                scale: 0.92
                transformOrigin: Item.Left

                states: State {
                    name: "open"
                    when: calendarPopup.visible
                    PropertyChanges {
                        target: calendarBg
                        opacity: 1; scale: 1.0
                    }
                }

                transitions: [
                    Transition {
                        to: "open"
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.OutCubic }
                            NumberAnimation { property: "scale";   duration: 250; easing.type: Easing.OutCubic }
                        }
                    },
                    Transition {
                        from: "open"; to: ""
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InCubic }
                            NumberAnimation { property: "scale";   duration: 180; easing.type: Easing.InCubic }
                        }
                    }
                ]

                Calendar {
                    anchors.fill: parent
                    colBg:        "transparent"
                    colAccent:    root.colAccent
                    colHighlight: root.colHighlight
                    colDim:       root.colDim
                }
            }
        }
    }
}
