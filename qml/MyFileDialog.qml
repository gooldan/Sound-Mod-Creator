import QtQuick 2.2
import QtQuick.Dialogs 1.0

FileDialog {
    property var dialogNameFilter
    property var rootParent
    id: fileDialog
    title: rootParent.languageIndex == 0 ? "Choose file:" : "Выберите файл:"
    folder: shortcuts.home
    selectMultiple: false
    onAccepted: {
        rootParent._LOG("You chose: " + fileDialog.fileUrl)

    }
    onRejected: {
        rootParent._LOG("Canceled")
    }

    nameFilters: dialogNameFilter
}
