import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3

Window {
    id: mydialog
    visible: false

    title: rootParent.languageIndex == 0 ? "About" : "О программе"
    minimumWidth: 320
    minimumHeight: 200
    property int myCurrentIndex
    property var rootParent
    property var filesTable
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    Rectangle {
        id: baseElem
        anchors.fill: parent
        enabled: true
        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            Text {
                wrapMode: Text.WordWrap
                width: baseElem.width
                id: smc_ver
                font.pixelSize: 15
                text: rootParent.pROGRAM_VERSION_STR.slice(3) + ". 2017."
            }
            Text {
                wrapMode: Text.WordWrap
                width: baseElem.width - 20
                id: wwiseVerLab
                font.pixelSize: 15
                text: rootParent.languageIndex == 0 ? "Supported WWISE version: 2016.2.1.5995" : "Поддерживаемая версия WWISE: 2016.2.1.5995"
            }
            Text {
                wrapMode: Text.WordWrap
                width: baseElem.width- 20
                id: ffmpeg
                font.pixelSize: 15
                text: rootParent.languageIndex == 0 ? "You may reach developer of this program via this e-mail: " : "Связаться с разработчиком этой программы: "
            }
            Text {
                wrapMode: Text.WordWrap
                id: ff2mpeg
                font.pixelSize: 15
                width: baseElem.width- 20
                text: "<a href=\"mailto:soundmodscreator@gmail.com\">" + "soundmodscreator@gmail.com</a>"
                onLinkActivated: {
                    Qt.openUrlExternally("mailto:soundmodscreator@gmail.com")
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            Text {
                wrapMode: Text.WordWrap
                width: baseElem.width- 20
                id: ffmpeg_legal
                text: "This software uses FFmpeg executable under the LGPLv2.1"
            }
            CheckBox{
                text:"Expert mode"
                checked: false
                onCheckedChanged: {
                    advanced_user = !advanced_user
                }
            }
        }
    }
}
