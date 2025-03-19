#include "ssboxes.h"

#include <QDebug>

SuperSourceBoxes::SuperSourceBoxes(QObject *parent) :
    QObject(parent),
    m_category("NSFW")
{
    m_time=QTime::currentTime();
}

SuperSourceBoxes::~SuperSourceBoxes()
{
    qDebug() << "Deleted" << m_key;
}

SuperSourceBoxes *SuperSourceBoxes::fromVariantMap(const QVariantMap &map)
{
    SuperSourceBoxes *dm=new SuperSourceBoxes();
    
    dm->m_id=map["id"].toInt();
    dm->m_key=map["key"].toString();    
    dm->m_name=map["name"].toString();
    
    QVector3D v3;
    if (map.contains("")) {
        QVariantMap m=map["vec3"].toMap();
        v3.setX(m["x"].toFloat());
        v3.setY(m["y"].toFloat());
        v3.setY(m["z"].toFloat());
        dm->m_vec3=v3;
    }
    
    return dm;
}

int SuperSourceBoxes::id() const
{
    return m_id;
}

QString SuperSourceBoxes::name() const
{
    return m_name;
}

void SuperSourceBoxes::setId(int id)
{
    if (m_id == id)
        return;
    
    m_id = id;
    emit idChanged(m_id);
}

void SuperSourceBoxes::setName(QString name)
{
    if (m_name == name)
        return;
    
    m_name = name;
    emit nameChanged(m_name);
}

