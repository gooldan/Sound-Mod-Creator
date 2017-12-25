import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

Window {
    property string imageUrl
    property int oldX: 15
    property int oldY: 45
    property int otherHeight: isVideo ? 91 : 66
    property int currentImageWidth: image.width + 22
    property int currentImageHeight: image.height + otherHeight
    property var rootParent
    property string displayScreenText: rootParent.languageIndex == 0 ? "Screenshot" : "Скриншот"
    property string displayAnimText: rootParent.languageIndex == 0 ? "Video" : "Видео"
    property string displayPlayButtonText: rootParent.languageIndex == 0 ? "Play" : "Продолжить"
    property string displayPauseButtonText: rootParent.languageIndex == 0 ? "Pause" : "Пауза"
    property bool isPaused: false
    property bool isVideo: imageUrl.indexOf("gif") !== -1
    property int videoFrameCount: 0
    id: screenDiag
    minimumWidth: currentImageWidth > 32 ? currentImageWidth : 33
    maximumWidth: minimumWidth
    minimumHeight: currentImageHeight > otherHeight ? currentImageHeight : otherHeight
    maximumHeight: minimumHeight
    width: minimumWidth
    height: minimumHeight
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    title: !isVideo ? displayScreenText : displayAnimText
    onClosing: {
        oldX = x
        oldY = y
    }
    signal sliderValueChanged(bool fromUser)

    Rectangle {
        id: innerRect
        anchors.fill: parent
        focus: true
        Keys.onReleased: {
            if (event.key === Qt.Key_Space && !event.isAutoRepeat) {
                screenDiag.isPaused = !screenDiag.isPaused
            }
        }
        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 5
            id: caption
            text: title + ":"
            font.pixelSize: 22
        }
        Rectangle {
            id: imageRect
            anchors.top: caption.bottom
            anchors.left: parent.left
            width: image.width + 8
            height: image.height + 8
            anchors.margins: 5
            border.width: 4
            border.color: "black"
            radius: 4
            AnimatedImage {
                anchors.centerIn: parent
                anchors.margins: 2
                id: image
                source: imageUrl
                cache: advanced_user
                onStatusChanged: {
                    playing = (status == AnimatedImage.Ready)
                    videoFrameCount = frameCount
                }
                Connections {
                    target: screenDiag
                    onIsPausedChanged: {
                        image.paused = screenDiag.isPaused
                    }
                }
                onProgressChanged: {
                    console.log(progress)
                }
            }
        }
        Slider {
            property bool oldPaused
            id: slider
            visible: pausebut.visible && advanced_user
            anchors.verticalCenter: begbut.verticalCenter
            anchors.left: begbut.right
            anchors.margins: 15
            width: imageRect.width - (pausebut.width + 5 + begbut.width + 15 + 12)
            maximumValue: videoFrameCount
            stepSize: 1.0
            onValueChanged: {
                if (pressed) {
                    image.currentFrame = Math.floor(value)
                }
            }
            onPressedChanged: {
                if (pressed) {
                    oldPaused = screenDiag.isPaused
                    screenDiag.isPaused = true
                } else {
                    screenDiag.isPaused = oldPaused
                }
            }
            Connections {
                target: image
                onCurrentFrameChanged: {
                    if (!slider.pressed)
                        slider.value = image.currentFrame
                }
            }
        }
        Button {
            id: pausebut
            visible: isVideo
            anchors.left: parent.left
            anchors.top: imageRect.bottom
            anchors.leftMargin: 15
            anchors.topMargin: 15
            text: !isPaused ? displayPauseButtonText : displayPlayButtonText
            onClicked: {
                screenDiag.isPaused = !screenDiag.isPaused
            }
        }
        Button {
            id: begbut
            visible: imageUrl.indexOf("gif") !== -1
            anchors.left: pausebut.right
            anchors.top: imageRect.bottom
            anchors.leftMargin: 5
            anchors.topMargin: 15
            text: rootParent.languageIndex == 0 ? "Play from start" : "Начать сначала"
            onClicked: {
                screenDiag.isPaused = false
                image.currentFrame = 0
            }
        }
    }
}
