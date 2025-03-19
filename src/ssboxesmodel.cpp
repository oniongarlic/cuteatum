#include "ssboxesmodel.h"

#include <QJsonObject>

SuperSourceBoxesModel::SuperSourceBoxesModel(QObject *parent) :
    AbstractObjectModel("DummyItem", parent)
{
    m_has_key=true;
    m_key_name="key";
    m_iswritable=true;
}

SuperSourceBoxes *SuperSourceBoxesModel::getItem(int index) const
{
    return dynamic_cast<SuperSourceBoxes *>(getObject(index));
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
    return false;
}

