#include "ssboxesmodel.h"

#include <QJsonObject>
#include <QJsonArray>

SuperSourceBoxesModel::SuperSourceBoxesModel(QObject *parent) :
    AbstractObjectModel("SuperSourceBoxes", parent)
{
    m_has_key=false;
    m_key_name="key";
    m_iswritable=true;
}

SuperSourceBoxes *SuperSourceBoxesModel::getItem(int index) const
{
    return dynamic_cast<SuperSourceBoxes *>(getObject(index));
}

void SuperSourceBoxesModel::appendFromMap(const QVariantMap map)
{
    qDebug() << "appendFromMap" << map;
    auto m=dynamic_cast<SuperSourceBoxes *>(fromVariantMap(map));
    append(m);
}

QVariant SuperSourceBoxesModel::formatProperty(const QObject *data, const QMetaProperty *meta) const
{
    if (strcmp(meta->name(), "time")==0) {
        QTime t;

        t=meta->read(data).toTime();
        return QVariant(t.toString("HH:mm:ss"));
    } else if (strcmp(meta->name(), "timestamp")==0) {
        QDateTime t;

        t=meta->read(data).toDateTime();
        return QVariant(t.toString("dd.MM.yyyy @ HH:mm"));    
    }
    return AbstractObjectModel::formatProperty(data, meta);
}

QObject *SuperSourceBoxesModel::fromVariantMap(const QVariantMap &map)
{
    return SuperSourceBoxes::fromVariantMap(map);
}

bool SuperSourceBoxesModel::formatToJson(const QString &key, const QVariant &value, QJsonValue &jvalue) const
{
    if (key=="boxes") {
        qDebug() << "formatToJson" << key << value;
        QJsonArray a;
        auto ssblist=value.value<QList<SuperSourceBox*>>();
        for (int i=0;i<4;i++) {
            QJsonObject o;
            auto ssb=ssblist.at(i);
            ssb->toJson(o);
            a.append(o);
        }
        jvalue=a;
        return true;
    }
    return false;
}

