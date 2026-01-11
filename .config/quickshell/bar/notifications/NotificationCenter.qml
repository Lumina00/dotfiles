import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// ── Notification Center 드로어 ──
Item {
    id: root

    property var model: null
    property int notifCount: 0
    property int maxNotifications: 50

    property color colBg: "#2B2030"
    property color colAccent: "#F0D0E8"
    property color colHighlight: "#55405D"
    property color colDim: "#887090"

    signal clearAll()
    signal dismissNotification(int index)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ━━ 헤더 ━━
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26

            Text {
                text: "Notification Center"
                color: root.colAccent
                font.pixelSize: 15
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                width: 26
                height: 26
                radius: 13
                color: clearAllArea.containsMouse ? root.colHighlight : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: root.colAccent
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    id: clearAllArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.clearAll()
                    }
                }
            }
        }

        // ━━ 구분선 ━━
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: root.colHighlight
        }

        // ━━ 빈 상태 ━━
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifCount === 0

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔔"
                    font.pixelSize: 32
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "No notifications"
                    color: root.colDim
                    font.pixelSize: 13
                }
            }
        }

        // ━━ 알림 리스트 ━━
        ListView {
            id: notifListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.notifCount > 0
            model: root.model
            spacing: 8
            clip: true

            // 항상 맨 위부터 표시
            onVisibleChanged: {
                if (visible) {
                    contentY = 0
                }
            }
            onCountChanged: {
                contentY = 0
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: NotificationItem {
                width: notifListView.width
                summary: model.summary ?? ""
                body: model.body ?? ""
                appName: model.appName ?? ""
                timeStr: model.timeStr ?? ""
                iconSource: model.iconSource ?? ""

                colAccent: root.colAccent
                colHighlight: root.colHighlight
                colDim: root.colDim

                onDismissed: {
                    root.dismissNotification(model.index)
                }
            }
        }
    }
}
