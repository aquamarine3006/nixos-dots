pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    // "silent" | "balanced" | "performance" | "auto"
    property string mode: "auto"
    property int    rpm:  0

    // nbfc speed percentages per mode
    readonly property var speeds: ({
        "silent":      0,
        "balanced":    50,
        "performance": 100
    })

    function setMode(m: string): void {
        root.mode = m
        if (m === "auto") {
            autoProc.running = true
        } else {
            setProc.command = ["bash", "-c",
                "nbfc set -s " + root.speeds[m] + " 2>/dev/null || true"]
            setProc.running = true
        }
    }

    // Poll RPM from nbfc status (or hwmon fallback)
    Timer {
        interval: 4000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: rpmPoll.running = true
    }
    Process { id: rpmPoll
        command: ["bash", "-c",
            // try nbfc first, fall back to hwmon fan input
            "nbfc status -a 2>/dev/null | grep -i 'current speed' | head -1 | grep -oP '[0-9]+' | tail -1 " +
            "|| cat /sys/class/hwmon/hwmon*/fan*_input 2>/dev/null | head -1 " +
            "|| echo 0"]
        stdout: SplitParser { onRead: d => {
            const v = parseInt(d.trim())
            if (!isNaN(v)) root.rpm = v
        } } }

    Process { id: setProc }
    Process { id: autoProc; command: ["bash", "-c", "nbfc set -a 2>/dev/null || true"] }
}
