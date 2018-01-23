#include "fileio.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDirIterator>
#include <QVersionNumber>
#include <memory>
#include <thread>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QObject>
#include <QProcess>
#include <QTemporaryDir>
#include <QDataStream>
FileIO::FileIO(QObject *parent) :
    QObject(parent)
{

}

QString FileIO::readOld()
{
    if (mSource.isEmpty()){
        emit error("source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QString line;
        QTextStream t( &file );
        do {
            line = t.readLine();
            fileContent += line;
         } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        return QString();
    }
    return fileContent;
}

QString FileIO::read()
{
    if (mSource.isEmpty()){
        emit error("source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if ( file.open(QIODevice::ReadOnly) ) {
        QByteArray asSaved = file.readAll();
#ifdef develop
        QString strRestored(QString::fromUtf8(asSaved));
#else
        QString strRestored(QString::fromUtf8(QByteArray::fromBase64(asSaved)));
#endif
        file.close();
        return strRestored;
    } else {
        emit error("Unable to open the file");
        return QString();
    }
}

bool FileIO::write(const QString& data)
{
    if (mSource.isEmpty())
        return false;

    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
#ifdef develop
    out << data.toUtf8();
#else
    out << data.toUtf8().toBase64();
#endif
    file.close();

    return true;
}

bool FileIO::createDir(const QString &filepath)
{
    if (filepath.isEmpty())
    {
        return false;
    }
    QDir dir(filepath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    if(!dir.exists())
    {
        return false;
    }
    return true;
}

bool FileIO::fileExists(const QString &filepath)
{
    if(!QFileInfo::exists(filepath))
    {
        return false;
    }
    return true;
}

QString FileIO::getFileDir(const QString &filepath)
{
    QFileInfo fi(filepath);
    if(fi.exists())
    {
        return fi.dir().absolutePath();
    }
    else
    {
        return "";
    }
}

QString FileIO::findLatestVersion(const QString &dirWithMods)
{
    QDir dir(dirWithMods);
    if(!dir.exists())
    {
        return "";
    }
    QDirIterator it(dir);
    std::vector<QVersionNumber> versions;
    while (it.hasNext())
    {
        QString p=QFileInfo(it.next()).fileName();
        auto ver = QVersionNumber::fromString(p);
        versions.push_back(ver);

    }
    auto ret = std::max_element(versions.begin(),versions.end());
    QString res = ret->toString();
    return dir.absoluteFilePath(ret->toString());
}

QString FileIO::copyFile(const QString &filePath, const QString &dirToCopy)
{
    QFileInfo file(filePath);
    if(file.exists())
    {
        QFile::copy(filePath,dirToCopy+"/"+file.fileName());
        return file.fileName();
    }
    else
    {

        return "";
    }
}
QString FileIO::copyAudioFile(const QString &filePath, const QString &dirToCopy, const bool copy)
{
    QFileInfo file(filePath);
    if(file.exists())
    {
        if(file.suffix()=="mp3")
        {
            std::unique_ptr<std::thread> t(new std::thread([=]{
                    emit namedFileCopyProgress(0.15f, filePath);
                    QString exe = "ffmpeg -i \"" + filePath + "\" " +"\"" + dirToCopy+"/"+file.fileName()+".wav\" -y -v quiet";
                    QProcess proc;
                    //printf("\nFFMPEG: %s \n",exe.toLatin1().data());
                    emit namedFileCopyProgress(0.25f, filePath);
                    proc.start(exe);
                    bool res = proc.waitForStarted();
//                    printf("RES: %d", res);
//                    fflush(stdout);
                    if(!res)
                    {
                        emit namedFileCopyProgress(-1., filePath);
                        return;
                    }
                    emit namedFileCopyProgress(0.55f, filePath);
                    proc.waitForFinished();
                    emit namedFileCopyProgress(0.85f, filePath);
                    if(QFileInfo::exists(dirToCopy+"/"+file.fileName()+".wav"))
                    {
                        emit namedFileCopyProgress(1., filePath);
                    }
                    else
                    {
                        emit namedFileCopyProgress(-1., filePath);
                    }
            }));
            t->detach();
            return file.fileName()+".wav";

        }
        else if(copy)
        {
            std::unique_ptr<std::thread> t(new std::thread([=]{
                    emit namedFileCopyProgress(0.5, filePath);
                    QFile::copy(filePath,dirToCopy+"/"+file.fileName());
                    emit namedFileCopyProgress(1., filePath);

            }));
            t->detach();            
        }
        else
        {
            return "";
        }
        return file.fileName();
    }
    else
    {

        return "";
    }
}

QString FileIO::massFilesCopy(const QString &jsonObj)
{
    std::unique_ptr<std::thread> t(new std::thread([=]{
        QJsonDocument doc;
        doc=QJsonDocument::fromJson(jsonObj.toUtf8());
        auto mainObj = doc.object();
        auto filesArr = mainObj["massFilesArr"].toArray();
        auto dirToCopy = mainObj["dirToCopy"].toString();
        for(int i = 0, iEnd = filesArr.size(); i < iEnd; ++i)
        {
            QFileInfo file(filesArr[i].toString());
            if(file.exists())
            {
                QFile::copy(file.absoluteFilePath(),dirToCopy+"/"+file.fileName());
                emit fileCopyProgress(i*100/iEnd);
            }
        }
        emit allFilesCopied(doc.toJson());
    }));
    t->detach();
    return "";
}
QString FileIO::getDirectoryContent(const QString &dirFilePath, bool allFiles)
{
    QDirIterator it(dirFilePath, QDirIterator::NoIteratorFlags);
    QJsonArray arr;
    while (it.hasNext()) {
        QString path=it.next();
        QFileInfo fi(path);

        if((allFiles && fi.isFile()) || (fi.suffix()=="mp3" || fi.suffix()=="wav"))
        {
            arr.append(fi.absoluteFilePath());
        }
    }
    QJsonDocument d;
    QJsonObject obj;
    obj["fileList"]=arr;
    d.setObject(obj);
    return d.toJson();
}

bool FileIO::removeFile(const QString &filePath)
{
    QFile f(filePath);
    if(f.exists())
    {
        return f.remove();
    }
    return false;
}

QString FileIO::getFileName(const QString &filePath)
{
    QFileInfo fi(filePath);
    return fi.fileName();
}

bool FileIO::createProjectFile(const QString &filename)
{
    QDir dir(mSource);
    if(!dir.exists())
    {
        return false;
    }
    QFile file(dir.absoluteFilePath(filename));
    if (file.exists())
    {
        return false;
    }
    file.open(QFile::WriteOnly | QFile::Truncate);
//    if (!file.open(QFile::WriteOnly | QFile::Truncate))
//        return false;
    mSource=dir.absoluteFilePath(filename);
    return true;
}
