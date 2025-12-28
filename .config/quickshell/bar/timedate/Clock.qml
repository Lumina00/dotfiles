import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

Rectangle {
    id: root
    
    property date currentDate
    property bool calendarOpen
    property color colBg
    property color colAccent
    property color colHighlight
    property color colDim

    signal toggleClicked()

    implicitWidth: 50
    implicitHeight: 150
    radius: 25
    
    color: colBg
    
    Rectangle {
        width: 50
        height: 50
        radius: 25
        color: root.colHighlight 
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        
        opacity: root.calendarOpen ? 1.0 : 0.8 

        Shape {
            anchors.centerIn: parent
            width: 18
            height: 18
            layer.enabled: true
            layer.samples: 4
            ShapePath {
                strokeColor: root.colAccent
                strokeWidth: 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                
                PathMove { x: 2; y: 4 }
                PathLine { x: 16; y: 4 }
                PathLine { x: 16; y: 16 }
                PathLine { x: 2; y: 16 }
                PathLine { x: 2; y: 4 }
                
                PathMove { x: 2; y: 7 }
                PathLine { x: 16; y: 7 }
                
                PathMove { x: 5; y: 1 }
                PathLine { x: 5; y: 4 }
                PathMove { x: 13; y: 1 }
                PathLine { x: 13; y: 4 }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleClicked()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 50
        anchors.bottomMargin: 10
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            
            Column {
                anchors.centerIn: parent
                spacing: -2
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(root.currentDate, "HH")
                    color: root.colAccent
                    font.family: "Monospace"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
                
                // Sep
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
					text: "••"
                    color: root.colDim
                    font.pixelSize: 20
                    font.bold: true
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatTime(root.currentDate, "mm")
                    color: root.colAccent
                    font.family: "Monospace"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
            }
        }
    }
}
