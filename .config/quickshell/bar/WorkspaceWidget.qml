import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    implicitWidth: 64
    implicitHeight: workspaceColumn.implicitHeight

    readonly property color colBg: "#2B2030"
    readonly property color colAccent: "#F0D0E8"
    readonly property color colHighlight: "#55405D"
    readonly property color colDim: "#887090"
    readonly property color colFocused: "#9060A0"

    // Sort data for workspaces
    property var sortedWorkspaces: {
        let wsList = [];
        let vals = Hyprland.workspaces.values;
        for (let i = 0; i < vals.length; i++) {
            if (vals[i].id > 0) {
                wsList.push(vals[i]);
            }
        }
        wsList.sort(function(a, b) { return a.id - b.id; });
        return wsList;
    }

	// Appclassname -> icon, name mapping helper 
    function getIconForClass(className) {
        if (!className || className === "") return "";
        let lower = className.toLowerCase();
        let mapping = {
            "firefox": "firefox",
            "google-chrome": "google-chrome",
            "chromium": "chromium",
			"librewolf": "librewolf",
            "code": "visual-studio-code",
            "code-oss": "code-oss",
            "kitty": "kitty",
            "alacritty": "Alacritty",
            "foot": "foot",
			"thunar": "thunar",
			"joshuto": "joshuto",
            "nautilus": "org.gnome.Nautilus",
            "dolphin": "system-file-manager",
            "spotify": "spotify",
            "discord": "discord",
            "telegram-desktop": "telegram",
            "obsidian": "obsidian",
            "steam": "steam",
            "org.kde.konsole": "utilities-terminal",
            "wofi": "wofi",
            "rofi": "rofi",
			"mpv": "mpv",
        };
        if (mapping[lower] !== undefined) return mapping[lower];
        return lower;
    }

    ColumnLayout {
        id: workspaceColumn
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 3

        Repeater {
            model: root.sortedWorkspaces

            delegate: Rectangle {
                id: wsDelegate

                required property var modelData

                property bool isFocused: Hyprland.focusedWorkspace !== null
                                         && Hyprland.focusedWorkspace.id === modelData.id

				//	ホバー状態を別のプロパティとして管理
				//	colorを直接代入するとバインディングが破綻するため、hoveredを通じて常にバインディングで色を決定
                property bool hovered: false

                property var toplevels: modelData.toplevels ? modelData.toplevels.values : []

                property string firstAppClass: {
                    if (toplevels.length > 0 && toplevels[0].lastIpcObject) {
                        return toplevels[0].lastIpcObject.class || "";
                    }
                    return "";
                }

                // 表示用アプリ名
                property string appName: {
                    if (firstAppClass === "") return "";
                    let name = firstAppClass;
                    let parts = name.split(".");
                    if (parts.length > 1) name = parts[parts.length - 1];
                    if (name.length > 0)
                        return name.charAt(0).toUpperCase() + name.substring(1);
                    return "";
                }

                // Quickshell.iconPath(name, check=true)
                property string iconSource: {
                    let iconName = root.getIconForClass(firstAppClass);
                    if (iconName === "") return "";
                    return Quickshell.iconPath(iconName, true);
                }

                // fallback
                property string fallbackIcon: {
                    if (toplevels.length > 0)
                        return Quickshell.iconPath("application-x-executable", true);
                    return "";
                }

                Layout.fillWidth: true
                Layout.preferredHeight: wsContent.implicitHeight + 20  // 패딩 늘림

                radius: 10

                color: isFocused ? root.colFocused
                     : hovered   ? root.colHighlight
                     :             "transparent"

                Behavior on color {
                    ColorAnimation { duration: 150; easing.type: Easing.OutQuad }
                }

                // left focus indicator bar
                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: isFocused ? parent.height * 0.55 : 0
                    radius: 1.5
                    color: root.colAccent
                    opacity: isFocused ? 1.0 : 0.0

                    Behavior on height {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }

                // workspace content
                ColumnLayout {
                    id: wsContent
                    anchors.centerIn: parent
                    spacing: 4

                    // workspace number
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.id
                        color: isFocused ? root.colAccent : root.colDim
                        font.family: "Monospace"
                        font.pixelSize: isFocused ? 20 : 16
                        font.bold: isFocused

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    Image {
                        id: appIcon
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        sourceSize.width: 26
                        sourceSize.height: 26
                        source: iconSource !== "" ? iconSource
                              : (fallbackIcon !== "" ? fallbackIcon : "")
                        visible: source !== "" && toplevels.length > 0
                        smooth: true
                        mipmap: true
                        opacity: isFocused ? 1.0 : 0.7

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    // fallback text
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: root.implicitWidth - 8
                        text: appName
                        color: isFocused ? root.colAccent : root.colDim
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        visible: appName !== "" && appIcon.status !== Image.Ready
                        opacity: 0.85

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 3
                        visible: toplevels.length > 1

                        Repeater {
                            model: Math.min(toplevels.length, 5)

                            Rectangle {
                                width: 5
                                height: 5
                                radius: 2.5
                                color: isFocused ? root.colAccent : root.colDim
                                opacity: isFocused ? 1.0 : 0.5

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }
                    }
                }

                // Click / hover 
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        Hyprland.dispatch("workspace " + modelData.id);
                    }

                    onEntered: wsDelegate.hovered = true
                    onExited:  wsDelegate.hovered = false
                }
            }
        }
    }
}
