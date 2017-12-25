#ifndef CONFIGREADER_H
#define CONFIGREADER_H
#include <QString>
#include <memory>
#include <QFile>
#include "ErrorCode.h"
#include <QXmlStreamReader>
#include <vector>
#include <map>
#include <array>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QObject>

//#define TRACE

struct ElementDescription
{

    std::array<QString,3> readable;
    std::array<QString,3> description;
};

struct ExternalType
{
    QString name;
    QString id;
    ElementDescription details;
};

struct Event
{
    QString name;
    std::array<ExternalType,3> acceptedTypes;
    ElementDescription details;
};

struct StateElement
{
    QString name;
    ElementDescription details;
};

struct State
{
    QString name;
    QString realName;
    std::vector<QString> references;
    std::vector<StateElement> values;
    ElementDescription details;
};

class ConfigReader : public QObject
{
    Q_OBJECT
public:

    enum ErrorCode{
        OK,
        XML_END,
        CANT_OPEN_CONFIG_FILE,
        FILE_NOT_OPENED,
        XML_ERROR
    };
    Q_ENUMS(ErrorCode)

    explicit ConfigReader(QObject *parent = 0);
    Q_INVOKABLE int openConfig(const QString &filepath);
    Q_INVOKABLE int parse();
    Q_INVOKABLE QString createJSON();
private:
    int parseStates();
    int parseEvents();
    int readNextHeaderName(const char *name="");
    QJsonObject getDefaultState();
    QXmlStreamReader xml;
    QFile configFile;
    std::vector<Event> events;
    std::vector<State> states;
    int version;
};

#endif // CONFIGREADER_H
