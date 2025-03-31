#include "ssbox.h"

SuperSourceBox::SuperSourceBox(const int id, QObject *parent)
    : QObject{parent}, m_id(id)
{

}

void SuperSourceBox::setPosition(const QVector3D pos)
{
    m_position=pos;
    emit positionChanged();
}

void SuperSourceBox::setCrop(const QVector4D croping)
{
    m_croping=croping;
    emit cropingChanged();
}

void SuperSourceBox::setSource(const int src)
{
    m_source=src;
    emit sourceChanged();
}

void SuperSourceBox::setName(const QString name)
{
    m_name=name;
    emit nameChanged();
}

void SuperSourceBox::fromVariantMap(const QVariantMap &map)
{
    qDebug() << "ssbox" << m_id;
    qDebug() << "*** map" << map;

    m_source=map["source"].toInt();
    m_name=map["name"].toString();
    m_enabled=map["enabled"].toBool();
    m_position=map["position"].value<QVector3D>();

    m_crop=map["crop"].toBool();
    m_croping=map["croping"].value<QVector4D>();
}

void SuperSourceBox::toJson(QJsonObject &obj)
{
    obj.insert("enabled", m_enabled);
    obj.insert("source", m_source);
    obj.insert("crop", m_crop);

    QVariantMap m;

    m.insert("x", m_position.x());
    m.insert("y", m_position.y());
    m.insert("z", m_position.z());
    obj.insert("position", QJsonObject::fromVariantMap(m));

    obj.insert("border", m_border);
    obj.insert("borderColor", m_border_color.name());
}

int SuperSourceBox::source() const
{
    return m_source;
}

QVector3D SuperSourceBox::position() const
{
    return m_position;
}

QString SuperSourceBox::name() const
{
    return m_name;
}

QVector4D SuperSourceBox::croping() const
{
    return m_croping;
}

void SuperSourceBox::setCroping(const QVector4D &newCroping)
{
    if (m_croping == newCroping)
        return;
    m_croping = newCroping;
    emit cropingChanged();
}
