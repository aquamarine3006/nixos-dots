pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int volume: 50
    property bool muted: false

    function setVolume(v) {
        const c = Math.max(0, Math.min(100, v))
        volSet.command = ["pamixer", "--set-volume", String(c)]
        volSet.running = true
        root.volume = c
    }
    function toggleMute() { muteProc.running = true; root.muted = !root.muted }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: volPoll.running = true
    }

    Process {
        id: volPoll
        command: ["bash", "-c", "pamixer --get-volume; pamixer --get-mute"]
        stdout: SplitParser {
            onRead: d => {
                const l = d.trim().split("\n")
                if (l[0]) root.volume = parseInt(l[0]) || 0
                if (l[1]) root.muted = l[1].trim() === "true"
            }
        }
    }
    Process { id: volSet }
    Process { id: muteProc; command: ["pamixer", "-t"] }
}
