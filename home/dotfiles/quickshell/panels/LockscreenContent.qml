import QtQuick
import Quickshell

FocusScope {
    id: root
    signal dismiss()

    focus: true
    Component.onCompleted: pinField.forceActiveFocus()

    property string pin: ""
    readonly property string lockScript: "/home/aqua/scripts/lockscreen.sh"

    function doLock(): void {
        Quickshell.execDetached(["bash", root.lockScript])
        root.dismiss()
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        TextInput {
            id: pinField
            width: 0; height: 0; color: "transparent"; cursorVisible: false
            echoMode: TextInput.Password
            onTextChanged: {
                root.pin = text.slice(0, 4)
                if (text.length > 4) { text = text.slice(0, 4) }
            }
            Keys.onEscapePressed: function(ev) { root.pin = ""; text = ""; root.dismiss(); ev.accepted = true }
            Keys.onReturnPressed: function(ev) { root.doLock(); ev.accepted = true }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                property string t: Qt.formatTime(new Date(), "hh:mm")
                text: t; color: "#ffffff"; font.pixelSize: 44; font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                Timer { running: true; repeat: true; interval: 1000
                        onTriggered: parent.t = Qt.formatTime(new Date(), "hh:mm") }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                property string d: Qt.formatDate(new Date(), "ddd, MMM d")
                text: d; color: "#555555"; font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                Timer { running: true; repeat: true; interval: 60000
                        onTriggered: parent.d = Qt.formatDate(new Date(), "ddd, MMM d") }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter; spacing: 14
            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: 11; height: 11; radius: 6
                    color: index < root.pin.length ? "#ffffff" : "#252525"
                    border.width: 1; border.color: index < root.pin.length ? "transparent" : "#3a3a3a"
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
            Rectangle {
                width: 120; height: 40; radius: 10
                color: cancelMa.containsMouse ? "#1c1c1c" : "#111111"
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "Cancel"; color: "#555555"
                    font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                MouseArea { id: cancelMa; anchors.fill: parent; hoverEnabled: true
                    onClicked: { root.pin = ""; pinField.text = ""; root.dismiss() } }
            }
            Rectangle {
                width: 120; height: 40; radius: 10
                color: lockMa.containsMouse ? "#1c1c1c" : "#111111"
                border.width: 1; border.color: "#ffffff"
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "󰌾  Lock"
                    color: "#ffffff"; font.pixelSize: 13; font.bold: true
                    font.family: "JetBrainsMono Nerd Font" }
                MouseArea { id: lockMa; anchors.fill: parent; hoverEnabled: true; onClicked: root.doLock() }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Enter lock   Esc cancel"; color: "#2a2a2a"
            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
        }
    }
}
