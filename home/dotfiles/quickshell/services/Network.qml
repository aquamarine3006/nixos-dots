pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    property string ssid:      ""
    property string ipAddr:    ""
    property string strength:  ""
    property bool   connected: false

    readonly property string icon: {
        if (!connected) return "󰤭"
        const s = parseInt(strength)
        if (isNaN(s))  return "󰤫"
        if (s >= 75)   return "󰤨"
        if (s >= 50)   return "󰤥"
        if (s >= 25)   return "󰤢"
        return "󰤟"
    }

    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { ssidPoll.running = true; ipPoll.running = true; strengthPoll.running = true }
    }
    Process { id: ssidPoll
        command: ["bash", "-c", "iwgetid -r 2>/dev/null || echo ''"]
        stdout: SplitParser { onRead: d => {
            const v = d.trim()
            root.ssid = v
            root.connected = v.length > 0
        } } }
    Process { id: ipPoll
        command: ["bash", "-c", "ip -4 addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -1"]
        stdout: SplitParser { onRead: d => { root.ipAddr = d.trim() } } }
    Process { id: strengthPoll
        command: ["bash", "-c", "awk 'NR==3{printf \"%.0f\", $3*100/70}' /proc/net/wireless 2>/dev/null || echo ''"]
        stdout: SplitParser { onRead: d => { root.strength = d.trim() } } }
}
