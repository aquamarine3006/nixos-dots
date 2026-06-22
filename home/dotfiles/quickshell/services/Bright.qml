pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    property int percent: 100

    function setPercent(v: int): void {
        const c = Math.max(5, Math.min(100, v))
        root.percent = c
        setProc.command = ["brightnessctl", "set", String(c) + "%"]
        setProc.running = true
    }

    Timer {
        interval: 50; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }
    Process {
        id: poll
        command: ["bash", "-c", "echo $(( $(brightnessctl get) * 100 / $(brightnessctl max) ))"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d.trim()); if (!isNaN(v)) root.percent = v } }
    }
    Process { id: setProc }
}
