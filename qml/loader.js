.pragma library
var db = {
}
var logging = 1;
function _LOG (body)
{
    if(logging == 1)
    {
        console.log(body)
    }
}

function saveProject(filesystemUrl, fileReader, tabs, rootObject) {
    fileReader.setSource(filesystemUrl)
    try {
        var currentSelection = db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex]
        var backup = []
        for (var i in currentSelection) {
            backup.push(db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex][i])
            db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex][i]
                    = []
        }
        db.modDirInGame = rootObject.modDirInGame
        db.projectFileDir = rootObject.projectFileDir
        db.projectFilePath = rootObject.projectFilePath
        db.modName = rootObject.modName
        db.copyFiles = rootObject.copyFiles
        db.lostFiles = []
        var dbToSave = JSON.stringify(db)
        fileReader.write(dbToSave)
        for (var i in currentSelection) {
            db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex][i]
                    = backup[i]
        }
    } catch (err) {
        _LOG(err)
        return
    }
}
function openNewProject(newDb, rootObject) {
    rootObject.globalMenuModel.clear();
    db = newDb
    db.programVersion = rootObject.pROGRAM_VERSION_STR;
    var tabs = rootObject.tabs
    for (var i = 0; i < 3; ++i) {
        _LOG("tabName:" + tabs.getTab(i).title)
        var tabTitle = tabs.getTab(i).title

        var tabModel = tabs.getTab(i).myEventListModel
        if (tabModel !== undefined) {
            tabModel.clear()
            loadEvents(tabTitle, tabModel, i)
        }
    }
    rootObject.eventList.currentIndex = -1
    rootObject.stateListModel.clear()
    rootObject.pathTableModel.clear()
    constructGlobalStates(rootObject);
    rootObject.enabled = true

}
function getActualDb(rootObject) {
    var err = rootObject.configReader.openConfig(rootObject.cfg.configFile)
    if (err == 0) {
        err = rootObject.configReader.parse()
        if (err == 0) {
            var jsonStr = rootObject.configReader.createJSON()
            var actualDb = JSON.parse(jsonStr)
            actualDb.ok = true
            return actualDb
        }
    }
    return {
        ok: false
    }
}

function compareArrays(arrOld, arrNew) {
    var missing = []
    for (var i in arrOld) {
        if (arrNew.indexOf(arrOld[i]) == -1) {
            missing.push(arrOld[i])
        }
    }
    return missing
}
function getArrayForMissingFiles(eventInd,tabInd,pathInd,fileInd)
{
    var trans = getTranslationArrayByArr(db.events[eventInd],db.events[eventInd].readable[tabInd]);
    var res = ["",""]
    db.events[eventInd].corrupted[tabInd] = true;

    res[0]="Event : "+trans[0]+ "; State :"+
                db.events[eventInd].filePaths[tabInd][pathInd].readable[0]
    res[1]="Событие : "+trans[1]+ "; Уточнения :"+
                db.events[eventInd].filePaths[tabInd][pathInd].readable[1]
    return res;
}

function cleanUpFiles(rootObject, fileIO, callback,missFileCallback) {
    var evListModel = rootObject.eventListModel
    var tabIndex = rootObject.tabs.currentIndex
    var deletedFiles = []
    var res = {
        answer: true,
        arr: [[], []]
    }
    var evCount = db.events.length-1;
    if(!rootObject.copyFiles)
    {
        for (var i in db.events) {
            callback(i/evCount);
            for (var t = 0; t < 3; ++t) {
                for (var k in db.events[i].filePaths[t]) {
                    if (db.events[i].filePaths[t][k].muted) {
                        continue
                    }
                    for (var j in db.events[i].filePaths[t][k].paths) {
                        if(!db.events[i].filePaths[t][k].filesNotFound && !fileIO.fileExists(db.events[i].filePaths[t][k].paths[j]))
                        {
                            db.events[i].filePaths[t][k].filesNotFound = true
                            res.answer = false
                            var ret = getArrayForMissingFiles(i,t,k,j);
                            if(missFileCallback(ret)===false)
                                return false


                                //res.arr[p].push(ret[p])
                            continue;
                        }
                    }
                }
            }
        }
        return true;
    }
    var obj = JSON.parse(fileIO.getDirectoryContent(
                             rootObject.projectFileDir + "/Audio"))
    var filesList = obj.fileList

    for (var i in db.events) {
        callback(i/evCount);
        for (var t = 0; t < 3; ++t) {
            for (var k in db.events[i].filePaths[t]) {
                if (db.events[i].filePaths[t][k].muted) {
                    continue
                }
                db.events[i].filePaths[t][k].filesNotFound = false;
                for (var j in db.events[i].filePaths[t][k].paths) {
                    var fileToFind = db.events[i].filePaths[t][k].paths[j]
                    var index = filesList.indexOf(fileToFind)
                    if(index === -1 && !db.events[i].filePaths[t][k].filesNotFound)
                    {
                        res.answer = false
                        db.events[i].filePaths[t][k].filesNotFound = true;
                        var ret = getArrayForMissingFiles(i,t,k,j);
                        if(missFileCallback(ret)===false)
                            return false
                        continue
                    }
                    else
                    {
                        deletedFiles[index] = true;
                    }
                }
            }
        }
    }
    for (var i in filesList) {
        //rootParent._LOG(filesList[i] + " DELETED: " + deletedFiles[i])
        if (deletedFiles[i] === undefined) {
            fileIO.removeFile(filesList[i])
        }
    }
    for (var i = 0; i < evListModel.count; ++i)
    {
        var evObj = evListModel.get(i)
        if(db.events[evObj.realIndex].corrupted[tabIndex])
        {
            evListModel.setProperty(i,"corrupted", true)
        }
        else
        {
            evListModel.setProperty(i,"corrupted", false)
        }
    }

    return true
}

