import QtQuick 2.0
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import "loader.js" as MyLoader
import FileIO 1.0
import Qt.labs.settings 1.0
import QtQuick.Window 2.2

Window {
    id: mydialog
    visible: false
    title: rootParent.languageIndex == 0 ? "Settings" : "Настройки"
    minimumWidth: 500
    minimumHeight: 310
    property var rootParent
    property alias textOfPath: pathForClient.text
    property alias textOfWwisePath: pathForWwise.text
    property alias warnLabel: warningLabel
    property alias warnWwiseLabel: warningWwiseLabel
    property alias clientFileDialog: clientFolderSelector
    property alias wwiseDirDialog: wwiseFolderSelector
    property alias wwiseProjFileDialog: wwiseProjectFileSelector
    property alias warnWwiseProjLabel: warningWwiseProjLabel
    //property alias language: languageCombo
    property alias textOfWwiseProjPath: pathForWwiseProj.text
    //modality: Qt.WindowModal

    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    FileIO {
        id: filemanager
    }
    Rectangle {

        anchors.fill: parent
        Label {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectClientLabel
            text: rootParent.languageIndex == 0 ? "Client folder:" : "Папка с игрой"
        }
        Label {
            anchors.top: clientPath.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectWwiseLabel
            text: rootParent.languageIndex == 0 ? "Wwise folder:" : "Папка WWise"
        }
        Label {
            anchors.top: wwiseRect.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectWwiseProjLabel
            text: rootParent.languageIndex == 0 ? "Wwise project file:" : "Файл проекта Wwise"
        }
        Button {
            anchors.top: selectClientLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.topMargin: 5
            id: selectClientFolderButton
            text: "..."
            width: 25
            height: 25
            onClicked: {
                clientFolderSelector.open()
            }
        }
        Button {
            anchors.top: selectWwiseLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.topMargin: 5
            id: selectWwiseFolderButton
            text: "..."
            width: 25
            height: 25
            onClicked: {
                wwiseFolderSelector.open()
            }
        }
        Button {
            anchors.top: selectWwiseProjLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.topMargin: 5
            id: selectWwiseProjFolderButton
            text: "..."
            width: 25
            height: 25
            onClicked: {
                wwiseProjectFileSelector.open()
            }
        }
        Rectangle {
            id: clientPath
            anchors.left: parent.left
            anchors.top: selectClientLabel.bottom
            anchors.right: selectClientFolderButton.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            height: 25
            TextField {
                anchors.fill: parent
                id: pathForClient
                readOnly: true
                Component.onCompleted: {

                }
            }
        }
        Rectangle {
            id: wwiseRect
            anchors.left: parent.left
            anchors.top: selectWwiseLabel.bottom
            anchors.right: selectWwiseFolderButton.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            height: 25
            TextField {
                anchors.fill: parent
                id: pathForWwise
                readOnly: true
            }
        }
        Rectangle {
            id: wwiseProjRect
            anchors.left: parent.left
            anchors.top: selectWwiseProjLabel.bottom
            anchors.right: selectWwiseProjFolderButton.left
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            height: 25
            TextField {
                anchors.fill: parent
                id: pathForWwiseProj
                readOnly: true
            }
        }
        Label {
            id: convLabel
            anchors.left: parent.left
            anchors.verticalCenter: conversionCombo.verticalCenter
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            text: rootParent.languageIndex == 0 ? "Conversion: " : "Формат: "
        }
        ComboBox {
            id: conversionCombo
            anchors.left: convLabel.right
            anchors.top: wwiseProjRect.bottom
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 5
            width: 170
            model: ["WOWS_WEM_CONVERSION"]
            onCurrentIndexChanged: {
                if (rootParent !== undefined) {

                    //rootParent.cfg.conversion=model.get(currentIndex).toString();
                }
            }
        }
//        Label {
//            id: langLabel
//            anchors.left: parent.left
//            anchors.verticalCenter: languageCombo.verticalCenter
//            anchors.leftMargin: 10
//            anchors.rightMargin: 10
//            anchors.topMargin: 5
//            text: rootParent.languageIndex == 0 ? "Language: " : "Язык: "
//        }

//        ComboBox {
//            id: languageCombo
//            anchors.left: langLabel.right
//            anchors.top: conversionCombo.bottom
//            anchors.leftMargin: 10
//            anchors.rightMargin: 10
//            anchors.topMargin: 5
//            width: 85
//            model: ["English", "Русский"]
//            onCurrentIndexChanged: {
//                if (rootParent !== undefined) {
//                    rootParent.languageIndex = currentIndex
//                    rootParent.cfg.languageIndex = currentIndex
//                }
//            }
//        }
        Rectangle {
            id: warningWwiseLabel
            color: "orange"
            anchors.right: cancelButton.right
            anchors.bottom: warningLabel.top
            anchors.bottomMargin: 5
            width: waringntext.paintedWidth + 6
            height: waringntext.paintedHeight + 4
            border.color: "black"
            border.width: 1
            radius: 2
            Text {
                id: waringWwisentext
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: rootParent.languageIndex
                      == 0 ? "Can not find wwise-cli!" : "Не могу найти wwise-cli!"
                font.pointSize: 15
            }
        }
        Rectangle {
            id: warningWwiseProjLabel
            color: "orange"
            anchors.right: cancelButton.right
            anchors.bottom: warningWwiseLabel.top
            anchors.bottomMargin: 5
            width: waringWwiseProjtext.paintedWidth + 6
            height: waringWwiseProjtext.paintedHeight + 4
            border.color: "black"
            border.width: 1
            radius: 2
            visible: pathForWwiseProj.text == ""
            Text {
                id: waringWwiseProjtext
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: rootParent.languageIndex
                      == 0 ? "Wwise project is not set!" : "Файл проекта Wwise не выбран!"
                font.pointSize: 15
            }
        }
        Rectangle {
            id: warningLabel
            color: "orange"
            anchors.right: cancelButton.right
            anchors.bottom: okbutton.top
            anchors.bottomMargin: 5
            width: waringntext.paintedWidth + 6
            height: waringntext.paintedHeight + 4
            border.color: "black"
            border.width: 1
            radius: 2
            Text {
                id: waringntext
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: rootParent.languageIndex
                      == 0 ? "Can not find config file!" : "Конфигурационный файл не найден!"
                font.pointSize: 15
            }
        }
        Button {
            id: okbutton
            text: "OK"
            anchors.right: cancelButton.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.rightMargin: 10
            width: 85
            height: 25

            onClicked: {
                mydialog.close()
            }
        }
        Button {
            id: cancelButton
            text: rootParent.languageIndex == 0 ? "Cancel" : "Отмена"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.rightMargin: 10
            width: 85
            height: 25
            onClicked: {
                mydialog.close()
            }
        }
    }
    FileDialog {
        id: clientFolderSelector
        visible: false

        onAccepted: {
            pathForClient.text = fileUrl.toString().substring(8)
            rootParent.cfg.gameDir = pathForClient.text
            folder = fileUrl
            if (filemanager.fileExists(
                        rootParent.cfg.gameDir + "/res/banks/mod.xml")) {
                warningLabel.visible = false
                rootParent.warnNewLab.visible = false
                rootParent.cfg.configFile = rootParent.cfg.gameDir + "/res/banks/mod.xml"
            } else {
                warningLabel.visible = true
                rootParent.warnNewLab.visible = true
                rootParent.cfg.configFile = ""
            }
        }
        selectMultiple: false
        selectFolder: true
    }
    FileDialog {
        id: wwiseFolderSelector
        visible: false

        onAccepted: {
            pathForWwise.text = fileUrl.toString().substring(8)
            rootParent.cfg.wwiseDir = fileUrl.toString().substring(8)
            folder = fileUrl
            if (filemanager.fileExists(
                        rootParent.cfg.wwiseDir + "/WwiseCLI.exe")) {
                warningWwiseLabel.visible = false
                rootParent.cfg.wwiseExe = rootParent.cfg.wwiseDir + "/WwiseCLI.exe"
            } else {
                warningWwiseLabel.visible = true
                rootParent.cfg.wwiseExe = ""
            }
        }
        selectMultiple: false
        selectFolder: true
    }
    FileDialog {
        id: wwiseProjectFileSelector
        visible: false

        onAccepted: {
            folder = fileUrl
            pathForWwiseProj.text = fileUrl.toString().substring(8)
            rootParent.cfg.wwiseProjFile = fileUrl.toString().substring(8)
            warningWwiseProjLabel.visible=false;
        }
        selectMultiple: false
        nameFilters: ["Wwise project file (*.wproj)"]
    }
}
