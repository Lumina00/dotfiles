import QtQuick
import QtQuick.Shapes

// In Drawer popup btn 
Item {
    id: btn

    property string icon: "play"
    property int size: 18
    property color colAccent: "#E8E0F0"

    signal btnClicked()

    width: size + 8
    height: size + 8

    // pressed feedback
    opacity: clickArea.pressed ? 0.5 : 1.0

    Behavior on opacity {
        NumberAnimation { duration: 80 }
    }

    // ── fill icon (prev, play, pause, next) ──
    Shape {
        anchors.centerIn: parent
        width: btn.size
        height: btn.size
        layer.enabled: true
        layer.samples: 4
        visible: btn.icon !== "shuffle" && btn.icon !== "loop"

        ShapePath {
            strokeColor: "transparent"
            fillColor: btn.colAccent

            PathSvg {
                path: {
                    let s = btn.size
                    if (btn.icon === "prev") {
                        let bw = Math.max(2, s * 0.14)
                        let bar = "M 0,0 L " + bw + ",0 L " + bw + "," + s + " L 0," + s + " Z"
                        let tri = "M " + (bw + 1) + "," + (s / 2) + " L " + s + ",0 L " + s + "," + s + " Z"
                        return bar + " " + tri
                    } else if (btn.icon === "next") {
                        let bw = Math.max(2, s * 0.14)
                        let tri = "M 0,0 L " + (s - bw - 1) + "," + (s / 2) + " L 0," + s + " Z"
                        let bx = s - bw
                        let bar = "M " + bx + ",0 L " + s + ",0 L " + s + "," + s + " L " + bx + "," + s + " Z"
                        return tri + " " + bar
                    } else if (btn.icon === "pause") {
                        let bw = Math.max(3, s * 0.25)
                        let gap = Math.max(3, s * 0.2)
                        let x1 = (s - bw * 2 - gap) / 2
                        let x2 = x1 + bw + gap
                        let b1 = "M " + x1 + ",1 L " + (x1 + bw) + ",1 L " + (x1 + bw) + "," + (s - 1) + " L " + x1 + "," + (s - 1) + " Z"
                        let b2 = "M " + x2 + ",1 L " + (x2 + bw) + ",1 L " + (x2 + bw) + "," + (s - 1) + " L " + x2 + "," + (s - 1) + " Z"
                        return b1 + " " + b2
                    } else {
                        return "M 1,0 L " + s + "," + (s / 2) + " L 1," + s + " Z"
                    }
                }
            }
        }
    }

    // ── stroke icon (shuffle, loop) ──
    Shape {
        anchors.centerIn: parent
        width: btn.size
        height: btn.size
        layer.enabled: true
        layer.samples: 4
        visible: btn.icon === "shuffle" || btn.icon === "loop"

        ShapePath {
            strokeColor: btn.colAccent
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathSvg {
                path: {
                    let s = btn.size
                    if (btn.icon === "shuffle") {
                        let m = s * 0.12
                        let e = s * 0.88
                        let p1 = "M " + m + "," + e + " L " + e + "," + m
                        let p2 = " M " + m + "," + m + " L " + e + "," + e
                        let a1 = " M " + (e - 4) + "," + m + " L " + e + "," + m + " L " + e + "," + (m + 4)
                        let a2 = " M " + (e - 4) + "," + e + " L " + e + "," + e + " L " + e + "," + (e - 4)
                        return p1 + p2 + a1 + a2
                    } else {
                        let m = s * 0.12
                        let e = s * 0.88
                        let rect = "M " + (m + 4) + "," + m + " L " + e + "," + m +
                                   " L " + e + "," + e + " L " + m + "," + e +
                                   " L " + m + "," + (m + 2)
                        let arr = " M " + (m + 1) + "," + m + " L " + (m + 5) + "," + (m - 3) +
                                  " M " + (m + 1) + "," + m + " L " + (m + 5) + "," + (m + 3)
                        return rect + arr
                    }
                }
            }
        }
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.btnClicked()
    }
}
