pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var entries: []

    function load() { lister.running = true }
    function paste(entry) {
        pasteProc.command = ["bash", "-c", "echo " + JSON.stringify(entry.raw) + " | cliphist decode | wl-copy"]
        pasteProc.running = true
        Flags.close()
    }
    function clear() { clearProc.running = true; entries = [] }

    Process {
        id: lister
        command: ["bash", "-c", "cliphist list | head -50"]
        stdout: SplitParser {
            onRead: d => {
                const lines = d.trim().split("\n").filter(Boolean)
                root.entries = lines.map((l, i) => ({ id: i, raw: l, preview: l.replace(/^\d+\t/, "").slice(0, 80) }))
            }
        }
    }
    Process { id: pasteProc }
    Process { id: clearProc; command: ["cliphist", "wipe"] }
}
