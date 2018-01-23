#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QDir>
//#define develop 1
class FileIO : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QString source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)
    explicit FileIO(QObject *parent = 0);
    Q_INVOKABLE QString readOld();
    Q_INVOKABLE QString read();

    Q_INVOKABLE bool write(const QString& data);
    Q_INVOKABLE bool createDir(const QString &filepath);
    Q_INVOKABLE static bool fileExists(const QString &filepath);
    Q_INVOKABLE QString getFileDir(const QString &filepath);
    Q_INVOKABLE static QString findLatestVersion(const QString &dirWithMods);
    Q_INVOKABLE static QString copyFile(const QString &filePath, const QString &dirToCopy);
    Q_INVOKABLE QString copyAudioFile(const QString &filePath, const QString &dirToCopy, const bool copy);
    Q_INVOKABLE QString massFilesCopy(const QString &jsonObj);
    Q_INVOKABLE static QString getDirectoryContent(const QString &dirFilePath, bool allFiles = false);
    Q_INVOKABLE static bool removeFile(const QString &filePath);
    Q_INVOKABLE QString getFileName(const QString &filePath);
    QString source() { return mSource; }

    Q_INVOKABLE bool createProjectFile(const QString &filename);
public slots:
    void setSource(const QString& source) { mSource = source; }

signals:
    void sourceChanged(const QString& source);
    void error(const QString& msg);
    void allFilesCopied(const QString copiedList);
    void fileCopyProgress(int progress);
    void namedFileCopyProgress(float progress, const QString &filename);
private:
    QString mSource;
    QString mProjectFile;
};

#endif // FILEIO_H
