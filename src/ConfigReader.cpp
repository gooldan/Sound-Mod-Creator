#include "ConfigReader.h"
ConfigReader::ConfigReader(QObject *parent):
    QObject(parent)
{


}

int ConfigReader::openConfig(const QString &filepath)
{
    configFile.close();
    configFile.setFileName(filepath);
    if(!configFile.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        return ErrorCode::CANT_OPEN_CONFIG_FILE;
    }
    xml.setDevice(&configFile);
    return ErrorCode::OK;
}

int ConfigReader::parse()
{
    events.clear();
    states.clear();
    if(xml.device() == NULL)
    {
        return ErrorCode::FILE_NOT_OPENED;
    }
    while (!xml.atEnd())
    {
        xml.readNext();
        if(xml.hasError())
        {
            return ErrorCode::XML_ERROR;
        }
        if (xml.isStartDocument())
        {
            continue;
        }
        if (xml.isStartElement())
        {
            if(xml.name() == "mod.xml")
            {

            }
            if(xml.name() == "events")
            {
                QXmlStreamAttributes attributes = xml.attributes();
                for(auto &attr : attributes)
                {
                    if(attr.name()=="version")
                    {
                        version=attr.value().toInt();
                    }
                    else
                    {
                        return ErrorCode::XML_ERROR;
                    }
                }
                auto err = parseEvents();
                if (err != ErrorCode::OK)
                {
                    return err;
                }
            }
            if(xml.name() == "states")
            {

                auto err = parseStates();
                if (err != ErrorCode::OK)
                {
                    return err;
                }
            }
        }

    }
    return ErrorCode::OK;
}
QJsonObject ConfigReader::getDefaultState()
{
    QJsonObject stateObj;
    stateObj["name"]="default (*)";
    stateObj["realName"]="default";
    QJsonArray acceptArr;
    stateObj["accepts"]=acceptArr;

    QJsonArray contentArr;
    QJsonArray valueArr;

    valueArr.append("default (*)");
    valueArr.append("");
    valueArr.append("default (*)");
    valueArr.append("По умолчанию (*)");
    contentArr.append(valueArr);
    valueArr.pop_front();
    stateObj["readable"]=valueArr;
    stateObj["content"]=contentArr;
    stateObj["globallyAppended"] = true;
    return stateObj;
}

QString ConfigReader::createJSON()
{
    QJsonDocument doc;
    QJsonObject obj;
    QJsonArray eventsArr;
    for (size_t i = 0, eSize=events.size(); i < eSize; ++i)
    {
        QJsonObject eventObj;
        eventObj["name"]=events[i].name;

        QJsonArray extIds;
        for(auto &type : events[i].acceptedTypes)
        {
            extIds.append(type.id);
        }
        eventObj["extIds"]=extIds;
        QJsonArray acceptsArray;
        for(auto &accType : events[i].acceptedTypes)
        {
            acceptsArray.append(QJsonValue(accType.name));
        }
        eventObj["accepts"]=acceptsArray;

        QJsonArray selectedChain;
        for (int i = 0; i < 3; ++i)
        {
            QJsonArray arr;
            arr.push_back("default (*)");
            selectedChain.push_back(arr);
        }
        eventObj["selectedChain"]=selectedChain;

        QJsonArray currentChain;
        for (int i = 0; i < 3; ++i)
        {
            QJsonArray arr;
            arr.push_back(QJsonArray());
            currentChain.push_back(arr);
        }
        eventObj["currentChain"]=currentChain;

        QJsonArray statePaths;
        for (int i = 0; i < 3; ++i)
        {
            statePaths.push_back(QJsonArray());
        }
        eventObj["statePaths"]=statePaths;

        QJsonArray filePaths;
        for (int i = 0; i < 3; ++i)
        {
            filePaths.push_back(QJsonArray());
        }

        QJsonArray readable;
        for (int j = 0; j < 3; ++j)
        {
            QJsonArray readableType;
            for(int t = 0; t < 3; ++t)
            {
                readableType.push_back(events[i].acceptedTypes[j].details.readable[t]);
            }
            readable.push_back(readableType);
        }
        QJsonArray description;
        for (int j = 0; j < 3; ++j)
        {
            description.push_back(events[i].details.description[j]);
        }
        eventObj["description"]=description;
        eventObj["readable"]=readable;
        QJsonArray filesExist;
        for (int j = 0; j < 3; ++j)
        {
            filesExist.append(false);
        }
        eventObj["filesExist"]=filesExist;
        eventObj["filePaths"]=filePaths;
        eventObj["index"]=QJsonValue(static_cast<int>(i));
        QJsonArray corrupted;
        for(int j = 0; j < 3; ++j)
        {
            corrupted.append(false);
        }
        eventObj["corrupted"] = corrupted;
        eventsArr.append(eventObj);
    }
    obj["events"]=eventsArr;

    QJsonArray statesArr;
    for (auto &state : states)
    {
        QJsonObject stateObj;
        stateObj["name"] = state.name + " (*)";
        stateObj["realName"] = state.name;
        stateObj["globallyAppended"] = false;
        QJsonArray acceptArr;
        for (auto &val : state.references)
        {
            acceptArr.append(val);
        }
        stateObj["accepts"]=acceptArr;

        QJsonArray contentArr;
        QJsonArray valueArr;

        valueArr.append(state.name + " (*)");
        for (int i = 0; i < 3; ++i)
        {
            valueArr.append(state.details.readable[i]);
        }
        contentArr.append(valueArr);
        valueArr.pop_front();
        stateObj["readable"]=valueArr;
        for (auto &val : state.values)
        {
            QJsonArray valueArr;
            valueArr.append(val.name);
            for (int i = 0; i < 3; ++i)
            {
                valueArr.append(val.details.readable[i]);
            }
            contentArr.append(valueArr);
        }
        stateObj["content"]=contentArr;
        statesArr.append(stateObj);
    }
    statesArr.append(getDefaultState());
    obj["states"]=statesArr;
    obj["version"]=version;
    doc.setObject(obj);
    return doc.toJson(QJsonDocument::JsonFormat::Compact);

}

