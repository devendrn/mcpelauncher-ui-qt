import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "ThemedControls"

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0
    BaseHeader {
        Layout.fillWidth: true
        title: qsTr("News")
        content: TabBar {
            id: tabs
            background: null
            anchors.fill: parent

            MTabButton {
                text: qsTr("Minecraft")
            }
        }
    }

    StackLayout {
        id: content
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabs.currentIndex
    }
}
