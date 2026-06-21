import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../singletons"

Item {
    anchors.fill: parent
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Text { text: "Volume"; color: Colors.colorOnSurface; font.pixelSize: 14 }
        Slider {
            id: volSlider
            Layout.fillWidth: true
            from: 0; to: 100; value: Audio.volume
            onMoved: Audio.setVolume(value)
        }
        Text { text: "Brightness"; color: Colors.colorOnSurface; font.pixelSize: 14 }
        Slider {
            from: 5; to: 100; value: Bright.percent
            Layout.fillWidth: true
            onMoved: Bright.setPercent(value)
        }
    }
}
