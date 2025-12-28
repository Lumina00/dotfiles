import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    implicitWidth: clock.implicitWidth
    implicitHeight: clock.implicitHeight

    property date currentDate: new Date()
    property bool showCalendar: false

    readonly property color colBg: "#2B2030"        // Background
    readonly property color colAccent: "#F0D0E8"    // text/icon
    readonly property color colHighlight: "#55405D" // Background for button
    readonly property color colDim: "#887090"      

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentDate = new Date()
    }

    Clock {
        id: clock
        anchors.top: parent.top
        anchors.left: parent.left
        
        currentDate: root.currentDate
        calendarOpen: root.showCalendar
        
        colBg: root.colBg
        colAccent: root.colAccent
        colHighlight: root.colHighlight
        colDim: root.colDim
        
        onToggleClicked: root.showCalendar = !root.showCalendar
    }

    PopupWindow {
        id: calendarPopup
        visible: root.showCalendar
        color: "transparent"
        
        width: 315 
        height: 360

        anchor {
            window: Window.window
            item: clock             
            
            gravity: Edges.Right
        }

        Calendar {
            anchors.fill: parent
            anchors.leftMargin: 55
            
            colBg: root.colBg
            colAccent: root.colAccent
            colHighlight: root.colHighlight
            colDim: root.colDim
        }
    }
}
