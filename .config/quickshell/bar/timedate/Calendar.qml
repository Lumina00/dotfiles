import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    property color colBg
    property color colAccent
    property color colHighlight
    property color colDim

    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth()

    color: colBg
    radius: 20
    
    // Popup Fade effect
    opacity: 0
    Component.onCompleted: opacity = 1
    Behavior on opacity { NumberAnimation { duration: 200 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 10
            
            Text {
                text: "<"
                color: root.colAccent
                font.pixelSize: 20
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: changeMonth(-1)
                }
            }
            
            Item { Layout.fillWidth: true } 
            
            Text {
                text: Qt.formatDateTime(new Date(root.selectedYear, root.selectedMonth, 1), "MMMM yyyy")
                color: root.colAccent
                font.bold: true
                font.pixelSize: 16
            }
            
            Item { Layout.fillWidth: true } 
            
            Text {
                text: ">"
                color: root.colAccent
                font.pixelSize: 20
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: changeMonth(1)
                }
            }
        }

        GridLayout {
            columns: 7
            columnSpacing: 0
            rowSpacing: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: root.colDim
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            Repeater {
                model: getCalendarModel(root.selectedYear, root.selectedMonth)
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    radius: width / 2
                    color: modelData.isToday ? root.colHighlight : "transparent"
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: width / 2
                        color: "transparent"
                        border.color: root.colAccent
                        border.width: 1
                        visible: modelData.isToday
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.dateNum
                        color: !modelData.isCurrentMonth ? Qt.darker(root.colDim) : (modelData.isToday ? "white" : root.colAccent)
                        font.bold: modelData.isToday
                    }
                }
            }
        }
    }

    function changeMonth(step) {
        let nextMonth = root.selectedMonth + step;
        if (nextMonth > 11) {
            root.selectedMonth = 0;
            root.selectedYear++;
        } else if (nextMonth < 0) {
            root.selectedMonth = 11;
            root.selectedYear--;
        } else {
            root.selectedMonth = nextMonth;
        }
    }

    function getCalendarModel(year, month) {
        let firstDay = new Date(year, month, 1).getDay(); 
        let daysInMonth = new Date(year, month + 1, 0).getDate();
        let daysInPrevMonth = new Date(year, month, 0).getDate();
        let result = [];
        
        for (let i = 0; i < firstDay; i++) {
            result.push({ dateNum: daysInPrevMonth - firstDay + 1 + i, isCurrentMonth: false, isToday: false });
        }
        
        let today = new Date();
        for (let i = 1; i <= daysInMonth; i++) {
            let isToday = (today.getFullYear() === year && today.getMonth() === month && today.getDate() === i);
            result.push({ dateNum: i, isCurrentMonth: true, isToday: isToday });
        }
        
        while (result.length < 42) {
            result.push({ dateNum: result.length - (firstDay + daysInMonth) + 1, isCurrentMonth: false, isToday: false });
        }
            
        return result;
    }
}
