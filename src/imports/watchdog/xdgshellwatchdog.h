#ifndef XDGSHELLWATCHDOG_H
#define XDGSHELLWATCHDOG_H

#include <QtCore/QObject>
#include <QtQml/qqml.h>
#include <QtMultiProcessSystem/QMpsWatchDogManager>
#include <QtMultiProcessSystem/QMpsApplication>

class XdgShellWatchDog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QMpsWatchDogManager *manager READ watchDogManager WRITE setWatchDogManager NOTIFY watchDogManagerChanged)
    Q_DISABLE_COPY(XdgShellWatchDog)
public:
    explicit XdgShellWatchDog(QObject *parent = nullptr);
    ~XdgShellWatchDog() override;

    QMpsWatchDogManager *watchDogManager() const;

public slots:
    void setWatchDogManager(QMpsWatchDogManager *watchDogManager);
    void ping(const QMpsApplication &application, uint serial);
    void pong(uint serial);

signals:
    void watchDogManagerChanged(QMpsWatchDogManager *watchDogManager);

private:
    class Private;
    QScopedPointer<Private> d;
};

#endif // XDGSHELLWATCHDOG_H
