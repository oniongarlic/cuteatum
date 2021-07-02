#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
    m_settings=new QSettings(this);
}

int Settings::getSettingsInt(const QString &key, const int defaultValue)
{
    return m_settings->value(key, defaultValue).toInt();
}

int Settings::getSettingsInt(const QString &key, const int defaultValue, const int minval, const int maxval)
{
    int t=getSettingsInt(key,  defaultValue);
    if (t>maxval)
        return maxval;
    if (t<minval)
        return minval;
    return t;
}

bool Settings::getSettingsBool(const QString &key, const bool defaultValue)
{
    return m_settings->value(key, defaultValue).toBool();
}

bool Settings::setSettings(const QString &key, const QVariant value)
{
    m_settings->setValue(key, value);
    m_settings->sync();

    return true;
}

QString Settings::getSettingsStr(const QString &key, const QString defaultValue)
{
    return m_settings->value(key, defaultValue).toString();
}

void Settings::setSettingsStr(const QString &key, const QString value)
{
    m_settings->setValue(key, value);
    m_settings->sync();
}
