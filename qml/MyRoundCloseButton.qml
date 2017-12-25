import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
Button {
        id: button
        text: "☓"
        height:15
        width:15
        style: ButtonStyle {
            background: Rectangle {
                implicitWidth: 15
                implicitHeight: 15
                color:"transparent"
                radius: 7
                opacity: 0.6
                border.color: "#111"
                border.width: 1
            }
            label:Component {
                Text {
                    text: button.text
                    clip: true
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.fill: parent
                    font.pointSize: 6
                    font.bold: true
                    color:"black"
                    opacity: 1
                }
            }
        }
}
