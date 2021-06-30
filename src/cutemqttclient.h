#ifndef CUTEMQTTCLIENT_H
#define CUTEMQTTCLIENT_H

#include <QObject>
#include <QtMqtt/QMqttClient>

class CuteMqttClient : public QMqttClient
{
    Q_OBJECT
public:
    CuteMqttClient(QObject *parent = nullptr);

    Q_INVOKABLE int publish(const QString &topic, const QString &message, int qos=1, bool retain=false);
};

#endif // CUTEMQTTCLIENT_H
