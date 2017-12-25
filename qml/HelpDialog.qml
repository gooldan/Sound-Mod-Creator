import QtQuick 2.0
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import QtQuick.Window 2.2
import "help.js" as Helper

Window {
    id: mydialog
    visible: false

    title: rootParent.languageIndex == 0 ? "Help" : "Справка"
    minimumWidth: 600
    minimumHeight: 280
    property int myCurrentIndex
    property var rootParent
    property var filesTable
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    Rectangle {
        id: baseElem
        anchors.fill: parent
        enabled: true
        CollapseTest{
            anchors.fill: parent
            anchors.margins: 5
            id:helpbox
            rootParent: mydialog.rootParent
        }
    }
}