function getDbFromfile(filesystemUrl, fileReader) {
    fileReader.setSource(filesystemUrl)
    try {
        return JSON.parse(fileReader.read())
    } catch (err) {
        _LOG(err)
        try {
            return JSON.parse(fileReader.readOld())
        }
        catch(err)
        {
            _LOG(err)
            return {

            }
        }
    }
}

function convertExternals(extArr, newDir, fileio) {
    for(var k in extArr)
    {
        for(var i in extArr[k].paths) {
            var fileName = fileio.getFileName(extArr[k].paths[i])
            extArr[k].paths[i] = newDir+"/Audio/"+fileName
        }
    }
}

function loadProject(newDb, tabs, rootObject, newFileDir,fileio) {
    rootObject.globalMenuModel.clear();
    if(newDb.programVersion !== rootObject.pROGRAM_VERSION_STR)
    {
        if(newDb.programVersion === undefined)
        {
            newDb.programVersion = "unspecified";
        }
        return {"ver":newDb.programVersion,"ans":false};
    }
    var actualDb = getActualDb(rootObject)
    if(actualDb.ok === false)
        return {"ver":"cfg file error","ans:":false};
    for (var i in actualDb.states) {
        var newStateObj = actualDb.states[i]
        var oldStateObj = search(newStateObj.name, newDb.states)
        if (oldStateObj === null) {
            //newDb.states.push(newStateObj);
            continue
        }
        var oldAcceptsArr = oldStateObj.accepts
        var newAcceptsArr = newStateObj.accepts
        newStateObj.globallyAppended = oldStateObj.globallyAppended;
        var missing = compareArrays(oldStateObj.accepts, newStateObj.accepts)
        if (oldStateObj.content.length !== newStateObj.content.length) {
            missing = oldAcceptsArr
        }
        for (var j in missing) {
            var toBeDelObj = search(missing[j], newDb.events)
            if (toBeDelObj === null) {
                _LOG("Merge error..")
                continue
            }

            for (var t = 0; t < 3; ++t) {
                toBeDelObj.currentChain[t] = []
                toBeDelObj.filePaths[t] = []
                toBeDelObj.selectedChain[t] = ["default (*)"]
                toBeDelObj.statePaths[t] = []
            }
        }
        //oldStateObj.states[i]=actualDb.states[i];
    }
    if(newFileDir === undefined) newFileDir = newDb.projectFileDir
    var needToExport = newDb.projectFileDir !== newFileDir;


    for (var i in actualDb.events) {
        var newEventObj = actualDb.events[i]
        var oldEventObj = search(newEventObj.name, newDb.events)
        if (oldEventObj === null) {
            newDb.events.push(newEventObj)
            continue
        }
        for (var t = 0; t < 3; ++t) {
            if (newEventObj.accepts[t] === oldEventObj.accepts[t]) {
                newEventObj.currentChain[t] = oldEventObj.currentChain[t]
                if(needToExport)
                {
                    convertExternals(oldEventObj.filePaths[t],newFileDir,fileio)
                }
                newEventObj.filePaths[t] = oldEventObj.filePaths[t]
                newEventObj.selectedChain[t] = oldEventObj.selectedChain[t]
                newEventObj.statePaths[t] = oldEventObj.statePaths[t]
                if(oldEventObj.corrupted !== undefined)
                    newEventObj.corrupted[t] = oldEventObj.corrupted[t]
                else
                    newEventObj.corrupted[t] = false
            }
        }
    }
    if(needToExport)
    {
        newDb.projectFileDir = newFileDir
        newDb.projectFilePath = newFileDir+"/"+newDb.modName+".rvm"
    }
    actualDb.modDirInGame = rootObject.modDirInGame
    actualDb.projectFileDir = newDb.projectFileDir
    actualDb.projectFilePath = newDb.projectFilePath
    actualDb.copyFiles = newDb.copyFiles
    actualDb.modName = newDb.modName
    actualDb.programVersion = newDb.programVersion
    db = actualDb
    for (var i in actualDb.events) {
        for (var t = 0; t < 3; ++t) {
            calcPathCount(i,t);
        }
    }
    //rootObject.modDirInGame = db.modDirInGame
    rootObject.projectFileDir = db.projectFileDir
    rootObject.projectFilePath = db.projectFilePath
    rootObject.copyFiles = db.copyFiles
    rootObject.modName = db.modName
    for (var i = 0; i < 3; ++i) {
        _LOG("tabName:" + tabs.getTab(i).title)
        var tabTitle = tabs.getTab(i).title

        var tabModel = tabs.getTab(i).myEventListModel
        if (tabModel !== undefined) {
            tabModel.clear()
            loadEvents(tabTitle, tabModel, i)
        }
    }
    rootObject.eventList.currentIndex = -1
    rootObject.stateListModel.clear()
    rootObject.pathTableModel.clear()
    rootObject.enabled = true
    constructGlobalStates(rootObject);
    return {"ans":true};
}
//object has readable and name props
function getTranslationArrayByArr(object, readableArr, descriptionArr) {
    var returnArr = []
    if (readableArr[0] == "") {
        for (var i = 0; i < 2; ++i) {
            if (readableArr[i + 1] == "") {
                returnArr[i] = object.name
            } else {
                returnArr[i] = readableArr[i + 1]
            }
        }
    } else {
        for (var i = 0; i < 2; ++i) {
            if (readableArr[i + 1] == "") {
                returnArr[i] = readableArr[0]
            } else {
                returnArr[i] = readableArr[i + 1]
            }
        }
    }
    if (descriptionArr !== undefined) {
        if (descriptionArr[0] == "") {
            for (var i = 0; i < 2; ++i) {
                if (descriptionArr[i + 1] == "") {
                    if(i==0)
                        returnArr[i + 2] = "No description provided for this event."
                    else
                        returnArr[i + 2] = "Для этого события нет описания."
                } else {
                    returnArr[i + 2] = descriptionArr[i + 1]
                }
            }
        } else {
            for (var i = 0; i < 2; ++i) {
                if (descriptionArr[i + 1] == "") {
                    returnArr[i + 2] = descriptionArr[0]
                } else {
                    returnArr[i + 2] = descriptionArr[i + 1]
                }
            }
        }
    }

    return returnArr
}

