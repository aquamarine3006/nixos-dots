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
        "":               { w: 260, h: 48,  r: 24 },
        "osd":            { w: 340, h: 48,  r: 24 },
        "launcher":       { w: 600, h: 420, r: 28 },
        "scriptlauncher": { w: 600, h: 420, r: 28 },
        "controlcenter":  { w: 540, h: 720, r: 28 },
        "sysinfo":        { w: 540, h: 460, r: 28 },
        "power":          { w: 360, h: 200, r: 28 },
        "wallpaper":      { w: 680, h: 560, r: 28 },
        "media":          { w: 480, h: 280, r: 28 },
        "powerprofile":   { w: 540, h: 460, r: 28 },
        "visualizer":     { w: 520, h: 220, r: 28 },
        "lockscreen":     { w: 440, h: 360, r: 32 }
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

        // ── Clock + Battery ───────────────────────────────────────────────
        Item {
            anchors.fill: parent
            opacity: (root.effectiveState === "") ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InCubic } }

            Text {
                anchors.centerIn: parent
                color: "#ffffff"; font.pixelSize: 24; font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                property string t: Qt.formatTime(new Date(), "hh:mm")
                text: t
                Timer { running: true; repeat: true; interval: 1000
                        onTriggered: parent.t = Qt.formatTime(new Date(), "hh:mm") }
            }

            Text {
                visible: Battery.present
                anchors.right: parent.right; anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: Battery.percent + "%"
                color: Battery.critical ? "#666666" : "#333333"
                font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"
                Behavior on color { ColorAnimation { duration: 400 } }
                SequentialAnimation on opacity {
                    running: Battery.critical; loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                }
            }
        }

        // ── OSD ───────────────────────────────────────────────────────────
        Item {
            anchors.fill: parent
            opacity: (root.effectiveState === "osd") ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                anchors.centerIn: parent; spacing: 12
                Text {
                    text: root.osdType === "volume" ? (Audio.muted ? "󰖁" : "󰕾") : "󰃟"
                    color: "#ffffff"; font.pixelSize: 24; font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: osdTrack; width: 200; height: 5; radius: 3; color: "#1c1c1c"
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
                    color: "#888888"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // ── Launcher ──────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "launcher"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: LauncherContent { onDismiss: root.dismiss() }
        }

        // ── Script Launcher ───────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "scriptlauncher"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: ScriptLauncherContent { onDismiss: root.dismiss() }
        }

        // ── Control Center ────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "controlcenter"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: ControlCenterContent { onDismiss: root.dismiss() }
        }

        // ── Sys Info ──────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "sysinfo"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: SysInfoContent { onDismiss: root.dismiss() }
        }

        // ── Power ─────────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "power"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: PowerContent { onDismiss: root.dismiss() }
        }

        // ── Wallpaper ─────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "wallpaper"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: WallpaperContent { onDismiss: root.dismiss() }
        }

        // ── Media ─────────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "media"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: MediaContent { onDismiss: root.dismiss() }
        }

        // ── Power Profile ─────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "powerprofile"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: PowerProfileContent { onDismiss: root.dismiss() }
        }

        // ── Visualizer ────────────────────────────────────────────────────
        Loader {
            anchors.fill: parent; active: root.panel === "visualizer"
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            sourceComponent: VisualizerContent { onDismiss: root.dismiss() }
        }

        // ── Lockscreen ────────────────────────────────────────────────────
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
