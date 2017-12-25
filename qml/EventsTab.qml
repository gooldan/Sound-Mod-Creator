import QtQuick 2.0
import QtQuick.Controls 1.5
import Qt.labs.controls 1.0
import "loader.js" as MyLoader
import QtQuick.Controls.Styles 1.4
Tab {
    id: myTab
    //title: "Red"
    property var rootParent
    property var myEventListModel
    property var myEventList
    property int maxWidth:150
    Rectangle {
        id: eventRect
        anchors.fill: parent
        color: "#f0f0f0"
        MySearchBar{
            placeToHidden:-20
            listViewBase:eventList
            rootParent : myTab.rootParent
            nameFieldEn: "nameEn"
            nameFieldRu: "nameRu"
            width:eventList.width
            anchors.left: eventList.left
            id:searchRect
        }
        ListView {
            id: eventList
            anchors.top: searchRect.visible?searchRect.bottom:parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 3
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            anchors.rightMargin: 3
            currentIndex: -1
            clip: true

            Component.onCompleted: {
                // rootParent._LOG("asd");
                myEventListModel = eventsModel
                myEventList = eventList
                rootParent.eventList = eventList
                rootParent.eventListModel = eventsModel
                //MyLoader.loadEvents(title,eventsModel);
            }

            model: ListModel {
                id: eventsModel
            }
            signal searchRequested()

            onSearchRequested: {
                searchRect.visible=true
            }

            spacing: 4
            delegate: MyVerticalListViewItem {
                rootParent: myTab.rootParent
                width: parent.width - 6
                myContent: eventList
                Component.onCompleted: {
                    if(realWidth > maxWidth)
                    {
                        maxWidth = realWidth
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if(searchRect.visible==true)
                        {
                            searchRect.visible=false;
                        }
                        if(mouse.button == Qt.LeftButton)
                        {
                        eventList.currentIndex = index
                        rootParent.currentEventDbIndex = MyLoader.getEventDbIndex(
                                    name)
                        rootParent.stateListModel.clear()
                        rootParent._LOG("asd")
                        MyLoader.loadCurrentStatesList(rootParent)
                        rootParent.descriptionText.text = Qt.binding(
                                    function () {
                                        return rootParent.languageIndex == 0 ? descEn : descRu
                                    })
                        }
                        else
                        {
                            eventList.searchRequested();
                        }

                        //rootParent.stateListModel.append({stateValues:[{name:"ASD"}]});

                        //                             rootParent._LOG(rootParent.stateListModel.get(0).nestedModel);

                        //                           MyLoader.test(rootParent);
                        //rootParent.stateItemListModel=rootParent.stateListModel[rootParent.stateListModel.count-1];
                    }
                }
            }
            ScrollBar.vertical: MyScrollBar {
                clip: false
                id: myScrollBar
            }
        }
    }
}
