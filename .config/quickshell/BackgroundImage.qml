import QtQuick
import Quickshell

Item {
    id: root

    required property ShellScreen screen;

    Image {
        id: image
        anchors.fill: parent
        source: Qt.resolvedUrl("wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
}
