import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import "loader.js" as MyLoader
import Generator 1.0

Window {
    id: mydialog
    visible: false

    title: rootParent.languageIndex === 0 ? "Mod generation" : "Генерация мода"
    minimumWidth: 450
    minimumHeight: 350
    property int myCurrentIndex
    property var rootParent
    property var filesTable
    modality: baseElem.enabled? Qt.NonModal : Qt.WindowModal
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    onClosing: {
        if (!baseElem.enabled)
            close.accepted = false
        else {
            wwiseOutText.text = "WWISE is ready to run."
            if (generator.filesCopied && generator.modCreated) {
                generator.filesCopied = false
                generator.modCreated = false
                myProgress.value = 0
                myFilesProgress.value = 0
                if (generator.wasError) {
                    generateButton.text = Qt.binding(function () {
                        return rootParent.languageIndex === 0 ? "Generate" : "Сгенерировать"
                    })
                }
            }
        }
    }

    Generator {
        property bool modCreated: false
        property bool filesCopied: false
        property bool wasError: false
        id: generator
        onFileCopyProgress: {
            myFilesProgress.value = progress / 100.0
        }
        function displayResultText()
        {
            if (generator.wasError) {
                generateButton.text = Qt.binding(function () {
                    return rootParent.languageIndex === 0 ? "Error..." : "Ошибка..."
                })
                errorRect.border.color="red"
            }
            else
            {
                generateButton.text = Qt.binding(function () {
                    return rootParent.languageIndex === 0 ? "Done..." : "Готово..."
                })
                errorRect.border.color="#00B000"
                genDone.visible = true
                genPath.text = rootParent.modDirInGame
                genPath.selectAll()
            }
        }

        onAllFilesCopied: {
            myFilesProgress.value = 1
            filesCopied = true
            if (filesCopied && modCreated) {
                baseElem.enabled = true
                displayResultText();
            }
        }
        onGenerationDone: {
            myProgress.value = 1
            modCreated = true
            if (filesCopied && modCreated) {
                baseElem.enabled = true
                displayResultText();
            }
        }
        onWwiseMessage: {
            wwiseOutText.text += message
            if (message.indexOf("Error") != -1 || message.indexOf(
                        "Warning") != -1) {
                wasError = true
            }
        }

        onWwiseGenEnd: {
            rootParent._LOG("KEK")
        }
    }

    Rectangle {
        id: baseElem
        anchors.fill: parent
        enabled: true
        ProgressBar {
            id: myProgress
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 15
            Text {
                id: loadText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Mod creation " + myProgress.value * 100 + "%"
            }
        }
        ProgressBar {
            id: myFilesProgress
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: myProgress.bottom
            anchors.topMargin: 15
            Text {
                id: loadFilesText
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Copying files " + Math.floor(
                          myFilesProgress.value * 100) + "%"
            }
        }
        Label {
            id: wwiselabel
            text: rootParent.languageIndex === 0 ? "Wwise output:" : "Сообщения Wwise:"
            anchors.left: wwiseOutText.left
            anchors.top: myFilesProgress.bottom
            anchors.topMargin: 15
        }

        TextArea {
            id: wwiseOutText
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: wwiselabel.bottom
            anchors.topMargin: 5
            text: "WWISE is ready to run."
            readOnly: true
        }
        Label{
            id: genDone
            anchors.left: wwiseOutText.left
            anchors.top: wwiseOutText.bottom
            anchors.topMargin: 15
            visible: false
            text:rootParent.languageIndex === 0 ? "Generation is done, mod was generated at:" : "Генерация закончена, мод находится в:"
        }
        TextField {
            id: genPath
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: genDone.bottom
            anchors.topMargin: 5
            height: 24
            visible: genDone.visible
            readOnly: true

        }

        Button {
            id: generateButton
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 15
            text: rootParent.languageIndex == 0 ? "Generate" : "Сгенерировать"
            onClicked: {
                if (generator.filesCopied && generator.modCreated) {
                    generator.filesCopied = false
                    generator.modCreated = false
                    myProgress.value = 0
                    myFilesProgress.value = 0
                    generateButton.text = Qt.binding(function () {
                        return rootParent.languageIndex === 0 ? "Generate" : "Сгенерировать"
                    })
                    errorRect.border.color="transparent"
                    generator.wasError=false;
                    mydialog.close()
                    genDone.visible = false
                    genPath.text = rootParent.modDirInGame
                } else {
                    baseElem.enabled = false
                    generateButton.text = Qt.binding(function () {
                        return rootParent.languageIndex === 0 ? "Generating..." : "Генерируется..."
                    })
                    wwiseOutText.text = ""
                    errorRect.border.color="yellow"
                    MyLoader.generateOutput(generator, rootParent)
                }
            }
        }
        Rectangle {
            id: errorRect
            anchors.fill: generateButton
            anchors.margins: -2
            color: "transparent"
            border.color: "transparent"
            border.width: 2
            radius: 4
        }
    }
}