function getTranslationArray(object) {
    var returnArr = []
    if (object.readable[0] == "") {
        for (var i = 0; i < 2; ++i) {
            if (object.readable[i + 1] == "") {
                returnArr[i] = object.name
            } else {
                returnArr[i] = object.readable[i + 1]
            }
        }
    } else {
        for (var i = 0; i < 2; ++i) {
            if (object.readable[i + 1] == "") {
                returnArr[i] = object.readable[0]
            } else {
                returnArr[i] = object.readable[i + 1]
            }
        }
    }
    if (object.hasOwnProperty("description")) {
        if (object.description[0] == "") {
            for (var i = 0; i < 2; ++i) {
                if (object.description[i + 1] == "") {
                    returnArr[i + 2] = "No description provided for this event."
                } else {
                    returnArr[i + 2] = object.description[i + 1]
                }
            }
        } else {
            for (var i = 0; i < 2; ++i) {
                if (object.description[i + 1] == "") {
                    returnArr[i + 2] = object.description[0]
                } else {
                    returnArr[i + 2] = object.description[i + 1]
                }
            }
        }
    }

    return returnArr
}
//has content with translations
function getTranslationStateArray(object) {
    var returnArr = []
    for (var i in object.content) {
        var curArr = getTranslationArray({
                                             name: object.content[i][0],
                                             readable: object.content[i].slice(
                                                 1)
                                         })
        returnArr.push(curArr)
    }
    return returnArr
}

function loadEvents(tabName, eventListModel, tabIndex) {

    for (var index in db.events) {
        if (db.events[index].accepts.indexOf(tabName) >= 0) {
            var transArr = getTranslationArrayByArr(
                        db.events[index], db.events[index].readable[tabIndex],
                        db.events[index].description)
            _LOG("NAME: " +db.events[index].name + " CORR: " + db.events[index].corrupted[tabIndex])
            eventListModel.append({
                                      name: db.events[index].name,
                                      nameRu: transArr[1],
                                      nameEn: transArr[0],
                                      descRu: transArr[3],
                                      descEn: transArr[2],
                                      modified : db.events[index].filesExist[tabIndex],
                                      isFound:false,
                                      highlighted:false,
                                      corrupted: db.events[index].corrupted[tabIndex],
                                      realIndex: db.events[index].index
                                  })
        }
        //_LOG(db.events[event].name);
    }
}
function loadState(stateListModel, currentEventIndex, eventListModel, currentTabIndex) {
    if (currentEventIndex < 0) {
        _LOG("nothing selected")
        return
    }

    var eventName = eventListModel.get(currentEventIndex).name
    var eventDbIndex = search(eventName, db.events).index
    for (var index in db.states) {
        if ((db.states[index].accepts.length == 0
             || db.states[index].accepts.indexOf(eventName) >= 0)
                && db.events[eventDbIndex].selectedChain[currentTabIndex].indexOf(
                    db.states[index].name) === -1) {
            var transArr = getTranslationArray(db.states[index])
            stateListModel.append({
                                      name: db.states[index].name,
                                      nameRu: transArr[1],
                                      nameEn: transArr[0],
                                      modified : false,
                                      isFound:false,
                                      highlighted:false,
                                      corrupted:false
                                  })
        }
    }
    _LOG(eventListModel.get(currentEventIndex).name)
}
function getFilesObj(eventDbIndex, tabIndex, stateIndex)
{
    return db.events[eventDbIndex].filePaths[tabIndex][stateIndex];
}

function filesAreMissing(eventDbIndex, tabIndex, stateIndex)
{
    return db.events[eventDbIndex].filePaths[tabIndex][stateIndex].filesNotFound;
}

function loadPaths(eventDbIndex, tabIndex, stateIndex) {
    return db.events[eventDbIndex].filePaths[tabIndex][stateIndex].paths
}

