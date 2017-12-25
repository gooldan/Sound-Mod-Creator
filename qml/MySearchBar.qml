import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
Rectangle{
    property int placeToHidden
    property var scrollFunc
    property var listViewBase
    property var rootParent
    property string nameFieldRu
    property string nameFieldEn
    height:20
    radius:2
    y:placeToHidden
    visible:false
    id:searchRect
    border.color: "#333"
    border.width: 1
    Keys.onPressed: {
        if (event.key === Qt.Key_Enter || event.key == Qt.Key_Return)
        {

            scrollFunc(1)
        }
    }

    TextField{
        id: searchField
        anchors.right:myButUp.visible?myButUp.left:myBut.left
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        onTextChanged: {
            if(text.length > 0 )
            {
                var res =searchRect.filter(text);
                if(res.ans)
                {
                    myButUp.visible=  true
                    myButUp.enabled=  true
                    myButDown.visible=true
                    myButDown.enabled=true
                    searchRect.scrollFunc=res.scrollFunc
                }
                else
                {
                    searchRect.scrollFunc=function(){};
                    myButUp.visible=false
                    myButUp.enabled=false
                    myButDown.visible=false
                    myButDown.enabled=false
                }
            } else
            {
              searchRect.filter("▨");
              myButUp.visible=  true
              myButUp.enabled=  true
              myButDown.visible=true
              myButDown.enabled=true
              searchRect.scrollFunc=function(){};
            }
        }
        style: TextFieldStyle {
                textColor: "black"
                background: Rectangle {
                    radius: 2
                    implicitWidth: 100
                    implicitHeight: 24
                }
            }

    }
    Behavior on y {
                NumberAnimation{ duration: 200 }
    }
    MyRoundCloseButton{
        anchors.right: parent.right
        anchors.rightMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3
        id:myBut
        onClicked: {
            searchRect.visible=false;
        }
    }
    MyRoundCloseButton{
        anchors.right:myButDown.left
        anchors.rightMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3
        enabled:false
        visible:false
        id:myButUp
        text:"▲"
        onClicked: {
            searchRect.scrollFunc(1);
        }
    }
    MyRoundCloseButton{
        anchors.right:myBut.left
        anchors.rightMargin: 3
        anchors.top: parent.top
        anchors.topMargin: 3
        id:myButDown
        enabled:false
        visible:false
        text:"▼"
        onClicked: {
            searchRect.scrollFunc(-1);
        }
    }
    onVisibleChanged: {
                if( visible) {
                    searchField.forceActiveFocus()
                    searchRect.y=0

                }
                else
                {
                    for(var i = 0; i < listViewBase.model.count; ++i)
                    {
                        listViewBase.model.get(i).isFound=false;
                    }
                    searchField.focus=false;
                    searchRect.y=placeToHidden
                    searchField.text=""
                }

            }
    function filter(text)
    {
        var model = listViewBase.model
        var indexes = [];
        for(var i = 0; i < model.count; ++i)
        {
            var neededName = rootParent.languageIndex == 0 ? nameFieldEn : nameFieldRu
            if(model.get(i)[neededName].indexOf(text)>=0)
            {
                indexes.push(i);
                model.get(i).isFound=true;
            }
            else
            {
                model.get(i).isFound=false;
            }
            model.get(i).highlighted=false;
        }
        var currentIndex = 0;
        if(indexes.length > 0)
        {
            listViewBase.positionViewAtIndex(indexes[currentIndex],ListView.Center);
            model.get(indexes[currentIndex]).highlighted=true;
        }
        if(indexes.length < 2)
        {
            return {ans:false};
        }

        var scroll=function(dest)
        {
            if(dest>0)
            {
                model.get(indexes[currentIndex]).highlighted=false;
                currentIndex+=1;
                if(currentIndex==indexes.length)
                {
                    currentIndex = 0;
                }
                listViewBase.positionViewAtIndex(indexes[currentIndex],ListView.Center);
                 model.get(indexes[currentIndex]).highlighted=true;
            }
            else
            {
                model.get(indexes[currentIndex]).highlighted=false;
                currentIndex-=1;
                if(currentIndex==-1)
                {
                    currentIndex = indexes.length-1;
                }
                listViewBase.positionViewAtIndex(indexes[currentIndex],ListView.Center);
                model.get(indexes[currentIndex]).highlighted=true;

            }
        }
        return {ans:true,scrollFunc:scroll};
    }
    z:20
}
