#include <QtQuick>
#include <QtQml>

#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QQmlPropertyMap>

#include <QQuickStyle>

#include <QSettings>

#include <QAtemControl/qatemconnection.h>
#include <QAtemControl/qatemcameracontrol.h>
#include <QAtemControl/qatemdownstreamkey.h>
#include <QAtemControl/qatemmixeffect.h>
#include <QAtemControl/qatemfairlight.h>
#include <QAtemControl/qatemsupersource.h>
#include <QAtemControl/qatemstreaming.h>
#include <QAtemControl/qatemrecording.h>

#include "servicediscovery.h"
#include "cutemqttclient.h"
#include "settings.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationDomain("org.tal.cuteatum");
    QCoreApplication::setOrganizationName("tal.org");
    QCoreApplication::setApplicationName("CuteAtum");
    QCoreApplication::setApplicationVersion("0.1");

    QLoggingCategory::setFilterRules(QStringLiteral("qt.qml.binding.removal.info=true"));

    if (!QDBusConnection::sessionBus().isConnected()) {
        qWarning("Cannot connect to the D-Bus session bus.\n"
                 "Please check your system settings and try again.\n"
                 "Unable to auto discover ATEM devices on the network.\n");
    }

    Settings settings;

    //QQuickStyle::setStyle("Universal");
    //QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    qmlRegisterType<QAtemConnection>("org.bm", 1, 0, "AtemConnection");
    qmlRegisterType<QAtemMixEffect>("org.bm", 1, 0, "AtemMixEffect");
    qmlRegisterUncreatableType<QAtemDownstreamKey>("org.bm", 1, 0, "AtemDownstreamKey", "AtemDownstreamKey can not be created");
    qmlRegisterUncreatableType<QAtemCameraControl>("org.bm", 1, 0, "AtemCameraControl", "AtemCameraControl can not be created");
    qmlRegisterType<QAtemFairlight>("org.bm", 1, 0, "AtemFairlight");
    qmlRegisterType<QAtemSuperSource>("org.bm", 1, 0, "AtemSuperSource");
    qmlRegisterUncreatableType<QAtemSuperSourceBox>("org.bm", 1, 0, "AtemSuperSourceBox", "Used in C++ only");

    qmlRegisterType<QAtemStreaming>("org.bm", 1, 0, "AtemStreaming");
    qmlRegisterType<QAtemRecording>("org.bm", 1, 0, "AtemRecording");

    qmlRegisterType<ServiceDiscovery>("org.tal.servicediscovery", 1, 0, "ServiceDiscovery");

    qRegisterMetaType<QAtemMixEffect*>("AtemMixEffect");
    qRegisterMetaType<QAtemDownstreamKey*>("AtemDownstreamKey");
    qRegisterMetaType<QAtemSuperSourceBox*>("QAtemSuperSourceBox");
    qRegisterMetaType<QAtem::SuperSourceBoxSettings>();    

    qmlRegisterUncreatableType<QList<QAtemSuperSourceBox>*>("org.bm", 1, 0, "AtemSuperSourceBoxes", "Used in C++ only");

    qRegisterMetaType<QAtem::InputInfo>();
    qRegisterMetaType<QAtem::Topology>();
    qRegisterMetaType<QAtem::MediaInfo>();
    qRegisterMetaType<QAtem::MacroInfo>();

    qRegisterMetaType<quint8>();
    qRegisterMetaType<quint16>();
    qRegisterMetaType<QMap<quint16,QAtem::InputInfo>>();

    qmlRegisterType<CuteMqttClient>("org.tal.mqtt", 1, 0, "MqttClient");

    engine.rootContext()->setContextProperty("settings", &settings);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
