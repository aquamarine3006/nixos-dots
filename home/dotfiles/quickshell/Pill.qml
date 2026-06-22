pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "panels"
import "services"

PanelWindow {
    id: root
    required property var screen

    property string panel:      ""
    property bool   osdVisible: false
    property string osdType:    ""

    signal dismiss()

    anchors { top: true; left: true; right: true }
    implicitHeight: screen?.height ?? 1080
    color: "transparent"
    WlrLayershell.layer:         WlrLayer.Top
    WlrLayershell.namespace:     "quickshell:pill"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: 56

    readonly property var dimMap: ({
        "":             { w: 160, h: 44,  r: 22 },
        "osd":          { w: 300, h: 44,  r: 22 },
        "launcher":     { w: 520, h: 310, r: 24 },
        "mixer":        { w: 380, h: 220, r: 24 },
        "power":        { w: 280, h: 150, r: 24 },
        "wallpaper":    { w: 580, h: 460, r: 24 },
        "media":        { w: 380, h: 215, r: 24 },
        "powerprofile": { w: 360, h: 240, r: 24 },
        "visualizer":   { w: 420, h: 160, r: 24 },
        "lockscreen":   { w: 360, h: 280, r: 28 }
    })

    readonly property string effectiveState:
        (panel === "" && osdVisible) ? "osd" : panel

    readonly property var dim: dimMap[effectiveState] ?? dimMap[""]

    HyprlandFocusGrab {
        windows: [root]
        active:  root.panel !== ""
        onCleared: root.dismiss()
    }

    Rectangle {
        id: pill
        anchors.top:              parent.top
        anchors.topMargin:        12
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#000000"; clip: true

        width:  root.dim.w
        height: root.dim.h
        radius: root.dim.r

        Behavior on width  { SpringAnimation { spring: 5.5; damping: 0.78; mass: 1.0 } }
        Behavior on height { SpringAnimation { spring: 5.5; damping: 0.78; mass: 1.0 } }
        Behavior on radius { SpringAnimation { spring: 5.5; damping: 0.78; mass: 1.0 } }

        readonly property bool isFullscreen:
            Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.hasFullscreen : false
        opacity: isFullscreen ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Item {
            anchors.fill: parent
            opacity: (root.effectiveState === "") ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }
            Text {
                anchors.centerIn: parent
                color: "#ffffff"; font.pixelSize: 20; font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                property string t: Qt.formatTime(new Date(), "hh:mm")
                text: t
                Timer { running: true; repeat: true; interval: 1000
                        onTriggered: parent.t = Qt.formatTime(new Date(), "hh:mm") }
            }
        }

        Item {
            anchors.fill: parent
            opacity: (root.effectiveState === "osd") ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: root.osdType === "volume" ? (Audio.muted ? "󰖁" : "󰕾") : "󰃟"
                    color: "#ffffff"; font.pixelSize: 16; font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: osdTrack; width: 160; height: 4; radius: 2; color: "#1c1c1c"
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        id: osdFill
                        width: Math.max(0, Math.min(osdTrack.width, osdTrack.width * (
                            root.osdType === "volume" ? (Audio.muted ? 0 : Audio.volume / 100) : (Bright.percent / 100)
                        )))
                        height: parent.height; radius: 2; color: "#ffffff"
                    }
                    Rectangle {
                        x: Math.max(0, Math.min(osdTrack.width - width, osdFill.width - width / 2))
                        anchors.verticalCenter: parent.verticalCenter
                        width: 10; height: 10; radius: 5; color: "#ffffff"
                    }
                }
                Text {
                    text: root.osdType === "volume" ? (Audio.muted ? "muted" : Audio.volume + "%") : (Bright.percent + "%")
                    color: "#888888"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "launcher"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: LauncherContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "mixer"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: MixerContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "power"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: PowerContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "wallpaper"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: WallpaperContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "media"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: MediaContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "powerprofile"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: PowerProfileContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "visualizer"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: VisualizerContent { onDismiss: root.dismiss() }
        }

        Loader {
            anchors.fill: parent; active: root.panel === "lockscreen"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: LockscreenContent { onDismiss: root.dismiss() }
        }
    }

    Region { id: pillMask; item: pill }
    mask: pillMask
}
