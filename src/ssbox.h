#ifndef SSBOX_H
#define SSBOX_H

#include <QObject>
#include <QColor>
#include <QVariant>
#include <QVariantMap>
#include <QVector3D>
#include <QVector4D>
#include <QJsonObject>

class SuperSourceBox : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(int source READ source WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(QVector3D position READ position WRITE setPosition NOTIFY positionChanged FINAL)

    Q_PROPERTY(QVector4D croping READ croping WRITE setCroping NOTIFY cropingChanged FINAL)

public:
    explicit SuperSourceBox(const int id, QObject *parent = nullptr);

    Q_INVOKABLE void setPosition(const QVector3D pos);
    Q_INVOKABLE void setCrop(const QVector4D croping);
    Q_INVOKABLE void setSource(const int src);
    Q_INVOKABLE void setName(const QString name);

    void fromVariantMap(const QVariantMap &map);
    Q_INVOKABLE void toJson(QJsonObject &obj);

    friend QDebug operator<<(QDebug debug, const SuperSourceBox &c)
    {
        QDebugStateSaver saver(debug);
        debug.nospace() << c.m_id << c.m_source << c.m_enabled << c.m_position << c.m_crop << c.m_croping;

        return debug;
    }

    int source() const;
    QVector3D position() const;
    QString name() const;

    QVector4D croping() const;
    void setCroping(const QVector4D &newCroping);

private:
    const int m_id;
    int m_source;
    bool m_enabled;
    QString m_name;
    QVector3D m_position;

    bool m_crop;
    QVector4D m_croping;

    bool m_border;
    QColor m_border_color;
    int m_border_inner_width;
    int m_border_outer_width;

signals:
    void sourceChanged();
    void positionChanged();
    void nameChanged();
    void cropingChanged();
};

#endif // SSBOX_H