function checkEventIsCorrupted(eventDbIndex, tabIndex)
{
    for(var i in db.events[eventDbIndex].filePaths[tabIndex])
    {
        if(db.events[eventDbIndex].filePaths[tabIndex][i].filesNotFound)
        {
            db.events[eventDbIndex].corrupted[tabIndex] = true;
            _LOG("ev cor - true")
            return true;
        }
    }
    db.events[eventDbIndex].corrupted[tabIndex] = false;
    return false;
}

function calcPathCount(eventDbIndex, tabIndex)
{
    var res = 0;
    for(var i in db.events[eventDbIndex].filePaths[tabIndex])
    {
        var path = db.events[eventDbIndex].filePaths[tabIndex][i];
        if(path.paths.length>0)
        {
            res+=1;
        }
    }
    db.events[eventDbIndex].filesExist[tabIndex]= res != 0;


    return res;
}

function updateRecents(cfg,recentModel,fileIO)
{
    recentModel.clear();
    for(var i = 0; i < cfg.projectHistory.length; ++i)
    {
        var text = i + ": " + cfg.projectHistory[i];
        if(fileIO.fileExists(cfg.projectHistory[i]))
        {
            recentModel.append({"text":text,"url":cfg.projectHistory[i]});
        }
    }
}

function checkPathInDb(listIndex, itemIndex, rootElement) {
    var currentEventName = rootElement.eventListModel.get(
                rootElement.eventList.currentIndex).name
    _LOG(currentEventName)
    var eventDbIndex = search(currentEventName, db.events).index
}

function getAllPathsIterative(inputArr, currentState, paths, maxCount)
{
    while(paths.length !== maxCount)
    {
        var shouldCont = false;
        for (var i = 1; i < currentState.length; ++i) {
            if (currentState[i] == -1) {
                if (currentState[i - 1] == -1) {
                    _LOG("i cannot be there?")
                } else {
                    currentState[i - 1] -= 1
                    currentState[i] = inputArr[i].length - 1
                    shouldCont = true;
                    continue;
                }
            }
        }
        if(shouldCont)
            continue;
        var arr = []
        for (i = 0; i < currentState.length; ++i) {
            arr.push(inputArr[i][currentState[i]])
        }
        paths.push(arr)
        currentState[currentState.length - 1] -= 1
    }
    return paths
}

function getAllPaths(inputArr, currentState, paths, maxCount) {
    if (paths.length == maxCount) {
        return paths
    }
    for (var i = 1; i < currentState.length; ++i) {
        if (currentState[i] == -1) {
            if (currentState[i - 1] == -1) {
                _LOG("i cannot be there?")
            } else {
                currentState[i - 1] -= 1
                currentState[i] = inputArr[i].length - 1
                return getAllPaths(inputArr, currentState, paths, maxCount)
            }
        }
    }
    var arr = []
    for (var i = 0; i < currentState.length; ++i) {
        arr.push(inputArr[i][currentState[i]])
    }
    paths.push(arr)
    currentState[currentState.length - 1] -= 1
    return getAllPaths(inputArr, currentState, paths, maxCount)
}

function checkValidity(eventDbIndex, tabIndex) {
    if (Object.keys(db.events[eventDbIndex].currentChain[tabIndex]).length
            != db.events[eventDbIndex].selectedChain[tabIndex].length) {
        return {
            addAnswer: false,
            removeAnswer: false
        }
    }
    for (var i in db.events[eventDbIndex].currentChain[tabIndex]) {
        if (db.events[eventDbIndex].currentChain[tabIndex][i].length == 0) {
            return {
                addAnswer: false,
                removeAnswer: false
            }
        }
    }


    var mySelection = db.events[eventDbIndex].currentChain[tabIndex]
    var selectionIndexes = []
    var count = 1
    for (var i in mySelection) {
        selectionIndexes.push(mySelection[i].length - 1)
        count *= mySelection[i].length
    }
    var arr = []
    var res = getAllPathsIterative(mySelection, selectionIndexes, arr, count)
    var dbPaths = db.events[eventDbIndex].statePaths[tabIndex]
    var resultAdd = res.filter(function (value) {
        return dbPaths.indexOf(value.toString()) == -1
    })
    var resultRemove = res.filter(function (value) {
        return dbPaths.indexOf(value.toString()) >= 0
    })
    for(var i in resultRemove)
    {
        _LOG(resultRemove[i].toString());
    }

    if (resultAdd.length == 0) {

        return {
            addAnswer: false,
            removeAnswer: true,
            removeArr: resultRemove
        }
    } else if (resultRemove.length == 0) {
        return {
            addAnswer: true,
            removeAnswer: false,
            addArr: resultAdd
        }
    } else {
        return {
            addAnswer: true,
            removeAnswer: true,
            addArr: resultAdd,
            removeArr: resultRemove
        }
    }
}

