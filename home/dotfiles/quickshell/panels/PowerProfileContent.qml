pragma ComponentBehavior: Bound
import QtQuick
import "../services"

FocusScope {
    id: root
    signal dismiss()

    focus: true
    Component.onCompleted: { forceActiveFocus(); profileList.currentIndex = PowerProfile.profiles.indexOf(PowerProfile.current) }

    Keys.onEscapePressed: { root.dismiss(); event.accepted = true }
    Keys.onReturnPressed: {
        PowerProfile.setProfile(PowerProfile.profiles[profileList.currentIndex])
        event.accepted = true
    }
    Keys.onUpPressed:   { profileList.decrementCurrentIndex(); event.accepted = true }
    Keys.onDownPressed: { profileList.incrementCurrentIndex(); event.accepted = true }

    Column {
        anchors { fill: parent; margins: 24 }
        spacing: 16

        Text {
            text: "POWER PROFILE"; color: "#2a2a2a"; font.pixelSize: 17; font.bold: true
            font.family: "JetBrainsMono Nerd Font"; font.letterSpacing: 3
        }

        ListView {
            id: profileList
            width: parent.width
            height: PowerProfile.profiles.length * 88
            model: PowerProfile.profiles
            currentIndex: PowerProfile.profiles.indexOf(PowerProfile.current)
            interactive: false; spacing: 10

            delegate: Rectangle {
                id: prow
                required property string modelData
                required property int    index
                width: profileList.width; height: 96; radius: 18

                readonly property bool isActive:   PowerProfile.current === prow.modelData
                readonly property bool isFocused:  profileList.currentIndex === prow.index
                readonly property string rowColor: PowerProfile.colors[prow.modelData] ?? "#ffffff"

                color: prow.isActive ? Qt.rgba(
                    parseInt(prow.rowColor.slice(1,3),16)/255 * 0.15,
                    parseInt(prow.rowColor.slice(3,5),16)/255 * 0.15,
                    parseInt(prow.rowColor.slice(5,7),16)/255 * 0.15,
                    1) : (prow.isFocused ? "#1c1c1c" : "#111111")

                border.width: prow.isActive || prow.isFocused ? 1 : 0
                border.color: prow.isActive ? prow.rowColor : "#333"

                Behavior on color        { ColorAnimation  { duration: 120 } }
                Behavior on border.width { NumberAnimation { duration: 80  } }

                Row {
                    anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
                    spacing: 16

                    Text {
                        text: PowerProfile.icons[prow.modelData] ?? "?"
                        color: prow.isActive ? prow.rowColor : "#666"
                        font.pixelSize: 36; font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    Text {
                        text: PowerProfile.labels[prow.modelData] ?? prow.modelData
                        color: prow.isActive ? "#ffffff" : "#aaaaaa"
                        font.pixelSize: 24; font.bold: prow.isActive
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                Text {
                    anchors { right: parent.right; rightMargin: 18; verticalCenter: parent.verticalCenter }
                    text: prow.isActive ? "● active" : ""
                    color: prow.rowColor; font.pixelSize: 15; font.letterSpacing: 1
                    font.family: "JetBrainsMono Nerd Font"
                }

                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: profileList.currentIndex = prow.index
                    onClicked: PowerProfile.setProfile(prow.modelData)
                }
            }
        }

        Text {
            text: "↑↓ select   Enter/click apply   Esc close"
            color: "#2a2a2a"; font.pixelSize: 17; font.family: "JetBrainsMono Nerd Font"
        }
    }
}
