import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../singletons"

Item {
    anchors.fill: parent
    property string query: ""
    property var apps: []
    property var filtered: apps.filter(a => query.length === 0 || a.name.toLowerCase().includes(query.toLowerCase()))

    Component.onCompleted: appScan.running = true

    Process {
        id: appScan
        command: ["bash", "-c",
            "for f in /run/current-system/sw/share/applications/*.desktop " +
            "~/.local/share/applications/*.desktop; do " +
            "[ -f \"$f\" ] || continue; " +
            "name=$(grep -m1 ^Name= \"$f\" | cut -d= -f2-); " +
            "exec=$(grep -m1 ^Exec= \"$f\" | cut -d= -f2- | sed 's/ %[uUfFdDnNickvm]//g'); " +
            "icon=$(grep -m1 ^Icon= \"$f\" | cut -d= -f2-); " +
            "[ -n \"$name\" ] && [ -n \"$exec\" ] && echo \"$name|$exec|$icon\"; " +
            "done | sort -u | head -100"]
        stdout: SplitParser {
            onRead: d => {
                const parts = d.trim().split("|")
                if (parts.length >= 2)
                    apps = [...apps, { name: parts[0], exec: parts[1], icon: parts[2] || "" }]
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: Colors.surfaceVariant
            radius: 10
            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                Text {
                    text: "󰍉"
                    font.pixelSize: 16
                    color: Colors.textSurface
                    anchors.verticalCenter: parent.verticalCenter
                }
                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.textSurface
                    font.pixelSize: 14
                    focus: true
                    onTextChanged: query = text
                    Keys.onEscapePressed: Flags.close()
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: filtered
            spacing: 4

            delegate: Rectangle {
                width: ListView.view.width
                height: 44
                radius: 8
                color: ma.containsMouse ? Colors.primaryAlpha : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 10

                    Text {
                        text: modelData.name
                        color: Colors.textSurface
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        width: parent.width - 24
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        launchProc.command = ["bash", "-c", modelData.exec + " &"]
                        launchProc.running = true
                        Flags.close()
                    }
                }
            }
        }
    }

    Process { id: launchProc }
}