int getIndexFromName(const QStringRef &str)
{
    auto c=str.constData()[str.length()-1];
    if(c=='i')
    {
        return 0;
    }
    else if(c=='n')
    {
        return 1;
    }
    else if(c=='u')
        return 2;

    return -1;
}

int ConfigReader::parseEvents()
{
    auto err=readNextHeaderName("event");
    if(err!=ErrorCode::OK)
    {
        return err;
    }
    while(err!=ErrorCode::XML_END)
    {
        QXmlStreamAttributes attributes = xml.attributes();
        Event newEvent;
        for(auto &attr : attributes)
        {
            if(attr.name()=="name")
            {
                newEvent.name=attr.value().toString();
            }
            else if (attr.name().indexOf("read")>=0)
            {
                int index=getIndexFromName(attr.name());
                if (index<0) return ErrorCode::XML_ERROR;
                newEvent.details.readable[index]=attr.value().toString();
            }
            else if (attr.name().indexOf("desc")>=0)
            {
                int index=getIndexFromName(attr.name());
                if (index<0) return ErrorCode::XML_ERROR;
                newEvent.details.description[index]=attr.value().toString();
            }
            else
            {
                return ErrorCode::XML_ERROR;
            }
        }
        err=readNextHeaderName("acceptedType");
        if(err != ErrorCode::OK)
        {
            return err;
        }

        while (err != ErrorCode::XML_END)
        {
            QXmlStreamAttributes attributes = xml.attributes();
            ExternalType newType;
            int typeIndex = -1;
            for(auto &attr : attributes)
            {
                if(attr.name()=="name")
                {
                    newType.name=attr.value().toString();
                    if(newType.name[0]=='V')
                        typeIndex = 0;
                    else if(newType.name[0]=='S')
                        typeIndex = 1;
                    else if(newType.name[0]=='L')
                        typeIndex = 2;
                    else
                        typeIndex = -1;

                }
                else if (attr.name() == "externalId")
                {
                    newType.id=attr.value().toString();
                }
                else if (attr.name().indexOf("read")>=0)
                {
                    int index=getIndexFromName(attr.name());
                    if (index<0) return ErrorCode::XML_ERROR;
                    newType.details.readable[index]=attr.value().toString();
                }
                else if (attr.name().indexOf("desc")>=0)
                {
                    int index=getIndexFromName(attr.name());
                    if (index<0) return ErrorCode::XML_ERROR;
                    newType.details.description[index]=attr.value().toString();
                }
                else
                {
                    return ErrorCode::XML_ERROR;
                }
            }
            if(typeIndex > 2 || typeIndex < 0)
            {
                return ErrorCode::XML_ERROR;
            }
            newEvent.acceptedTypes[typeIndex]=newType;
            err=readNextHeaderName("acceptedType");
            if(err != ErrorCode::OK && err != ErrorCode::XML_END)
            {
                return err;
            }
        }
        events.push_back(newEvent);
        err=readNextHeaderName("event");
    }
    return ErrorCode::OK;
}



