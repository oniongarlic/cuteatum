#include "ssboxes.h"

#include <QDebug>

/**
 * Container of 4 Super Source Box definitions
 *
 * @brief SuperSourceBoxes::SuperSourceBoxes
 * @param parent
 */

SuperSourceBoxes::SuperSourceBoxes(QObject *parent) :
    QObject(parent)
{
    m_boxes.resize(4);
    for (int i=0;i<4;i++) {
        m_boxes[i]=new SuperSourceBox(i+1, this);
    }
}

SuperSourceBoxes::~SuperSourceBoxes()
{    
    m_boxes.clear();
}

void setVector(QVector3D &v, const QString &key, const QVariantMap &map)
{
    if (!map.contains(key)) {
        v.setX(0.0);
        v.setY(0.0);
        v.setZ(0.0);
    }
    QVariantMap m=map[key].toMap();
    v.setX(m["x"].toFloat());
    v.setY(m["y"].toFloat());
    v.setY(m["z"].toFloat());
}

SuperSourceBoxes *SuperSourceBoxes::fromVariantMap(const QVariantMap &map)
{
    SuperSourceBoxes *dm=new SuperSourceBoxes();

    qDebug() << "SuperSourceBoxes::fromVariantMap" << map.keys();

    dm->m_name=map["name"].toString();

    if (map.contains("boxes")) {
        QVariantList b=map["boxes"].toList();

        qDebug() << "boxes" << b;

        for (int i=0;i<4;i++) {
            auto ssb=dm->getBox(i);
            ssb->fromVariantMap(b.at(i).toMap());
        }
    } else {
        qWarning() << "No boxes defined in super source box data ?";
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


QList<SuperSourceBox *> SuperSourceBoxes::boxes() const
{
    return m_boxes;
}