function addStatePath(arrToInsert, eventIndex, tabIndex, isMuted) {
    var returnArr = []
    var readable = []
    for (var i = 0; i < arrToInsert.length; ++i) {
        var index = db.events[eventIndex].statePaths[tabIndex].push(
                    arrToInsert[i].toString()) - 1
        var pathName = ""
        var readableArr = ["", ""]
        for (var j = 0; j < arrToInsert[i].length; ++j) {
            var state = search(
                        db.events[eventIndex].selectedChain[tabIndex][j],
                        db.states)

            if (state.content[arrToInsert[i][j]][0].indexOf('(*)') != -1) {
                pathName += '*'
                readableArr[0] += '*'
                readableArr[1] += '*'
            } else {
                pathName += state.content[arrToInsert[i][j]][0]
                var arr = getTranslationArray({
                                                  name: state.content[arrToInsert[i][j]][0],
                                                  readable: state.content[arrToInsert[i][j]].slice(
                                                      1)
                                              })
                readableArr[0] += arr[0]
                readableArr[1] += arr[1]
            }

            if (j != arrToInsert[i].length - 1) {
                pathName += '.'
                readableArr[0] += '.'
                readableArr[1] += '.'
            }
        }
        if (isMuted) {
            db.events[eventIndex].filePaths[tabIndex].push({
                                                               name: pathName,
                                                               readable: readableArr,
                                                               muted:true,
                                                               filesNotFound:false,
                                                               paths: ["Muted"]
                                                           })
        } else {
            db.events[eventIndex].filePaths[tabIndex].push({
                                                               name: pathName,
                                                               readable: readableArr,
                                                               muted:false,
                                                               filesNotFound:false,
                                                               paths: []
                                                           })
        }

        returnArr.push(pathName)
        readable.push(readableArr)
    }
    return [returnArr, readable]
}

function massCopyFiles(fileIO,obj)
{
    fileIO.massFilesCopy(JSON.stringify(obj));
}

function exportProject(rootObject, fileIO, exportPath, modName) {
    var res = fileIO.createDir(exportPath + "/" + modName+"_EXPORT")
    if (!res) {
        return false
    }
    var res = fileIO.createDir(
                exportPath + "/" + modName+"_EXPORT" + "/AudioExport")
    if (!res) {
        return false
    }
    var dirToCopy = exportPath + "/" + modName+"_EXPORT" + "/AudioExport"
    var exportDb = JSON.parse(JSON.stringify(db))
    var returnObj= {massFilesArr:[],dirToCopy:dirToCopy};
    for (var i in exportDb.events) {
        var eventObj = exportDb.events[i]
        for (var j in eventObj.filePaths) {
            var filePathsArr = eventObj.filePaths[j]
            for (var t in filePathsArr) {
                if(filePathsArr[t].filesNotFound)
                {
                    eventObj.corrupted[j] = false
                    filePathsArr[t].filesNotFound = false
                    filePathsArr[t].paths = []
                    continue
                }
                var filePathArr = filePathsArr[t].paths
                for (var k in filePathArr) {
                    if (fileIO.fileExists(filePathArr[k])) {
                        returnObj.massFilesArr.push(filePathArr[k])
                        var fileName = fileIO.getFileName(filePathArr[k])
                        filePathArr[k] = "AudioExport/" + fileName
                    }
                }
            }
        }
    }
    var currentSelection = exportDb.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex]
    for (var i in currentSelection) {
        exportDb.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex][i] = []
    }
    exportDb.modDirInGame = ""
    exportDb.projectFileDir = ""
    exportDb.projectFilePath = ""
    exportDb.modName = modName
    exportDb.copyFiles = true
    fileIO.setSource(
                exportPath + "/" + modName+"_EXPORT" + "/" + modName + ".rve")
    fileIO.write(JSON.stringify(exportDb))
    return returnObj;
}

function appendGlobalStateToAll(rootObject,stateNameFull,stateValue,stateValueIndex)
{
    for(var i in db.events)
    {
        var currentEvent = db.events[i];
        for(var tabIndex in currentEvent.selectedChain)
        {
            if(currentEvent.selectedChain[tabIndex].indexOf(stateNameFull) === -1)
            {

                currentEvent.selectedChain[tabIndex].push(stateNameFull);
                var currentSelection = db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex]
                for (var k in currentSelection) {
                    db.events[rootObject.currentEventDbIndex].currentChain[rootObject.tabs.currentIndex][k] = []
                }
                currentEvent.currentChain[tabIndex].push([]);
                var filePaths = currentEvent.filePaths[tabIndex];
                for (var j = 0; j < filePaths.length; ++j)
                {
                    filePaths[j].name += "."+stateValue;
                    var newReadableArr = []
                    for (var k = 0; k < 2; ++k) {
                        newReadableArr[k] = filePaths[j].readable[k] + "."+stateValue
                    }
                    filePaths[j].readable = newReadableArr
                }
                for (var k = 0; k < currentEvent.statePaths[tabIndex].length; ++k)
                {
                   currentEvent.statePaths[tabIndex][k] += ","+stateValueIndex;
                }
            }
        }
    }
}

function appendGlobalState(rootObject,stateName,stateValue)
{
    _LOG(stateName,stateValue);
    var found = false;
    for(var i in db.states)
    {
        if(db.states[i].accepts.length === 0)
        {
            if(db.states[i].content[0].indexOf(stateName) !== -1)
            {
                for(var j in db.states[i].content)
                {
                    if(db.states[i].content[j].indexOf(stateValue) !== -1)
                    {
                        db.states[i].globallyAppended = true;
                        found = true;
                        appendGlobalStateToAll(rootObject,db.states[i].name,stateValue,j);
                        for(var k = 0; k < rootObject.globalMenuModel.count; ++k)
                        {
                            var t = rootObject.globalMenuModel.get(k).text;
                            if(t.split(';').indexOf(stateName) !== -1)
                            {
                                rootObject.globalMenuModel.remove(k);
                                return true;
                            }
                        }
                    }
                }
            }
        }
    }
    return false;
}

