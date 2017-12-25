import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml 2.2
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper
import QtQuick.Window 2.2

Window {
    property var rootParent
    property alias missingListModel: missingListModel_p
    property bool isCorrupted: false
    property bool isFinished: false
    id: messageDialog
    title: isCorrupted ? (rootParent.languageIndex
                          == 0 ? "Error" : "Ошибка") : (rootParent.languageIndex
                                                        == 0 ? "Checking" : "Проверка")
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    minimumWidth: 600
    minimumHeight: isCorrupted ? 250 : 180
    function progressCallback(val) {
        myFilesProgress.value = val
        return true
    }

    function missFileCallback(res) {
        isCorrupted = true

        missingListModel.append({
                                    myTextRu: res[1],
                                    myTextEn: res[0]
                                })
        return true
        //lostFiles.push(res)
    }

    onVisibleChanged: {
        if (visible) {
            isCorrupted = false
            isFinished = false
            myFilesProgress.value = 0
            rootParent.eventList.currentIndex = -1
            rootParent.stateListModel.clear()
            rootParent.pathTableModel.clear()
            missingListModel.clear()

            var res = MyLoader.cleanUpFiles(rootParent, myFile,
                                            progressCallback, missFileCallback)
            isFinished = true
        }
    }

    Rectangle {
        anchors.fill: parent
        ProgressBar {
            id: myFilesProgress
            width: parent.width - 200
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 15
            value: 0
            Text {
                id: loadFilesText
                anchors.centerIn: parent
                text: rootParent.languageIndex
                      == 0 ? "Checking and cleaning things up: " + Math.floor(
                                 myFilesProgress.value * 100)
                             + "%" : "Проверка и очистка рабочей директории: " + Math.floor(
                                 myFilesProgress.value * 100) + "%"
            }
        }

        Label {
            function getText() {
                if (isCorrupted)
                    return rootParent.languageIndex == 0 ? "Audio files are missing for following paths:" : "Отсутствуют аудиофайлы для следующих путей:"
                else
                    return rootParent.languageIndex == 0 ? "Project is valid, no errors." : "Проект проверен. Ошибки отсутствуют."
            }

            id: lab
            visible: isFinished || isCorrupted
            text: getText()
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: myFilesProgress.bottom
            anchors.margins: 10
            font.pixelSize: 20
        }
        Rectangle {
            id: listrect
            visible: isCorrupted
            anchors.margins: 10
            anchors.top: lab.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: okbut.top
            color: "#eeeeee"
            clip: true
            border.width: 2
            border.color: "black"
            ListView {
                anchors.fill: parent
                spacing: 3
                id: missingFilesList
                model: ListModel {
                    id: missingListModel_p
                }
                delegate: Rectangle {
                    id: rowDel
                    color: "transparent"
                    border.width: 2
                    border.color: "black"
                    height: 25
                    width: rectEv.width + rectSt.width + 18
                    x: 4
                    function getEventName(text) {
                        var t = text.substr(0, text.indexOf(';'))
                        rootParent._LOG(t)
                        return t
                    }
                    function getStateNames(text) {
                        return text.substr(text.indexOf(';') + 1)
                    }
                    property string fullText: rootParent.languageIndex == 0 ? myTextEn : myTextRu
                    property string event: rowDel.getEventName(fullText)
                    property string states: rowDel.getStateNames(fullText)
                    Rectangle {
                        id: rectEv
                        border.width: 1
                        border.color: "blue"
                        width: evText.paintedWidth + 4
                        height: evText.paintedHeight + 4
                        radius: 2
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            anchors.margins: 2
                            id: evText
                            text: rowDel.event
                            font.pixelSize: 16
                        }
                    }
                    Rectangle {
                        id: rectSt
                        border.width: 1
                        border.color: "red"
                        width: stText.paintedWidth + 4
                        height: stText.paintedHeight + 4
                        radius: 2
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            id: stText
                            text: rowDel.states
                            font.pixelSize: 16
                        }
                    }
                }
                ScrollBar.vertical: MyScrollBar {
                    clip: false
                    id: myScrollBar
                }
            }
        }
        Button {
            id: okbut
            anchors.margins: 10
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "OK"
            onClicked: {
                messageDialog.visible = false
            }
        }
    }
}
