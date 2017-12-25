import QtQuick 2.0

ListView{
    property string myDataStringEN:"";
    property string myDataStringRU:"";
    property var myDataEN:[]
    property var myDataRU:[]
    property int myRowIndex:styleData.row
    property int myWidth:15;
    property var rootParent
    property var myTable
    property var pathCol
    id:pathList
    interactive: false
    anchors.fill:parent
    spacing:0
    orientation: ListView.Horizontal
    signal temp()
    Component.onCompleted: {
        rootParent.activated.connect(temp);
        myDataStringEN=myTable.model.get(styleData.row).readEN;
        myDataStringRU=myTable.model.get(styleData.row).readRU;
    }
    onTemp: {
        if(myTable.model.count > 0)
        {
            myDataStringEN=myTable.model.get(styleData.row).readEN;
            myDataStringRU=myTable.model.get(styleData.row).readRU;
        }
    }

    onMyDataStringRUChanged: {
        myDataEN=myDataStringEN.split('.');
        myDataRU=myDataStringRU.split('.');
        rowModel.clear()
        for(var i in myDataEN)
        {
            rowModel.append({});
        }
    }

    ListModel{
        id:rowModel
    }
    width:{
        if(contentItem.childrenRect.width > pathCol.maxElemWidth)
        {
            pathCol.maxElemWidth=contentItem.childrenRect.width
        }
        return contentItem.childrenRect.width;
    }

    model:rowModel
    delegate:
        Item{
            property bool isLast: index==rowModel.count-1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            clip:true
            width:innerText.paintedWidth+4+5
            id:listelem
            Rectangle
            {
                id:textRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: rightRect.left
                border.width: 1
                border.color: "black"
                width:innerText.paintedWidth+4
                Text{
                    id:innerText
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip: true
                    text:{
                        if(myDataEN[index]!==undefined)
                            return rootParent.languageIndex == 0 ? myDataEN[index] : myDataRU[index]
                        else
                            return "";
                    }
                }
                radius: 3
            }
            Rectangle
            {
                id:rightRect
                height:2
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width:5
                color: "black"
                visible: !listelem.isLast
            }
        }
    }

