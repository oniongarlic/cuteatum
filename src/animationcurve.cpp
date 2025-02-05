#include "animationcurve.h"

AnimationCurve::AnimationCurve(QObject *parent)
    : QObject{parent}
{
    setType(QEasingCurve::InOutQuad);
}

qreal AnimationCurve::valueAt(qreal position)
{
    return valueForProgress(position);
}
