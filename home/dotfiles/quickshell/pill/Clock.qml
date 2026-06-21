import QtQuick
import "../singletons"

Item {
    implicitWidth: t.implicitWidth
    implicitHeight: t.implicitHeight
    Text {
        id: t
        color: Colors.textSurface
        font.pixelSize: 13
        Timer {
            interval: 60000; running: true; repeat: true; triggeredOnStart: true
            onTriggered: {
                const now = new Date()
                t.text = now.getHours().toString().padStart(2,"0") + ":" + now.getMinutes().toString().padStart(2,"0")
            }
        }
    }
    MouseArea { anchors.fill: parent; onClicked: Flags.toggle("calendar") }
}
