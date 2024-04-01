import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
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

    ScrollView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        contentWidth: availableWidth
        contentHeight: content.height + 30

        StackLayout {
            id: content
            currentIndex: tabs.currentIndex
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width > 800 + 30 ? 800 : parent.width - 30
            y: 15

            Launcher2SettingsGeneral {}
            Launcher2SettingsStorage {}
            Launcher2SettingsVersions {}
            Launcher2SettingsDev {}
            Launcher2SettingsAbout {}
        }
    }
}
