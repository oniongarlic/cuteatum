#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <qatemconnection.h>
#include <qatemcameracontrol.h>
#include <qatemdownstreamkey.h>
#include <qatemmixeffect.h>

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

    QQmlApplicationEngine engine;

    qmlRegisterType<QAtemConnection>("org.bm", 1, 0, "AtemConnection");
    //qmlRegisterType<QAtemDownstreamKey>("org.bm", 1, 0, "AtemDownstreamKey");
    qmlRegisterType<QAtemMixEffect>("org.bm", 1, 0, "AtemMixEffect");
    //qmlRegisterType<QAtemCameraControl>("org.bm", 1, 0, "AtemCameraControl");

    qRegisterMetaType<QAtemMixEffect*>("AtemMixEffect");

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
