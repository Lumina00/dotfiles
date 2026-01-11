import QtQuick
import QtQuick.Shapes

// ── 벨 아이콘 (최적화) ──
// layer.enabled: 흔들림 중에만 활성화 → GPU 텍스처 상시 점유 제거
// Shape 정적 렌더링 → layer.samples 제거 (Shape 자체 antialiasing 사용)
Rectangle {
    id: root

    property int badgeCount: 0
    property bool panelOpen: false
    property color colAccent: "#F0D0E8"
    property color colHighlight: "#55405D"

    signal clicked()

    function shake() {
        bellShake.start()
    }

    width: 40
    height: 40
    radius: 20
    color: bellHover.containsMouse || root.panelOpen ? root.colHighlight : "transparent"

    // ── 벨 Shape ──
    Shape {
        id: bellShape
        anchors.centerIn: parent
        width: 20
        height: 22

        // layer를 흔들림 중에만 켜서 GPU 부담 최소화
        layer.enabled: bellShake.running
        layer.samples: 4

        // 정적일 때도 안티앨리어싱
        antialiasing: true

        ShapePath {
            strokeColor: root.colAccent
            strokeWidth: 1.8
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathMove { x: 10; y: 1 }
            PathCubic { x: 2; y: 8; control1X: 4; control1Y: 1; control2X: 2; control2Y: 4 }
            PathLine { x: 2; y: 14 }
            PathLine { x: 18; y: 14 }
            PathLine { x: 18; y: 8 }
            PathCubic { x: 10; y: 1; control1X: 18; control1Y: 4; control2X: 16; control2Y: 1 }

            PathMove { x: 1; y: 14 }
            PathLine { x: 19; y: 14 }

            PathMove { x: 8; y: 17 }
            PathArc { x: 12; y: 17; radiusX: 2.5; radiusY: 2.5; direction: PathArc.Counterclockwise }
        }
    }

    // ── 흔들림 애니메이션 ──
    SequentialAnimation {
        id: bellShake
        loops: 2
        NumberAnimation { target: bellShape; property: "rotation"; from: 0; to: 15; duration: 60; easing.type: Easing.InOutQuad }
        NumberAnimation { target: bellShape; property: "rotation"; from: 15; to: -15; duration: 120; easing.type: Easing.InOutQuad }
        NumberAnimation { target: bellShape; property: "rotation"; from: -15; to: 0; duration: 60; easing.type: Easing.InOutQuad }
    }

    // ── 뱃지 ──
    Rectangle {
        id: badge
        visible: root.badgeCount > 0
        width: 14
        height: 14
        radius: 7
        color: "#E04060"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 2

        Text {
            anchors.centerIn: parent
            text: root.badgeCount > 9 ? "9+" : root.badgeCount.toString()
            color: "white"
            font.pixelSize: 8
            font.bold: true
        }
    }

    // ── 클릭 ──
    MouseArea {
        id: bellHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
