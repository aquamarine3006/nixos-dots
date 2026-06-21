import QtQuick
import QtQuick.Layouts
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Text { text: "CPU"; color: Colors.colorOnSurface; font.pixelSize: 13; Layout.preferredWidth: 80 }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surfaceVariant
                Rectangle { width: parent.width * SysInfo.cpuPercent / 100; height: parent.height; radius: 4; color: Colors.primary }
            }
            Text { text: SysInfo.cpuPercent.toFixed(0) + "%"; color: Colors.colorOnSurface; font.pixelSize: 12 }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "RAM"; color: Colors.colorOnSurface; font.pixelSize: 13; Layout.preferredWidth: 80 }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surfaceVariant
                Rectangle {
                    width: parent.width * (SysInfo.ramTotalGb > 0 ? SysInfo.ramUsedGb / SysInfo.ramTotalGb : 0)
                    height: parent.height; radius: 4; color: Colors.tertiary
                }
            }
            Text { text: SysInfo.ramUsedGb + "/" + SysInfo.ramTotalGb + "GB"; color: Colors.colorOnSurface; font.pixelSize: 12 }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Disk"; color: Colors.colorOnSurface; font.pixelSize: 13; Layout.preferredWidth: 80 }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surfaceVariant
                Rectangle { width: parent.width * SysInfo.diskPercent / 100; height: parent.height; radius: 4; color: Colors.secondary }
            }
            Text { text: SysInfo.diskPercent.toFixed(0) + "%"; color: Colors.colorOnSurface; font.pixelSize: 12 }
        }
    }
}
