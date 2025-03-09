#include "animationcurve.h"

AnimationCurve::AnimationCurve(QObject *parent)
    : QObject{parent},
    m_from(0),
    m_to(1)
{
    QEasingCurve::setType(QEasingCurve::InOutQuad);
}

qreal AnimationCurve::valueAt(qreal position)
{
    qreal dif=m_to-m_from;

    return m_from+valueForProgress(position)*dif;
}

qreal AnimationCurve::valueAtNormalized(qreal position)
{
    return valueForProgress(position);
}

void AnimationCurve::setAmplitude(qreal amplitude)
{
    QEasingCurve::setAmplitude(amplitude);
}

qreal AnimationCurve::from() const
{
    return m_from;
}

void AnimationCurve::setFrom(qreal newFrom)
{
    if (qFuzzyCompare(m_from, newFrom))
        return;
    m_from = newFrom;
    emit fromChanged();
}

qreal AnimationCurve::to() const
{
    return m_to;
}

void AnimationCurve::setTo(qreal newTo)
{
    if (qFuzzyCompare(m_to, newTo))
        return;
    m_to = newTo;
    emit toChanged();
}

QEasingCurve::Type AnimationCurve::type() const
{
    return QEasingCurve::type();
}

void AnimationCurve::setType(const QEasingCurve::Type newType)
{
    if (type() == newType)
        return;
    QEasingCurve::setType(newType);
    emit typeChanged();
}
