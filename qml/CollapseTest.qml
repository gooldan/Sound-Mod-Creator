import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQml.Models 2.1
import Qt.labs.controls 1.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0

Item {
    id: baseCollapseElem
    property var rootParent
    property var screendialog: screenDiag
    property var ruListModel: HelpRuModel {
    }
    property var engListModel: HelpEnModel{

    }

    property var currentModel: rootParent.languageIndex == 0 ? engListModel : ruListModel
    ListView {
        id: mainView
        anchors.fill: parent
        model: currentModel
        delegate: categoryDelegate
        ScrollBar.vertical: MyScrollBar {
            clip: true
            id: myScrollBar
        }
    }

    Component {
        id: categoryDelegate
        Column {
            width: mainView.width
            Rectangle {
                id: categoryItem
                border.color: "black"
                border.width: 2
                color: "white"
                height: textInnn.paintedHeight + 10
                width: parent.width

                Text {
                    id:textInnn
                    anchors.verticalCenter: parent.verticalCenter
                    x: 15
                    font.pixelSize: 20
                    wrapMode: Text.WordWrap
                    width: parent.width-40
                    text: (index + 1) + ". " + categoryName
                }

                Rectangle {
                    color: "#54aec8"
                    width: 21
                    height: 21
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: image2
                        anchors.fill: parent
                        source: "../screens/left.png"
                        transform: Rotation {
                            origin.x: 10.5
                            origin.y: 10.5
                            angle: collapsed ? 0 : -90
                            Behavior on angle {
                                SpringAnimation {
                                    spring: 2
                                    damping: 0.2
                                    modulus: 360
                                }
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    // Toggle the 'collapsed' property
                    onClicked: currentModel.setProperty(index, "collapsed",
                                                        !collapsed)
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        categoryItem.color = "#efefef"
                    }
                    onExited: {
                        categoryItem.color = "white"
                    }
                }
            }

            Loader {
                id: subItemLoader

                // This is a workaround for a bug/feature in the Loader element. If sourceComponent is set to null
                // the Loader element retains the same height it had when sourceComponent was set. Setting visible
                // to false makes the parent Column treat it as if it's height was 0.
                visible: !collapsed
                property variant subItemModel: subItems
                sourceComponent: collapsed ? null : subItemColumnDelegate
                onLoaded: {
                    item.parentIndex = index + 1
                }

                onStatusChanged: if (status == Loader.Ready)
                                     item.model = subItemModel
            }
        }
    }

    Component {
        id: subItemColumnDelegate
        Column {
            property int parentIndex
            property alias model: subItemRepeater.model
            width: mainView.width - 4
            anchors.leftMargin: 2
            id: colMod
            spacing: 5
            topPadding: 5
            bottomPadding: 5
            Repeater {
                id: subItemRepeater
                width: mainView.width - 4
                anchors.leftMargin: 2

                delegate: Rectangle {
                    Component.onCompleted: {
                        //rootParent._LOG("asd")
                    }
                    color: "#ededed"
                    height: innerText.contentHeight
                    width: mainView.width - 4
                    anchors.leftMargin: 2
                    anchors.left: subItemRepeater.left
                    border.color: "black"
                    border.width: 1
                    radius: 4
                    Rectangle {
                        id: textRect
                        anchors.fill: parent
                        Text {
                            id: innerText
                            font.pixelSize: 18
                            text: parentIndex + "." + (index+1) + ". " + itemName
                            x: 10
                            width: parent.width - 18
                            wrapMode: Text.WordWrap
                            onLinkActivated: function (link) {
                                var screenShower = screenDiag
                                screenShower.isPaused = false
                                screenShower.imageUrl = link
                                screenShower.setX(screenShower.oldX)
                                screenShower.setY(screenShower.oldY)
                                if(!screenShower.visible)
                                    screenShower.show()
                                else
                                    screenShower.requestActivate()
                                rootParent._LOG(link)
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                        border.color: "black"
                        border.width: 1
                        radius: 2
                    }
                }
            }
        }
    }
    ScreenDialog {
        id: screenDiag
        rootParent: baseCollapseElem.rootParent
    }
}
