pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int percent: 100
    property bool charging: false

    Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: bat.running = true
    }

    Process {
        id: bat
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: d => {
                const l = d.trim().split("\n")
                if (l[0]) root.percent = parseInt(l[0]) || 100
                if (l[1]) root.charging = l[1].trim() === "Charging"
            }
        }
    }
}
