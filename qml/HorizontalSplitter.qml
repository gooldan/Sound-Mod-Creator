import QtQuick 2.0

Rectangle {

    color: "black"
    height: 4
    property var upperElement
    property var bottomElement
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.SizeVerCursor
        onPositionChanged: {
            if (upperElement.height + mouse.y > upperElement.minHeight
                    && bottomElement.height - mouse.y > bottomElement.minHeight) {
                upperElement.height += mouse.y
                bottomElement.height -= mouse.y
            }
        }
    }
}
