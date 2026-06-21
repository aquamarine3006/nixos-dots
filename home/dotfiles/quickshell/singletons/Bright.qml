pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int percent: 100

    function setPercent(v) {
        const c = Math.max(5, Math.min(100, v))
        setProc.command = ["brightnessctl", "set", c + "%"]
        setProc.running = true
        root.percent = c
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }

    Process {
        id: poll
        command: ["bash", "-c", "echo $(( $(brightnessctl get) * 100 / $(brightnessctl max) ))"]
        stdout: SplitParser { onRead: d => root.percent = parseInt(d.trim()) || 100 }
    }
    Process { id: setProc }
}
