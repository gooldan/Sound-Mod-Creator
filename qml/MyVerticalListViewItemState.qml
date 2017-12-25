import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    property var rootParent
    property var myParent
    //property bool selected:false;
    property var isRealElement: null
    property int newWidth: 120
    property int realWidth: textBody.width + 10
    property int realIndex: index
    function getColor() {
        if (selected)
            return "#54aec8"
        else if (isFound)
            if (highlighted)
                return "#ffff00"
            else
                return "#ff7700"
        else if (index == 0)
            return "#b5b5b5"
        else
            return "#e0e0e0"
    }

    id: listViewItem
    width: newWidth + 6
    height: 20
    color: selected ? "#54aec8" : isFound ? (highlighted ? "#ffff00" : "#ff7700") : (index == 0 ? "#b5b5b5" : "#e0e0e0")
    radius: 1
    border.width: 1
    focus: true
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        border.width: 1
        border.color: "#54aec8"
        color: "transparent"
        visible: history === 1
    }

    Text {
        id: textBody
        text: rootParent.languageIndex == 0 ? nameEn : nameRu
        anchors.leftMargin: 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 3
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            //selected = !selected
            if (mouse.button == Qt.LeftButton)
                myParent.clicked(index)
            else if (mouse.button == Qt.RightButton)
                myParent.searchRequested(index, listViewItem.y)
        }
    }
}