function constructGlobalStates(rootObject)
{
    var globalMenuModel = rootObject.globalMenuModel;
    var listReadyToAppend = []
    for(var i in db.states)
    {
        if(db.states[i].accepts.length === 0 &&
                (db.states[i].hasOwnProperty('globallyAppended') === false
                 || db.states[i].globallyAppended === false))
        {
            db.states[i].globallyAppended = false;
            var objToAppend = []
            var translation = getTranslationStateArray(db.states[i])
            for(var j = 1; j < translation.length; ++j)
            {
                objToAppend.push(translation[j][0]+';'+translation[j][1])
            }
            var strToAppend =objToAppend.toString();
            listReadyToAppend.push({"name":translation[0][0]+';'+translation[0][1],"content":strToAppend});
        }
    }
    for(var i in listReadyToAppend)
    {
        globalMenuModel.append({"text":listReadyToAppend[i].name,"statesNames":listReadyToAppend[i].content});
    }
}

function updateGlobalStates(rootObject)
{

}

function checkModGameDir(rootObject, fileIO, modName)
{
    var res = fileIO.createDir(rootObject.cfg.gameDir + "/res_mods")
    if (!res) {
        return false
    }
    var verPath = fileIO.findLatestVersion(
                rootObject.cfg.gameDir + "/res_mods/")
    if (verPath !== "") {
        res = fileIO.createDir(verPath + "/banks")
        res = fileIO.createDir(verPath + "/banks/mods")
        res = fileIO.createDir(verPath + "/banks/mods/" + modName)
        if (res) {
            rootObject.modDirInGame = verPath + "/banks/mods/" + modName
        }
    } else {
        return false
    }
    db.modDirInGame = rootObject.modDirInGame;
    return true;
}

function importProject(rootObject, fileIO, importFilePath) {
    var projectFileDir = fileIO.getFileDir(importFilePath)
    var res = fileIO.createDir(projectFileDir + "/Audio")
    if (!res) {
        return false
    }
    var dirToCopy = projectFileDir + "/Audio"
    var ditFromCopy = projectFileDir
    var importDb = getDbFromfile(importFilePath, fileIO)
    if (!importDb.hasOwnProperty("events")) {
        return false
    }
    for (var i in importDb.events) {
        var eventObj = importDb.events[i]
        for (var j in eventObj.filePaths) {
            var filePathsArr = eventObj.filePaths[j]
            for (var t in filePathsArr) {
                var filePathArr = filePathsArr[t].paths
                for (var k in filePathArr) {
                    var absFilePath = ditFromCopy + "/" + filePathArr[k]
                    if (fileIO.fileExists(absFilePath)) {
                        var fileName = fileIO.copyFile(absFilePath, dirToCopy)
                        filePathArr[k] = dirToCopy + "/" + fileName
                    }
                }
            }
        }
    }

    if(checkModGameDir(rootObject,fileIO,importDb.modName)===false)
    {
        return false
    }

    importDb.modDirInGame = rootObject.modDirInGame
    importDb.projectFileDir = projectFileDir
    fileIO.setSource(projectFileDir + "/" + importDb.modName + ".rvm")
    fileIO.write(JSON.stringify(importDb))
    importDb.projectFilePath = fileIO.source
    importDb.programVersion = rootObject.pROGRAM_VERSION_STR;
    loadProject(importDb, rootObject.tabs, rootObject)
}

function selectionChanged(listIndex, itemsSelected, eventDbIndex, tabIndex) {

    db.events[eventDbIndex].currentChain[tabIndex][listIndex] = itemsSelected
    var str = ""
    for (var i in db.events[eventDbIndex].currentChain[tabIndex]) {
        str += i + "->("
        for (var j in db.events[eventDbIndex].currentChain[tabIndex][i]) {
            str += db.events[eventDbIndex].currentChain[tabIndex][i][j] + " "
        }
        str += ");"
    }
    _LOG(str)
}

function loadCurrentStatesList(rootElement) {
    var currentEventName = rootElement.eventListModel.get(
                rootElement.eventList.currentIndex).name
    _LOG(currentEventName)
    var eventDbIndex = search(currentEventName, db.events).index
    _LOG(eventDbIndex + " " + rootElement.tabs.currentIndex)
    rootElement.stateListModel.clear()
    for (var index in db.events[eventDbIndex].selectedChain[rootElement.tabs.currentIndex]) {
        var t = addStateToStateList(
                    rootElement,
                    db.events[eventDbIndex].selectedChain[rootElement.tabs.currentIndex][index],
                    true, rootElement.tabs.currentIndex)
        _LOG(t)
        rootElement.stateListModel.append({
                                              stateValues: t,
                                              name: db.events[eventDbIndex].selectedChain[rootElement.tabs.currentIndex][index]
                                          })
    }

    rootElement.pathTableModel.clear()
    db.events[eventDbIndex].currentChain[rootElement.tabs.currentIndex]=[];
    var filepaths = db.events[eventDbIndex].filePaths[rootElement.tabs.currentIndex]
    for (var index in filepaths) {
        var paths = filepaths[index].paths.toString()
        var displayButton = 1
        if(filepaths[index].muted)
        {
            displayButton = 0
        }
        if(filepaths[index].filesNotFound)
        {
            paths = "NOT FOUND"
        }
        var chainIndexesArr = db.events[eventDbIndex].statePaths[rootElement.tabs.currentIndex][index];
        db.events[eventDbIndex].filesExist[rootElement.tabs.currentIndex] = true;

        rootElement.pathTableModel.append({
                                              path: filepaths[index].name,
                                              readEN: filepaths[index].readable[0],
                                              readRU: filepaths[index].readable[1],
                                              chainIndexes : chainIndexesArr,
                                              files: paths,
                                              mySuperIndex: displayButton,
                                              selected : false,
                                              history : 0
                                          })
    }
    rootElement.activated()
}

