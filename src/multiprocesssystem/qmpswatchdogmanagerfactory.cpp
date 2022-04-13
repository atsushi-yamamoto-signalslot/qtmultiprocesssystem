#include "qmpswatchdogmanagerfactory.h"
#include "qmpswatchdogmanagerplugin.h"

#include <QtCore/private/qfactoryloader_p.h>

Q_GLOBAL_STATIC_WITH_ARGS(QFactoryLoader, loader,
    (QMpsWatchDogManagerFactoryInterface_iid,
     QLatin1String("/multiprocesssystem/watchdogmanager"), Qt::CaseInsensitive))

QStringList QMpsWatchDogManagerFactory::keys()
{
    QStringList list;

    const auto keyMap = loader()->keyMap();
    const auto cend = keyMap.constEnd();
    for (auto it = keyMap.constBegin(); it != cend; ++it)
        if (!list.contains(it.value()))
            list += it.value();
    return list;
}

QMpsWatchDogManager *QMpsWatchDogManagerFactory::create(const QString &key, Type type, QObject *parent)
{
    return qLoadPlugin<QMpsWatchDogManager, QMpsWatchDogManagerPlugin>(loader(), key.toLower(), type, parent);
}