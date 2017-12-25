import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3

import QtQuick.Window 2.2
import "loader.js" as MyLoader
import FileIO 1.0

Window {
    id: mydialog
    visible: false
    title: rootParent.languageIndex
           == 0 ? "Choose file(s) for path:" : "Выберите файл(ы) для текущего пути"
    minimumWidth: 600
    minimumHeight: 200
    property int myCurrentIndex
    property var rootParent
    property var filesTable
    property var currentAddedFiles: []
    property int okIsReady: 0
    function handleWindowClosing() {
        var countFiles = MyLoader.calcPathCount(rootParent.currentEventDbIndex,
                                                rootParent.tabs.currentIndex)
        if (countFiles === 0) {
            rootParent.eventListModel.get(
                        rootParent.eventList.currentIndex).modified = false
        } else {
            rootParent.eventListModel.get(
                        rootParent.eventList.currentIndex).modified = true
        }
        var paths = MyLoader.loadPaths(rootParent.currentEventDbIndex,
                                       rootParent.tabs.currentIndex,
                                       myCurrentIndex)
        var obj = MyLoader.getFilesObj(rootParent.currentEventDbIndex,
                                       rootParent.tabs.currentIndex,
                                       myCurrentIndex)
        obj.filesNotFound = false
        for (var i in paths) {
            if (!myFile.fileExists(paths[i])) {
                obj.filesNotFound = true
            }
        }
        if (MyLoader.filesAreMissing(rootParent.currentEventDbIndex,
                                     rootParent.tabs.currentIndex,
                                     myCurrentIndex)) {
            paths = "NOT FOUND"
        }
        if (MyLoader.checkEventIsCorrupted(rootParent.currentEventDbIndex,
                                           rootParent.tabs.currentIndex)) {
            rootParent._LOG("ind - " + rootParent.eventList.currentIndex)
            rootParent.eventListModel.setProperty(
                        rootParent.eventList.currentIndex, "corrupted", true)
        } else {
            rootParent.eventListModel.setProperty(
                        rootParent.eventList.currentIndex, "corrupted", false)
        }

        filesTable.setProperty(myCurrentIndex, "files", paths.toString())
    }

    function handleNewFiles(filesArr) {
        var oldPaths = MyLoader.loadPaths(rootParent.currentEventDbIndex,
                                          rootParent.tabs.currentIndex,
                                          myCurrentIndex)
        for (var i in filesArr) {
            var fileUrl = filesArr[i].toString().substring(8)
            rootParent._LOG(fileUrl)
            if (oldPaths.indexOf(fileUrl) == -1) {
                if (MyLoader.search(fileUrl, currentAddedFiles) !== null) {
                    continue
                }
                dialogFilesModel.append({
                                            nameEn: fileUrl,
                                            nameRu: fileUrl,
                                            modified: false,
                                            fileProgress: 0,
                                            corrupted: false
                                        })
                okIsReady += 1
                var newName = fileManager.copyAudioFile(
                            fileUrl, rootParent.projectFileDir + "/Audio", true)
                currentAddedFiles.push({
                                           name: fileUrl,
                                           newName: newName
                                       })
            }
        }
    }
    onOkIsReadyChanged: {
        rootParent._LOG("OK: ", okIsReady)
    }
    onClosing: {
        mydialog.handleWindowClosing()
    }

    FileIO {
        id: fileManager
        onNamedFileCopyProgress: {
            rootParent._LOG("PROGRESS: " + progress)
            if (currentAddedFiles != null) {

                var res = MyLoader.searchWithIndex(filename, currentAddedFiles)
                if (res !== null) {
                    var index = -1
                    for (var i = 0; i < dialogFilesModel.count; ++i) {
                        if (dialogFilesModel.get(i).nameEn === filename) {
                            index = i
                            break
                        }
                    }
                    if (index == -1) {
                        return
                    }

                    if (progress > 0) {
                        dialogFilesModel.setProperty(index,
                                                     "fileProgress", progress)
                        if (progress === 1) {
                            var oldPaths = MyLoader.loadPaths(
                                        rootParent.currentEventDbIndex,
                                        rootParent.tabs.currentIndex,
                                        myCurrentIndex)
                            var newPath = rootParent.projectFileDir + "/Audio/" + res.newName
                            if (oldPaths.indexOf(newPath) === -1) {
                                oldPaths.push(newPath)
                                dialogFilesModel.setProperty(index,
                                                             "nameEn", newPath)
                                dialogFilesModel.setProperty(index,
                                                             "nameRu", newPath)
                                dialogFilesModel.setProperty(index,
                                                             "modified", true)
                            } else {
                                dialogFilesModel.remove(index)
                            }

                            currentAddedFiles.splice(res.__MY_CURRENT_INDEX, 1)
                            okIsReady -= 1
                        }
                    } else {
                        oldPaths = MyLoader.loadPaths(
                                    rootParent.currentEventDbIndex,
                                    rootParent.tabs.currentIndex,
                                    myCurrentIndex)
                        var newPath = rootParent.projectFileDir + "/Audio/" + res.newName
                        oldPaths.push(newPath)
                        dialogFilesModel.setProperty(index, "fileProgress", 0)
                        dialogFilesModel.setProperty(index, "corrupted", true)
                        dialogFilesModel.setProperty(index, "nameEn", newPath)
                        dialogFilesModel.setProperty(index, "nameRu", newPath)
                        currentAddedFiles.splice(res.__MY_CURRENT_INDEX, 1)
                        okIsReady -= 1
                    }
                }
            }
        }
    }
    modality: Qt.WindowModal
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint
    onVisibleChanged: {
        if (visible == true) {
            dialogFilesModel.clear()
            var paths = MyLoader.loadPaths(rootParent.currentEventDbIndex,
                                           rootParent.tabs.currentIndex,
                                           myCurrentIndex)

            if (paths.length == 0) {
                dialogList.empty = true
                dialogFilesModel.append({
                                            nameEn: "No files selected",
                                            nameRu: "Файлы не выбраны",
                                            tempElem: "YES",
                                            modified: false,
                                            corrupted: true,
                                            fileProgress: 0
                                        })
                dialogList.currentIndex = -1
                paths = []
            } else {
                for (var i in paths) {
                    if (paths[i] === "Muted") {
                        dialogFilesModel.append({
                                                    nameEn: "Muted",
                                                    nameRu: "Заглушено",
                                                    modified: false,
                                                    corrupted: true,
                                                    fileProgress: 1
                                                })
                    } else {
                        var exists = myFile.fileExists(paths[i])
                        dialogFilesModel.append({
                                                    nameEn: paths[i],
                                                    nameRu: paths[i],
                                                    modified: exists,
                                                    corrupted: !exists,
                                                    fileProgress: exists ? 1 : 0
                                                })
                        if (!exists) {
                            var obj = MyLoader.getFilesObj(
                                        rootParent.currentEventDbIndex,
                                        rootParent.tabs.currentIndex,
                                        myCurrentIndex)
                            obj.filesNotFound = true
                        }
                    }
                }
                dialogList.empty = false
            }
        } else {

        }
    }

    Rectangle {
        focus: true
        Keys.onPressed: {
            rootParent._LOG("ADS")
            rootParent._LOG(event.key)
            if (event.key === Qt.Key_Enter || event.key == Qt.Key_Return) {
                if (okbutton.enabled)
                    okbutton.clicked()
            }
        }
        anchors.fill: parent
        DropArea {
            anchors.fill: parent
            onEntered: {
                rootParent._LOG("[Droparea] entered")

                // Ensure at least one file is supported before accepted the drag
                var validFile = true
                for (var i = 0; i < drag.urls.length; i++) {
                    if (!validateFileExtension(drag.urls[i])) {
                        validFile = false
                        break
                    }
                }

                if (!validFile) {
                    rootParent._LOG("No valid files, refusing drag event")
                    drag.accepted = false
                    return false
                }
            }

            onExited: {
                rootParent._LOG("[Droparea] entered")
            }

            onDropped: {
                rootParent._LOG("[Droparea] dropped")
                handleNewFiles(drop.urls)
                requestActivate()
            }

            // Only MP3s
            function validateFileExtension(filePath) {
                var extension = filePath.split('.').pop()
                var valid = false
                rootParent._LOG(extension)
                if (extension == "mp3" || extension == "wav") {
                    valid = true
                }

                return valid
            }
        }
        Button {
            id: chooseButton
            anchors.margins: 10
            text: rootParent.languageIndex == 0 ? "Choose files" : "Выберите файлы"
            anchors.right: parent.right
            anchors.top: parent.top
            width: 120
            height: 25
            onClicked: {
                filesLoader.visible = true
            }
        }
        Button {
            id: okbutton
            text: "OK"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            width: 85
            height: 25
            enabled: okIsReady == 0
            onClicked: {
                mydialog.close()
            }
        }

        Button {
            id: delButton
            text: rootParent.languageIndex == 0 ? "Delete" : "Удалить"
            anchors.right: parent.right
            anchors.top: chooseButton.bottom
            anchors.margins: 10
            width: 120
            height: 25
            enabled: !dialogList.empty && dialogList.currentIndex >= 0
            onClicked: {
                var t = MyLoader.loadPaths(rootParent.currentEventDbIndex,
                                           rootParent.tabs.currentIndex,
                                           myCurrentIndex)
                var index = t.indexOf(dialogFilesModel.get(
                                          dialogList.currentIndex).nameEn)
                if (index >= 0) {
                    t.splice(index, 1)
                }
                dialogFilesModel.remove(dialogList.currentIndex)
                if (dialogFilesModel.count == 0) {
                    dialogFilesModel.append({
                                                nameEn: "No files selected",
                                                nameRu: "Файлы не выбраны",
                                                tempElem: "YES",
                                                modified: false,
                                                corrupted: true,
                                                fileProgress: 0
                                            })
                    dialogList.currentIndex = -1
                    dialogList.empty = true
                }
            }
        }
        GroupBox {
            enabled: !dialogList.empty
            title: rootParent.languageIndex == 0 ? "Show:" : "Показывать:"
            anchors.left: delButton.left
            anchors.top: delButton.bottom
            anchors.margins: 10
            ColumnLayout {
                ExclusiveGroup {
                    id: tabPositionGroup
                }
                RadioButton {
                    text: rootParent.languageIndex == 0 ? "Only names" : "Только имя"
                    checked: true
                    exclusiveGroup: tabPositionGroup
                }
                RadioButton {
                    id: fullRadioBox
                    text: rootParent.languageIndex == 0 ? "Full path" : "Полный путь"
                    exclusiveGroup: tabPositionGroup
                }
            }
        }
        ListView {
            property bool empty: true
            property bool showNames: !fullRadioBox.checked
            id: dialogList
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: okbutton.top
            anchors.right: chooseButton.left
            anchors.margins: 10
            spacing: 5
            currentIndex: -1
            Component.onCompleted: {
                empty = true
            }

            model: ListModel {
                id: dialogFilesModel
            }

            onCountChanged: {
                if (count > 1 && dialogFilesModel.get(
                            0).tempElem !== undefined) {
                    dialogFilesModel.remove(0)
                    empty = false
                }
            }

            clip: true
            delegate: MyFileBrowserListViewItem {
                rootParent: mydialog.rootParent
                myContent: dialogList
                id: stateListItem
                width: parent.width
                height: 25
            }
            ScrollBar.vertical: MyScrollBar {
                clip: false
                id: myScrollBar
            }
        }
    }

    MyFileDialog {
        id: filesLoader
        visible: false
        dialogNameFilter: ["Sound files (*.wav *.mp3)"]
        rootParent: mydialog.rootParent
        onAccepted: {
            handleNewFiles(filesLoader.fileUrls)
            if (filesLoader.fileUrls.length > 0) {
                folder = "file:///" + myFile.getFileDir(
                            filesLoader.fileUrls[0].toString().substring(8))
            }

            //okbutton.clicked()
        }
        selectMultiple: true
    }
}
