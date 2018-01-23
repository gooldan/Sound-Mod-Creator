import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0

import "loader.js" as MyLoader

Rectangle {
    property var upperSlider
    property var rootParent
    property var currentAddSelection
    property var currentRemoveSelection
    property alias deleteBut: removePathButton
    property alias addBut : addPathButton
    id: precisionsBlock
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: upperSlider.bottom
    height: 401
    property int minHeight: 100
    color: "#f0f0f0"

    Rectangle {
        id: buttonRect
        height: 25
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        color: "#f0f0f0"
        Button {
            id: addPathButton
            height: parent.height - 6
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.leftMargin: 5
            enabled: false
            text: rootParent.languageIndex == 0 ? "Add path" : "Добавить путь"
            onClicked: {
                var fullArr = MyLoader.addStatePath(
                            currentAddSelection,
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex)
                for (var i = 0; i < currentAddSelection.length; ++i) {
                    rootParent.pathTableModel.append({
                                                         path: fullArr[0][i],
                                                         readEN: fullArr[1][i][0],
                                                         readRU: fullArr[1][i][1],
                                                         chainIndexes : currentAddSelection[i].toString(),
                                                         files: "",
                                                         mySuperIndex: 1,
                                                         selected : false,
                                                         history : 0
                                                     })
                    //rootParent.activated()
                }
                rootParent.activated()
                removePathButton.enabled = true
                var result = MyLoader.checkValidity(
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex, false)
                currentRemoveSelection = result.removeArr
                removePathButton.enabled = true
                addPathButton.enabled = false
                muteButton.enabled = false

            }
        }
        Button {
            id: removePathButton
            height: parent.height - 6
            anchors.left: addPathButton.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 5
            text: rootParent.languageIndex == 0 ? "Remove path" : "Удалить путь"
            enabled: false
            onClicked: {
                var indexArr = MyLoader.deletePaths(
                            currentRemoveSelection,
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex)
                for (var i in indexArr) {
                    rootParent.pathTableModel.remove(indexArr[i])
                }
                rootParent.pathTable.selection.clear();
                var result = MyLoader.checkValidity(
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex)
                var countFiles = MyLoader.calcPathCount(rootParent.currentEventDbIndex,
                                                       rootParent.tabs.currentIndex)
                if(countFiles === 0)
                {
                    rootParent.eventListModel.get(rootParent.eventList.currentIndex).modified = false;
                }
                else
                {
                    rootParent.eventListModel.get(rootParent.eventList.currentIndex).modified = true;
                }
                currentAddSelection = result.addArr
                addPathButton.enabled = true
                muteButton.enabled = true
                removePathButton.enabled = false
            }
        }
        Button {
            id: muteButton
            height: parent.height - 6
            anchors.left: removePathButton.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            anchors.topMargin: 5
            text: rootParent.languageIndex == 0 ? "Mute path" : "Заглушить путь"
            enabled: false

            onClicked: {
                var fullArr = MyLoader.addStatePath(
                            currentAddSelection,
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex, true)
                for (var i = 0; i < currentAddSelection.length; ++i) {
                    rootParent.pathTableModel.append({
                                                         path: fullArr[0][i],
                                                         readEN: fullArr[1][i][0],
                                                         readRU: fullArr[1][i][1],
                                                         chainIndexes : currentAddSelection[i].toString(),
                                                         files: "Muted",
                                                         mySuperIndex: 0,
                                                         selected : false,
                                                         history : 0
                                                     })
                    //rootParent.activated()
                }
                rootParent.activated()
                removePathButton.enabled = true
                var result = MyLoader.checkValidity(
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex)
                currentRemoveSelection = result.removeArr
                removePathButton.enabled = true
                addPathButton.enabled = false
                muteButton.enabled = false
            }
        }
        Label {
            anchors.right: parent.right
            anchors.top:parent.top
            id: xmlVersion
            visible: rootParent.modxmlVersion > 0 && rootParent.enabled
            text: (rootParent.languageIndex == 0 ?
                      "Mod.xml root version: " :
                      "Версия mod.xml: ")
                      + rootParent.modxmlVersion
        }
    }
    Rectangle {
        id: statesListRect
        anchors.left: parent.left
        anchors.top: buttonRect.bottom
        anchors.right: parent.right
        anchors.topMargin: 5
        width: parent.width
        height: parent.height - buttonRect.height
        radius: 1
        color: "#f0f0f0"
        border.color: "gray"
        border.width: 1
        ListView {
            property var myModel
            id: sampleListView
            clip: true
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 3
            width: childrenRect.width
            anchors.bottom: parent.bottom
            spacing: 6
            orientation: ListView.Horizontal

            interactive: false
            signal listClick(var arrayOfSelection, bool fromTable)
            onListClick: {
                for(var i in arrayOfSelection)
                {
                    MyLoader.selectionChanged(arrayOfSelection[i].index,
                                              arrayOfSelection[i].selected,
                                          rootParent.currentEventDbIndex,
                                          rootParent.tabs.currentIndex)
                }
                var result = MyLoader.checkValidity(
                            rootParent.currentEventDbIndex,
                            rootParent.tabs.currentIndex)
                rootParent.pathTable.selection.clear()
                if (result.addAnswer) {
                    currentAddSelection = result.addArr
                    addPathButton.enabled = true
                    muteButton.enabled = true
                } else {
                    currentAddSelection = []
                    addPathButton.enabled = false
                    muteButton.enabled = false
                }

                if (result.removeAnswer) {
                    currentRemoveSelection = result.removeArr
                    removePathButton.enabled = true
                        MyLoader.selectInTable(rootParent,
                                           rootParent.currentEventDbIndex,
                                           rootParent.tabs.currentIndex,
                                           result.removeArr)

                } else {
                    currentRemoveSelection = []
                    removePathButton.enabled = false
                }
            }
            Component.onCompleted: {
                rootParent.stateListModel = sampleModel
                rootParent.stateList = sampleListView;
                //sampleModel.append({});
            }
            ListModel {
                id: sampleModel
                property string name
                onCountChanged: {
                    addPathButton.enabled = false
                    muteButton.enabled = false
                    removePathButton.enabled = false
                }
            }
            model: sampleModel
            delegate: Item {
                    //property var nestedModel:stateValues
                    property var myName: name
                    property int childRectHeight
                    property int myCurrentIndex: index
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: myContent.childrenRect.width + 11
                    id: listDelegate
                    Rectangle {
                        anchors.top: parent.top
                        anchors.topMargin: 3
                        anchors.left: myContent.right
                        anchors.bottom: myContent.bottom
                        width: 4
                        opacity: 0
                        MouseArea {
                            id: rectMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.SizeHorCursor
                            onPositionChanged: {
                                rootParent._LOG(sampleListView.width,
                                            statesListRect.width - 10)
                                rootParent._LOG(myContent.elemWidth)
                                if (sampleListView.width + mouse.x < statesListRect.width - 10
                                        && myContent.elemWidth + mouse.x >= 120)
                                    myContent.elemWidth += mouse.x
                            }
                        }
                    }
                    ListView {
                        id: myContent
                        property bool multiselect: false
                        property int elemWidth: 120
                        signal clicked(int indexOfItem)
                        signal searchRequested(int indexOfItem,real y)
                        anchors.top: deleteRect.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: contentItem.childrenRect.width
                        //height:contentItem.childrenRect.height
                        anchors.topMargin: 3
                        anchors.leftMargin: 5
                        currentIndex: -1
                        clip: true
                        model: stateValues
                        ScrollBar.vertical: MyScrollBar {
                            clip: false
                            id: myScrollBar
                        }
                        Component.onCompleted: {
                            rootParent._LOG("appended")
                            //rootParent.stateItemListModel=stateItemListModel;
                        }


                        onCountChanged: {
                            deleteRect.y = contentItem.height + 3
                        }

                        onClicked: {
                            if(searchRect.visible==true)
                            {
                                searchRect.visible=false;

                            }
                            rootParent._LOG(indexOfItem)
                            var currentSelection = [];
                            for (var i = 0; i < model.count; ++i)
                            {
                                currentSelection.push({
                                             selected: model.get(i).selected,
                                             history : model.get(i).history
                                            })
                            }
                            var newSelectionObj = MyLoader.getSelectionFromClick(currentSelection,
                                                           indexOfItem,
                                                           rootParent.shiftIsPressed,
                                                           rootParent.controlIsPressed,
                                                           multiselect)
                            multiselect = newSelectionObj.multiselect;
                            currentSelection = newSelectionObj.newSelection;
                            var listOfSelected = newSelectionObj.listOfSelected;
                            for (var i = 0; i < model.count; ++i)
                            {
                                model.get(i).selected = currentSelection[i].selected;
                                model.get(i).history = currentSelection[i].history;
                            }
                            var returnObj = [{index : myCurrentIndex, selected:listOfSelected}];
                            sampleListView.listClick(returnObj,false)
                        }
                        onSearchRequested:{
                            searchRect.visible=true
                        }

                        delegate: MyVerticalListViewItemState {
                            id: myDelegate
                            myParent: myContent
                            rootParent: precisionsBlock.rootParent
                            newWidth: myContent.elemWidth
                            Component.onCompleted: {
                                if(realWidth > myContent.elemWidth)
                                {
                                    myContent.elemWidth = realWidth
                                }
                            }
                        }
                    }
                    MySearchBar{
                        placeToHidden:-20
                        listViewBase:myContent
                        rootParent : precisionsBlock.rootParent
                        nameFieldEn: "nameEn"
                        nameFieldRu: "nameRu"
                        width:myContent.width
                        anchors.left: myContent.left
                        id:searchRect
                    }

                    Rectangle {
                        property bool iWasClicked: false
                        id: deleteRect
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: parent.top
                        //y:myContent.height+3
                        width: deleteRect.iWasClicked ? 90 : 15
                        height: 15
                        color: "red"
                        z:10
                        Behavior on width{
                            NumberAnimation { duration: 200 }
                        }

                        Text {
                            id: textOnDelete
                            text:   deleteRect.iWasClicked ? (rootParent.languageIndex
                                                              == 0 ? "DELETE?" : "УДАЛИТЬ?") : "⛌";
                            color: "white"
                            font.letterSpacing: 2
                            font.bold: true
                            style: Text.Outline
                            styleColor: "black"
                            anchors.fill: parent
                            clip: true
                            wrapMode: Text.WordWrap
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter

                        }
                        Rectangle {
                            id: yesDelete
                            visible: deleteRect.iWasClicked
                            anchors.left: deleteRect.right
                            anchors.top: deleteRect.top
                            width: 15
                            height: 15
                            color: yesArea.containsMouse ? "#63b270" : "green"
                            Text {
                                text: rootParent.languageIndex == 0 ? "Y" : "Д"
                                color: "white"
                                font.letterSpacing: 2
                                font.bold: true
                                style: Text.Outline
                                styleColor: "black"
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                            MouseArea {
                                id: yesArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                            border.color: "black"
                            border.width: 1
                        }

                        Rectangle {
                            visible: deleteRect.iWasClicked
                            anchors.left: yesDelete.right
                            anchors.top: deleteRect.top
                            width: 15
                            height: 15
                            Text {
                                text: rootParent.languageIndex == 0 ? "N" : "Н"
                                color: "white"
                                font.letterSpacing: 2
                                font.bold: true
                                style: Text.Outline
                                styleColor: "black"
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                            MouseArea {
                                id: noArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                            border.color: "black"
                            border.width: 1
                            color: noArea.containsMouse ? "#ea7c7c" : "red"
                        }
                        border.color: "black"
                        border.width: 1
                        radius: 1
                        MouseArea {
                            id: deleteButtonMouseArea
                            anchors.left: deleteRect.left
                            anchors.top: deleteRect.top
                            height: 15
                            width: deleteRect.iWasClicked ? 120 : 15
                            //hoverEnabled: true
                            onClicked: {
                                if (yesArea.containsMouse) {
                                    MyLoader.removeItemFromChain(
                                                listDelegate.myName,
                                                rootParent.eventList.currentIndex,
                                                rootParent.tabs.currentIndex,
                                                rootParent.pathTableModel,
                                                rootParent)
                                    sampleModel.remove(index)
                                }
                                deleteRect.iWasClicked = !deleteRect.iWasClicked

                                //sampleModel.remove(index);
                            }
                        }
                    }
                }

        }
        Button {
            id: popupButton
            height: 20
            width: 35
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.left: sampleListView.right
            text: qsTr(">>")
            onClicked: {

                //                            var point = mapToItem(precisionsBlock,
                //                                                  popupButton.x+popupButton.width,
                //                                                  popupButton.y);
                if(precisionsBlock.x + sampleListView.width
                        + popupButton.width + anchors.leftMargin+200>precisionsBlock.width)
                {
                    popup.x = precisionsBlock.x + sampleListView.width - 200
                }
                else
                {
                    popup.x = precisionsBlock.x + sampleListView.width
                            + popupButton.width + anchors.leftMargin
                }
                popup.y = 0
                rootParent._LOG(precisionsBlock.x + sampleListView.width + popupButton.width,
                            0)
                popup.open()
            }
        }
        Popup {
            id: popup
            modal: true
            closePolicy: Popup.OnEscape | Popup.OnPressOutside
            onAboutToShow: {
                addStateListModel.clear()
                MyLoader.loadState(addStateListModel,
                                   rootParent.eventList.currentIndex,
                                   rootParent.eventListModel,
                                   rootParent.tabs.currentIndex)


                popup.height =  (addStateList.count>0?addStateList.count*25 :25)+ 5
                popup.width = 200
            }

            Behavior on width{
                NumberAnimation{duration: 200}
            }
            Behavior on height{
                NumberAnimation{duration: 200}
            }
            onAboutToHide:{
                popup.height = 0
                popup.width = 0
            }

            contentItem: ListView {
                id: addStateList
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: 5
                width: 200
                implicitHeight: contentItem.childrenRect.height
                spacing: 5
                currentIndex: -1
                model: ListModel {
                    id: addStateListModel

                }
                clip: true
                delegate: MyVerticalListViewItem {
                    id: stateListItem
                    width: parent.width
                    myContent: addStateList
                    rootParent: precisionsBlock.rootParent
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            addStateList.currentIndex = index
                            var t = MyLoader.addStateToStateList(
                                        rootParent,
                                        addStateListModel.get(index).name,
                                        false, rootParent.tabs.currentIndex)
                            rootParent.stateListModel.append({
                                                                 stateValues: t,
                                                                 name: addStateListModel.get(
                                                                           index).name
                                                             })
                            addStateList.currentIndex = -1
                            popup.close()
                        }
                    }
                }
            }
        }
    }
}
