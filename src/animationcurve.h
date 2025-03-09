#ifndef ANIMATIONCURVE_H
#define ANIMATIONCURVE_H

#include <QObject>
#include <QQmlEngine>
#include <QEasingCurve>

class AnimationCurve : public QObject, QEasingCurve
{
    Q_OBJECT    
public:
    explicit AnimationCurve(QObject *parent = nullptr);

    Q_PROPERTY(qreal from READ from WRITE setFrom NOTIFY fromChanged FINAL)
    Q_PROPERTY(qreal to READ to WRITE setTo NOTIFY toChanged FINAL)

    Q_PROPERTY(QEasingCurve::Type type READ type WRITE setType NOTIFY typeChanged FINAL)

    Q_INVOKABLE qreal valueAt(qreal position);
    Q_INVOKABLE qreal valueAtNormalized(qreal position);

    Q_INVOKABLE void setType(QEasingCurve::Type type);
    Q_INVOKABLE void setAmplitude(qreal amplitude);

    qreal from() const;
    Q_INVOKABLE void setFrom(qreal newFrom);

    qreal to() const;
    Q_INVOKABLE void setTo(qreal newTo);

    QEasingCurve::Type type() const;

signals:

    void fromChanged();
    void toChanged();
    void typeChanged();

private:
    qreal m_from;
    qreal m_to;
};

#endif // ANIMATIONCURVE_H
