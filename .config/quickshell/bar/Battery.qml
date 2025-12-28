import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.PowerProfiles

Item {
    id: root
    width: 32
    height: 32

    property var battery: UPower.displayDevice
    
    readonly property var profileIds: ["power-saver", "balanced", "performance"]
    readonly property var profileLabels: ["Power Saver", "Balanced", "Performance"]

    readonly property string iconName: {
        if (!battery) return "battery-missing-symbolic";
        
        const isCharging = (battery.state === 1); // 1: Charging
        const level = Math.floor(battery.percentage / 10) * 10;
        const stateStr = isCharging ? "-charging" : "";
        
        if (battery.state === 4 || (battery.percentage >= 99 && isCharging)) {
            return "battery-level-100-charged-symbolic";
        }

        return `battery-level-${level}${stateStr}-symbolic`;
    }

    readonly property int currentProfileIndex: {
        const idx = profileIds.indexOf(PowerProfiles.activeProfile);
        return idx !== -1 ? idx : 1; // failback Balanced(1)
    }

    // --- UI ---

    // Main icon
    Item {
        anchors.fill: parent

        Image {
            anchors.centerIn: parent
            width: 24
            height: 24
            source: "image://theme/" + root.iconName
            fillMode: Image.PreserveAspectFit
            opacity: mouseArea.containsMouse ? 0.3 : 1.0
            
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Text {
            anchors.centerIn: parent
            text: root.battery ? Math.round(root.battery.percentage) + "%" : "--%"
            visible: mouseArea.containsMouse
            font.bold: true
            font.pixelSize: 10
            color: "white"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: profilePopup.visible = !profilePopup.visible
        }
    }

    // PopupWindow
    PopupWindow {
        id: profilePopup
        visible: false
        
        width: 220
        height: bgRect.height

        anchor.item: root
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right

        color: "transparent"

        Rectangle {
            id: bgRect
            width: parent.width
            height: layout.implicitHeight + 20
            
            color: "#2b2b2b"
            radius: 8
            border.color: "#444444"
            border.width: 1

            ColumnLayout {
                id: layout
                width: parent.width
                spacing: 8
                anchors.centerIn: parent
                
                // Title
                Text {
                    text: "Power Profile"
                    color: "#aaaaaa"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 10
                }

                Text {
                    text: root.profileLabels[slider.value] || "Unknown"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }

                Slider {
                    id: slider
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    
                    from: 0
                    to: 2
                    stepSize: 1
                    snapMode: Slider.SnapAlways

                    value: root.currentProfileIndex

                    onMoved: {
                        const newProfile = root.profileIds[value];
                        if (newProfile && newProfile !== PowerProfiles.activeProfile) {
                            PowerProfiles.activeProfile = newProfile;
                        }
                    }

                    // (선택) Slider handle custom style
                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: slider.pressed ? "#f0f0f0" : "#ffffff"
                        border.color: "#3daee9"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.bottomMargin: 10

                    Text { text: "Save"; font.pixelSize: 9; color: "#888888" }
                    Item { Layout.fillWidth: true }
                    Text { text: "Bal"; font.pixelSize: 9; color: "#888888" }
                    Item { Layout.fillWidth: true }
                    Text { text: "Perf"; font.pixelSize: 9; color: "#888888" }
                }
            }
        }
    }
}
