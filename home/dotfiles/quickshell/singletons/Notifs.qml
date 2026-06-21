pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var notifications: []

    function add(app, summary, body, expire) {
        const n = { id: Date.now(), app: app, summary: summary, body: body, expire: expire || 5000 }
        notifications = [...notifications, n]
    }

    function dismiss(id) {
        notifications = notifications.filter(n => n.id !== id)
    }

    function dismissAll() { notifications = [] }
}
