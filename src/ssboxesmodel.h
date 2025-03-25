#ifndef DUMMYITEMMODEL_H
#define DUMMYITEMMODEL_H

#include <QObject>
#include <QMetaProperty>
#include <QJsonValue>

#include "libcutegenericmodel/abstractobjectmodel.h"
#include "ssboxes.h"

class SuperSourceBoxesModel : public Cute::AbstractObjectModel
{
    Q_OBJECT
public:
    explicit SuperSourceBoxesModel(QObject *parent = nullptr);

    Q_INVOKABLE SuperSourceBoxes *getItem(int index) const;
    Q_INVOKABLE void appendFromMap(const QVariantMap map);

    // AbstractObjectModel interface
protected:
    QVariant formatProperty(const QObject *data, const QMetaProperty *meta) const;
    QObject *fromVariantMap(const QVariantMap &map);
    bool formatToJson(const QString &key, const QVariant &value, QJsonValue &jvalue) const;    
};

#endif // DUMMYITEMMODEL_H
