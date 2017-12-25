import QtQuick 2.0
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import "loader.js" as MyLoader
import FileIO 1.0
import ConfigReader 1.0

Window {
    id: mydialog
    visible: false
    title: rootParent.languageIndex
           == 0 ? "Choose options for new project" : "Выберите опции для нового проекта"
    minimumHeight: 215
    minimumWidth: 500
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    property var rootParent
    property alias warnNewLabel: warningLabel
    property alias newProjectDirDialog: projectDirChooser
    FileIO {
        id: filemanager
    }

    Rectangle {
        id: baseRect
        property var canCreate: nameInputField.text.length > 0
                                && pathForProject.text.length > 0
        anchors.fill: parent
        Label {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectFolderLabel
            text: rootParent.languageIndex
                  == 0 ? "Select folder for project:" : "Выберите папку для проекта"
        }

        Rectangle {
            id: pathRect
            anchors.left: parent.left
            anchors.top: selectFolderLabel.bottom
            anchors.right: selectPathButton.left
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.topMargin: 5
            height: 25
            TextField {
                anchors.fill: parent
                id: pathForProject
                readOnly: true
                text: projectDirChooser.folder.toString().substring(8)
            }
        }
        Button {
            anchors.top: selectFolderLabel.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.topMargin: 5
            id: selectPathButton
            text: "..."
            width: 25
            height: 25
            onClicked: {
                projectDirChooser.open()
            }
        }
        Label {
            anchors.top: pathRect.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            id: selectNameLabel
            text: rootParent.languageIndex == 0 ? "Project name:" : "Имя проекта"
        }

        Rectangle {
            anchors.top: selectNameLabel.bottom
            anchors.left: parent.left
            anchors.right: selectPathButton.left
            anchors.leftMargin: 10
            anchors.topMargin: 5
            anchors.rightMargin: 10
            id: nameInput
            height: 25
            border.color: nameInputField.isError? "red" : "transparent"
            border.width: 2
            radius: 4
            TextField {
                property string oldValue : ""
                property bool isError: false
                id: nameInputField
                anchors.fill: parent
                anchors.margins: 2
                validator: RegExpValidator {
                    regExp: /^[^\\\/:*?<>|]+$/
                }
                onTextChanged: {
                    if (isError) {
                        text = oldValue
                        isError = false
                    }
                }
            }
        }
        CheckBox {
            id: copyOrigsBox
            anchors.top: nameInput.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 15
            checked: true
            visible: false
            text: rootParent.languageIndex == 0 ? "Copy originals" : "Скопировать файлы"
        }
        Button {
            function errorHandler(error) {
                nameInputField.oldValue = nameInputField.text
                rootParent._LOG(pathForProject.text.length + nameInputField.text.length + 2 + 12)
                switch (error) {
                case "fae":
                    //file already exists:
                    nameInputField.text = Qt.binding(function () {
                        return rootParent.languageIndex == 0 ? "Project with this name already exists in mods directory" :
                                                               "Проект с таким именем уже существует"
                    })
                    break
                case "toolong":
                    //name or path is too long
                    nameInputField.text = Qt.binding(function () {
                        return rootParent.languageIndex == 0 ? "Too long filepath!" :
                                                               "Слишком длинное имя проекта или путь до рабочей директории!"
                    })
                    break
                case "dirC":
                    //dir creation error
                    nameInputField.text = Qt.binding(function () {
                        return rootParent.languageIndex == 0 ? "There was an error on directory creation!" :
                                                               "Ошибка создания директории!"
                    })
                    break
                case "config_error":
                    nameInputField.text = Qt.binding(function () {
                        return rootParent.languageIndex == 0 ? "There was an error on reading mod.xml in World of Warships/res/banks!" :
                                                               "Ошибка чтения файла mod.xml в World of Warships/res/banks!"
                    })
                    break
                case "mod_exists":
                    nameInputField.text = Qt.binding(function () {
                        return rootParent.languageIndex == 0 ? "Modification with this name has already placed in game directory!" :
                                                               "Модификация с таким именем уже присутствует в папке с игрой."
                    })
                    break
                }
                //nameInputField.textColor = "red"
                nameInputField.selectAll()
                nameInputField.isError = true
            }

            id: okbutton
            text: "OK"
            anchors.right: cancelButton.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.rightMargin: 10
            enabled: !warningLabel.visible && baseRect.canCreate
                     && !nameInputField.isError
            width: 85
            height: 25
            onClicked: {
                if (pathForProject.text.length + nameInputField.text.length + 2 + 12 > 259) {
                    errorHandler("toolong")
                    return
                }

                var res = filemanager.createDir(pathForProject.text)
                res = filemanager.createDir(
                            pathForProject.text + "/" + nameInputField.text)
                if (res) {
                    filemanager.setSource(
                                pathForProject.text + "/" + nameInputField.text)
                    res = filemanager.createProjectFile(
                                pathForProject.text + "/" + nameInputField.text
                                + "/" + nameInputField.text + ".rvm")
                    if (res) {
                        var err = rootParent.configReader.openConfig(
                                    rootParent.cfg.configFile)
                        if (err == 0) {
                            err = rootParent.configReader.parse()
                            if (err == 0) {
                                var jsonStr = rootParent.configReader.createJSON()
                                var t = JSON.parse(jsonStr)
                                filemanager.write(jsonStr)
                                rootParent.projectFilePath = filemanager.source
                                rootParent.projectFileDir = filemanager.getFileDir(
                                            filemanager.source)
                                filemanager.createDir(
                                            rootParent.projectFileDir + "/Audio")
                                res = filemanager.createDir(
                                            rootParent.cfg.gameDir + "/res_mods")
                                if (res) {
                                    var verPath = filemanager.findLatestVersion(
                                                rootParent.cfg.gameDir + "/res_mods/")
                                    if (verPath !== "") {
                                        res = filemanager.createDir(
                                                    verPath + "/banks")
                                        res = filemanager.createDir(
                                                    verPath + "/banks/mods")
                                        res = filemanager.fileExists(
                                                    verPath + "/banks/mods/" + nameInputField.text)
                                        if (!res) {
                                            res = filemanager.createDir(
                                                        verPath + "/banks/mods/"
                                                        + nameInputField.text)
                                            if (res) {
                                                rootParent.modDirInGame = verPath
                                                        + "/banks/mods/" + nameInputField.text
                                                rootParent.modName = nameInputField.text
                                                if (copyOrigsBox.checked) {
                                                    rootParent.copyFiles = true
                                                } else {
                                                    rootParent.copyFiles = false
                                                }

                                                MyLoader.openNewProject(
                                                            t, rootParent)
                                                mydialog.close()
                                                rootParent.cfg.projectHistory.push(
                                                            rootParent.projectFilePath)
                                                if (rootParent.cfg.projectHistory.length > 10) {
                                                    rootParent.cfg.projectHistory.splice(
                                                                0, 1)
                                                }
                                                MyLoader.saveProject(
                                                            rootParent.projectFilePath,
                                                            myFile, rootParent.tabs,
                                                            rootParent)
                                                MyLoader.updateRecents(
                                                            rootParent.cfg,
                                                            rootParent.recentModel, myFile)
                                                myWindow.title = rootParent.projectFilePath + pROGRAM_VERSION_STR
                                            }
                                        } else {
                                            errorHandler("mod_exists")
                                        }
                                    }
                                    else
                                    {
                                        errorHandler("dirC")
                                    }
                                }
                                else
                                {
                                    errorHandler("dirC")
                                }
                            }
                            else
                            {
                                errorHandler("config_error")
                            }
                        }
                        else
                        {
                            errorHandler("config_error")
                        }
                    } else {
                        errorHandler("fae")
                    }
                }
                else
                {
                    errorHandler("dirC")
                }
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
            visible: true
            Text {
                id: waringntext
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: rootParent.languageIndex
                      == 0 ? "Path for the game does not set!" : "Не задан путь к игре!"
                font.pointSize: 18
            }
        }
    }
    FileDialog {
        id: projectDirChooser
        visible: false

        onAccepted: {
            rootParent.cfg.newProjDir = fileUrl.toString()
            folder = rootParent.cfg.newProjDir
            pathForProject.text = fileUrl.toString().substring(8)
        }
        folder: shortcuts.documents
        selectMultiple: false
        selectFolder: true
        selectExisting: false
    }
}
