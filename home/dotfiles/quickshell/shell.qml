import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "services"

ShellRoot {
    id: root

    property bool   osdVisible: false
    property string osdType:    ""

    Timer { id: osdTimer; interval: 2000; onTriggered: root.osdVisible = false }

    function showOsd(type: string): void {
        root.osdType    = type
        root.osdVisible = true
        osdTimer.restart()
    }

    property string panel: ""

    function toggle(name: string): void {
        root.panel = (root.panel === name) ? "" : name
        if (root.panel !== "") root.osdVisible = false
    }

    IpcHandler {
        target: "island"
        function launcher():     void { root.toggle("launcher")     }
        function mixer():        void { root.toggle("mixer")        }
        function power():        void { root.toggle("power")        }
        function wallpaper():    void { root.toggle("wallpaper")    }
        function media():        void { root.toggle("media")        }
        function powerprofile(): void { root.toggle("powerprofile") }
        function visualizer():   void { root.toggle("visualizer")   }
        function lockscreen():   void { root.toggle("lockscreen")   }
    }

    Hyprland.onWorkspaceChanged: function(ws) {
        root.panel = ""
        root.osdVisible = false
    }

    Component.onCompleted: {
        for (var i = 0; i < Quickshell.screens.length; ++i) {
            var comp = Qt.createComponent("Pill.qml")
            comp.createObject(Quickshell.screens[i], { "screen": Quickshell.screens[i] })
        }
    }
}
