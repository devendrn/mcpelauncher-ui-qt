import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "ThemedControls"

ColumnLayout {
    spacing: 0

    BaseHeader {
        title: qsTr("Settings")
        content: TabBar {
            id: tabs
            background: null
            anchors.fill: parent

            MTabButton {
                text: qsTr("General")
            }
            MTabButton {
                text: qsTr("Storage")
            }
            MTabButton {
                text: qsTr("Versions")
            }
            MTabButton {
                text: qsTr("Dev")
            }
            MTabButton {
                text: qsTr("About")
            }
        }
    }

    StackLayout {
        id: content
        currentIndex: tabs.currentIndex
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.maximumWidth: 900
        Layout.margins: 15

        Launcher2SettingsGeneral {}
        Launcher2SettingsStorage {}
        // LauncherSettingsVersions {}
        // LauncherSettingsDev {}
        // LauncherSettingsAbout {}
        // Keys.forwardTo: children[tabs.currentIndex]
    }
}
