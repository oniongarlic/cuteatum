#ifndef SSBOBXES_H
#define SSBOBXES_H

#include <QObject>
#include <QVariant>
#include <QMap>
#include <QVector3D>
#include <QVector4D>

#include "ssbox.h"

class SuperSourceBoxes : public QObject
{
    Q_OBJECT
    // Q_CLASSINFO("ModelItem", "SuperSourceBox")
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)    
    Q_PROPERTY(QString key MEMBER m_key)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QList<SuperSourceBox *> boxes READ boxes NOTIFY boxesChanged FINAL)

public:
    explicit SuperSourceBoxes(QObject *parent = nullptr);
    ~SuperSourceBoxes();

    Q_INVOKABLE SuperSourceBox *getBox(int idx) const { return m_boxes.at(idx); };

    static SuperSourceBoxes *fromVariantMap(const QVariantMap &map);

    QList<SuperSourceBox *> boxes() const;

    friend QDebug operator<<(QDebug debug, const SuperSourceBoxes &c)
    {
        QDebugStateSaver saver(debug);

        for (int i=0;i<4;i++) {
            auto ssb=c.getBox(i);

            debug.space() << i << c.m_name << c.m_id << ssb;
        }
        return debug;
    }

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
    
    void boxesChanged();

public slots:
    void setId(int id);
    void setName(QString name);
};

#endif // SSBOBXES_H

