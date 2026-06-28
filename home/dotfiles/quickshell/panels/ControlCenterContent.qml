pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "../services"

FocusScope {
    id: root
    signal dismiss()

    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: function(ev) { root.dismiss(); ev.accepted = true }

    // ── Inline slider component ───────────────────────────────────────────────
    component SliderRow: Item {
        id: sldr; height: 44
        signal moved(real v)
        property real  value:  0
        property color accent: "#ffffff"

        Rectangle {
            id: track
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            height: 7; radius: 4; color: "#1c1c1c"
            Rectangle {
                width: Math.max(0, Math.min(track.width, track.width * sldr.value))
                height: parent.height; radius: 3; color: sldr.accent
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
        Rectangle {
            width: 20; height: 20; radius: 10; color: sldr.accent
            x: Math.max(0, Math.min(track.width - width, track.width * sldr.value - width / 2))
            anchors.verticalCenter: track.verticalCenter
            Behavior on color { ColorAnimation { duration: 200 } }
        }
        MouseArea {
            anchors.fill: parent; preventStealing: true
            function val(mx) { return Math.max(0, Math.min(1, mx / track.width)) }
            onPressed:         function(mouse) { sldr.moved(val(mouse.x)) }
            onPositionChanged: function(mouse) { if (pressed) sldr.moved(val(mouse.x)) }
        }
    }

    // ── Stat row component ────────────────────────────────────────────────────
    component StatBar: Item {
        id: sb; height: 36
        property string label: ""
        property string value: ""
        property real   pct:   0

        Text {
            id: lbl; text: sb.label; color: "#555555"
            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            width: 52
        }
        Rectangle {
            id: sbTrack
            anchors { left: lbl.right; leftMargin: 8; right: valLbl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
            height: 4; radius: 2; color: "#1c1c1c"
            Rectangle {
                width: Math.max(0, Math.min(sbTrack.width, sbTrack.width * sb.pct / 100))
                height: parent.height; radius: 2
                color: sb.pct > 85 ? "#ffffff" : (sb.pct > 60 ? "#aaaaaa" : "#555555")
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }
        Text {
            id: valLbl; text: sb.value; color: "#888888"
            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width: 100; horizontalAlignment: Text.AlignRight
        }
    }

    // ── Scrollable body ───────────────────────────────────────────────────────
    Flickable {
        anchors.fill: parent
        contentHeight: col.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; margins: 24 }
            spacing: 20

            // ── Giant clock ───────────────────────────────────────────────
            Item {
                width: parent.width; height: 96
                Text {
                    id: bigClock
                    anchors.centerIn: parent
                    color: "#ffffff"; font.pixelSize: 60; font.bold: true
                    font.family: "JetBrainsMono Nerd Font"
                    property string t: Qt.formatTime(new Date(), "hh:mm")
                    text: t
                    Timer { running: true; repeat: true; interval: 1000
                            onTriggered: parent.t = Qt.formatTime(new Date(), "hh:mm") }
                }
                Text {
                    anchors { top: bigClock.bottom; horizontalCenter: parent.horizontalCenter }
                    property string d: Qt.formatDate(new Date(), "ddd, MMM d")
                    text: d; color: "#333333"; font.pixelSize: 15
                    font.family: "JetBrainsMono Nerd Font"
                    Timer { running: true; repeat: true; interval: 60000
                            onTriggered: parent.d = Qt.formatDate(new Date(), "ddd, MMM d") }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

            // ── Quick tiles row 1: Mute | PowerProfile | HyprSunset | Impala ─
            Row {
                width: parent.width; spacing: 12

                // Mute
                Rectangle {
                    id: muteTileRect
                    width: (parent.width - 30) / 4; height: 84; radius: 18
                    color: Audio.muted ? "#ffffff" : "#111111"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Audio.muted ? "󰖁" : "󰕾"
                            color: Audio.muted ? "#000000" : "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Audio.muted ? "Muted" : "Sound"
                            color: Audio.muted ? "#000000" : "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    scale: muteTileMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea { id: muteTileMa; anchors.fill: parent; hoverEnabled: true; onClicked: Audio.toggleMute() }
                }

                // Power profile cycle
                Rectangle {
                    id: ppTile
                    width: (parent.width - 30) / 4; height: 84; radius: 18
                    color: PowerProfile.current === "performance" ? "#ffffff" : "#111111"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    readonly property bool active: PowerProfile.current === "performance"
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: PowerProfile.icons[PowerProfile.current] ?? "󰈐"
                            color: ppTile.active ? "#000000" : "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: ppTile.active ? "Perf" : (PowerProfile.current === "power-saver" ? "Saver" : "Bal")
                            color: ppTile.active ? "#000000" : "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    scale: ppTileMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea {
                        id: ppTileMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            const p = PowerProfile.profiles
                            PowerProfile.setProfile(p[(p.indexOf(PowerProfile.current) + 1) % p.length])
                        }
                    }
                }

                // HyprSunset toggle
                Rectangle {
                    id: sunsetTile
                    width: (parent.width - 30) / 4; height: 84; radius: 18
                    color: HyprSunset.active ? "#ffffff" : "#111111"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰖙"
                            color: HyprSunset.active ? "#000000" : "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sunset"
                            color: HyprSunset.active ? "#000000" : "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    scale: sunsetTileMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea { id: sunsetTileMa; anchors.fill: parent; hoverEnabled: true; onClicked: HyprSunset.toggle() }
                }

                // Launch nmtui
                Rectangle {
                    id: impalaTile
                    width: (parent.width - 30) / 4; height: 84; radius: 18; color: "#111111"
                    scale: impalaMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰖟"; color: "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "nmtui"; color: "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                    MouseArea {
                        id: impalaMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exec '[float] kitty -e nmtui'"]); root.dismiss() }
                    }
                }
            }

            // ── Quick tiles row 2: Play | Skip | Prev | (spacer) ─────────────
            Row {
                width: parent.width; spacing: 12

                Rectangle {
                    id: playTile2
                    width: (parent.width - 30) / 4; height: 84; radius: 18
                    color: Media.playing ? "#ffffff" : "#111111"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Media.playing ? "󰏤" : "󰐊"
                            color: Media.playing ? "#000000" : "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Media.playing ? "Pause" : "Play"
                            color: Media.playing ? "#000000" : "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    scale: playTileMa2.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea { id: playTileMa2; anchors.fill: parent; hoverEnabled: true; onClicked: Media.toggle() }
                }

                Rectangle {
                    width: (parent.width - 30) / 4; height: 84; radius: 18; color: "#111111"
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰒮"; color: "#555555"; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Prev"; color: "#555555"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font" }
                    }
                    scale: prevTileMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea { id: prevTileMa; anchors.fill: parent; hoverEnabled: true; onClicked: Media.prev() }
                }

                Rectangle {
                    width: (parent.width - 30) / 4; height: 84; radius: 18; color: "#111111"
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰒭"; color: "#555555"; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Next"; color: "#555555"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font" }
                    }
                    scale: skipTileMa2.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    MouseArea { id: skipTileMa2; anchors.fill: parent; hoverEnabled: true; onClicked: Media.next() }
                }

                // Placeholder 4th tile (spacer)
                Item { width: (parent.width - 30) / 4; height: 70 }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

            // ── Volume slider ──────────────────────────────────────────────
            Column { width: parent.width; spacing: 6
                Item { width: parent.width; height: 18
                    Row {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        Text { text: Audio.muted ? "󰖁" : "󰕾"; color: "#555555"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Volume"; color: "#ffffff"; font.pixelSize: 17; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    }
                    Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Audio.muted ? "MUTED" : Audio.volume + "%"; color: "#555555"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                }
                SliderRow { width: parent.width; value: Audio.muted ? 0 : Audio.volume / 100; accent: "#ffffff"; onMoved: function(v) { Audio.setVolume(Math.round(v * 100)) } }
            }

            // ── Brightness slider ──────────────────────────────────────────
            Column { width: parent.width; spacing: 6
                Item { width: parent.width; height: 18
                    Row {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        Text { text: "󰃟"; color: "#555555"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Brightness"; color: "#ffffff"; font.pixelSize: 17; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    }
                    Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Bright.percent + "%"; color: "#555555"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                }
                SliderRow { width: parent.width; value: Bright.percent / 100; accent: "#ffffff"; onMoved: function(v) { Bright.setPercent(Math.round(v * 100)) } }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

            // ── WiFi info ──────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 64; radius: 14; color: "#0d0d0d"
                Row {
                    anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
                    spacing: 10
                    Text {
                        text: Network.icon; color: Network.connected ? "#ffffff" : "#333333"
                        font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                        Text {
                            text: Network.connected ? Network.ssid : "Not connected"
                            color: Network.connected ? "#ffffff" : "#444444"
                            font.pixelSize: 17; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        }
                        Text {
                            text: Network.connected ? (Network.ipAddr.length > 0 ? Network.ipAddr : "obtaining IP…") : "no network"
                            color: "#444444"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                    Text {
                        visible: Network.connected && Network.strength.length > 0
                        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        text: Network.strength + "%"; color: "#555555"
                        font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            // ── Battery bar (when present) ─────────────────────────────────
            Column {
                width: parent.width; spacing: 6; visible: Battery.present
                Item { width: parent.width; height: 18
                    Row {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                        Text { text: Battery.icon; color: "#ffffff"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Battery"; color: "#ffffff"; font.pixelSize: 17; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                    }
                    Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Battery.percent + "% · " + Battery.status; color: "#555555"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font" }
                }
                Rectangle {
                    id: batBar2; width: parent.width; height: 7; radius: 4; color: "#1c1c1c"
                    Rectangle {
                        width: Math.max(0, Math.min(batBar2.width, batBar2.width * Battery.percent / 100))
                        height: parent.height; radius: 3; color: "#ffffff"
                        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

            // ── Media mini-card ────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 64; radius: 14; color: "#0d0d0d"
                visible: Media.title.length > 0
                Row {
                    anchors { fill: parent; margins: 10 }
                    spacing: 10
                    Rectangle {
                        width: 44; height: 44; radius: 8; color: "#1c1c1c"; anchors.verticalCenter: parent.verticalCenter
                        Image { anchors.fill: parent; source: Media.artUrl.length > 0 ? Media.artUrl : ""; fillMode: Image.PreserveAspectCrop; visible: Media.artUrl.length > 0 }
                        Text { anchors.centerIn: parent; visible: Media.artUrl.length === 0; text: "♪"; color: "#333333"; font.pixelSize: 16 }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                        width: parent.width - 34 - 10 - 80
                        Text { text: Media.title; color: "#ffffff"; font.pixelSize: 15; font.bold: true; font.family: "JetBrainsMono Nerd Font"; width: parent.width; elide: Text.ElideRight }
                        Text { text: Media.artist.length > 0 ? Media.artist : "Unknown"; color: "#555555"; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"; width: parent.width; elide: Text.ElideRight }
                    }
                    // Media controls — NO inline object array (avoids parser bug)
                    Row {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 10
                        Text {
                            text: "󰒮"; color: "#888888"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: Media.prev() }
                        }
                        Text {
                            text: Media.playing ? "󰏤" : "󰐊"; color: "#ffffff"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: Media.toggle() }
                        }
                        Text {
                            text: "󰒭"; color: "#888888"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"
                            MouseArea { anchors.fill: parent; onClicked: Media.next() }
                        }
                    }
                }
            }

            Text { text: "Esc close"; color: "#2a2a2a"; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }

            // ── Quick tiles row 3: Files | Do Not Disturb | Sysinfo ───────────
            Row {
                width: parent.width; spacing: 12

                // Nautilus files
                Rectangle {
                    width: (parent.width - 30) / 4; height: 84; radius: 18; color: "#111111"
                    scale: filesMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰝰"; color: "#555555"; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Files"; color: "#555555"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font" }
                    }
                    MouseArea { id: filesMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exec '[float] nautilus --new-window'"]); root.dismiss() } }
                }

                // Do Not Disturb (notif daemon mute via dunstctl / mako)
                Rectangle {
                    id: dndTile
                    width: (parent.width - 30) / 4; height: 84; radius: 18
                    property bool on: false
                    color: on ? "#ffffff" : "#111111"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    scale: dndMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: dndTile.on ? "󰂛" : "󰂜"
                            color: dndTile.on ? "#000000" : "#555555"
                            font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "DnD"
                            color: dndTile.on ? "#000000" : "#555555"
                            font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    Process {
                        id: dndProc
                        command: dndTile.on
                            ? ["bash", "-c", "dunstctl set-paused true 2>/dev/null || makoctl mode -a do-not-disturb 2>/dev/null || true"]
                            : ["bash", "-c", "dunstctl set-paused false 2>/dev/null || makoctl mode -r do-not-disturb 2>/dev/null || true"]
                    }
                    MouseArea { id: dndMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: { dndTile.on = !dndTile.on; dndProc.running = true } }
                }

                // Sysinfo shortcut
                Rectangle {
                    width: (parent.width - 30) / 4; height: 84; radius: 18; color: "#111111"
                    scale: sysMa.containsMouse ? 0.93 : 1.0
                    Behavior on scale { SpringAnimation { spring: 8; damping: 0.8 } }
                    Column {
                        anchors.centerIn: parent; spacing: 6
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰘚"; color: "#555555"; font.pixelSize: 24; font.family: "JetBrainsMono Nerd Font" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Stats"; color: "#555555"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font" }
                    }
                    MouseArea { id: sysMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: { Quickshell.execDetached(["quickshell", "ipc", "call", "island", "sysinfo"]); root.dismiss() } }
                }

                // Spacer
                Item { width: (parent.width - 30) / 4; height: 84 }
            }


            Item { width: 1; height: 8 }
        }
    }
}
