pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property int duration: 220
    readonly property int durationFast: 120
    readonly property int decel: Easing.OutCubic
    readonly property int accel: Easing.InCubic
    readonly property real pillCollapsed: 280
    readonly property real pillExpanded: 520
}