int ConfigReader::parseStates()
{
    auto err=readNextHeaderName("state");
    if(err!=ErrorCode::OK)
    {
        return err;
    }
    while(err!=ErrorCode::XML_END)
    {
        QXmlStreamAttributes attributes = xml.attributes();
        State newState;
        for(auto &attr : attributes)
        {
            if(attr.name()=="name")
            {
                newState.name=attr.value().toString();
            }
            else if (attr.name().indexOf("read")>=0)
            {
                int index=getIndexFromName(attr.name());
                if (index<0) return ErrorCode::XML_ERROR;
                newState.details.readable[index]=attr.value().toString();
            }
            else if (attr.name().indexOf("desc")>=0)
            {
                int index=getIndexFromName(attr.name());
                if (index<0) return ErrorCode::XML_ERROR;
                newState.details.description[index]=attr.value().toString();
            }
            else
            {
                return ErrorCode::XML_ERROR;
            }
        }
        err=readNextHeaderName("values");
        if(err != ErrorCode::OK)
        {
            return err;
        }
        err=readNextHeaderName("value");
        if(err != ErrorCode::OK)
        {
            return err;
        }
        while (err != ErrorCode::XML_END)
        {
            QXmlStreamAttributes attributes = xml.attributes();
            StateElement newStateElement;
            for(auto &attr : attributes)
            {
                if(attr.name()=="name")
                {
                    newStateElement.name=attr.value().toString();
                }
                else if (attr.name().indexOf("read")>=0)
                {
                    int index=getIndexFromName(attr.name());
                    if (index<0) return ErrorCode::XML_ERROR;
                    newStateElement.details.readable[index]=attr.value().toString();
                }
                else if (attr.name().indexOf("desc")>=0)
                {
                    int index=getIndexFromName(attr.name());
                    if (index<0) return ErrorCode::XML_ERROR;
                    newStateElement.details.description[index]=attr.value().toString();
                }
                else
                {
                    return ErrorCode::XML_ERROR;
                }
            }
            newState.values.push_back(newStateElement);
            err=readNextHeaderName("value");
            if(err != ErrorCode::OK && err != ErrorCode::XML_END)
            {
                return err;
            }
        }
        err=readNextHeaderName("references");
        if(err != ErrorCode::OK)
        {
            return err;
        }
        err=readNextHeaderName("event");
        if(err != ErrorCode::OK && err != ErrorCode::XML_END)
        {
            return err;
        }
        while (err != ErrorCode::XML_END)
        {
            auto attributes = xml.attributes();
            if (attributes.hasAttribute("name"))
            {
                newState.references.push_back(attributes.value("name").toString());
            }
            else
            {
                return ErrorCode::XML_ERROR;
            }
            err=readNextHeaderName("event");
            if(err != ErrorCode::OK && err != ErrorCode::XML_END)
            {
                return err;
            }
        }
        states.push_back(newState);
        err=readNextHeaderName("state");
    }
    return ErrorCode::OK;
}


int ConfigReader::readNextHeaderName(const char *name)
{
    bool res=xml.readNextStartElement();
    while(res==false)
    {
        if(xml.hasError())
        {
            return ErrorCode::XML_ERROR;
        }
        if(xml.isEndElement() && xml.name() != name)
        {
            return ErrorCode::XML_END;
        }
        res=xml.readNextStartElement();
    }
#ifdef TRACE
    auto str=xml.qualifiedName();

    printf("%s",str.toUtf8().data());
    fflush(stdout);
#endif
    return ErrorCode::OK;
}
