import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtQml 2.2
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper

Window {
    property string errorVersion: ""
    property string currentVersion : pROGRAM_VERSION_STR.slice(pROGRAM_VERSION_STR.lastIndexOf(' ')+1)
    property alias showAgaing: showAgainCheck
    property alias messageText: info.text
    width: 200
    height: 150
    minimumWidth: 200
    minimumHeight: 120
    id:errorDialog
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint
    modality: Qt.WindowModal
    onVisibleChanged: {
        okbut.forceActiveFocus()
    }

    Rectangle{
        anchors.left: parent.left
        anchors.top: parent.top
        width:errorDialog.width
        height: errorDialog.height
        Rectangle{
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            height: info.paintedHeight
            Text{
                anchors.centerIn: parent
                id:info
                font.pixelSize: 14
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
        CheckBox{
            visible: false
            anchors.bottom: okbut.top
            anchors.margins: 10
            anchors.horizontalCenter: parent.horizontalCenter
            id:showAgainCheck
            text:rectangle1.languageIndex == 0 ? "Do not show again" : "Не показывать снова"
            checked: false

        }
        Button{
            id:okbut
            text:"OK"
            anchors.bottom: parent.bottom
            anchors.margins: 10
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                errorDialog.close()
            }
        }
    }

}
