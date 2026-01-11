import QtQuick
import QtQuick.Shapes

// In bar control btn 
Item {
    id: btn

    property string icon: "play"   // "prev", "play", "pause", "next"
    property int size: 12
    property color colAccent: "#E8E0F0"

    signal clicked()

    width: size + 8
    height: size + 8

    Shape {
        anchors.centerIn: parent
        width: btn.size
        height: btn.size
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: "transparent"
            fillColor: btn.colAccent

            PathSvg {
                path: {
                    let s = btn.size
                    if (btn.icon === "prev") {
                        let bw = 2
                        let bar = "M 0,0 L " + bw + ",0 L " + bw + "," + s + " L 0," + s + " Z"
                        let tri = "M " + (bw + 1) + "," + (s / 2) + " L " + s + ",0 L " + s + "," + s + " Z"
                        return bar + " " + tri
                    } else if (btn.icon === "next") {
                        let bw = 2
                        let tri = "M 0,0 L " + (s - bw - 1) + "," + (s / 2) + " L 0," + s + " Z"
                        let bx = s - bw
                        let bar = "M " + bx + ",0 L " + s + ",0 L " + s + "," + s + " L " + bx + "," + s + " Z"
                        return tri + " " + bar
                    } else if (btn.icon === "pause") {
                        let bw = Math.max(2, s * 0.28)
                        let gap = Math.max(2, s * 0.22)
                        let x1 = (s - bw * 2 - gap) / 2
                        let x2 = x1 + bw + gap
                        let b1 = "M " + x1 + ",0 L " + (x1 + bw) + ",0 L " + (x1 + bw) + "," + s + " L " + x1 + "," + s + " Z"
                        let b2 = "M " + x2 + ",0 L " + (x2 + bw) + ",0 L " + (x2 + bw) + "," + s + " L " + x2 + "," + s + " Z"
                        return b1 + " " + b2
                    } else {
                        return "M 1,0 L " + s + "," + (s / 2) + " L 1," + s + " Z"
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
