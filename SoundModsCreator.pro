TEMPLATE = app

QT += qml quick widgets
CONFIG += c++14
#CONFIG += static

SOURCES += \
    src/FileIO.cpp \
    src/ConfigReader.cpp \
    src/Generator.cpp \
    main.cpp
INCLUDEPATH += $$PWD/src

RC_ICONS = smc_icon.ico
RESOURCES += qml.qrc
# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
#CONFIG+=qml_debug
# Default rules for deployment.
include(deployment.pri)
#LIBS +=-LC:/Qt/Static/5.7.0/lib -lqtmain\
#-LC:/Qt/Static/5.7.0/qml/QtQuick.2 -lqtquick2plugin\
#-LC:/Qt/Static/5.7.0/qml/QtQuick/Window.2 -lwindowplugin\
#-LC:/Qt/Static/5.7.0/qml/QtQuick/Controls -lqtquickcontrolsplugin\
#-LC:/Qt/Static/5.7.0/qml/Qt/labs/controls -lqtlabscontrolsplugin\
#-LC:/Qt/Static/5.7.0/qml/QtQuick/Layouts -lqquicklayoutsplugin\
#-LC:/Qt/Static/5.7.0/qml/Qt/labs/templates -lqtlabstemplatesplugin\
#-LC:/Qt/Static/5.7.0/qml/QtQuick/Dialogs -ldialogplugin\
#-LC:/Qt/Static/5.7.0/qml/Qt/labs/folderlistmodel -lqmlfolderlistmodelplugin\
#-LC:/Qt/Static/5.7.0/qml/Qt/labs/settings -lqmlsettingsplugin\
#-LC:/Qt/Static/5.7.0/qml/QtQuick/Dialogs/Private -ldialogsprivateplugin\
#-LC:/Qt/Static/5.7.0/qml/QtQml/Models.2 -lmodelsplugin

HEADERS += \
    src/FileIO.h \
    src/ConfigReader.h \
    src/ErrorCode.h \
    src/Generator.h

DISTFILES +=
