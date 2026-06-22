pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    property string current: "balanced"

    readonly property var profiles: ["power-saver", "balanced", "performance"]

    readonly property var icons: ({
        "power-saver":  "󰌪",
        "balanced":     "󰈐",
        "performance":  "󰓅"
    })
    readonly property var labels: ({
        "power-saver":  "Power Saver",
        "balanced":     "Balanced",
        "performance":  "Performance"
    })
    readonly property var colors: ({
        "power-saver":  "#ffffff",
        "balanced":     "#aaaaaa",
        "performance":  "#ffffff"
    })

    function setProfile(p: string): void {
        root.current = p
        setProc.command = ["powerprofilesctl", "set", p]
        setProc.running = true
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }
    Process {
        id: poll; command: ["powerprofilesctl", "get"]
        stdout: SplitParser { onRead: d => { const v = d.trim(); if (v.length > 0) root.current = v } }
    }
    Process { id: setProc }
}
