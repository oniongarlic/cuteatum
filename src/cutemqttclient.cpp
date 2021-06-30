#include "cutemqttclient.h"

CuteMqttClient::CuteMqttClient(QObject *parent) : QMqttClient(parent)
{

}

int CuteMqttClient::publish(const QString &topic, const QString &message, int qos, bool retain)
{
    return QMqttClient::publish(QMqttTopicName(topic), message.toUtf8(), qos, retain);
}
