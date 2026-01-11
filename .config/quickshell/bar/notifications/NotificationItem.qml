import QtQuick
import QtQuick.Layouts

// ── 개별 알림 카드 ──
Rectangle {
    id: notifItem

    property string summary: ""
    property string body: ""
    property string appName: ""
    property string timeStr: ""
    property string iconSource: ""

    property color colAccent: "#F0D0E8"
    property color colHighlight: "#55405D"
    property color colDim: "#887090"

    signal dismissed()

    width: parent ? parent.width : 280
    height: 64
    radius: 12
    color: colHighlight

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        // ── 썸네일 (고정 40×40) ──
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 8
            color: Qt.darker(notifItem.colHighlight, 1.3)
            clip: true

            Image {
                anchors.fill: parent
                source: notifItem.iconSource
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
                visible: notifItem.iconSource === ""
            }
        }

        // ── 텍스트 영역 ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: notifItem.summary
                    color: notifItem.colAccent
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    text: notifItem.timeStr
                    color: notifItem.colAccent
                    font.pixelSize: 10
                }
            }

            Text {
                Layout.fillWidth: true
                text: notifItem.body !== "" ? notifItem.body : notifItem.appName
                color: notifItem.colAccent
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        // ── X 닫기 ──
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: closeArea.containsMouse ? Qt.lighter(notifItem.colHighlight, 1.4) : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                color: closeArea.containsMouse ? notifItem.colAccent : notifItem.colDim
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    notifItem.dismissed()
                }
            }
        }
    }
}
