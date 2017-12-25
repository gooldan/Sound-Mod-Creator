import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml 2.2
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper

MenuBar {
    id: myMenuBar
    property var rootParent: rectangle1
    property alias globalStateMenuModel: globalStateMenuModel
    property alias recentModel: recentModel
    Menu {
        title: myMenuBar.rootParent.languageIndex == 0 ? "File" : "Файл"
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "New project" : "Новый проект"
            onTriggered: {
                newProjDialog.show()
            }
        }

        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Load project" : "Загрузить проект"
            onTriggered: {
                projectLoader.open()
            }
            enabled: !myMenuBar.rootParent.warnNewLab.visible
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Save project" : "Сохранить проект"
            onTriggered: {
                MyLoader.saveProject(myMenuBar.rootParent.projectFilePath,
                                     myFile, tabs, myMenuBar.rootParent)
                errorWindow.messageText = rootParent.languageIndex == 0 ? "Saved!" : "Сохранено!"
                errorWindow.showAgaing.visible = true
                if (!errorWindow.showAgaing.checked) {
                    errorWindow.width = 200
                    errorWindow.height = 120
                    errorWindow.show()
                }
                //projectSaver.open()
            }
            enabled: myMenuBar.rootParent.enabled
        }

        MenuItem{
            text:myMenuBar.rootParent.languageIndex == 0 ? "Close project" : "Закрыть проект"
            enabled: rootParent.enabled
            onTriggered: {
                rootParent.eventListModel.clear();
                rootParent.eventList.currentIndex = -1
                rootParent.stateListModel.clear()
                rootParent.pathTableModel.clear()
                myMenuBar.rootParent.projectFilePath == ""
                rootParent.enabled = false
            }
        }
        MenuSeparator {
        }
        Menu {
            id: recentMenu
            title: myMenuBar.rootParent.languageIndex == 0 ? "Recent projects" : "Последние проекты"
            enabled: !myMenuBar.rootParent.warnNewLab.visible
            Instantiator {
                id: recent
                MenuItem {
                    id: recentMenuItem
                    property var rootParent
                    property string trueUrl
                    Component.onCompleted: {
                        recentMenuItem.errorWindow = myWindow.errorWindow
                    }
                    property var errorWindow
                    onTriggered: {
                        var newDb = MyLoader.getDbFromfile(trueUrl, myFile)
                        if (!newDb.hasOwnProperty("events")) {
                            rootParent.cfg.projectHistory.splice(index, 1)
                            recentMenu.removeItem(index)
                            recentModel.remove(index)
                            return
                        }
                        if (MyLoader.checkModGameDir(rootParent, myFile,
                                                     newDb.modName) === false) {
                            return
                        }
                        //var loadedProjDir = myFile.getFileDir(trueUrl)
                        var res = MyLoader.loadProject(newDb, tabs, rootParent)
                        if (res.ans === false) {
                            rootParent.cfg.projectHistory.splice(index, 1)
                            recentMenu.removeItem(index)
                            recentModel.remove(index)
                            if (res.ver === "cfg file error") {
                                errorWindow.messageText = res.ver
                            } else {
                                errorWindow.messageText = Helper.incompatibleVersion(
                                            rootParent.languageIndex, res.ver.slice(res.ver.lastIndexOf(' ')+1),
                                            rootParent.pROGRAM_VERSION_STR.slice(
                                                rootParent.pROGRAM_VERSION_STR.lastIndexOf(
                                                    ' ')+1))
                            }
                            errorWindow.width = 580
                            errorWindow.height = 120
                            errorWindow.showAgaing.visible = false
                            errorWindow.show()
                            return
                        }
                        rootParent.pathTable.selection.clear()
                        rootParent.projectFilePath = trueUrl
                        rootParent.projectFileDir = myFile.getFileDir(trueUrl)
                        myWindow.title = rootParent.projectFilePath + pROGRAM_VERSION_STR
                    }
                }
                model: ListModel {
                    id: recentModel
                }
                onObjectAdded: {
                    object.rootParent = myMenuBar.rootParent
                    object.text = recentModel.get(index).text
                    object.trueUrl = recentModel.get(index).url
                    recentMenu.insertItem(index, object)
                }
            }
        }
        MenuSeparator {
        }
        MenuItem {

            text: myMenuBar.rootParent.languageIndex == 0 ? "Generate mod" : "Сгенерировать мод"
            onTriggered: {
                //messageDialog.genNext = true;
                //messageDialog.show()/*
                var func = function () {
                    return false
                }
                var res = MyLoader.cleanUpFiles(myMenuBar.rootParent, myFile,
                                                function () {}, func)
                if (res) {
                    genDialog.show()
                } else {
                    messageDialog.show()
                }
            }
            enabled: !settingsDialog.warnWwiseLabel.visible
                     && myMenuBar.rootParent.projectFilePath !== ""
                     && !settingsDialog.warnWwiseProjLabel.visible
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex
                  == 0 ? "Check and cleanup" : "Проверка и очистка"
            onTriggered: {
                messageDialog.show()
            }
            enabled: myMenuBar.rootParent.enabled
        }
        MenuSeparator {
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Export project" : "Экспорт проекта"
            enabled: myMenuBar.rootParent.projectFilePath !== ""
                     && !myMenuBar.rootParent.warnNewLab.visible
            onTriggered: {
                expDialog.show()
            }
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Import project" : "Импорт проекта"
            enabled: !myMenuBar.rootParent.warnNewLab.visible
            onTriggered: {
                importProjectFileChooser.open()
            }
        }
    }
    Menu {
        title: myMenuBar.rootParent.languageIndex == 0 ? "Options" : "Опции"
        iconSource: "warning.png"
        iconName: "warning.png"
        Component.onCompleted: {
            myMenuBar.rootParent._LOG(iconSource)
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Settings" : "Настройки"
            onTriggered: {
                settingsDialog.show()
            }
        }
        MenuSeparator {
        }
        Menu {
            title: myMenuBar.rootParent.languageIndex == 0 ? "Language" : "Язык"
            MenuItem {
                text: "English"
                onTriggered: {
                    myMenuBar.rootParent.languageIndex = 0
                    myMenuBar.rootParent.cfg.languageIndex = 0
                }
            }
            MenuItem {
                text: "Русский"
                onTriggered: {
                    myMenuBar.rootParent.languageIndex = 1
                    myMenuBar.rootParent.cfg.languageIndex = 1
                }
            }
        }
        Menu {
            id: appendStateMenu
            visible: advanced_user
            title: myMenuBar.rootParent.languageIndex
                   == 0 ? "Append global state" : "Добавить глобальное состояние"
            enabled: myMenuBar.rootParent.enabled
                     && myMenuBar.rootParent.projectFilePath !== ""
            Instantiator {
                id: globalStateMenu
                Menu {
                    id: currentStateMenu
                    property var rootParent
                    property string statesNames
                    property alias namesInstance: currentStateModel
                    property string myTextRu
                    property string myTextEn
                    title: rootParent.languageIndex == 0 ? myTextEn : myTextRu
                    Instantiator {
                        id: namesInstatinator
                        MenuItem {
                            property string myTextRu
                            property string myTextEn
                            property var rootParent
                            text: rootParent.languageIndex == 0 ? myTextEn : myTextRu
                            onTriggered: {
                                MyLoader.appendGlobalState(
                                            rootParent,
                                            currentStateMenu.title, text)
                                rootParent.eventList.currentIndex = -1
                                rootParent.stateListModel.clear()
                                rootParent.pathTableModel.clear()
                            }
                        }
                        model: ListModel {
                            id: currentStateModel
                        }
                        onObjectAdded: {
                            var list = currentStateModel.get(
                                        index).text.split(';')
                            object.myTextEn = list[0]
                            object.myTextRu = list[1]
                            object.rootParent = rootParent
                            currentStateMenu.insertItem(index, object)
                        }
                    }
                }
                model: ListModel {
                    id: globalStateMenuModel
                }
                onObjectAdded: {
                    object.rootParent = myMenuBar.rootParent
                    var titleList = globalStateMenuModel.get(
                                index).text.split(';')
                    object.myTextEn = titleList[0]
                    object.myTextRu = titleList[1]
                    object.statesNames = globalStateMenuModel.get(
                                index).statesNames
                    var list = object.statesNames.split(",")
                    for (var i in list) {
                        object.namesInstance.append({
                                                        text: list[i]
                                                    })
                    }
                    appendStateMenu.insertItem(index, object)
                }
            }
        }
    }
    Menu {
        title: myMenuBar.rootParent.languageIndex == 0 ? "Help" : "Справка"
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "Content" : "Содержание"
            onTriggered: {
                helpDialog.show()
            }
        }
        MenuItem {
            text: myMenuBar.rootParent.languageIndex == 0 ? "About" : "О программе"
            onTriggered: {
                aboutDialog.show()
            }
        }
    }
}
