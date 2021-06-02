#include <QDebug>
#include <QDBusObjectPath>
#include "servicediscovery.h"

ServiceDiscovery::ServiceDiscovery(QObject *parent) : QObject(parent)
{
    m_interface=new QDBusInterface("org.freedesktop.Avahi", "/", "org.freedesktop.Avahi.Server", QDBusConnection::systemBus(), this);
}

void ServiceDiscovery::startDiscovery()
{
    m_devices.clear();

    auto reply=m_interface->call("ServiceBrowserNew", -1, -1, "_blackmagic._tcp", "", (uint)0);
    auto args=reply.arguments();
    QString path=args[0].toString();

    QDBusConnection::systemBus().connect("org.freedesktop.Avahi",path,"org.freedesktop.Avahi.ServiceBrowser", "ItemNew", this, SLOT(onItemNew(const QDBusMessage)));
    QDBusConnection::systemBus().connect("org.freedesktop.Avahi",path,"org.freedesktop.Avahi.ServiceBrowser", "ItemRemoved", this, SLOT(onItemRemoved(const QDBusMessage)));
    QDBusConnection::systemBus().connect("org.freedesktop.Avahi",path,"org.freedesktop.Avahi.ServiceBrowser", "AllForNow", this, SLOT(onAllForNow(const QDBusMessage)));
}

QVariantList ServiceDiscovery::getDevices() const
{
    return m_devices;
}

void ServiceDiscovery::onItemNew(const QDBusMessage &reply)
{
    qDebug() << "onItemNew" << reply.arguments();

    auto rsreply=m_interface->call(
                "ResolveService",
                reply.arguments()[0],
                reply.arguments()[1],
                reply.arguments()[2],
                reply.arguments()[3],
                reply.arguments()[4],
                -1,
                (uint)0);

    qDebug() << "ResolveService" << rsreply << rsreply.arguments();

    // XXX: Handle resolve timeout properly
    if (rsreply.arguments().count()<7)
        return;

    QVariantMap d;
    QString ip=rsreply.arguments()[7].toString();
    QString name=rsreply.arguments()[2].toString();
    quint16 port=rsreply.arguments()[8].toUInt();

    d.insert("name", name);
    d.insert("ip", ip);
    d.insert("port", port);
    m_devices.append(d);
}

void ServiceDiscovery::onItemRemoved(const QDBusMessage &reply)
{
    qDebug() << "onItemRemoved" << reply.arguments();
}

void ServiceDiscovery::onAllForNow(const QDBusMessage &reply)
{
    qDebug() << "onAllForNow" << reply.arguments() << m_devices;

    emit servicesFound();
}
