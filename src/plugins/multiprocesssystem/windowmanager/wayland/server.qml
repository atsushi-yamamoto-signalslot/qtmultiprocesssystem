﻿import QtQuick 2.15
import QtWayland.Compositor 1.15
import QtMultiProcessSystem.Internal 1.0
import QtMultiProcessSystem.XdgShell 1.15

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
            onSurfaceDestroyed: destroy()
            onWidthChanged: handleResized(width, height)
            onHeightChanged: handleResized(width, height)
            signal handleResized(real width, real height)
        }
    }

    function add(key, surface) {
        if (key === Qt.application.name) // QPA changes title once with its name
            return
        var app = applicationManager.findByKey(key)
        var parent = main.findParent(app)
        var item = chromeComponent.createObject(parent, { "shellSurface": surface } )
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
                item.handleResized.connect(function(width, height) {
                    if (width < 0 || height < 0)
                        return
                    shellSurface.sendConfigure(Qt.size(width, height), WlShellSurface.NoneEdge);
                })
            })
        }
    }

    XdgShell {
        id: shell
        onPong: watchDog.pongReceived(serial)
        onToplevelCreated: {
            toplevel.titleChanged.connect(function() {
                var item = root.add(toplevel.title, xdgSurface)
                if (!item)
                    return
                item.handleResized.connect(function(width, height) {
                    if (width < 0 || height < 0)
                        return
                    toplevel.sendConfigure(Qt.size(width, height), []);
                })
            })
        }
    }

    XdgShellWatchDog {
        id: watchDog
    }

    Timer {
        id: watchDogTimer
        interval: 1000 // TODO: settable
        repeat: true
        running: typeof watchDogManager !== 'undefined'
        onTriggered: {
            for (var id in apps) {
                var item = root.apps[id]
                var client = item.shellSurface.surface.client
                var serial = shell.ping(client)
                watchDog.pingSent(applicationManager.findByID(id), serial)
            }
        }
    }

    property var apps: ({})
    Connections {
        target: applicationManager
        function onActivated(app) {
            var current = applicationManager.current
            if (app.id === current.id)
                return
            if (app.area)
                return

            if (!current.valid && !app.systemUI)
                return

            if (current.id in root.apps)
                root.apps[current.id].enabled = false
            applicationManager.current = app
            if (app.id in root.apps)
                root.apps[app.id].enabled = true
        }
    }
}
