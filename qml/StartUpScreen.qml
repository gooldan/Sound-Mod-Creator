import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml 2.2

ApplicationWindow{
    width: 300
    height: 300
    modality: Qt.ApplicationModal
    flags: Qt.SplashScreen
    visible: true
    Rectangle {
       id: splashRect
       anchors.fill: parent
       color: "white"
       border.width: 1
       border.color: "black"

       Text {
           id: initializationErrorMessage
           text: "This is the splash screen"
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.top: parent.top
           anchors.topMargin: 50
           font.bold: true
           font.pixelSize: 20
           color: "black"
       }

       BusyIndicator {
           id: busyAnimation
           anchors.horizontalCenter: parent.horizontalCenter
           anchors.bottom: parent.bottom
           anchors.bottomMargin: parent.height / 5
           width: parent.width / 2
           height: width
           running: true
       }
    }

    Component.onCompleted: {
        //mainWindowLoader.active = true
    }

    Loader {
        id: mainWindowLoader
        active: false
        source: "qrc:/qml/main.qml"
        asynchronous: false
        onLoaded: {
            console.log("loasded")
            item.visible = true;
        }
    }


}
