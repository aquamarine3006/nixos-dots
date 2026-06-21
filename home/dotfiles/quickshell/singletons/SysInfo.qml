pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property real cpuPercent: 0
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property real diskPercent: 0

    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { cpu.running = true; ram.running = true; disk.running = true }
    }

    Process {
        id: cpu
        command: ["bash", "-c", "awk '/cpu / {u=$2+$4; t=$2+$3+$4+$5; printf \"%.1f\", u/t*100}' /proc/stat"]
        stdout: SplitParser { onRead: d => root.cpuPercent = parseFloat(d) || 0 }
    }

    Process {
        id: ram
        command: ["bash", "-c", "free -m | awk '/Mem:/{printf \"%d %d\", $3, $2}'"]
        stdout: SplitParser {
            onRead: d => {
                const p = d.trim().split(" ").map(Number)
                root.ramUsedGb = (p[0] / 1024).toFixed(1)
                root.ramTotalGb = (p[1] / 1024).toFixed(1)
            }
        }
    }

    Process {
        id: disk
        command: ["bash", "-c", "df / | awk 'NR==2{gsub(/%/,\"\",$5); print $5}'"]
        stdout: SplitParser { onRead: d => root.diskPercent = parseFloat(d) || 0 }
    }
}
