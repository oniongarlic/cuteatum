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
public:
    explicit SuperSourceBox(const int id, QObject *parent = nullptr);

    Q_INVOKABLE void setPosition(const QVector3D pos) { m_position=pos; }
    Q_INVOKABLE void setCrop(const QVector3D croping) { m_croping=croping; }
    Q_INVOKABLE void setSource(const int src) { m_source=src; }
    Q_INVOKABLE void setName(const QString name) { m_name=name; }

    void fromVariantMap(const QVariantMap &map);
    Q_INVOKABLE void toJson(QJsonObject &obj);

private:
    const int m_id;
    int m_source;
    bool m_enabled;
    QString m_name;
    QVector3D m_position;

    bool m_crop;
    QVector3D m_croping;

    bool m_border;
    QColor m_border_color;
    int m_border_inner_width;
    int m_border_outer_width;

signals:
};

#endif // SSBOX_H
