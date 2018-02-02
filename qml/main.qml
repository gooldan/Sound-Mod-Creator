import QtQuick 2.6
import Qt.labs.controls 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQml 2.2
import FileIO 1.0
import ConfigReader 1.0
import "loader.js" as MyLoader
import "help.js" as Helper

ApplicationWindow {
    id: myWindow
    visible: false
    width: 1080
    height: 720
    minimumWidth: 640
    minimumHeight: 480
    title: pROGRAM_VERSION_STR.slice(3);
    ConfigReader{
        id:confReader
    }
    property string pROGRAM_VERSION_STR : " - Sound Mods Creator 0.2.4с"
    property alias errorWindow : errorDialog
    FileIO {
            id: myFile
            onError: rectangle1._LOG(msg)
        }
    MyFileDialog{
        id:projectLoader
        visible:false
        rootParent:rectangle1
        dialogNameFilter: ["SMC project file (*.rvm)"]
        onAccepted:
        {
            //rootParent._LOG(projectLoader.fileUrl)
            //TODO:
            //warning, check file urls            
            MyLoader.saveProject(
                        rootParent.projectBackupPath,
                        myFile, rootParent.tabs,
                        rootParent)
            rootParent.cfg.lastLoadFolder = projectLoader.fileUrl.toString();
            folder =  projectLoader.fileUrl.toString();
            var fileUrlChosen=projectLoader.fileUrl.toString().substring(8);
            var newDb = MyLoader.getDbFromfile(fileUrlChosen,myFile);
            if(!newDb.hasOwnProperty("events"))
            {
                return;
            }

            if(MyLoader.checkModGameDir(rootParent,myFile,newDb.modName)===false)
            {
                return;
            }
            var loadedProjDir = myFile.getFileDir(fileUrlChosen)
            rootParent.pathTable.selection.clear()
            var res = MyLoader.loadProject(newDb,tabs,rootParent,loadedProjDir, myFile);
            if(res.ans === false)
            {                
                errorWindow.messageText = Helper.incompatibleVersion(
                            rootParent.languageIndex, res.ver.slice(res.ver.lastIndexOf(' ')+1),
                            rootParent.pROGRAM_VERSION_STR.slice(
                                rootParent.pROGRAM_VERSION_STR.lastIndexOf(
                                    ' ')+1))
                errorWindow.showAgaing.visible = false
                errorWindow.width = 580
                errorWindow.height = 120
                errorWindow.show();
                return
            }
            rootParent.projectFilePath=fileUrlChosen;
            rootParent.projectFileDir=myFile.getFileDir(fileUrlChosen);
            rootParent.projectBackupPath = rootParent.projectFileDir + "/Backups/"+rootParent.modName+".rvb"
            MyLoader.saveProject(
                        rootParent.projectBackupPath,
                        myFile, rootParent.tabs,
                        rootParent)
            myWindow.title = rootParent.projectFilePath + pROGRAM_VERSION_STR
            if(rootParent.cfg.projectHistory.indexOf(fileUrlChosen) === -1)
            {
                rootParent.cfg.projectHistory.push(rootParent.projectFilePath);
                if(rootParent.cfg.projectHistory.length > 10)
                {
                    rootParent.cfg.projectHistory.splice(0,1);
                }
                MyLoader.updateRecents(rootParent.cfg,myMenuBar.recentModel,myFile);
            }
        }
    }
    MyFileDialog{
        id:importProjectFileChooser
        visible:false
        rootParent:rectangle1
        dialogNameFilter: ["SMC export file (*.rve)"]
        onAccepted:
        {
            rootParent.cfg.importLastFolder = fileUrl.toString();
            folder = fileUrl.toString();
            var importFilePath=fileUrl.toString().substring(8);            
            MyLoader.saveProject(
                        rootParent.projectBackupPath,
                        myFile, rootParent.tabs,
                        rootParent)
            if(MyLoader.importProject(rootParent,myFile,importFilePath)===false)
                return
            MyLoader.saveProject(
                        rootParent.projectBackupPath,
                        myFile, rootParent.tabs,
                        rootParent)
            rootParent.pathTable.selection.clear()
            myWindow.title = rootParent.projectFilePath + pROGRAM_VERSION_STR
            rootParent.cfg.importLastFolder = fileUrl.toString();
            folder = fileUrl.toString();
        }
    }
    onClosing:{
//        MyLoader.saveProject(
//                    rectangle1.projectBackupPath,
//                    myFile, rectangle1.tabs,
//                    rectangle1)
       MyLoader.saveProject(rectangle1.projectFilePath,myFile,tabs,rectangle1);
    }
    ErrorDialog {
        id: errorDialog
    }
    Component.onCompleted: {
        visible = true
    }

    property bool advanced_user: false
    MissingFilesDialog {
        id: messageDialog
        rootParent: rectangle1
    }
    menuBar: MyMenuBar {
        id: myMenuBar
    }
    Rectangle{
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 3
        width: group.width+lanhide.width+6 + (lanhide.collapsed? 0:3)
        height: lanhide.height+6
        color: "transparent"
        border.width: 1
        border.color: "black"
        radius: 3
        z:225
        id:lanRect
        Behavior on width{
            SmoothedAnimation { velocity: 200 }
        }
        GroupBox {
            state: lanhide.collapsed ? "closed" : "opened"
            states: [
                State{
                    name:"opened"
                    PropertyChanges {
                        target: group
                        width:undefined
                        title:rectangle1.languageIndex == 0 ? "Language:" : "Язык:"
                    }
                },
                State{
                    name:"closed"
                    PropertyChanges {
                        target: group
                        width:0
                        title:"      "
                    }
                }
            ]
            anchors.left: lanhide.right
            anchors.top: parent.top
            anchors.margins: 3
            title: rectangle1.languageIndex == 0 ? "Language:" : "Язык:"
            id:group
            z:125
            ColumnLayout {
                ExclusiveGroup {
                    id: tabPositionGroup
                }
                RadioButton {
                    text: rectangle1.languageIndex == 0 ? "EN    " : "EN    "
                    checked: rectangle1.languageIndex == 0
                    exclusiveGroup: tabPositionGroup
                    onClicked: {
                        if (rectangle1.languageIndex == 1)
                            rectangle1.languageIndex = 0
                        checked = Qt.binding(function(){return rectangle1.languageIndex == 0})
                    }
                    Rectangle{
                        id:tetett
                        color: "transparent"
                        width: 15
                        height: 15
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -5
                        Image {
                            id: name1
                            source: "../screens/en/eng.png"
                            anchors.fill: parent
                        }
                    }

                }
                RadioButton {
                    id: fullRadioBox
                    checked: rectangle1.languageIndex == 1
                    text: rectangle1.languageIndex == 0 ? "RU    " : "RU    "
                    exclusiveGroup: tabPositionGroup
                    onClicked: {
                        if (rectangle1.languageIndex == 0)
                            rectangle1.languageIndex = 1
                        checked = Qt.binding(function(){return rectangle1.languageIndex == 1})
                    }
                    Rectangle{
                        id:tetett4
                        color: "transparent"
                        width: 15
                        height: 11
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -4
                        Image {
                            id: name2
                            source: "../screens/ru/50px-Flag_of_Russia.svg.png"
                            anchors.fill: parent
                        }
                    }
                }
            }
        }
        Button{
            property bool collapsed: false
            anchors.left: parent.left
            anchors.top: group.top
            anchors.bottom: group.bottom
            anchors.leftMargin: 3
            //color: areat.containsMouse ? "#ee2211" : "#bb0505"
            width:18
            z:152
            id:lanhide
            onClicked: {
                collapsed = !collapsed
                rectangle1.cfg.collapsed = collapsed
            }

            Rectangle{
                anchors.centerIn: parent
                color:"transparent"
                width:18
                height: 18
                Image
                {
                    anchors.fill: parent
                    source: "../screens/left.png"
                    transform: Rotation {
                        origin.x: 9
                        origin.y: 9
                        angle: lanhide.collapsed ? 0 : 180
                        Behavior on angle {
                            SmoothedAnimation { velocity: 500 }
                        }
                    }
                }
            }
        }

    }
    Rectangle{
        color: "transparent"
        anchors.right: parent.right
        anchors.top:parent.top
        width:30
        height: 15
        z:125
    }

    Rectangle {
        z:12
        focus: true
        anchors.fill: parent
        id: rectangle1
        color:"#f0f0f0"
        function _LOG(body)
        {
            MyLoader._LOG(body)
        }
        property int modxmlVersion : 0
        property alias pROGRAM_VERSION_STR: myWindow.pROGRAM_VERSION_STR
        property alias mouseArea: mouseArea
        property alias recentModel: myMenuBar.recentModel
        property var eventList;
        property var eventListModel;
        property var stateListModel;
        property var stateList;
        property var stateItemListModel;
        property var stateListNewModel;
        property int currentEventDbIndex;
        property var tabs;
        property bool controlIsPressed:false;
        property bool shiftIsPressed:false;
        property var pathTableModel;
        property var pathTable;
        property var popup;
        property bool popupOpened:false;
        property var configReader:confReader
        property int languageIndex:0;
        property string projectFilePath: "";
        property string projectFileDir : "";
        property string projectBackupPath : "";
        property string modDirInGame : "";
        property string modName: "";
        property bool copyFiles : false;
        property alias warnNewLab : newProjDialog.warnNewLabel;
        property alias descriptionText : descText;
        property var lostFiles : [];
        property var globalMenuModel:myMenuBar.globalStateMenuModel
        property var progressBar;
        property var cfg:
        {
            "conversion":"WOWS_WEM_CONVERSION",
            "wwiseDir":"",
            "wwiseExe":"",
            "gameDir":"",
            "configFile":"",
            "wwiseProjFile":"",
            "lastOpenedDir":"",
            "languageIndex":0,
            "projectHistory":[],
            "importLastFolder":"",
            "lastLoadFolder":"",
            "newProjDir":"",
            "lanCollapsed":false
        }

        signal activated()

        enabled: false;
        width: 560
        height: 360

        Component.onCompleted: {
            if(myFile.fileExists("cfg.json"))
            {
                myFile.setSource("cfg.json");
                var str = myFile.read();
                try
                {
                    cfg = JSON.parse(str);
                }
                catch (err)
                {
                    str = myFile.readOld()
                    try
                    {
                        cfg = JSON.parse(str)
                    }
                    catch(err)
                    {
                        myFile.setSource("cfg.json");
                        myFile.write(JSON.stringify(cfg));
                    }

                }
            }
            else
            {
                myFile.setSource("cfg.json");
                myFile.write(JSON.stringify(cfg));
            }
            if(cfg.gameDir !== "")
            {
                settingsDialog.textOfPath=cfg.gameDir;
                if(myFile.fileExists(cfg.gameDir+"/res/banks/mod.xml"))
                {
                   settingsDialog.warnLabel.visible=false;
                   newProjDialog.warnNewLabel.visible=false;                
                   settingsDialog.clientFileDialog.folder="file:///"+settingsDialog.textOfPath+"/";
                }
                else
                {
                    cfg.gameDir="";
                }
            }
            if(cfg.configFile !== "")
            {
                if(myFile.fileExists(cfg.configFile))
                {
                    settingsDialog.modXmlFilepath = cfg.configFile;
                }
                else
                {
                    cfg.configFile = "";
                    settingsDialog.warnLabel.visible=true;
                    newProjDialog.warnNewLabel.visible=true
                }
            }

            if(cfg.wwiseDir !== "")
            {
                settingsDialog.textOfWwisePath=cfg.wwiseDir;
                if(myFile.fileExists(cfg.wwiseDir+"/WwiseCLI.exe"))
                {
                   settingsDialog.warnWwiseLabel.visible=false;
                   settingsDialog.wwiseDirDialog.folder="file:///"+settingsDialog.textOfWwisePath+"/";
                }
                else
                {
                    cfg.wwiseDir=""
                }

            }
            if(cfg.wwiseProjFile !== "")
            {
                settingsDialog.textOfWwiseProjPath=cfg.wwiseProjFile;
                if(!myFile.fileExists(cfg.wwiseProjFile))
                {
                    cfg.wwiseProjFile="";
                    settingsDialog.warnWwiseProjLabel.visible = true;
                }
                else
                {
                    settingsDialog.wwiseProjFileDialog.folder="file:///"+myFile.getFileDir(settingsDialog.textOfWwiseProjPath);
                }
            }
            if(cfg.newProjDir !== "")
            {
                newProjDialog.newProjectDirDialog.folder = cfg.newProjDir;
            }
            if(cfg.lastLoadFolder !== "")
            {
                projectLoader.folder = cfg.lastLoadFolder;
            }
            if(cfg.importLastFolder !== "")
            {
                importProjectFileChooser.folder = cfg.importLastFolder;
            }
            if(cfg.collapsed === undefined)
                cfg.collapsed = false
            lanhide.collapsed = cfg.collapsed
            MyLoader.updateRecents(cfg,myMenuBar.recentModel,myFile);
            rectangle1.languageIndex=cfg.languageIndex;

            //settingsDialog.language.currentIndex=cfg.languageIndex;
        }
        Component.onDestruction: {
            myFile.setSource("cfg.json");
            myFile.write(JSON.stringify(cfg));
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Control)
            {
                controlIsPressed=true;
            }
            else if (event.key === Qt.Key_Shift)
            {
                shiftIsPressed=true;
            }
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Control)
            {
                controlIsPressed=false;
            }
            else if (event.key === Qt.Key_Shift)
            {
                shiftIsPressed=false;
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
        }

        Shortcut{
            sequence: "Ctrl+S"
            onActivated: {
                MyLoader.saveProject(rectangle1.projectFilePath,myFile,tabs,rectangle1);
                MyLoader.saveProject(
                            rectangle1.projectBackupPath,
                            myFile, rectangle1.tabs,
                            rectangle1)
            }
        }

        MyTabs {
            id: tabs
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: parent.top
            property alias rootParent: rectangle1
        }
        VerSplitter {
            id: verSplitter
            anchors.bottom: parent.bottom
            anchors.left: tabs.right
            anchors.top: parent.top
            property alias rootParent: rectangle1
            leftBlock: tabs
            rightBlock: mainRect
        }
        Rectangle{
            anchors.left: verSplitter.right
            anchors.right: parent.right
            anchors.top:parent.top
            anchors.bottom: parent.bottom
            id:mainRect
            color:"#f0f0f0"
            property real minWidth: 410
            border.color: "gray"
            border.width: 1
            property var rootParent: rectangle1
            Rectangle{
                id: infoBlock
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height:lanhide.height+10
                color:"#f0f0f0"
                property real minHeight:lanhide.height+10
                TextArea {
                    id:descText
                    anchors.fill: parent
                            text: ""
                }
            }

            HorizontalSplitter{
                id:horSlider
                anchors.top: infoBlock.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                upperElement: infoBlock
                bottomElement: statesBlock
                visible: mainRect.rootParent.enabled
            }

            StatesBlock{
                id:statesBlock
                upperSlider: horSlider
                rootParent: mainRect.rootParent
                border.color: "gray"
                border.width: 1
                enabled: rootParent.eventList.currentIndex !== -1
            }

            HorizontalSplitter{
                id:horSlider2
                anchors.top: statesBlock.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                upperElement: statesBlock
                bottomElement: bottomBlock
                visible: mainRect.rootParent.enabled
            }


            Rectangle{
                id:bottomBlock
                anchors.top:horSlider2.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                property real minHeight: 50
                property var rootParent:mainRect.rootParent
                Rectangle{
                    id:pathBlock
                    anchors.fill:parent
                    TableView{
                        id:myTableView
                        property bool multiselect : false
                        property var rootParent: bottomBlock.rootParent
                        anchors.fill: parent
                        onWidthChanged: {
                            filecol.width=pathBlock.width-buttonCol.width-pathColumn.width-15
                        }
                        selectionMode :SelectionMode.NoSelection
                        TableViewColumn {
                            property real colWidth: 50
                            property var myWidthArr:[]
                            property real maxElemWidth:40;
                            width: maxElemWidth;
                            id:pathColumn
                            role:"path"
                            delegate:MyTableColumnStateList{
                                rootParent:myTableView.rootParent
                                myTable   :myTableView
                                pathCol   :pathColumn
                            }

                            title: myTableView.rootParent.languageIndex == 0 ? "Path" : "Путь"
                            onWidthChanged: {
                                filecol.width=pathBlock.width-buttonCol.width-pathColumn.width-15
                            }
                        }

                        TableViewColumn {
                            function getText(value) {
                                switch(value){
                                    case "":
                                            return myTableView.rootParent.languageIndex == 0 ? "No files selected"
                                                                                                   : "Файлы не выбраны"
                                    case "Muted":
                                            return myTableView.rootParent.languageIndex == 0 ? "Muted": "Заглушено"
                                    case "NOT FOUND":
                                            return myTableView.rootParent.languageIndex == 0 ? "ERROR: SOME FILES ARE MISSING":
                                                                                   "ОШИБКА: ОТСУТСТВУЮТ НЕКОТОРЫЕ ФАЙЛЫ"
                                    default:
                                            if(/*advanced_user*/true)
                                            {
                                                var filesArr = value.split(".wav,")
                                                for(var i = 0; i < filesArr.length-1; ++i)
                                                {
                                                    filesArr[i] = filesArr[i].substr(
                                                                filesArr[i].lastIndexOf(
                                                                    "/") + 1) + ".wav"
                                                }
                                                filesArr[filesArr.length-1] = filesArr[filesArr.length-1].substr(
                                                            filesArr[filesArr.length-1].lastIndexOf(
                                                                "/") + 1)
                                                return filesArr.toString()
                                            }

                                            return value
                                }
                            }
                            id:filecol
                            role: "files"
                            delegate:
                                Text{
                                    anchors.left: filecol.left
                                    anchors.leftMargin: 5
                                    clip: true
                                    text: filecol.getText(styleData.value)
                                    color: (styleData.value==="Muted" || styleData.value==="NOT FOUND")?"red":"black"

                            }

                            title: myTableView.rootParent.languageIndex == 0 ? "Files" : "Файлы"
                            width: 100
                        }
                        TableViewColumn {
                            id:buttonCol
                            width:25
                            role:"mySuperIndex"

                            delegate: Rectangle{
                                width:23
                                anchors.fill: parent
                                id:buttonDelegate
                                Button{
                                    anchors.fill: parent
                                    text:"..."
                                    onClicked: {
                                        mydialog.myCurrentIndex=styleData.row
                                        mydialog.show()
                                    }
                                    enabled: styleData.value > 0 ? 1 : 0;

                                }
                                opacity: styleData.value > 0 ? 1 : 0;
                            }
                        }
                        Component.onCompleted: {
                            rootParent.pathTableModel=libraryModel;
                            rootParent.pathTable=myTableView;
                        }
                        onDoubleClicked: {
                            if(libraryModel.get(row).mySuperIndex > 0)
                            {
                                mydialog.myCurrentIndex=row
                                mydialog.show();
                            }
                        }
                        onClicked: {
                            var currentSelection = [];
                            for (var i = 0; i < libraryModel.count; ++i)
                            {
                                currentSelection.push({
                                             selected: libraryModel.get(i).selected,
                                             history : libraryModel.get(i).history
                                            })
                            }
                            var newSelectionObj = MyLoader.getSelectionFromClick(currentSelection,
                                                       row,
                                                       rootParent.shiftIsPressed,
                                                       rootParent.controlIsPressed,
                                                       multiselect)

                            currentSelection = newSelectionObj.newSelection;
                            multiselect = newSelectionObj.multiselect
                            rootParent._LOG(multiselect);
                            var listOfSelected = newSelectionObj.listOfSelected;

                            var resultArr = [];
                            for (var i = 0; i < libraryModel.count; ++i)
                            {
                                libraryModel.get(i).selected = currentSelection[i].selected;
                                libraryModel.get(i).history = currentSelection[i].history;
                                if(currentSelection[i].selected)
                                {
                                    var chainIndexArr = libraryModel.get(i).chainIndexes.split(",");
                                    for(var j in chainIndexArr)
                                    {
                                        if(resultArr[j] !== undefined)
                                        {
                                            if(resultArr[j].indexOf(chainIndexArr[j]) === -1)
                                            {
                                                resultArr[j].push(chainIndexArr[j]);
                                            }
                                        }
                                        else
                                        {
                                            resultArr[j]=[chainIndexArr[j]];
                                        }
                                    }
                                    rootParent._LOG(i);
                                }
                            }
                            if(listOfSelected.length == 0)
                            {
                                var retArr = [];
                                for(var i = 0; i < rootParent.stateListModel.count; ++i)
                                {
                                    retArr.push({index : i, selected:[]});
                                    var stateValuesObj = rootParent.stateListModel.get(i).stateValues;
                                    for(var j = 0; j < stateValuesObj.count; ++j)
                                    {
                                        if(j==0)
                                        {
                                            rootParent.stateListModel.get(i).stateValues.get(j).history=1;
                                        }
                                        else
                                        {
                                            rootParent.stateListModel.get(i).stateValues.get(j).history=0;
                                        }
                                        rootParent.stateListModel.get(i).stateValues.get(j).selected=false;
                                    }
                                }
                                rootParent.stateList.listClick(retArr,true);

                                return;
                            }
                            for(var i = 0; i < rootParent.stateListModel.count; ++i)
                            {
                                var stateValuesObj = rootParent.stateListModel.get(i).stateValues;
                                var oneTimeFlag = false
                                for(var j = 0; j < stateValuesObj.count; ++j)
                                {
                                    if(resultArr[i].indexOf(j.toString()) >= 0)
                                    {
                                        rootParent.stateListModel.get(i).stateValues.get(j).selected=true;
                                        if(!oneTimeFlag)
                                        {
                                            rootParent.stateListModel.get(i).stateValues.get(j).history = 1;
                                            oneTimeFlag=true;
                                        }
                                        else
                                        {
                                            rootParent.stateListModel.get(i).stateValues.get(j).history = 0;
                                        }
                                    }
                                    else
                                    {
                                        rootParent.stateListModel.get(i).stateValues.get(j).selected=false;
                                        rootParent.stateListModel.get(i).stateValues.get(j).history = 0;
                                    }
                                }
                            }
                            var returnArr = []
                            for(var i in resultArr)
                                returnArr.push({index : i, selected : resultArr[i]});
                            rootParent.stateList.listClick(returnArr,true);

                        }


                        model:ListModel {
                            id: libraryModel

                            onCountChanged: {
                            }
                        }
                        function addedPressed()
                        {
                            if(statesBlock.addBut.enabled)
                            {
                                statesBlock.addBut.clicked()
                            }
                        }

                        Shortcut {
                            sequence:"Ctrl+T"
                            onActivated: myTableView.addedPressed()
                        }
                        Shortcut {
                            sequence:"Delete"
                            onActivated: {
                                if(statesBlock.deleteBut.enabled) {
                                    statesBlock.deleteBut.clicked()
                                }
                            }
                        }
                    }
                }
        }

     }


    }
    FileBrowserDialog{
        id:mydialog
        Component.onCompleted: {
            mydialog.rootParent=rectangle1;
            mydialog.filesTable=libraryModel;
        }
    }
    NewProjectDialog{
        id:newProjDialog
        Component.onCompleted: {
            newProjDialog.rootParent= rectangle1
        }
    }
    SettingsDialog{
        id:settingsDialog
        Component.onCompleted: {
            settingsDialog.rootParent= rectangle1

        }
    }
    GeneratorDialog{
        id:genDialog
        visible:false
        Component.onCompleted: {
            genDialog.rootParent= rectangle1
        }
    }
    ExportDialog{
        id:expDialog
        visible:false
        Component.onCompleted: {
            expDialog.rootParent= rectangle1
        }
    }

    HelpDialog{
        id:helpDialog
        visible: false
        Component.onCompleted: {
            helpDialog.rootParent = rectangle1;
        }
    }
    AboutDialog{
        id:aboutDialog
        visible:false
        Component.onCompleted: {
            aboutDialog.rootParent = rectangle1;
        }
    }
    RestoreDialog{
        id:restoreDialog
        visible: false
        Component.onCompleted: {
            rootParent = rectangle1
        }
    }
}
