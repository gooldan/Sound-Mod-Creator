#include <QApplication>
#include <QQmlApplicationEngine>
#include <src/FileIO.h>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickWindow>
#include "src/ConfigReader.h"
#include "src/FileIO.h"
#include "src/Generator.h"
#include <QQuickView>
#include <QSplashScreen>
#include <thread>

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Base");
    QApplication app(argc, argv);
    QPixmap pixmap(":/screens/splash.png");
    if (pixmap.isNull())
    {
        pixmap = QPixmap(300, 300);
        pixmap.fill(Qt::magenta);
    }

    QSplashScreen *splash = new QSplashScreen(pixmap);
    splash->show();

    QQmlApplicationEngine engine;

    qmlRegisterType<Generator, 1>("Generator", 1, 0, "Generator");
    qmlRegisterType<FileIO, 1>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<ConfigReader, 1>("ConfigReader", 1, 0, "ConfigReader");

    engine.load(QUrl("qrc:/qml/main.qml"));
    splash->close();
    delete splash;
    return app.exec();
}
