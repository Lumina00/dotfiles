import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme

Item {
    id: networkWidget

    property var parentWindow: null
    implicitWidth: 50
    implicitHeight: 40

    property var backend: NetworkBackend
    property bool showPopup: false
    readonly property bool isConnected: backend.connectionType !== "none"

    // 팝업 Y 위치 — showPopup 변경 시에만 계산 (매 프레임 바인딩 방지)
    property real _popupY: 0
    onShowPopupChanged: {
        if (showPopup && parentWindow) {
            var mapped = mapToItem(parentWindow.contentItem, 0, 0);
            var targetY = mapped.y + (height / 2) - (310 / 2);
            _popupY = Math.max(4, Math.min(targetY, parentWindow.height - 310 - 4));
        }
    }

    // ── 아이콘 ──
    Rectangle {
        anchors.centerIn: parent
        width: 36; height: 36; radius: 18
        color: "transparent"

        Row {
            anchors.centerIn: parent
            spacing: 1

            Text {
                font.pixelSize: 18
                font.family: "Material Design Icons"
                anchors.verticalCenter: parent.verticalCenter
                color: backend.connectionType === "none"
                        ? ThemeGradient.textSecondary
                        : ThemeGradient.light.start
                text: {
                    if (!backend.wifiEnabled && backend.connectionType !== "ethernet")
                        return "󰤭";
                    if (backend.connectionType === "ethernet")
                        return "󰈀";
                    if (backend.connectionType === "wifi") {
                        var s = backend.wifiStrength;
                        return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟";
                    }
                    return "󰤮";
                }
            }

            Text {
                visible: backend.vpnActive
                text: "󰌾"
                font.pixelSize: 10
                font.family: "Material Design Icons"
                color: "#7ECE8A"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // ── 마우스 영역 ──
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            networkWidget.showPopup = !networkWidget.showPopup;
            if (networkWidget.showPopup) {
                popupLoader.loading = true;
                if (backend.wifiEnabled) backend.scanWifi();
            }
        }
        onExited: closeTimer.restart()
        onEntered: closeTimer.stop()
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            if (!hoverArea.containsMouse && popupLoader.item && !popupLoader.item._hovered) {
                networkWidget.showPopup = false;
            }
        }
    }

    // ── 팝업 — LazyLoader (최초 클릭 시에만 인스턴스 생성) ──
    LazyLoader {
        id: popupLoader
        loading: false

        PopupWindow {
            visible: networkWidget.showPopup

            property bool _hovered: popupHover.containsMouse

            anchor.window: networkWidget.parentWindow
            anchor.rect.x: networkWidget.parentWindow ? networkWidget.parentWindow.width + 4 : 54
            anchor.rect.y: networkWidget._popupY
            width: 240; height: 310
            color: "transparent"

            NetworkPopup {
                anchors.fill: parent
                backend: networkWidget.backend
            }

            MouseArea {
                id: popupHover
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onPressed: function(mouse) { mouse.accepted = false; }
                onReleased: function(mouse) { mouse.accepted = false; }
                onClicked: function(mouse) { mouse.accepted = false; }
                onExited: closeTimer.restart()
                onEntered: closeTimer.stop()
            }
        }
    }
}
