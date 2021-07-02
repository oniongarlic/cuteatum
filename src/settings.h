#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = nullptr);

    Q_INVOKABLE int getSettingsInt(const QString &key, const int defaultValue, const int minval, const int maxval);
    Q_INVOKABLE int getSettingsInt(const QString &key, const int defaultValue);

    Q_INVOKABLE bool getSettingsBool(const QString &key, const bool defaultValue);
    Q_INVOKABLE bool setSettings(const QString &key, const QVariant value);

    Q_INVOKABLE void setSettingsStr(const QString &key, const QString value);
    Q_INVOKABLE QString getSettingsStr(const QString &key, const QString defaultValue);
signals:

public slots:

private:
    QSettings *m_settings;
};

#endif // SETTINGS_H
