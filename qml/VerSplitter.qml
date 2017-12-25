import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml 2.2
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper

Rectangle{
    id:verSplitter
    color:"black"
    width:4
    visible: rootParent.enabled
    property var leftBlock
    property var rightBlock
    MouseArea {
        id:verMouse
        anchors.fill: parent
        cursorShape: Qt.SizeHorCursor
        onPositionChanged: {
            if(leftBlock.width + mouse.x > leftBlock.minWidth &&
                    rightBlock.width - mouse.x > rightBlock.minWidth)
            {
                leftBlock.width+=mouse.x
                rightBlock.width-=mouse.x
            }
            
        }
    }
}
