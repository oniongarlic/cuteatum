#ifndef DUMMYITEM_H
#define DUMMYITEM_H

#include <QObject>
#include <QVariant>
#include <QMap>
#include <QVector3D>
#include <QVector4D>

#include "ssbox.h"

class SuperSourceBoxes : public QObject
{
    Q_OBJECT
    // Q_CLASSINFO("Dummy", "Test")
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)    
    Q_PROPERTY(QString key MEMBER m_key)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    explicit SuperSourceBoxes(QObject *parent = nullptr);
    ~SuperSourceBoxes();

    Q_INVOKABLE SuperSourceBox *getBox(int idx) { return m_boxes.at(idx); };

    static SuperSourceBoxes *fromVariantMap(const QVariantMap &map);

private:
    int m_id;

    QString m_key;
    QString m_name;        

    int id() const;
    QString name() const;
    QList<SuperSourceBox *> m_boxes;
    
signals:
    void idChanged(int id);
    void nameChanged(QString name);    
    
public slots:
    void setId(int id);
    void setName(QString name);
};

#endif // DUMMYITEM_H

