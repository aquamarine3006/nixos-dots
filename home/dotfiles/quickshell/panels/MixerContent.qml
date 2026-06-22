import QtQuick
import "../services"

FocusScope {
    id: root
    signal dismiss()

    focus: true
    Component.onCompleted: forceActiveFocus()

    Keys.onEscapePressed: { root.dismiss(); event.accepted = true }
    Keys.onUpPressed:     { Audio.setVolume(Audio.volume + 5);    event.accepted = true }
    Keys.onDownPressed:   { Audio.setVolume(Audio.volume - 5);    event.accepted = true }
    Keys.onRightPressed:  { Bright.setPercent(Bright.percent + 5); event.accepted = true }
    Keys.onLeftPressed:   { Bright.setPercent(Bright.percent - 5); event.accepted = true }
    Keys.onSpacePressed:  { Audio.toggleMute();                   event.accepted = true }

    Column {
        anchors { fill: parent; margins: 20 }
        spacing: 18

        Column { width: parent.width; spacing: 8
            Item { width: parent.width; height: 18
                Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "Volume"; color: "#ffffff"; font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Audio.muted ? "MUTED" : Audio.volume + "%"; color: Audio.muted ? "#444444" : "#888888"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
            }
            SliderRow { width: parent.width; value: Audio.muted ? 0 : Audio.volume / 100; onMoved: v => Audio.setVolume(Math.round(v * 100)) }
        }

        Rectangle { width: parent.width; height: 1; color: "#1c1c1c" }

        Column { width: parent.width; spacing: 8
            Item { width: parent.width; height: 18
                Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "Brightness"; color: "#ffffff"; font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: Bright.percent + "%"; color: "#888888"; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
            }
            SliderRow { width: parent.width; value: Bright.percent / 100; onMoved: v => Bright.setPercent(Math.round(v * 100)) }
        }

        Text { text: "↑↓ vol   ←→ bright   Space mute   Esc close"; color: "#2a2a2a"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; width: parent.width; wrapMode: Text.WordWrap }
    }

    component SliderRow: Item {
        id: sldr; height: 36
        signal moved(real v)
        property real value: 0

        Rectangle {
            id: track
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
            height: 6; radius: 3; color: "#1c1c1c"
            Rectangle {
                width: Math.max(0, Math.min(track.width, track.width * sldr.value))
                height: parent.height; radius: 3; color: "#ffffff"
            }
        }
        Rectangle {
            width: 16; height: 16; radius: 8; color: "#ffffff"
            x: Math.max(0, Math.min(track.width - width, track.width * sldr.value - width / 2))
            anchors.verticalCenter: track.verticalCenter
        }
        MouseArea {
            anchors.fill: parent; preventStealing: true
            function val(mx) { return Math.max(0, Math.min(1, mx / track.width)) }
            onPressed:         mouse => sldr.moved(val(mouse.x))
            onPositionChanged: mouse => { if (pressed) sldr.moved(val(mouse.x)) }
        }
    }
}
