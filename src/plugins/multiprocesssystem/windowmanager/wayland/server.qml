﻿import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWayland.Compositor 1.15
import QtMultiProcessSystem.Internal 1.0
import QtMultiProcessSystem.WatchDog 1.15

WaylandCompositor {
    id: root
    WaylandOutput {
        sizeFollowsWindow: true
        window: Main {
            id: main
        }
    }
    Component {
        id: chromeComponent
        ShellSurfaceItem {
            id: item
            anchors.fill: parent
            visible: enabled
            property var application
            onSurfaceDestroyed: {
                if (applicationManager.current.id === item.application.id) {
                    applicationManager.exec(applicationManager.findByKey('home'))
                }
                delete root.apps[item.application.id]
                destroy()
            }
            onWidthChanged: handleResized(width, height)
            onHeightChanged: handleResized(width, height)
            signal handleResized(real width, real height)

            property alias busy: busy.visible
            MouseArea {
                id: busy
                anchors.fill: parent
                visible: false
                Rectangle {
                    anchors.fill: parent
                    opacity: 0.25
                    color: 'white'
                }
                BusyIndicator {
                    anchors.centerIn: parent
                    running: parent.visible
                }
            }
        }
    }

    function add(key, surface) {
        if (key === Qt.application.name) // QPA changes title once with its name
            return
        var app = applicationManager.findByKey(key)
        var parent = main.findParent(app)
        var item = chromeComponent.createObject(parent, { "shellSurface": surface, "application": app } )
        root.apps[app.id] = item
        if (!app.systemUI) {
            item.enabled = (applicationManager.current.key === key)
        }

        return item
    }

    WlShell {
        onWlShellSurfaceCreated: {
            shellSurface.titleChanged.connect(function() {
                var item = root.add(shellSurface.title, shellSurface)
                if (!item)
                    return
                shellSurface.sendConfigure(Qt.size(item.width, item.height), WlShellSurface.NoneEdge)
                item.handleResized.connect(function(width, height) {
                    if (width < 0 || height < 0)
                        return
                    shellSurface.sendConfigure(Qt.size(width, height), WlShellSurface.NoneEdge)
                })
            })
        }
    }

    XdgShell {
        id: shell
        onPong: xdgWatchDog.pong(serial)
        onToplevelCreated: {
            toplevel.titleChanged.connect(function() {
                var item = root.add(toplevel.title, xdgSurface)
                if (!item)
                    return
                toplevel.sendConfigure(Qt.size(item.width, item.height), [])
                item.handleResized.connect(function(width, height) {
                    if (width < 0 || height < 0)
                        return
                    toplevel.sendConfigure(Qt.size(width, height), [])
                })
            })
        }
    }

    XdgShellWatchDog {
        id: xdgWatchDog
        manager: typeof watchDogManager === 'undefined' ? null : watchDogManager
    }
    SystemdWatchDog {
        id: systemdWatchDog
    }
    Timer {
        interval: 100 // TODO: settable
        repeat: true
        running: typeof watchDogManager !== 'undefined'
        onTriggered: {
            systemdWatchDog.pang()
            for (var id in apps) {
                var item = root.apps[id]
                var client = item.shellSurface.surface.client
                var serial = shell.ping(client)
                xdgWatchDog.ping(applicationManager.findByID(id), serial)
            }
        }
    }

    Connections {
        enabled: typeof watchDogManager !== 'undefined'
        target: enabled ? watchDogManager : null
        function onInactiveChanged(method, application, inactive, msecs) {
            var item = root.apps[application.id]
            item.busy = inactive
        }
    }

    property var apps: ({})
    Connections {
        id: activator
        target: applicationManager
        function onActivated(application, args) {
            var current = applicationManager.current
            console.debug(current)
            console.debug(application)
            if (application.id === current.id)
                return

            if (!application.valid || application.area)
                return

            console.debug(application.key, application.systemUI)
            if (current.id in root.apps)
                root.apps[current.id].enabled = false
            applicationManager.current = application
            if (application.id in root.apps) {
                root.apps[application.id].enabled = true
                if (typeof root.apps[application.id].activated === 'function')
                    root.apps[application.id].activated(args)
            }
        }
    }
}
