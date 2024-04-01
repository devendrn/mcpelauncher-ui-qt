import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

ColumnLayout {
    id: columnLayout
    signal finished
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0

    BaseHeader {
        Layout.fillWidth: true
        title: qsTr("Minecraft: Unofficial *nix launcher")
        content: TabBar {
            id: tabs
            background: null
            anchors.fill: parent

            MTabButton {
                text: qsTr("Changelog and License")
            }
        }
    }

    ScrollView {
        id: changelog
        Layout.fillHeight: true
        Layout.fillWidth: true
        contentWidth: changelog.availableWidth
        TextEdit {
            padding: 15
            textFormat: TextEdit.RichText
            text: "<b>Welcome to the new Minecraft Linux Launcher Update</b><br/><br/>" + LAUNCHER_CHANGE_LOG
            color: "#fff"
            readOnly: true
            font.pointSize: 10
            wrapMode: Text.WordWrap
            selectByMouse: true
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.minimumHeight: pbutton.height + 10 * 2

        color: "#242424"
        MButton {
            id: pbutton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10

            text: "Continue"
            onClicked: {
                columnLayout.finished()
            }
        }
    }
}
