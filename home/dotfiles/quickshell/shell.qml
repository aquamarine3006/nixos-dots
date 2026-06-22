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
        function launcher():       void { root.toggle("launcher")       }
        function scriptlauncher(): void { root.toggle("scriptlauncher") }
        function controlcenter():  void { root.toggle("controlcenter")  }
        function mixer():          void { root.toggle("controlcenter")  }  // alias: old keybind still works
        function sysinfo():        void { root.toggle("sysinfo")        }
        function power():          void { root.toggle("power")          }
        function wallpaper():      void { root.toggle("wallpaper")      }
        function media():          void { root.toggle("media")          }
        function powerprofile():   void { root.toggle("powerprofile")   }
        function visualizer():     void { root.toggle("visualizer")     }
        function lockscreen():     void { root.toggle("lockscreen")     }
        function close():          void { root.panel = ""               }

        function volUp(): void   { Audio.setVolume(Audio.volume + 5);      root.showOsd("volume")     }
        function volDown(): void { Audio.setVolume(Audio.volume - 5);      root.showOsd("volume")     }
        function mute(): void    { Audio.toggleMute();                     root.showOsd("volume")     }
        function briUp(): void   { Bright.setPercent(Bright.percent + 5);  root.showOsd("brightness") }
        function briDown(): void { Bright.setPercent(Bright.percent - 5);  root.showOsd("brightness") }
        function osd(type: string): void { root.showOsd(type) }

        // Media shortcuts
        function mediaToggle(): void { Media.toggle() }
        function mediaNext():   void { Media.next()   }
        function mediaPrev():   void { Media.prev()   }
    }

    Pill {
        screen:     Quickshell.screens[0]
        panel:      root.panel
        osdVisible: root.osdVisible && root.panel === ""
        osdType:    root.osdType
        onDismiss:  root.panel = ""
    }
}
