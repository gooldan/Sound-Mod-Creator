import QtQuick 2.0
import Qt.labs.controls 1.0

ScrollBar {
    id: control
    implicitWidth: Math.max(
                       background ? background.implicitWidth : 0,
                                    handle.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(
                        background ? background.implicitHeight : 0,
                                     handle.implicitHeight + topPadding + bottomPadding)

    padding: 2
    background: Rectangle {
        anchors.fill: parent
        border.width: 1
        border.color: "black"
        radius: 3
        visible: control.size < 1.0
    }
    handle: Rectangle {
        id: handle

        implicitWidth: 6
        implicitHeight: 6

        radius: width / 2
        color: control.pressed ? "#28282a" : "#bdbebf"
        visible: control.size < 1.0
        opacity: 1

        readonly property bool horizontal: control.orientation === Qt.Horizontal
        x: control.leftPadding + (horizontal ? control.position * control.availableWidth : 0)
        y: control.topPadding + (horizontal ? 0 : control.position * control.availableHeight)
        width: horizontal ? control.size * control.availableWidth : implicitWidth
        height: horizontal ? implicitHeight : control.size * control.availableHeight
    }
}
