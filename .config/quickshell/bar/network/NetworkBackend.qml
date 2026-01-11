pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // ── 공개 상태 ──
    property string connectionType: "none"
    property string wifiSsid: ""
    property int    wifiStrength: 0
    property bool   wifiEnabled: true
    property bool   vpnActive: false
    property string vpnName: ""
    property var    wifiList: []
    property bool   _scanning: false

    // ── nmcli 이스케이프 파서 ──
    // '\:' → 리터럴 ':', 순수 ':' → 필드 구분
    // 배열 push 기반으로 문자열 concat 최소화
    function _parseNmcliLine(raw) {
        var fields = [];
        var start = 0;
        var len = raw.length;
        var buf = "";
        for (var i = 0; i < len; i++) {
            if (raw[i] === '\\' && i + 1 < len && raw[i + 1] === ':') {
                buf += raw.substring(start, i) + ':';
                i++;
                start = i + 1;
            } else if (raw[i] === ':') {
                fields.push(buf + raw.substring(start, i));
                buf = "";
                start = i + 1;
            }
        }
        fields.push(buf + raw.substring(start));
        return fields;
    }

    // ══════════════════════════════════════
    // 상태 폴링 — 단일 sh -c (프로세스 fork 1회)
    // ══════════════════════════════════════
    Process {
        id: statusProc
        command: ["sh", "-c",
            "echo '---STATUS---';" +
            "nmcli -t -f TYPE,NAME,DEVICE,STATE connection show --active 2>/dev/null;" +
            "echo '---WIFI---';" +
            "nmcli radio wifi 2>/dev/null;" +
            "echo '---STRENGTH---';" +
            "nmcli -t -f ACTIVE,SIGNAL dev wifi list --rescan no 2>/dev/null"
        ]
        running: true

        property string _section: ""
        property string _tmpType: "none"
        property string _tmpSsid: ""
        property bool   _tmpVpn: false
        property string _tmpVpnName: ""
        property int    _tmpStrength: 0
        property bool   _tmpWifiEnabled: true

        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var line = data.trim();
                if (line === "") return;

                if (line === "---STATUS---")   { statusProc._section = "status";   return; }
                if (line === "---WIFI---")     { statusProc._section = "wifi";     return; }
                if (line === "---STRENGTH---") { statusProc._section = "strength"; return; }

                var p = statusProc;

                if (p._section === "status") {
                    var fields = root._parseNmcliLine(line);
                    if (fields.length < 4) return;
                    var type  = fields[0].toLowerCase();
                    var name  = fields[1];
                    var state = fields[3].toLowerCase();
                    if (state !== "activated") return;

                    if (type.indexOf("wireless") !== -1 || type.indexOf("wifi") !== -1 || type === "802-11-wireless") {
                        p._tmpType = "wifi";
                        p._tmpSsid = name;
                    } else if (type.indexOf("ethernet") !== -1 || type === "802-3-ethernet") {
                        if (p._tmpType !== "wifi") p._tmpType = "ethernet";
                    } else if (type.indexOf("vpn") !== -1 || type.indexOf("wireguard") !== -1 || type.indexOf("tun") !== -1) {
                        p._tmpVpn = true;
                        p._tmpVpnName = name;
                    }
                }
                else if (p._section === "wifi") {
                    p._tmpWifiEnabled = (line === "enabled");
                }
                else if (p._section === "strength") {
                    var parts = root._parseNmcliLine(line);
                    if (parts.length >= 2 && parts[0] === "yes") {
                        p._tmpStrength = parseInt(parts[1]) || 0;
                    }
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                // 변경된 값만 반영 — 불필요한 바인딩 재평가 방지
                if (root.connectionType !== _tmpType) root.connectionType = _tmpType;
                if (root.wifiSsid !== _tmpSsid)       root.wifiSsid = _tmpSsid;
                if (root.vpnActive !== _tmpVpn)        root.vpnActive = _tmpVpn;
                if (root.vpnName !== _tmpVpnName)      root.vpnName = _tmpVpnName;
                if (root.wifiStrength !== _tmpStrength) root.wifiStrength = _tmpStrength;
                if (root.wifiEnabled !== _tmpWifiEnabled) root.wifiEnabled = _tmpWifiEnabled;

                _section = "";
                _tmpType = "none";   _tmpSsid = "";
                _tmpVpn = false;     _tmpVpnName = "";
                _tmpStrength = 0;    _tmpWifiEnabled = true;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            // 이전 프로세스가 아직 실행 중이면 건너뜀
            if (!statusProc.running) statusProc.running = true;
        }
    }

    // ══════════════════════════════════════
    // Wi-Fi 스캔 — 팝업 열 때만
    // ══════════════════════════════════════
    function scanWifi() {
        if (root._scanning || scanProc.running) return;
        root._scanning = true;
        scanProc._tmpList = [];
        scanProc.running = true;
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "yes"]
        property var _tmpList: []

        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var raw = data.trim();
                if (raw === "") return;

                var fields = root._parseNmcliLine(raw);
                if (fields.length < 4) return;

                var ssid = fields[1];
                if (ssid === "" || ssid === "--") return;

                scanProc._tmpList.push({
                    ssid:     ssid,
                    signal:   parseInt(fields[2]) || 0,
                    security: fields[3],
                    inUse:    fields[0] === '*'
                });
            }
        }

        onRunningChanged: {
            if (!running) {
                var seen = {};
                var list = _tmpList;
                for (var i = 0, len = list.length; i < len; i++) {
                    var item = list[i];
                    var prev = seen[item.ssid];
                    if (!prev || item.signal > prev.signal || (item.inUse && !prev.inUse)) {
                        seen[item.ssid] = item;
                    }
                }

                var unique = [];
                for (var ssid in seen) unique.push(seen[ssid]);

                unique.sort(function(a, b) {
                    if (a.inUse !== b.inUse) return a.inUse ? -1 : 1;
                    return b.signal - a.signal;
                });

                // 내용이 같으면 wifiList를 재할당하지 않음 (바인딩 재평가 방지)
                if (!_listEqual(root.wifiList, unique)) {
                    root.wifiList = unique;
                }
                root._scanning = false;
                _tmpList = [];
            }
        }
    }

    // Wi-Fi 리스트 얕은 비교
    function _listEqual(a, b) {
        if (a.length !== b.length) return false;
        for (var i = 0; i < a.length; i++) {
            if (a[i].ssid !== b[i].ssid || a[i].signal !== b[i].signal || a[i].inUse !== b[i].inUse)
                return false;
        }
        return true;
    }

    // ══════════════════════════════════════
    // 액션
    // ══════════════════════════════════════
    function toggleWifi() {
        toggleProc.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"];
        toggleProc.running = true;
    }

    Process {
        id: toggleProc
        onRunningChanged: { if (!running) statusProc.running = true; }
    }

    function connectToNetwork(ssid, password) {
        connectProc.command = (password && password !== "")
            ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "dev", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    Process {
        id: connectProc
        onRunningChanged: {
            if (!running) {
                statusProc.running = true;
                if (!scanProc.running) scanProc.running = true;
            }
        }
    }

    function disconnectWifi() {
        if (!disconnProc.running) disconnProc.running = true;
    }

    Process {
        id: disconnProc
        command: ["nmcli", "dev", "disconnect", "wlan0"]
        onRunningChanged: { if (!running) statusProc.running = true; }
    }

    Component.onCompleted: statusProc.running = true
}
