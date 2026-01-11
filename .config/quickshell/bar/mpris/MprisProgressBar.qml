import QtQuick

Item {
    id: root

    property var player
    property color colAccent: "#E070B8"
    property color colBg: "#484068"
    property var fillGradient: null
    property color handleColor: colAccent

    property real currentPosition: player ? player.position : 0
    property real trackLength: player ? player.length : 0

    height: 6

    Timer {
        interval: 500
        running: root.player != null
        repeat: true
        onTriggered: {
            root.currentPosition = root.player ? root.player.position : 0
            root.trackLength = root.player ? root.player.length : 0
        }
    }

    // track bg
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 4
        radius: 2
        color: root.colBg
    }

    Rectangle {
        id: progressFill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 4
        radius: 2
        color: root.fillGradient ? "transparent" : root.colAccent
        gradient: root.fillGradient ?? undefined

        width: root.trackLength > 0
            ? Math.min(parent.width, (root.currentPosition / root.trackLength) * parent.width)
            : 0

        Behavior on width {
            NumberAnimation { duration: 400; easing.type: Easing.Linear }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: -4
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            radius: 5
            color: root.handleColor
            visible: root.trackLength > 0

            scale: seekArea.pressed ? 1.3 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }
    }

    // seek control 
    MouseArea {
        id: seekArea
        anchors.fill: parent
        anchors.topMargin: -6
        anchors.bottomMargin: -6
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor

        onClicked: function(mouse) {
            if (root.player && root.trackLength > 0) {
                let ratio = mouse.x / root.width
                root.player.position = ratio * root.trackLength
            }
        }

        onPositionChanged: function(mouse) {
            if (pressed && root.player && root.trackLength > 0) {
                let ratio = Math.max(0, Math.min(1, mouse.x / root.width))
                root.player.position = ratio * root.trackLength
            }
        }
    }
}
