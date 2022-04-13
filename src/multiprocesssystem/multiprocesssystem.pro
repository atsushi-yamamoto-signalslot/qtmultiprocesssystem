TARGET = QtMultiProcessSystem

HEADERS += \
    multiprocesssystem_global.h \
    qmpsabstractmanagerfactory.h \
    qmpsapplication.h \
    qmpsapplicationfactory.h \
    qmpsapplicationmanager.h \
    qmpsapplicationmanagerfactory.h \
    qmpsapplicationmanagerplugin.h \
    qmpsapplicationplugin.h \
    qmpswatchdog.h \
    qmpswatchdogmanager.h \
    qmpswatchdogmanagerfactory.h \
    qmpswatchdogmanagerplugin.h \
    qmpswindowmanager.h \
    qmpswindowmanagerfactory.h \
    qmpswindowmanagerplugin.h

SOURCES += \
    qmpsapplication.cpp \
    qmpsapplicationfactory.cpp \
    qmpsapplicationmanager.cpp \
    qmpsapplicationmanagerfactory.cpp \
    qmpsapplicationmanagerplugin.cpp \
    qmpsapplicationplugin.cpp \
    qmpswatchdog.cpp \
    qmpswatchdogmanager.cpp \
    qmpswatchdogmanagerfactory.cpp \
    qmpswatchdogmanagerplugin.cpp \
    qmpswindowmanager.cpp \
    qmpswindowmanagerfactory.cpp \
    qmpswindowmanagerplugin.cpp

QT = core-private quick
CONFIG += git_build
MODULE_PLUGIN_TYPES = multiprocesssystem/applicationmanager multiprocesssystem/windowmanager multiprocesssystem/watchdogmanager multiprocesssystem/application
load(qt_module)
