#include "ssbox.h"

SuperSourceBox::SuperSourceBox(const int id, QObject *parent)
    : QObject{parent}, m_id(id)
{

}

void SuperSourceBox::fromVariantMap(const QVariantMap &map)
{
    m_source=map["source"].toInt();
    m_enabled=map["enabled"].toBool();

    m_position.setX(map["x"].toFloat());
    m_position.setY(map["y"].toFloat());
    m_position.setY(map["z"].toFloat());

    m_crop=map["crop"].toBool();
}

void SuperSourceBox::toJson(QJsonObject &obj)
{
    obj.insert("enabled", m_enabled);
    obj.insert("source", m_source);
    obj.insert("crop", m_crop);

    // obj.insert("position", m_position);

    obj.insert("border", m_border);
    obj.insert("borderColor", m_border_color.name());
}
