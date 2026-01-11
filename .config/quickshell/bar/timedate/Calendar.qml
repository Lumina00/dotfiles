import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color colBg
    property color colAccent
    property color colHighlight
    property color colDim

    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth()

    // 오늘 날짜 캐시 — 컴포넌트 생성 시 1회 평가
    readonly property int _todayYear:  new Date().getFullYear()
    readonly property int _todayMonth: new Date().getMonth()
    readonly property int _todayDate:  new Date().getDate()

    ListModel { id: calendarModel }

    onSelectedYearChanged:  Qt.callLater(_rebuildModel)
    onSelectedMonthChanged: Qt.callLater(_rebuildModel)
    Component.onCompleted: _rebuildModel()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        // ── 헤더: 월 네비게이션 ──
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            Text {
                text: "\u25C0"
                color: root.colAccent
                font.pixelSize: 16

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._changeMonth(-1)
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: {
                    var d = new Date(root.selectedYear, root.selectedMonth, 1);
                    return Qt.formatDateTime(d, "MMMM yyyy");
                }
                color: root.colAccent
                font.bold: true
                font.pixelSize: 16
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "\u25B6"
                color: root.colAccent
                font.pixelSize: 16

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._changeMonth(1)
                }
            }
        }

        // ── 요일 헤더 (월요일 시작) ──
        GridLayout {
            columns: 7
            columnSpacing: 0
            rowSpacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: root.colDim
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }

        // ── 날짜 그리드 ──
        GridLayout {
            columns: 7
            columnSpacing: 0
            rowSpacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: calendarModel

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    radius: width / 2
                    color: model.isToday ? root.colHighlight : "transparent"

                    // 오늘 링 — 필요할 때만 인스턴스화
                    Loader {
                        anchors.fill: parent
                        anchors.margins: 2
                        active: model.isToday
                        sourceComponent: Rectangle {
                            radius: width / 2
                            color: "transparent"
                            border.color: root.colAccent
                            border.width: 1
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.dateNum
                        color: !model.isCurrent
                               ? Qt.darker(root.colDim)
                               : (model.isToday ? "#FFFFFF" : root.colAccent)
                        font.bold: model.isToday
                        font.pixelSize: 13
                    }
                }
            }
        }
    }

    // ── 내부 함수 ──

    function _changeMonth(step) {
        var m = root.selectedMonth + step;
        if (m > 11)       { root.selectedMonth = 0;  root.selectedYear++; }
        else if (m < 0)   { root.selectedMonth = 11; root.selectedYear--; }
        else              { root.selectedMonth = m; }
    }

    function _rebuildModel() {
        calendarModel.clear();

        var year  = root.selectedYear;
        var month = root.selectedMonth;

        var dayOfWeek   = new Date(year, month, 1).getDay();
        var firstDay    = (dayOfWeek + 6) % 7;           // Mon=0 … Sun=6
        var daysInMonth = new Date(year, month + 1, 0).getDate();
        var daysInPrev  = new Date(year, month, 0).getDate();

        var ty = root._todayYear, tm = root._todayMonth, td = root._todayDate;

        // 이전 달 잔여
        for (var i = 0; i < firstDay; i++) {
            calendarModel.append({
                dateNum:   daysInPrev - firstDay + 1 + i,
                isCurrent: false,
                isToday:   false
            });
        }

        // 이번 달
        var checkToday = (ty === year && tm === month);
        for (var d = 1; d <= daysInMonth; d++) {
            calendarModel.append({
                dateNum:   d,
                isCurrent: true,
                isToday:   checkToday && d === td
            });
        }

        // 다음 달 채움 — 5주(35)로 충분하면 35, 아니면 42
        var total  = calendarModel.count;
        var target = total <= 35 ? 35 : 42;
        for (var n = 1; total < target; n++, total++) {
            calendarModel.append({
                dateNum:   n,
                isCurrent: false,
                isToday:   false
            });
        }
    }
}
