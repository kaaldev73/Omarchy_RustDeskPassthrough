import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root
    property var shell: null
    // Ownership prevents an older service's teardown removing a newer instance.
    readonly property string token: Date.now().toString(36) + "-" + Math.random().toString(36).slice(2)
    property bool stopping: false
    property bool pending: false

    function install() {
        if (root.stopping || !source.loaded) return
        if (installer.running) {
            root.pending = true
            return
        }
        root.pending = false
        installer.command = ["hyprctl", "eval",
            "local install = (function()\n" + source.text() +
            "\nend)(); install(" + JSON.stringify(root.token) + ")"]
        installer.running = true
    }

    FileView {
        id: source
        path: Qt.resolvedUrl("runtime.lua")
        onLoaded: root.install()
        onLoadFailed: console.error("RustDesk passthrough: cannot read runtime.lua")
    }

    Process {
        id: installer
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "ok" && text.trim() !== "")
                    console.warn("RustDesk passthrough: " + text.trim())
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") console.warn("RustDesk passthrough: " + text.trim())
            }
        }
        onExited: function(exitCode, exitStatus) {
            if (exitCode !== 0) console.warn("RustDesk passthrough installation failed: " + exitCode)
            if (root.pending && !root.stopping) Qt.callLater(root.install)
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "configreloaded") root.install()
        }
    }

    Component.onDestruction: {
        root.stopping = true
        installer.running = false
        // Inline cleanup also works after the plugin directory has been deleted.
        Quickshell.execDetached(["hyprctl", "eval",
            "local s=_G.omarchy_rustdesk_passthrough; if s and s.token==" +
            JSON.stringify(root.token) + " then s.stop() end"])
    }
}
