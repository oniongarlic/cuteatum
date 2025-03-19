#ifndef DUMMYITEM_H
#define DUMMYITEM_H

#include <QObject>
#include <QMap>
#include <QDateTime>
#include <QVector2D>
#include <QVector3D>
#include <QVector4D>

class SuperSourceBoxes : public QObject
{
    Q_OBJECT
    // Q_CLASSINFO("Dummy", "Test")
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)    
    Q_PROPERTY(QString key MEMBER m_key)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool enabled MEMBER m_enabled NOTIFY enabledChanged)    
    Q_PROPERTY(QVector2D vec2 MEMBER m_vec2 NOTIFY vec2Changed)
    Q_PROPERTY(QVector3D vec3 MEMBER m_vec3 NOTIFY vec3Changed)
    Q_PROPERTY(QVector4D vec4 MEMBER m_vec4 NOTIFY vec4Changed)

public:
    explicit SuperSourceBoxes(QObject *parent = nullptr);
    ~SuperSourceBoxes();

    static SuperSourceBoxes *fromVariantMap(const QVariantMap &map);

private:
    int m_id;

    QString m_key;
    QString m_name;
    bool m_enabled;    

    int id() const;
    QString name() const;
    QVector3D m_ssbox[4];
    
signals:

    void idChanged(int id);
    void nameChanged(QString name);
    void categoryChanged(QString category);
    void enabledChanged();    
    
    void vec2Changed();
    void vec3Changed();
    void vec4Changed();
    
public slots:
    void setId(int id);
    void setName(QString name);
};

#endif // DUMMYITEM_H

