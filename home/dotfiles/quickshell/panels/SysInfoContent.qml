pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import "../services"

FocusScope {
    id: root
    signal dismiss()

    focus: true
    Component.onCompleted: forceActiveFocus()
    Keys.onEscapePressed: function(ev) { root.dismiss(); ev.accepted = true }

    // ── Arc gauge component ───────────────────────────────────────────────────
    // Uses Canvas with a single onPaint handler driven by a smooth animPct property.
    // Only ONE onAnimPctChanged handler — calling requestPaint() — no duplicate.
    component ArcGauge: Item {
        id: ag
        width: 110; height: 110
        property real   pct:   0
        property string label: ""
        property string value: ""

        // Smoothly animated internal value
        property real animPct: 0
        Behavior on animPct { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
        onPctChanged:     animPct = ag.pct
        Component.onCompleted: animPct = ag.pct

        Canvas {
            anchors.fill: parent
            // repaint whenever animPct moves
            property real trigger: ag.animPct
            onTriggerChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                const cx = width / 2, cy = height / 2, r = width / 2 - 10
                const start = Math.PI * 0.75
                const full  = Math.PI * 1.5

                // background track
                ctx.beginPath()
                ctx.arc(cx, cy, r, start, start + full)
                ctx.strokeStyle = "#1c1c1c"
                ctx.lineWidth   = 9
                ctx.lineCap     = "round"
                ctx.stroke()

                // foreground fill
                const sweep = full * Math.min(1, Math.max(0, ag.animPct) / 100)
                if (sweep > 0) {
                    ctx.beginPath()
                    ctx.arc(cx, cy, r, start, start + sweep)
                    ctx.strokeStyle = ag.animPct > 85 ? "#ffffff"
                                    : ag.animPct > 60 ? "#aaaaaa"
                                    : "#555555"
                    ctx.lineWidth   = 9
                    ctx.lineCap     = "round"
                    ctx.stroke()
                }
            }
        }

        Column {
            anchors.centerIn: parent; spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: ag.value; color: "#ffffff"
                font.pixelSize: 19; font.bold: true
                font.family: "JetBrainsMono Nerd Font"
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: ag.label; color: "#555555"
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }

    // ── Bar stat for Disk ─────────────────────────────────────────────────────
    component StatBar: Item {
        id: sb; height: 46
        property string icon:  ""
        property string label: ""
        property string value: ""
        property real   pct:   0

        Row {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            spacing: 8
            Text { text: sb.icon; color: "#444444"; font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
            Text { text: sb.label; color: "#777777"; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
        }
        Text {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            text: sb.value; color: "#aaaaaa"
            font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"
        }
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 5; radius: 3; color: "#1c1c1c"
            Rectangle {
                width: Math.max(0, Math.min(parent.width, parent.width * sb.pct / 100))
                height: parent.height; radius: 3
                color: sb.pct > 85 ? "#ffffff" : (sb.pct > 60 ? "#aaaaaa" : "#555555")
                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 300 } }
            }
        }
    }

    Column {
        anchors { fill: parent; margins: 22 }
        spacing: 14

        // ── Header row ────────────────────────────────────────────────────────
        Item {
            width: parent.width; height: 32
            Row {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                spacing: 8
                Text { text: "󰻟"; color: "#333333"; font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "SYSTEM"; color: "#2a2a2a"; font.pixelSize: 15; font.bold: true; font.family: "JetBrainsMono Nerd Font"; font.letterSpacing: 3; anchors.verticalCenter: parent.verticalCenter }
            }
            Text {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: SysStats.hostname; color: "#444444"
                font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
            }
        }

        Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

        // ── Arc gauges row: CPU | RAM | Swap ─────────────────────────────────
        Row {
            width: parent.width
            spacing: (parent.width - 330) / 2

            ArcGauge {
                pct:   SysStats.cpuPercent
                label: "CPU"
                value: SysStats.cpuPercent + "%"
            }
            ArcGauge {
                pct:   SysStats.ramPercent
                label: "RAM"
                value: {
                    const used  = SysStats.ramUsedMB
                    const total = SysStats.ramTotalMB
                    if (total <= 0) return "—"
                    return used >= 1024
                        ? (used / 1024).toFixed(1) + "G"
                        : used + "M"
                }
            }
            ArcGauge {
                pct:   SysStats.swapPercent
                label: "Swap"
                value: {
                    const used  = SysStats.swapUsedMB
                    const total = SysStats.swapTotalMB
                    if (total <= 0) return "—"
                    return used >= 1024
                        ? (used / 1024).toFixed(1) + "G"
                        : used + "M"
                }
            }
        }

        // RAM / Swap detail line
        Row {
            width: parent.width; spacing: 20
            // RAM detail
            Text {
                width: (parent.width - 20) / 2
                text: {
                    const u = SysStats.ramUsedMB, t = SysStats.ramTotalMB
                    if (t <= 0) return "RAM: —"
                    const ug = u >= 1024 ? (u/1024).toFixed(1)+"G" : u+"M"
                    const tg = t >= 1024 ? (t/1024).toFixed(1)+"G" : t+"M"
                    return "RAM  " + ug + " / " + tg + "  (" + SysStats.ramPercent + "%)"
                }
                color: "#444444"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                horizontalAlignment: Text.AlignHCenter
            }
            // Swap detail
            Text {
                width: (parent.width - 20) / 2
                text: {
                    const u = SysStats.swapUsedMB, t = SysStats.swapTotalMB
                    if (t <= 0) return "Swap: none"
                    const ug = u >= 1024 ? (u/1024).toFixed(1)+"G" : u+"M"
                    const tg = t >= 1024 ? (t/1024).toFixed(1)+"G" : t+"M"
                    return "Swap  " + ug + " / " + tg + "  (" + SysStats.swapPercent + "%)"
                }
                color: "#444444"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

        // ── Disk bar ──────────────────────────────────────────────────────────
        StatBar {
            width: parent.width
            icon: "󰋊"; label: "Disk"
            value: SysStats.diskUsed + " / " + SysStats.diskTotal + "  (" + SysStats.diskPercent + "%)"
            pct:   SysStats.diskPercent
        }

        Rectangle { width: parent.width; height: 1; color: "#1a1a1a" }

        // ── Kernel + uptime ───────────────────────────────────────────────────
        Row {
            width: parent.width; spacing: 10
            Column {
                spacing: 6; width: parent.width
                Row {
                    spacing: 8
                    Text { text: "󰌢"; color: "#333333"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: SysStats.kernel; color: "#555555"; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"; elide: Text.ElideRight; width: parent.parent.width - 28 }
                }
                Row {
                    spacing: 8
                    Text { text: "󰅐"; color: "#333333"; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "up " + SysStats.uptime; color: "#444444"; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }
                }
            }
        }

        Item { width: 1; height: 2 }
        Text { text: "Esc  close"; color: "#2a2a2a"; font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font" }
    }
}
