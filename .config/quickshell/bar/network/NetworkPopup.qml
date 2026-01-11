import QtQuick
import QtQuick.Layouts
import qs.theme

Rectangle {
    id: popup

    property var backend: NetworkBackend

    width: 240; height: 310; radius: 16
    color: ThemeGradient.bgDark
    border.color: _borderColor; border.width: 1

    property string _pendingSsid: ""
    property bool   _showPassword: false

    // ── 자주 쓰는 파생 색상 캐시 (매 프레임 Qt.rgba 재계산 방지) ──
    readonly property color _borderColor:  Qt.rgba(ThemeGradient.dark.start.r, ThemeGradient.dark.start.g, ThemeGradient.dark.start.b, 0.25)
    readonly property color _hoverBgColor: Qt.rgba(ThemeGradient.dark.start.r, ThemeGradient.dark.start.g, ThemeGradient.dark.start.b, 0.12)
    readonly property color _inputBorder:  Qt.rgba(ThemeGradient.dark.start.r, ThemeGradient.dark.start.g, ThemeGradient.dark.start.b, 0.3)
    readonly property color _inputBg:      Qt.darker(ThemeGradient.bgDark, 1.3)

    ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 8

        // ━━ 헤더 ━━
        RowLayout {
            Layout.fillWidth: true; spacing: 10

            Rectangle {
                width: 36; height: 36; radius: 18
                gradient: backend.connectionType !== "none"
                            ? ThemeGradient.light.horizontal : ThemeGradient.dark.iconBg
                Text {
                    anchors.centerIn: parent
                    text: backend.connectionType === "wifi" ? "󰤨"
                        : backend.connectionType === "ethernet" ? "󰈀" : "󰤭"
                    font.pixelSize: 18; font.family: "Material Design Icons"
                    color: backend.connectionType !== "none"
                            ? ThemeGradient.bgDark : ThemeGradient.light.start
                }
            }

            Column {
                Layout.fillWidth: true; spacing: 2
                Text {
                    text: backend.connectionType === "wifi" ? backend.wifiSsid
                        : backend.connectionType === "ethernet" ? "이더넷" : "연결 없음"
                    font { pixelSize: 13; bold: true; family: "Pretendard, sans-serif" }
                    color: ThemeGradient.textPrimary
                    elide: Text.ElideRight; width: parent.width
                }
                Text {
                    text: backend.connectionType !== "none" ? "연결됨" : "연결 끊김"
                    font { pixelSize: 10; family: "Pretendard, sans-serif" }
                    color: backend.connectionType !== "none"
                            ? ThemeGradient.light.mid : ThemeGradient.textSecondary
                }
            }
        }

        // ━━ VPN ━━
        Rectangle {
            Layout.fillWidth: true; height: 32; radius: 10
            gradient: ThemeGradient.light.soft
            visible: backend.vpnActive
            RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 6
                Text {
                    text: "󰌾"; font.pixelSize: 14
                    font.family: "Material Design Icons"; color: "#4E9A6D"
                }
                Text {
                    text: "VPN · " + backend.vpnName
                    font { pixelSize: 11; bold: true; family: "Pretendard, sans-serif" }
                    color: ThemeGradient.bgDark
                    elide: Text.ElideRight; Layout.fillWidth: true
                }
            }
        }

        // ━━ 구분선 ━━
        Rectangle { Layout.fillWidth: true; height: 1; gradient: ThemeGradient.glow }

        // ━━ Wi-Fi 토글 ━━
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Text {
                text: "Wi-Fi"; font { pixelSize: 13; family: "Pretendard, sans-serif" }
                color: ThemeGradient.textPrimary; Layout.fillWidth: true
            }
            Rectangle {
                width: 38; height: 20; radius: 10
                gradient: backend.wifiEnabled ? ThemeGradient.light.horizontal : null
                color: backend.wifiEnabled ? "transparent" : ThemeGradient.bgSurface
                Rectangle {
                    width: 16; height: 16; radius: 8; y: 2
                    x: backend.wifiEnabled ? parent.width - width - 2 : 2
                    color: ThemeGradient.bgDark
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: backend.toggleWifi()
                }
            }
        }

        // ━━ 목록 헤더 ━━
        RowLayout {
            Layout.fillWidth: true; visible: backend.wifiEnabled; spacing: 4
            Text {
                text: "사용 가능한 네트워크"
                font { pixelSize: 10; family: "Pretendard, sans-serif" }
                color: ThemeGradient.textSecondary; Layout.fillWidth: true
            }
            Rectangle {
                width: 22; height: 22; radius: 11
                gradient: refreshArea.containsMouse ? ThemeGradient.dark.iconBg : null
                color: "transparent"
                Text {
                    anchors.centerIn: parent; text: "󰑐"; font.pixelSize: 12
                    font.family: "Material Design Icons"
                    color: refreshArea.containsMouse
                            ? ThemeGradient.light.start : ThemeGradient.textSecondary
                    RotationAnimation on rotation {
                        running: backend._scanning
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                    }
                }
                MouseArea {
                    id: refreshArea; anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: backend.scanWifi()
                }
            }
        }

        // ━━ Wi-Fi 목록 ━━
        ListView {
            id: wifiListView
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; visible: backend.wifiEnabled
            model: backend.wifiList; spacing: 2
            reuseItems: true
            cacheBuffer: 120  // 화면 밖 120px까지 delegate 유지

            delegate: Rectangle {
                id: delegateRoot
                required property var modelData
                required property int index

                width: wifiListView.width
                height: popup._pendingSsid === modelData.ssid && !modelData.inUse ? 72 : 36
                radius: 10

                gradient: modelData.inUse ? ThemeGradient.light.soft : null
                color: modelData.inUse ? "transparent"
                     : dMouseArea.containsMouse ? popup._hoverBgColor
                     : "transparent"

                Behavior on height { NumberAnimation { duration: 150 } }

                ColumnLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8; topMargin: 4; bottomMargin: 4 }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true; spacing: 6

                        Text {
                            text: {
                                var s = modelData.signal;
                                return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟";
                            }
                            font.pixelSize: 13; font.family: "Material Design Icons"
                            color: modelData.inUse ? ThemeGradient.bgDark : ThemeGradient.textSecondary
                        }

                        Text {
                            text: modelData.ssid; font.pixelSize: 11
                            font { family: "Pretendard, sans-serif"; bold: modelData.inUse }
                            color: modelData.inUse ? ThemeGradient.bgDark : ThemeGradient.textPrimary
                            elide: Text.ElideRight; Layout.fillWidth: true
                        }

                        Text {
                            text: "󰌾"; font.pixelSize: 10; font.family: "Material Design Icons"
                            color: modelData.inUse ? ThemeGradient.bgDark : ThemeGradient.textSecondary
                            visible: modelData.security !== "" && modelData.security !== "--"
                        }

                        Text {
                            text: "연결됨"; font { pixelSize: 9; bold: true; family: "Pretendard, sans-serif" }
                            color: ThemeGradient.bgDark; visible: modelData.inUse
                        }
                    }

                    // 비밀번호 입력 (해당 SSID 선택 시에만 visible)
                    RowLayout {
                        Layout.fillWidth: true; spacing: 4
                        visible: popup._pendingSsid === modelData.ssid && !modelData.inUse

                        Rectangle {
                            Layout.fillWidth: true; height: 26; radius: 8
                            color: popup._inputBg
                            border.color: popup._inputBorder; border.width: 1

                            TextInput {
                                id: pwInput
                                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                verticalAlignment: TextInput.AlignVCenter
                                font { pixelSize: 11; family: "Pretendard, monospace" }
                                color: ThemeGradient.textPrimary
                                echoMode: popup._showPassword ? TextInput.Normal : TextInput.Password
                                clip: true

                                Text {
                                    anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                                    text: "비밀번호 입력…"
                                    font { pixelSize: 11; family: "Pretendard, sans-serif" }
                                    color: ThemeGradient.textSecondary
                                    visible: !pwInput.text && !pwInput.activeFocus
                                }

                                Keys.onReturnPressed: {
                                    backend.connectToNetwork(modelData.ssid, pwInput.text);
                                    popup._pendingSsid = ""; pwInput.text = "";
                                }
                            }
                        }

                        Rectangle {
                            width: 26; height: 26; radius: 8
                            gradient: cBtnArea.containsMouse ? ThemeGradient.light.horizontal : null
                            color: cBtnArea.containsMouse ? "transparent" : ThemeGradient.bgSurface
                            Text {
                                anchors.centerIn: parent; text: "󰁕"
                                font.pixelSize: 14; font.family: "Material Design Icons"
                                color: cBtnArea.containsMouse ? ThemeGradient.bgDark : ThemeGradient.textSecondary
                            }
                            MouseArea {
                                id: cBtnArea; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    backend.connectToNetwork(modelData.ssid, pwInput.text);
                                    popup._pendingSsid = ""; pwInput.text = "";
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: dMouseArea; anchors.fill: parent
                    hoverEnabled: true; propagateComposedEvents: true; z: -1
                    onClicked: {
                        if (modelData.inUse) return;
                        if (modelData.security !== "" && modelData.security !== "--") {
                            popup._pendingSsid = popup._pendingSsid === modelData.ssid ? "" : modelData.ssid;
                        } else {
                            backend.connectToNetwork(modelData.ssid, "");
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true; Layout.topMargin: 4
            text: "네트워크 검색 중…"
            font { pixelSize: 11; family: "Pretendard, sans-serif" }
            color: ThemeGradient.textSecondary
            horizontalAlignment: Text.AlignHCenter
            visible: backend._scanning && backend.wifiList.length === 0
        }
        Text {
            Layout.fillWidth: true; Layout.topMargin: 8
            text: "Wi-Fi가 꺼져 있습니다"
            font { pixelSize: 12; family: "Pretendard, sans-serif" }
            color: ThemeGradient.textSecondary
            horizontalAlignment: Text.AlignHCenter
            visible: !backend.wifiEnabled
        }
    }
}
