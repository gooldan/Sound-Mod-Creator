#ifndef GENERATOR_H
#define GENERATOR_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <thread>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QObject>
#include "ConfigReader.h"
#include <QHash>
#include "QXmlStreamWriter"
#include <functional>
#include <algorithm>
#include <thread>
#include <QProcess>

struct StateValue{
    QString stateName;
    QString stateValue;
};

struct ExtendedEvent:Event{
    std::vector<StateValue> stateList;
    std::vector<QString> pathList;
    std::vector<QString> latinPathList;

};

struct ExternalEventContainer{
    std::vector<ExtendedEvent> stateChains;
    QString extID;
};
struct ExternalEvent{
    std::array<ExternalEventContainer,3> events;
    std::vector<QString> names={"Voice","SFX","Loop"};
    std::vector<QString> extIds={"","",""};
    QString eventName;
};

class Generator : public QObject
{
    Q_OBJECT
public:
    explicit Generator(QObject *parent = 0);
    Q_INVOKABLE bool setOutputDir(const QString &dirFilepath);
    Q_INVOKABLE bool serialize(const QString &jsString);
    Q_INVOKABLE QString generate(bool copy,const QString &dir,const QString &pathToCLI, const QString &pathToProj, const QString& conversion);

signals:
    void mainProgress(int progress);
    void fileCopyProgress(int progress);
    void allFilesCopied();
    void generationDone();
    void wwiseGenEnd(int errorCode);
    void wwiseMessage(QString message);
public slots:
    void printProgress(int progress);
    void wwiseOutput();
private:
    QString runWwiseConversion(const QString &dir,const QString &pathToCLI, const QString &pathToProj, const QString& conversion);
    bool checkForExistance();
    void copyFiles(const QString &dir, const QString &pathToCLI, const QString &pathToProj, const QString &conversion);
    std::vector<QString> filesList;
    std::vector<QString> latinFilesList;
    std::vector<QString> notFoundFiles;
    std::vector<QString> wavFiles;
    std::vector<ExternalEvent> serializedEvents;
    QString outputDir;
    QProcess *proc;
};

#endif // GENERATOR_H
