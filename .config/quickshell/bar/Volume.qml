import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import qs.theme

Item {
    id: root
    width: 22
    height: 60

    required property var parentWindow

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property var sink: Pipewire.defaultAudioSink
    property var audio: (sink && sink.audio) ? sink.audio : null

    readonly property var sinkNodes: {
        var nodes = Pipewire.nodes.values;
        var result = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (!n.isStream && n.audio && n.isSink) result.push(n);
        }
        return result;
    }

    readonly property var sourceNodes: {
        var nodes = Pipewire.nodes.values;
        var result = [];
        for (var i = 0; i < nodes.length; i++) {
            var n = nodes[i];
            if (!n.isStream && n.audio && !n.isSink) result.push(n);
        }
        return result;
    }

    function getNodeName(node) {
        if (node.nickname && node.nickname.length > 0) return node.nickname;
        if (node.description && node.description.length > 0) return node.description;
        if (node.name && node.name.length > 0) return node.name;
        return "Device " + node.id;
    }

    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: width / 2
        visible: false
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: ThemeGradient.bgCard

        Item {
            id: fillClip
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * (root.audio ? root.audio.volume : 0)
            clip: true

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }

            Rectangle {
                width: container.width
                height: container.height
                anchors.bottom: parent.bottom
                gradient: ThemeGradient.light.vertical
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskRect
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 3
        z: 10

        Rectangle {
            width: 18
            height: 18
            radius: 9
            anchors.horizontalCenter: parent.horizontalCenter
            gradient: ThemeGradient.dark.iconBg

            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: "Symbols Nerd Font"
                font.pixelSize: 11
                color: ThemeGradient.textPrimary

                text: {
                    if (!root.audio || root.audio.muted || root.audio.volume === 0)
                        return "\uf466";
                    const vol = root.audio.volume;
                    if (vol < 0.3) return "";
                    if (vol < 0.7) return "";
                    return "";
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.audio ? Math.round(root.audio.volume * 100) : "0"
            font.pixelSize: 9
            font.bold: true
            color: ThemeGradient.textSecondary
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onWheel: (wheel) => {
            if (!root.audio) return;
            var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01;
            var newVolume = root.audio.volume + delta;
            if (newVolume > 1.0) newVolume = 1.0;
            if (newVolume < 0.0) newVolume = 0.0;
            root.audio.volume = newVolume;
            if (root.audio.muted && delta > 0) root.audio.muted = false;
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                devicePopup.visible = !devicePopup.visible;
            } else {
                if (root.audio) root.audio.muted = !root.audio.muted;
            }
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            devicePopup.visible = false;
        }
        function onDefaultAudioSourceChanged() {
            devicePopup.visible = false;
        }
    }

    PopupWindow {
        id: devicePopup
        anchor.window: root.parentWindow
        anchor.rect.x: root.parentWindow ? root.parentWindow.width : 60
        anchor.rect.y: root.parentWindow
            ? root.parentWindow.height - 320
            : 0
        implicitWidth: 220
        implicitHeight: popupContent.implicitHeight + 24
        visible: false
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: ThemeGradient.bgDark
            radius: 12
            border.color: Qt.rgba(
                ThemeGradient.dark.start.r,
                ThemeGradient.dark.start.g,
                ThemeGradient.dark.start.b, 0.3
            )
            border.width: 1

            ColumnLayout {
                id: popupContent
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
					text: "  Output Device"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    color: ThemeGradient.light.start
                }

                Repeater {
                    model: ScriptModel { values: root.sinkNodes }

                    delegate: Rectangle {
                        required property var modelData

                        property bool isCurrent: Pipewire.defaultAudioSink === modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        gradient: isCurrent ? ThemeGradient.dark.iconBg : null
                        color: isCurrent ? "transparent" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: isCurrent ? "\uf058" : "\uf111"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 10
                                color: isCurrent
                                    ? ThemeGradient.light.start
                                    : ThemeGradient.textSecondary
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: root.getNodeName(modelData)
                                font.pixelSize: 11
                                color: ThemeGradient.textPrimary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Pipewire.preferredDefaultAudioSink = modelData;
                                devicePopup.visible = false;
                            }
                        }
                    }
                }

                // Sep
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                    color: Qt.rgba(
                        ThemeGradient.textSecondary.r,
                        ThemeGradient.textSecondary.g,
                        ThemeGradient.textSecondary.b, 0.3
                    )
                }

                Text {
                    text: "\uf130  Input Device"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    color: ThemeGradient.light.start
                }

                Repeater {
                    model: ScriptModel { values: root.sourceNodes }

                    delegate: Rectangle {
                        required property var modelData

                        property bool isCurrent: Pipewire.defaultAudioSource === modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        radius: 8
                        gradient: isCurrent ? ThemeGradient.dark.iconBg : null
                        color: isCurrent ? "transparent" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            Text {
                                text: isCurrent ? "\uf058" : "\uf111"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 10
                                color: isCurrent
                                    ? ThemeGradient.light.start
                                    : ThemeGradient.textSecondary
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: root.getNodeName(modelData)
                                font.pixelSize: 11
                                color: ThemeGradient.textPrimary
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Pipewire.preferredDefaultAudioSource = modelData;
                                devicePopup.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
