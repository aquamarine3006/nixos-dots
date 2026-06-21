pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string title: ""
    property string artist: ""
    property string status: "Stopped"

    function play() { _run(["playerctl", "play"]) }
    function pause() { _run(["playerctl", "pause"]) }
    function toggle() { _run(["playerctl", "play-pause"]) }
    function next() { _run(["playerctl", "next"]) }
    function previous() { _run(["playerctl", "previous"]) }
    function _run(cmd) { cmdProc.command = cmd; cmdProc.running = true }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }

    Process {
        id: poll
        command: ["bash", "-c", "playerctl metadata --format '{{status}}\\n{{title}}\\n{{artist}}' 2>/dev/null"]
        stdout: SplitParser {
            onRead: d => {
                const l = d.split("\n")
                root.status = l[0] || "Stopped"
                root.title = l[1] || ""
                root.artist = l[2] || ""
            }
        }
    }
    Process { id: cmdProc }
}