function getPathIndex(stateChain, currentEventIndex, currentTabIndex) {
    return db.events[currentEventIndex].statePaths[currentTabIndex].indexOf(
                stateChain)
}
function deletePaths(stateChain, currentEventIndex, currentTabIndex) {
    var indexArr = []
    for (var i in stateChain) {
        var index = getPathIndex(stateChain[i].toString(), currentEventIndex,
                                 currentTabIndex)
        db.events[currentEventIndex].statePaths[currentTabIndex].splice(index,
                                                                        1)
        db.events[currentEventIndex].filePaths[currentTabIndex].splice(index, 1)
        indexArr.push(index)
    }
    return indexArr
}

function mutePaths(arrToInsert, eventIndex, tabIndex) {}
function searchWithIndex(nameKey, myArray) {
    for (var i = 0; i < myArray.length; i++) {
        if (myArray[i].name === nameKey) {
            myArray[i].__MY_CURRENT_INDEX = i;
            return myArray[i]
        }
    }
    return null
}
function search(nameKey, myArray) {
    for (var i = 0; i < myArray.length; i++) {
        if (myArray[i].name === nameKey) {            
            return myArray[i]
        }
    }
    return null
}
function getSelectionFromClick(currentSelection,indexOfItemPressed, shiftIsPressed,
                               controlIsPressed, multiselect)
{
    var listOfSelected = []
    if(!(controlIsPressed
         || shiftIsPressed))
    {
        for (var i = 0; i < currentSelection.length; ++i)
        {
            var state = currentSelection[i];
            if (i !== indexOfItemPressed)
            {
                state.selected = false
            } else if(!multiselect)
            {
                state.selected = !state.selected
            }
            else
            {
                state.selected = true
            }
        }
        multiselect=false;
    }
    else if(controlIsPressed && !shiftIsPressed)
    {
        currentSelection[indexOfItemPressed].selected = !currentSelection[indexOfItemPressed].selected
        multiselect=true;
    }
    else if(shiftIsPressed)
    {
        multiselect=true;
        var indexOfPrev = 0;
        for (var i = 0; i < currentSelection.length; ++i)
        {
            if(currentSelection[i].history === 1)
            {
                indexOfPrev = i;
                break;
            }
        }
        var sign = indexOfPrev - indexOfItemPressed  > 0 ? 1 : -1
        if(!controlIsPressed)
        {
            for (var i = 0; i < currentSelection.length; ++i) {
                if (i * sign <= indexOfPrev * sign
                        && i * sign >= indexOfItemPressed * sign) {
                    currentSelection[i].selected = true
                } else {
                    currentSelection[i].selected = false
                }
            }
        }
        else
        {
            for(var i = indexOfItemPressed; (indexOfPrev-i)*sign >= 0; i+=sign)
            {
                currentSelection[i].selected = true;
            }
        }
    }
    for (var i = 0; i < currentSelection.length; ++i)
    {
        var state =  currentSelection[i];
        if (i != indexOfItemPressed)
        {
            state.history = 0
        }
        else
        {
            state.history = 1
        }
        if(state.selected)
        {
            listOfSelected.push(i);
        }
    }
    return {multiselect:multiselect,newSelection:currentSelection, listOfSelected:listOfSelected};
}

function selectInTable(rootElement, currentEventIndex, currentTabIndex, arrToSelect) {
    _LOG(arrToSelect.length);
    for (var i in arrToSelect) {
        var indItTable = db.events[currentEventIndex].statePaths[currentTabIndex].indexOf(
                    arrToSelect[i].toString())
        if (indItTable >= 0)
            rootElement.pathTable.selection.select(indItTable)
    }
}

function getEventDbIndex(eventName) {
    _LOG(eventName)
    return search(eventName, db.events).index
}

