import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import "loader.js" as MyLoader
import FileIO 1.0
import "help.js" as Helper

Window {
    id: restoreDialog
    visible: false

    title: rootParent.languageIndex === 0 ? "Project restore" : "Восстановление проекта"
    minimumWidth: 470
    minimumHeight: 350
    property var rootParent
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    onVisibleChanged: {
        if (visible) {
            restoreModel.clear()
            var content = JSON.parse(
                        myFile.getDirectoryContent(rootParent.projectFileDir+"/Backups", true))
            var filelist = content.fileList
            for(var i = 0; i< filelist.length;++i)
            {
                var fileInfo = filelist[i].substring(filelist[i].indexOf(".rvb")+4)
                var date = new Date(Number(fileInfo));
                var dateMonth = "0"+date.getUTCMonth()+1
                var dateDay= "0"+date.getUTCDate()
                var hours = "0"+date.getHours();
                var minutes = "0"+date.getMinutes();
                var seconds = "0"+date.getSeconds();
                restoreModel.append({"filename":dateDay.substr(-2)+
                                                "."+dateMonth.substr(-2)+
                                                " "+hours.substr(-2)+
                                                ":"+minutes.substr(-2)+
                                                ":"+seconds.substr(-2),
                                     "filepath":filelist[i]
                                    })
            }
        }
    }
    Rectangle {
        id: contentRect
        anchors.margins: 10
        anchors.fill: parent
        Label {
            text: rootParent.languageIndex === 0 ? "Project versions available to restore:" : "Доступные для восстановления файлы проекта:"
            anchors.margins: 5
            anchors.top: parent.top
            anchors.left: parent.left
            font.pixelSize: 20
            id:textlab
        }
        ListModel {
            id: restoreModel
        }
        Rectangle{
            id:innerrect
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: restorBut.top
            anchors.top: textlab.bottom
            anchors.margins: 10
            color: "transparent"
            radius: 2
            border.width:2
            ListView {
                currentIndex: -1
                clip: true
                anchors.margins: 5
                anchors.fill: parent
                spacing: 5
                id:listView
                model: restoreModel
                delegate: Rectangle {
                    anchors.margins: 4
                    id:displayRect
                    width: text.contentWidth+8
                    height: text.contentHeight+4
                    radius: 2
                    color: ListView.isCurrentItem? "#b8f2a4" :"transparent"
                    border.width: 2
                    border.color: ListView.isCurrentItem? "green" : "black"
                    Text {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 1
                        anchors.leftMargin: 5
                        id: text
                        text: rootParent.modName +".rvm saved at: " + filename
                        font.pixelSize: 14
                    }
                    MouseArea{
                        id:area
                        anchors.fill: parent
                        onClicked: {
                            if(listView.currentIndex == index)
                            {
                                listView.currentIndex = -1
                            }
                            else
                            {
                                listView.currentIndex = index
                            }
                        }
                    }
                }
                ScrollBar.vertical: MyScrollBar {
                    clip: false
                    id: myScrollBar
                }
            }
        }
        Button{
            id:restorBut
            anchors.bottom: parent.bottom
            anchors.right: deleteBut.left
            anchors.margins: 10
            width: 85
            height: 25
            text:  rootParent.languageIndex === 0 ? "Restore" : "Восстановить"
            enabled: listView.currentIndex>=0
            onClicked: {
                MyLoader.saveProject(
                            rootParent.projectBackupPath,
                            myFile, rootParent.tabs,
                            rootParent)
                var fileUrlChosen = restoreModel.get(listView.currentIndex).filepath
                var newDb = MyLoader.getDbFromfile(fileUrlChosen,myFile)
                var loadedProjDir = myFile.getFileDir(fileUrlChosen)
                rootParent.pathTable.selection.clear()
                var res = MyLoader.loadProject(newDb,tabs,
                                               rootParent,rootParent.projectFileDir,
                                               myFile);
                if(res.ans === false)
                {
                    errorWindow.messageText = Helper.incompatibleVersion(
                                rootParent.languageIndex,
                                res.ver.slice(res.ver.lastIndexOf(' ')+1),
                                rootParent.pROGRAM_VERSION_STR.slice(
                                    rootParent.pROGRAM_VERSION_STR.lastIndexOf(
                                        ' ')+1))
                    errorWindow.showAgaing.visible = false
                    errorWindow.width = 580
                    errorWindow.height = 120
                    errorWindow.show();
                    return
                }
                restoreDialog.close()
            }
        }
        Button{
            id:deleteBut
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 10
            width: 85
            height: 25
            text:  rootParent.languageIndex === 0 ? "Delete" : "Удалить"
            enabled: listView.currentIndex>=0
            onClicked: {
                var fileUrlChosen = restoreModel.get(listView.currentIndex).filepath
                if(myFile.removeFile(fileUrlChosen))
                {
                    restoreModel.remove(listView.currentIndex)
                }
            }
        }
    }
}
