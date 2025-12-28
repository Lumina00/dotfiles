import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects // Need masking effect

Item {
    id: root
    width: 50
    height: 120
    
    // PwObjectTracker: Grant Audio Control
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property var sink: Pipewire.defaultAudioSink
    property var audio: (sink && sink.audio) ? sink.audio : null

    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: width / 2  
        visible: false
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "#FFFFFF" // 0%
        
        // gage color
        Rectangle {
            id: fill
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            
            height: parent.height * (root.audio ? root.audio.volume : 0)
            
            color: "#F4C2D7"
            
            radius: root.width / 2 

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: maskRect
        }
    }

    // Icon and text
    Column {
        anchors.centerIn: parent
        spacing: 5
        z: 10

        Image {
            width: 24
            height: 24
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            
            source: Quickshell.iconPath(getIconName())

            function getIconName() {
                if (!root.audio) return "audio-volume-muted";
                if (root.audio.muted || root.audio.volume === 0) 
                    return "audio-volume-muted";
                
                const vol = root.audio.volume;
                if (vol < 0.3) return "audio-volume-low";
                if (vol < 0.7) return "audio-volume-medium";
                return "audio-volume-high";
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.audio ? Math.round(root.audio.volume * 100) : "0"
            
            font.pixelSize: 16
            font.bold: true
            color: "#4A3B4A"
        }
    }

    MouseArea {
        anchors.fill: parent
        
        onWheel: (wheel) => {
            if (!root.audio) return;
            
            var delta = wheel.angleDelta.y > 0 ? 0.01 : -0.01;
            var newVolume = root.audio.volume + delta;

            if (newVolume > 1.0) newVolume = 1.0;
            if (newVolume < 0.0) newVolume = 0.0;

            root.audio.volume = newVolume;
            
            if (root.audio.muted && delta > 0) {
                root.audio.muted = false;
            }
        }

        onClicked: {
            if (root.audio) {
                root.audio.muted = !root.audio.muted;
            }
        }
    }
}
