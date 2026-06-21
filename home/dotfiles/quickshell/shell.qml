import Quickshell
import Quickshell.Wayland
import QtQuick
import "pill"

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PillSurface { required property var modelData; screen: modelData }
    }
    Variants {
        model: Quickshell.screens
        delegate: OsdSurface { required property var modelData; screen: modelData }
    }
    Variants {
        model: Quickshell.screens
        delegate: NotifPopups { required property var modelData; screen: modelData }
    }
    LockSurface {}
}
