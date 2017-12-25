import QtQuick 2.0
import Qt.labs.controls 1.0

MenuItem{
    property var rootParent;
    onTriggered: {
        rootParent._LOG(text);
    }
}
