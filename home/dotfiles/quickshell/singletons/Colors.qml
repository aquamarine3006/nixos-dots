pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property color primary: "#c0a0ff"
    property color textPrimary: "#ffffff"
    property color primaryContainer: "#2a1a5e"
    property color secondary: "#a090e0"
    property color tertiary: "#e0a0c0"
    property color surface: "#1a1a2e"
    property color textSurface: "#e0e0ff"
    property color surfaceVariant: "#2a2a3e"
    property color outline: "#4a4a6a"
    property color error: "#ff6b6b"
    property color background: "#181c22"

    property color surfaceAlpha: Qt.rgba(surface.r, surface.g, surface.b, 0.85)
    property color primaryAlpha: Qt.rgba(primary.r, primary.g, primary.b, 0.15)

    function applyJson(jsonText) {
        try {
            const c = JSON.parse(jsonText)
            if (c.primary) root.primary = c.primary
            if (c.onPrimary) root.textPrimary = c.onPrimary
            if (c.primaryContainer) root.primaryContainer = c.primaryContainer
            if (c.secondary) root.secondary = c.secondary
            if (c.tertiary) root.tertiary = c.tertiary
            if (c.surface) root.surface = c.surface
            if (c.onSurface) root.textSurface = c.onSurface
            if (c.surfaceVariant) root.surfaceVariant = c.surfaceVariant
            if (c.outline) root.outline = c.outline
            if (c.error) root.error = c.error
            if (c.background) root.background = c.background
        } catch (e) {}
    }

    FileView {
        id: colorFile
        path: "/tmp/qs_colors.json"
        watchChanges: true
        onTextChanged: root.applyJson(colorFile.text())
    }
}
