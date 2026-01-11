import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property date currentDate
    property bool calendarOpen
    property color colBg
    property color colAccent
    property color colHighlight
    property color colDim

    signal toggleClicked()

    radius: 25
    color: colBg

    // ── 달력 토글 버튼 (상단) ──
    Rectangle {
        id: calBtn
        width: 50; height: 50; radius: 25
        color: root.colHighlight
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: root.calendarOpen ? 1.0 : 0.8

        // Shape + layer.samples 대신 경량 Canvas (1회 페인트)
        Canvas {
            id: calIcon
            anchors.centerIn: parent
            width: 20; height: 20
            renderStrategy: Canvas.Cooperative

            readonly property color strokeCol: root.colAccent

            onStrokeColChanged: requestPaint()
            Component.onCompleted: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.strokeStyle = strokeCol;
                ctx.lineWidth   = 2;
                ctx.lineCap     = "round";

                // 달력 몸체
                ctx.beginPath();
                ctx.roundedRect(2, 4, 16, 14, 2, 2);
                ctx.stroke();

                // 가로 줄 (헤더)
                ctx.beginPath();
                ctx.moveTo(2, 8);
                ctx.lineTo(18, 8);
                ctx.stroke();

                // 고리 두 개
                ctx.beginPath();
                ctx.moveTo(6, 1);  ctx.lineTo(6, 5);
                ctx.moveTo(14, 1); ctx.lineTo(14, 5);
                ctx.stroke();
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleClicked()
        }
    }

    // ── 시계 표시 ──
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: calBtn.bottom
        anchors.topMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        spacing: -2

        Item { width: 1; height: (parent.height - timeCol.height) / 2 }

        Column {
            id: timeCol
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: -2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.currentDate, "HH")
                color: root.colAccent
                font { family: "Proxima Nova"; pixelSize: 24; weight: Font.Bold }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u2022\u2022"
                color: root.colDim
                font { pixelSize: 20; bold: true }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(root.currentDate, "mm")
                color: root.colAccent
                font { family: "Proxima Nova"; pixelSize: 24; weight: Font.Bold }
            }
        }
    }
}
