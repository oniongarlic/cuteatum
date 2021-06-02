#ifndef SERVICEDISCOVERY_H
#define SERVICEDISCOVERY_H

#include <QObject>
#include <QtDBus>

class ServiceDiscovery : public QObject
{
    Q_OBJECT
public:
    explicit ServiceDiscovery(QObject *parent = nullptr);

    Q_INVOKABLE void startDiscovery();

signals:
    void servicesFound();

public slots:
    void onItemNew(const QDBusMessage& reply);
    void onItemRemoved(const QDBusMessage& reply);
    void onAllForNow(const QDBusMessage& reply);

protected:
    QDBusInterface *m_interface;
};

#endif // SERVICEDISCOVERY_H
