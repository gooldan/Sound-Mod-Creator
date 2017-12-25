import QtQuick 2.0

Rectangle {
    property var rootParent
    property var myContent
    property var translation
    property int realWidth: textBody.width + 20
    id: listViewItem
    implicitWidth: 120
    implicitHeight: 20
    function getColor() {
        if (ListView.view.currentIndex === index)
            return "#54aec8"
        else if (isFound) {
            if (highlighted) {
                return "#ffff00"
            } else {
                return "#ff7700"
            }
        } else if (modified) {
            return "white"
        } else {
            return "#e5e5e5"
        }
    }

    color: getColor()
    radius: 1
    border.color: corrupted !== undefined ? (corrupted ? "red" : "black") : "black"
    border.width: 1

    clip: true
    Text {
        id: textBody
        text: rootParent.languageIndex == 0 ? nameEn : nameRu
        anchors.leftMargin: 6
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        //font.pixelSize: 16
    }

    MouseArea {
        anchors.fill: parent
        onClicked: myContent.currentIndex = index
    }
}
