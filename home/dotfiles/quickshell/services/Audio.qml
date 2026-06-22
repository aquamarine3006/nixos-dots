pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    property int  volume: 0
    property bool muted:  false

    function setVolume(v: int): void {
        const c = Math.max(0, Math.min(100, v))
        root.volume = c
        volSet.command = ["pamixer", "--set-volume", String(c)]
        volSet.running = true
    }
    function toggleMute(): void {
        root.muted = !root.muted
        muteProc.running = true
    }

    Timer {
        interval: 50; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { volPoll.running = true; mutePoll.running = true }
    }
    Process {
        id: volPoll; command: ["pamixer", "--get-volume"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d.trim()); if (!isNaN(v)) root.volume = v } }
    }
    Process {
        id: mutePoll; command: ["pamixer", "--get-mute"]
        stdout: SplitParser { onRead: d => { root.muted = d.trim() === "true" } }
    }
    Process { id: volSet }
    Process { id: muteProc; command: ["pamixer", "-t"] }
}
