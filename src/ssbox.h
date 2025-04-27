#ifndef SSBOX_H
#define SSBOX_H

#include <QObject>
#include <QColor>
#include <QVariant>
#include <QVariantMap>
#include <QVector3D>
#include <QVector4D>
#include <QJsonObject>

#include <QAtemControl/qatemsupersourcebox.h>

class SuperSourceBox : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged FINAL)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged FINAL)
    Q_PROPERTY(int source READ source WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(QVector3D position READ position WRITE setPosition NOTIFY positionChanged FINAL)

    Q_PROPERTY(bool crop READ crop WRITE setCrop NOTIFY cropChanged FINAL)
    Q_PROPERTY(QVector4D cropping READ cropping WRITE setCropping NOTIFY croppingChanged FINAL)

    Q_PROPERTY(bool border READ border WRITE setBorder NOTIFY borderChanged FINAL)
    Q_PROPERTY(QColor borderColor READ borderColor WRITE setBorderColor NOTIFY borderColorChanged FINAL)

    Q_PROPERTY(int borderWidthInner READ borderWidthInner WRITE setBorderWidthInner NOTIFY borderWidthInnerChanged FINAL)
    Q_PROPERTY(int borderWidthOuter READ borderWidthOuter WRITE setBorderWidthOuter NOTIFY borderWidthOuterChanged FINAL)

public:
    explicit SuperSourceBox(const int id, QObject *parent = nullptr);

    Q_INVOKABLE void setPosition(const QVector3D pos);
    Q_INVOKABLE void setCrop(bool crop);
    Q_INVOKABLE void setSource(const int src);
    Q_INVOKABLE void setName(const QString name);

    Q_INVOKABLE void fromAtemSuperSourceBox(const QAtemSuperSourceBox &sbox);

    void fromVariantMap(const QVariantMap &map);
    Q_INVOKABLE void toJson(QJsonObject &obj);

    friend QDebug operator<<(QDebug debug, const SuperSourceBox &c)
    {
        QDebugStateSaver saver(debug);
        debug.space() << c.m_id << c.m_source << c.m_enabled << c.m_position << c.m_crop << c.m_cropping;

        return debug;
    }

    int source() const;
    QVector3D position() const;
    QString name() const;

    QVector4D cropping() const;
    Q_INVOKABLE void setCropping(const QVector4D &newCropping);

    bool crop() const;

    QColor borderColor() const;
    Q_INVOKABLE void setBorderColor(const QColor &newBorderColor);

    int borderWidthInner() const;
    Q_INVOKABLE void setBorderWidthInner(int newBorderWidthInner);

    int borderWidthOuter() const;
    Q_INVOKABLE void setBorderWidthOuter(int newBorderWidthOuter);

    bool border() const;
    Q_INVOKABLE void setBorder(bool newBorder);

    bool enabled() const;
    void setEnabled(bool newEnabled);

private:
    int m_id;
    int m_source;
    bool m_enabled;
    QString m_name;
    QVector3D m_position;

    bool m_crop;
    QVector4D m_cropping;

    bool m_border;
    QColor m_borderColor;
    int m_borderWidthInner;
    int m_borderWidthOuter;

signals:
    void sourceChanged();
    void positionChanged();
    void nameChanged();
    void croppingChanged();
    void cropChanged();
    void borderColorChanged();
    void borderWidthInnerChanged();
    void borderWidthOuterChanged();
    void borderChanged();
    void enabledChanged();
};

#endif // SSBOX_H
