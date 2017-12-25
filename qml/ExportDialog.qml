import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import "loader.js" as MyLoader
import Generator 1.0
import FileIO 1.0
Window {
    id: exportDialog
    visible: false

    title: rootParent.languageIndex === 0 ? "Project export" : "Экспорт проекта"
    minimumWidth: 300
    minimumHeight: 150
    property int myCurrentIndex
    property var rootParent
    property var filesTable    
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    onClosing: {
        if (!baseElem.enabled)
            close.accepted = false
    }
    FileIO{
        property bool filesCopied:false
        id:fileIO
        onAllFilesCopied:{

            myFilesProgress.value = 1
            filesCopied = true
            baseElem.enabled = true
            generateButton.text = Qt.binding(function () {
                return rootParent.languageIndex === 0 ? "Done..." : "Готово..."
            })
        }
        onFileCopyProgress: {
            myFilesProgress.value = progress / 100.0
        }
    }



    Rectangle {
        id: baseElem
        anchors.fill: parent
        enabled: true
        Label {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectFolderLabel
            text: rootParent.languageIndex
                  == 0 ? "Modification name:" : "Имя мода:"
        }

        Rectangle {
            id: pathRect
            anchors.left: parent.left
            anchors.top: selectFolderLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.topMargin: 5
            height: 25
            TextField {
                anchors.fill: parent
                id: pathForProject
                validator: RegExpValidator {
                    regExp: /^[^\\\/:*?<>|]+$/
                }
                text:rootParent.modName
            }
        }
        ProgressBar {
            id: myFilesProgress
            width: 180
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: pathRect.bottom
            anchors.topMargin: 15
            Text {
                id: loadFilesText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Copying files " + myFilesProgress.value * 100 + "%"
            }
        }
        Button {
            id: generateButton
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 15
            text: rootParent.languageIndex == 0 ? "Generate" : "Сгенерировать"
            enabled: pathForProject.text !== ""
            onClicked: {
                if (fileIO.filesCopied) {
                    fileIO.filesCopied = false
                    myFilesProgress.value = 0
                    generateButton.text = Qt.binding(function () {
                        return rootParent.languageIndex === 0 ? "Generate" : "Сгенерировать"
                    })
                    exportDialog.close()
                } else {
                    baseElem.enabled = false
                    generateButton.text = Qt.binding(function () {
                        return rootParent.languageIndex === 0 ? "Generating..." : "Генерируется..."
                    })
                    var exportDir=rootParent.projectFileDir;

                    var arrObj = MyLoader.exportProject(rootParent,fileIO,exportDir, pathForProject.text);
                    MyLoader.massCopyFiles(fileIO,arrObj);
                }
            }
        }
    }
}