function removeItemFromChain(itemName, currentEventIndex, currentTabIndex, pathsTable, rootElement) {
    var currentEventName = rootElement.eventListModel.get(
                rootElement.eventList.currentIndex).name
    currentEventIndex = getEventDbIndex(currentEventName)
    _LOG(itemName)
    var index = db.events[currentEventIndex].selectedChain[currentTabIndex].indexOf(
                itemName)
    if (index >= 0) {
        db.events[currentEventIndex].selectedChain[currentTabIndex].splice(
                    index, 1)
        var currentPaths = db.events[currentEventIndex].statePaths[currentTabIndex]
        var canMerge = currentPaths.length > 1
        for (var i = 1; i < currentPaths.length; ++i) {
            var states = currentPaths[i].split(',')
            var prevStates = currentPaths[i - 1].split(',')
            if (states[index] != prevStates[index]) {
                canMerge = false
            }
        }
        if (canMerge) {
            var filePaths = db.events[currentEventIndex].filePaths[currentTabIndex]
            for (var i in filePaths) {
                var states = filePaths[i].name.split('.')
                states.splice(index, 1)
                var newStr = ""
                for (var j in states) {
                    newStr += states[j]
                    if (j != states.length - 1) {
                        newStr += '.'
                    }
                }
                filePaths[i].name = newStr
                var newReadableArr = ["", ""]
                var oldReadableArr = [filePaths[i].readable[0].split(
                                          '.'), filePaths[i].readable[1].split(
                                          '.')]
                for (var t = 0; t < 2; ++t) {
                    oldReadableArr[t].splice(index, 1)
                    for (var j in oldReadableArr[t]) {
                        newReadableArr[t] += oldReadableArr[t][j]
                        if (j != oldReadableArr[t].length - 1) {
                            newReadableArr[t] += '.'
                        }
                    }
                }
                filePaths[i].readable = newReadableArr
            }
            var statePaths = db.events[currentEventIndex].statePaths[currentTabIndex]
            for (var i in statePaths) {
                var statesIndexes = statePaths[i].split(',')
                statesIndexes.splice(index, 1)
                statePaths[i] = statesIndexes.toString()
                pathsTable.setProperty(i, "chainIndexes", statePaths[i])
            }
            for (var i = 0; i < pathsTable.count; ++i) {
                pathsTable.setProperty(i, "path", filePaths[i].name)
                pathsTable.setProperty(i, "readEN", filePaths[i].readable[0])
                pathsTable.setProperty(i, "readRU", filePaths[i].readable[1])
            }
            rootElement.activated()
        } else {
            db.events[currentEventIndex].filePaths[currentTabIndex] = []
            db.events[currentEventIndex].statePaths[currentTabIndex] = []
            pathsTable.clear()
        }
        var arr = []
        for (var i = 0; i
             < db.events[currentEventIndex].selectedChain[currentTabIndex].length; ++i) {
            arr.push([])
        }
        db.events[currentEventIndex].currentChain[currentTabIndex] = arr
        loadCurrentStatesList(rootElement)
    } else {
        _LOG("error")
    }
}

//chain is array of strings
function addNewItemToChain(itemName, rootElement, tabIndex, pathsTable) {
    var currentEventName = rootElement.eventListModel.get(
                rootElement.eventList.currentIndex).name
    _LOG(currentEventName)
    var eventDbIndex = search(currentEventName, db.events).index
    if (itemName.indexOf("*") > -1) {
        db.events[eventDbIndex].selectedChain[tabIndex].push(itemName)
        db.events[eventDbIndex].currentChain[tabIndex].push([])
        var filePaths = db.events[eventDbIndex].filePaths[tabIndex]
        for (var i = 0; i < filePaths.length; ++i) {
            filePaths[i].name += ".*"
            var newReadableArr = []
            for (var j = 0; j < 2; ++j) {
                newReadableArr[j] = filePaths[i].readable[j] + ".*"
            }
            filePaths[i].readable = newReadableArr
        }
        for (var i = 0; i < pathsTable.count; ++i) {
            pathsTable.setProperty(i, "path", filePaths[i].name)
            pathsTable.setProperty(i, "readEN", filePaths[i].readable[0])
            pathsTable.setProperty(i, "readRU", filePaths[i].readable[1])
        }
        rootElement.activated()

        for (var i = 0; i < db.events[eventDbIndex].statePaths[tabIndex].length; ++i) {
            db.events[eventDbIndex].statePaths[tabIndex][i] += ",0"
            pathsTable.setProperty(i, "chainIndexes", db.events[eventDbIndex].statePaths[tabIndex][i]);
        }
        //_LOG(JSON.stringify(db));
    } else {
        _LOG("error addNewItemToChain")
    }
}

function addStateToStateList(rectangle, selectedState, initLoad, tabIndex) {
    var newList = []
    var currentState = search(selectedState, db.states)
    var translationNames = getTranslationStateArray(currentState)
    newList.push({
                     name: currentState.name,
                     nameRu: translationNames[0][1],
                     nameEn: translationNames[0][0],
                     selected: false,
                     isFound:false,
                     highlighted:false,
                     modified : false,
                     history : 0
                 })
    for (var index = 1; index < currentState.content.length; ++index) {
        //_LOG(currentState.content[index]);
        newList.push({
                         name: currentState.content[index][0],
                         nameRu: translationNames[index][1],
                         nameEn: translationNames[index][0],
                         selected: false,
                         isFound:false,
                         highlighted:false,
                         modified : false,
                         history : 0
                     })

        //_LOG(db.events[event].name);
    }
    if (!initLoad) {
        addNewItemToChain(selectedState, rectangle, tabIndex,
                          rectangle.pathTableModel)
    }
    return newList
}

function getIsCopyFiles() {
    return db.copyFiles
}

function generateOutput(generator, rootElement) {
    generator.setOutputDir(rootElement.modDirInGame)
    generator.serialize(JSON.stringify(db))
    var ans = generator.generate(true, rootElement.projectFileDir + "/Audio",
                                 rootElement.cfg.wwiseExe,
                                 rootElement.cfg.wwiseProjFile,
                                 "WOWS_WEM_CONVERSION")

    //var t = generator.runWwiseConversion();
    _LOG(ans.toString())
}
