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

void SuperSourceBox::setCrop(bool crop)
{
    m_crop=crop;
    emit cropChanged();
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
    m_cropping=map["cropping"].value<QVector4D>();

    m_border=map["border"].toBool();
    m_borderColor=map["borderColor"].toString();
    m_borderWidthInner=map["borderWidthInner"].toInt();
    m_borderWidthOuter=map["borderWidthOuter"].toInt();
}

void SuperSourceBox::toJson(QJsonObject &obj)
{
    obj.insert("enabled", m_enabled);
    obj.insert("source", m_source);
    obj.insert("crop", m_crop);

    QVariantMap p;
    p.insert("x", m_position.x());
    p.insert("y", m_position.y());
    p.insert("z", m_position.z());
    obj.insert("position", QJsonObject::fromVariantMap(p));

    QVariantMap c;
    c.insert("x", m_cropping.x());
    c.insert("y", m_cropping.y());
    c.insert("z", m_cropping.z());
    c.insert("w", m_cropping.w());
    obj.insert("cropping", QJsonObject::fromVariantMap(c));

    obj.insert("border", m_border);
    obj.insert("borderColor", m_borderColor.name());
    obj.insert("borderWidthInner", m_borderWidthInner);
    obj.insert("borderWidthOuter", m_borderWidthOuter);
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

QVector4D SuperSourceBox::cropping() const
{
    return m_cropping;
}

void SuperSourceBox::setCropping(const QVector4D &newCropping)
{
    if (m_cropping == newCropping)
        return;
    m_cropping = newCropping;
    emit croppingChanged();
}

bool SuperSourceBox::crop() const
{
    return m_crop;
}

QColor SuperSourceBox::borderColor() const
{
    return m_borderColor;
}

void SuperSourceBox::setBorderColor(const QColor &newBorderColor)
{
    if (m_borderColor == newBorderColor)
        return;
    m_borderColor = newBorderColor;
    emit borderColorChanged();
}

int SuperSourceBox::borderWidthInner() const
{
    return m_borderWidthInner;
}

void SuperSourceBox::setBorderWidthInner(int newBorderWidthInner)
{
    if (m_borderWidthInner == newBorderWidthInner)
        return;
    m_borderWidthInner = newBorderWidthInner;
    emit borderWidthInnerChanged();
}

int SuperSourceBox::borderWidthOuter() const
{
    return m_borderWidthOuter;
}

void SuperSourceBox::setBorderWidthOuter(int newBorderWidthOuter)
{
    if (m_borderWidthOuter == newBorderWidthOuter)
        return;
    m_borderWidthOuter = newBorderWidthOuter;
    emit borderWidthOuterChanged();
}

bool SuperSourceBox::border() const
{
    return m_border;
}

void SuperSourceBox::setBorder(bool newBorder)
{
    if (m_border == newBorder)
        return;
    m_border = newBorder;
    emit borderChanged();
}

bool SuperSourceBox::enabled() const
{
    return m_enabled;
}

void SuperSourceBox::setEnabled(bool newEnabled)
{
    if (m_enabled == newEnabled)
        return;
    m_enabled = newEnabled;
    emit enabledChanged();
}
