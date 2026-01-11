import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// ── Notifications 위젯 ──
Item {
    id: root

    implicitWidth: 50
    implicitHeight: 50

    property int barWidth: 50
    property int maxNotifications: 50

    readonly property color colBg: "#2B2030"
    readonly property color colAccent: "#F0D0E8"
    readonly property color colHighlight: "#55405D"
    readonly property color colDim: "#887090"

    property bool panelOpen: false
    property int badgeCount: 0

    property string latestSummary: ""
    property string latestBody: ""
    property string latestIcon: ""

    property bool toastVisible: false
    property bool centerVisible: false

    // ── 알림 데이터 모델 ──
    ListModel {
        id: notifModel
    }

    // ── NotificationServer ──
    NotificationServer {
        id: notifServer

        onNotification: (notification) => {
            let now = new Date();
            let timeStr = Qt.formatTime(now, "HH:mm");

            root.latestSummary = notification.summary ?? ""
            root.latestBody    = notification.body ?? ""
            root.latestIcon    = notification.appIcon ?? ""

            notifModel.insert(0, {
                nId:        notification.id ?? Date.now(),
                summary:    root.latestSummary,
                body:       root.latestBody,
                appName:    notification.appName ?? "",
                iconSource: root.latestIcon,
                timeStr:    timeStr
            });

            while (notifModel.count > root.maxNotifications) {
                notifModel.remove(notifModel.count - 1)
            }

            bell.shake();
            root.badgeCount = notifModel.count;

            if (!root.panelOpen) {
                root.toastVisible = true
                toastTimer.restart();
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 3000
        onTriggered: root.toastVisible = false
    }

    Timer {
        id: panelCloseTimer
        interval: 400
        onTriggered: {
            root.panelOpen = false
            root.centerVisible = false
        }
    }

    // ── 헬퍼: 벨 아이콘의 화면 절대 Y 좌표 ──
    property real bellScreenY: {
        let pt = root.mapToGlobal(0, 0)
        return pt.y
    }

    // ── 벨 아이콘 ──
    NotificationBell {
        id: bell
        anchors.centerIn: parent

        badgeCount: root.badgeCount
        panelOpen: root.panelOpen
        colAccent: root.colAccent
        colHighlight: root.colHighlight

        onClicked: {
            root.panelOpen = !root.panelOpen
            root.centerVisible = root.panelOpen

            if (root.panelOpen) {
                root.toastVisible = false
                toastTimer.stop()
            }
        }
    }

    // ═══════════════════════════════════════════════════
    // 토스트 — PanelWindow overlay 레이어
    // ═══════════════════════════════════════════════════
    PanelWindow {
        id: toastPanel
        visible: root.toastVisible
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            left: true
        }

        margins.left: root.barWidth + 6
        margins.top: root.bellScreenY

        implicitWidth: 300
        implicitHeight: 72

        // 토스트 배경 — opacity 애니메이션은 시각적 요소에만
        Rectangle {
            anchors.fill: parent
            radius: 14
            color: root.colBg
            border.color: root.colHighlight
            border.width: 1
            opacity: root.toastVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 8
                    color: root.colHighlight
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.latestIcon
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                        sourceSize.width: 40
                        sourceSize.height: 40
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🔔"
                        font.pixelSize: 16
                        visible: root.latestIcon === ""
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.latestSummary
                        color: root.colAccent
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.latestBody
                        color: root.colDim
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════
    // Notification Center — PanelWindow overlay 레이어
    // ═══════════════════════════════════════════════════
    PanelWindow {
        id: notifPanel
        visible: root.centerVisible
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            left: true
        }

        margins.left: root.barWidth + 6
        margins.top: root.bellScreenY

        implicitWidth: 320
        implicitHeight: 420

        // hover 감지 — z: 0 (뒤), 콘텐츠보다 아래
        MouseArea {
            z: 0
            anchors.fill: parent
            hoverEnabled: true
            // 클릭은 통과시킴
            acceptedButtons: Qt.NoButton
            propagateComposedEvents: true

            onExited: panelCloseTimer.restart()
            onEntered: panelCloseTimer.stop()
        }

        // 콘텐츠 — z: 1 (위), 클릭 가능
        Rectangle {
            z: 1
            anchors.fill: parent
            radius: 20
            color: root.colBg

            NotificationCenter {
                anchors.fill: parent

                model: notifModel
                notifCount: notifModel.count
                maxNotifications: root.maxNotifications

                colBg: "transparent"
                colAccent: root.colAccent
                colHighlight: root.colHighlight
                colDim: root.colDim

                onClearAll: {
                    notifModel.clear()
                    root.badgeCount = 0
                }
                onDismissNotification: (idx) => {
                    notifModel.remove(idx)
                    root.badgeCount = notifModel.count
                }
            }
        }
    }
}
