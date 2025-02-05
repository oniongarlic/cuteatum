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

    Q_INVOKABLE qreal valueAt(qreal position);

signals:
};

#endif // ANIMATIONCURVE_H
