QT += quick quickcontrols2 dbus mqtt

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/cutemqttclient.cpp \
        src/main.cpp \
        src/settings.cpp \
        src/servicediscovery.cpp

HEADERS += \
    src/cutemqttclient.h \
    src/settings.h \
    src/servicediscovery.h

unix {
INCLUDEPATH += /usr/local/include
LIBS += -L/usr/local/lib
LIBS += -lqatemcontrol
}

windows {
INCLUDEPATH += $$[QT_INSTALL_PREFIX]/include/qatemcontrol
LIBS += -L$$[QT_INSTALL_PREFIX]/lib/qatemcontrol
LIBS += -lqatemcontrol
}

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

