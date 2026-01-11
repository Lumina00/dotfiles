import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Mpris

import qs.theme

Item {
    id: root

    implicitWidth: 50
    implicitHeight: mprisContent.implicitHeight
    visible: player != null

    property var parentWindow

    readonly property color colBg: "#282840"
    readonly property color colBgLight: "#363558"
    readonly property color colAccent: "#E8E0F0"
    readonly property color colHighlight: "#484068"
    readonly property color colDim: "#8882A0"
    readonly property color colPink: "#E070B8" 

    property var player: Mpris.players.values.length > 0
        ? Mpris.players.values[0] : null

    property bool showDrawer: false

    // in Bar Widget
    Rectangle {
        id: mprisContent
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: compactColumn.implicitHeight + 20
        radius: 14
        color: "transparent"

        MouseArea {
            id: barHoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            onEntered: {
                closeTimer.stop()
                root.showDrawer = true
                drawerPopup.visible = true
            }
            onExited: {
                closeTimer.restart()
            }
        }

        ColumnLayout {
            id: compactColumn
            anchors.centerIn: parent
            spacing: 6
            width: parent.width

            // eq icon
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 22
                Layout.preferredHeight: 18

                Row {
                    anchors.centerIn: parent
                    anchors.bottom: parent.bottom
                    spacing: 2

                    Repeater {
                        model: 3
                        Rectangle {
                            id: eqBar
                            required property int index
                            width: 4
                            radius: 2
                            color: root.colAccent
                            anchors.bottom: parent.bottom

                            property real baseHeight: index === 0 ? 8 : (index === 1 ? 14 : 5)
                            height: baseHeight

                            SequentialAnimation on height {
                                running: root.player != null && root.player.playbackState === MprisPlaybackState.Playing
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: eqBar.baseHeight * 0.3
                                    duration: 280 + eqBar.index * 130
                                    easing.type: Easing.InOutSine
                                }
                                NumberAnimation {
                                    to: eqBar.baseHeight
                                    duration: 280 + eqBar.index * 130
                                    easing.type: Easing.InOutSine
                                }
                            }
                        }
                    }
                }
            }

            // track title
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 46
                text: root.player ? root.player.trackTitle : ""
                color: root.colAccent
                font.pixelSize: 11
                font.bold: true
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 5
                elide: Text.ElideRight
            }

            // track artist
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 46
                text: root.player ? (root.player.trackArtist || "") : ""
                color: root.colDim
                font.pixelSize: 9
                wrapMode: Text.WrapAnywhere
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
            }

            // Control btn
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                MprisBarButton {
                    icon: "prev"
                    size: 9
                    colAccent: root.colAccent
                    onClicked: {
                        if (root.player) root.player.previous()
                    }
                }

                // Play / Pause radius
                Rectangle {
                    width: 22
                    height: 22
                    radius: 11
                    color: root.colHighlight

                    MprisBarButton {
                        anchors.centerIn: parent
                        icon: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "pause" : "play"
                        size: 9
                        colAccent: root.colAccent
                        onClicked: {
                            if (root.player) root.player.togglePlaying()
                        }
                    }
                }

                MprisBarButton {
                    icon: "next"
                    size: 9
                    colAccent: root.colAccent
                    onClicked: {
                        if (root.player) root.player.next()
                    }
                }
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            root.showDrawer = false
            drawerPopup.visible = false
        }
    }

    PopupWindow {
        id: drawerPopup
        visible: false
        color: "transparent"

        implicitWidth: 340
        implicitHeight: 120

        anchor {
            window: root.parentWindow ?? undefined
            item: root
            rect.x: root.width + 4
            rect.y: root.height - drawerPopup.height
        }

        MouseArea {
            id: popupHoverArea
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true

            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
            onPressed: function(mouse) { mouse.accepted = false }
            onReleased: function(mouse) { mouse.accepted = false }
            onClicked: function(mouse) { mouse.accepted = false }
        }

        // Drawer main
        Rectangle {
            id: drawerBg
            anchors.fill: parent
            radius: 18
            color: root.colBgLight
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1

            opacity: 0
            scale: 0.92
            transformOrigin: Item.Left

            states: [
                State {
                    name: "open"
                    when: drawerPopup.visible
                    PropertyChanges {
                        target: drawerBg
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

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                // ── Album art ──
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: root.colHighlight
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.player && root.player.trackArtUrl
                            ? root.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }

                    // if missing Album art
                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        font.pixelSize: 28
                        color: root.colDim
                        visible: !(root.player && root.player.trackArtUrl
                            && root.player.trackArtUrl.toString() !== "")
                    }
                }

                // track info + progress + control
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 1

                    // track title
                    Text {
                        Layout.fillWidth: true
                        text: root.player ? root.player.trackTitle : "재생 중인 곡 없음"
                        color: root.colAccent
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // track track Artist
                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackArtist || "") : ""
                        color: root.colDim
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // track Album
                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackAlbum || "") : ""
                        color: Qt.darker(root.colDim, 1.15)
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: text !== ""
                    }

                    Item { Layout.fillHeight: true }

                    MprisProgressBar {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        player: root.player
                        fillGradient: ThemeGradient.light.soft
                        handleColor: ThemeGradient.light.start
                        colBg: root.colHighlight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        // get duration
                        Text {
                            text: root.player ? formatTime(root.player.position) : "0:00"
                            color: root.colDim
                            font.pixelSize: 10
                            font.family: "Proxima Nova"
                        }

                        Item { Layout.fillWidth: true }

                        // control btn 
                        Row {
                            spacing: 5

                            // Shuffle
                            MprisDrawerButton {
                                icon: "shuffle"
                                size: 12
                                colAccent: root.player && root.player.shuffleSupported && root.player.shuffle
                                    ? root.colPink : root.colDim
                                onBtnClicked: {
                                    if (root.player && root.player.shuffleSupported)
                                        root.player.shuffle = !root.player.shuffle
                                }
                            }

                            // Previous
                            MprisDrawerButton {
                                icon: "prev"
                                size: 14
                                colAccent: root.colAccent
                                onBtnClicked: {
                                    if (root.player) root.player.previous()
                                }
                            }

                            // Play / Pause
                            MprisDrawerButton {
                                icon: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "pause" : "play"
                                size: 18
                                colAccent: root.colAccent
                                onBtnClicked: {
                                    if (root.player) root.player.togglePlaying()
                                }
                            }

                            // Next
                            MprisDrawerButton {
                                icon: "next"
                                size: 14
                                colAccent: root.colAccent
                                onBtnClicked: {
                                    if (root.player) root.player.next()
                                }
                            }

                            // Loop
                            MprisDrawerButton {
                                icon: "loop"
                                size: 12
                                colAccent: root.player && root.player.loopSupported
                                    && root.player.loopState !== MprisLoopState.None
                                    ? root.colPink : root.colDim
                                onBtnClicked: {
                                    if (root.player && root.player.loopSupported) {
                                        if (root.player.loopState === MprisLoopState.None)
                                            root.player.loopState = MprisLoopState.Playlist
                                        else if (root.player.loopState === MprisLoopState.Playlist)
                                            root.player.loopState = MprisLoopState.Track
                                        else
                                            root.player.loopState = MprisLoopState.None
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // all duration
                        Text {
                            text: root.player ? formatTime(root.player.length) : "0:00"
                            color: root.colDim
                            font.pixelSize: 10
                            font.family: "Proxima Nova"
                        }
                    }
                }
            }
        }
    }

	// duration reset 
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00"
        let s = Math.floor(seconds)
        let m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
