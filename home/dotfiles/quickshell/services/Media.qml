pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: root
    property string title:    ""
    property string artist:   ""
    property string status:   "Stopped"
    property int    position: 0
    property int    length:   0
    property string artUrl:   ""

    readonly property bool playing: status === "Playing"

    function play():     void { _cmd(["playerctl", "play"])     }
    function pause():    void { _cmd(["playerctl", "pause"])    }
    function toggle():   void { _cmd(["playerctl", "play-pause"]) }
    function next():     void { _cmd(["playerctl", "next"])     }
    function prev():     void { _cmd(["playerctl", "previous"]) }
    function seekTo(s: int): void { _cmd(["playerctl", "position", String(s)]) }

    function _cmd(c): void { cmdProc.command = c; cmdProc.running = true }

    Timer {
        interval: 500; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            titlePoll.running   = true
            artistPoll.running  = true
            statusPoll.running  = true
            posPoll.running     = true
            lenPoll.running     = true
            artPoll.running     = true
        }
    }

    Process { id: titlePoll;  command: ["playerctl", "metadata", "title"]
        stdout: SplitParser { onRead: d => root.title  = d.trim() } }
    Process { id: artistPoll; command: ["playerctl", "metadata", "artist"]
        stdout: SplitParser { onRead: d => root.artist = d.trim() } }
    Process { id: statusPoll; command: ["playerctl", "status"]
        stdout: SplitParser { onRead: d => root.status = d.trim() } }
    Process { id: posPoll;
        command: ["bash", "-c", "playerctl position 2>/dev/null | cut -d. -f1"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d.trim()); if (!isNaN(v)) root.position = v } } }
    Process { id: lenPoll;
        command: ["bash", "-c", "playerctl metadata mpris:length 2>/dev/null | awk '{printf \"%d\", $1/1000000}'"]
        stdout: SplitParser { onRead: d => { const v = parseInt(d.trim()); if (!isNaN(v)) root.length = v } } }
    Process { id: artPoll;
        command: ["playerctl", "metadata", "mpris:artUrl"]
        stdout: SplitParser { onRead: d => root.artUrl = d.trim() } }

    Process { id: cmdProc }
}
