TARGET = QtMultiProcessSystem

HEADERS += \
    multiprocesssystem_global.h \
    qmpsabstractipcinterface.h \
    qmpsabstractmanagerfactory.h \
    qmpsapplication.h \
    qmpsapplicationfactory.h \
    qmpsapplicationmanager.h \
    qmpsapplicationmanagerfactory.h \
    qmpsapplicationmanagerplugin.h \
    qmpsapplicationplugin.h \
    qmpsipcinterface.h \
    qmpswatchdog.h \
    qmpswatchdogmanager.h \
    qmpswatchdogmanagerfactory.h \
    qmpswatchdogmanagerplugin.h \
    qmpswindowmanager.h \
    qmpswindowmanagerfactory.h \
    qmpswindowmanagerplugin.h

SOURCES += \
    qmpsabstractipcinterface.cpp \
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

qtHaveModule(dbus) {
    QT += dbus
    HEADERS += qmpsabstractdbusinterface.h
    SOURCES += qmpsabstractdbusinterface.cpp
}

CONFIG += git_build
MODULE_PLUGIN_TYPES = multiprocesssystem/applicationmanager multiprocesssystem/windowmanager multiprocesssystem/watchdogmanager multiprocesssystem/application
load(qt_module)
