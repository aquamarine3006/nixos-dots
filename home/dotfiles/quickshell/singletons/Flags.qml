pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    property string activePanel: ""
    property string osdType: ""
    property real osdValue: 0.0

    function toggle(name) { activePanel = (activePanel === name) ? "" : name }
    function close() { activePanel = "" }

    property Timer osdTimer: Timer {
        interval: 2000
        onTriggered: if (root.activePanel === "osd") root.activePanel = ""
    }

    function showOsd(type, value) {
        osdType = type
        osdValue = value
        activePanel = "osd"
        osdTimer.restart()
    }
}
