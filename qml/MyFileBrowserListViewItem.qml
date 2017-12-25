import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    property var rootParent
    property var myContent
    property var translation
    property string onlyName: nameEn !== undefined ? nameEn.substr(
                                                         nameEn.lastIndexOf(
                                                             "/") + 1) : ""

    id: listViewItem
    width: 120
    height: 20
    color: ListView.view.currentIndex === index ? "#54aec8" : modified ? "#c0e0be" : "#e5e5e5"
    radius: 1
    border.color: corrupted ? "#dd4444" : "black"
    border.width: 2
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: myFilesProgress.left
        Text {
            function getName(name) {
                if (name === undefined)
                    return ""
                if (!myContent.empty && myContent.showNames)
                    return onlyName
                else
                    return name
            }
            id: pathid
            text: rootParent.languageIndex === 0 ? getName(
                                                       nameEn) : getName(nameRu)
            anchors.leftMargin: 6
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 6
        }
    }
    ProgressBar {
        visible: !myContent.empty && fileProgress != 1
        id: myFilesProgress
        anchors.right: parent.right
        anchors.rightMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        value: fileProgress
        width: loadFilesText.text.indexOf(
                   "%") == -1 ? loadFilesText.contentWidth + 10 : 40
        height: 18
        Text {
            id: loadFilesText
            anchors.centerIn: parent
            text: corrupted ? (rootParent.languageIndex === 0 ? "ERROR: FILE NOT FOUND" : "ОШИБКА: ФАЙЛ НЕ НАЙДЕН") : (Math.floor(myFilesProgress.value * 100) + "%")
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!myContent.empty) {
                if (myContent.currentIndex !== index) {
                    myContent.currentIndex = index
                } else {
                    myContent.currentIndex = -1
                }
            }
        }
    }
}
