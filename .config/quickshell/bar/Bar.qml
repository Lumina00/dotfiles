import QtQuick
import QtQuick.Layouts
import Quickshell

import "timedate"

PanelWindow {
    id: barWindow
    
    anchors {
        top: true
        bottom: true
        left: true
    }

    width: 60
    
    color: "transparent"

    ColumnLayout {
        id: barLayout
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        
        anchors.leftMargin: 10
        anchors.bottomMargin: 20
        spacing: 15

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 1 // dummy
        }
        Sound {
            id: volumeWidget
//            anchors.horizontalCenter: parent.horizontalCenter
        }
		Battery {
            id: myBattery
            
            Layout.alignment: Qt.AlignHCenter
        }

        TimeWidget {
            Layout.alignment: Qt.AlignLeft
        }
    }
}
