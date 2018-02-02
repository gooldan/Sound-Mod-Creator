import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml 2.2
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper

TabView {
    id:tabs
    width: minWidth
    property int minWidth:150

    EventsTab{
        title:"Voice"
        rootParent: tabs.rootParent
    }
    EventsTab{
        title:"SFX"
        rootParent: tabs.rootParent
    }
    EventsTab{
        title:"Loop"
        rootParent: tabs.rootParent
    }
    onCurrentIndexChanged: {
        if(rootParent.enabled)
        {
            var model=tabs.getTab(currentIndex).myEventListModel
            model.clear();
            rootParent.eventList=tabs.getTab(currentIndex).myEventList;
            rootParent.eventListModel=model;
            rootParent.stateListModel.clear();
            rootParent.pathTable.selection.clear();
            MyLoader.loadEvents(tabs.getTab(currentIndex).title,model,currentIndex);
            rootParent.eventList.currentIndex=-1;
            rootParent._LOG(tabs.getTab(currentIndex).width)
        }
    }
    Component.onCompleted: {
        rootParent.tabs=tabs;
    }
    
}
