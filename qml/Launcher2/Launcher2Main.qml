import QtQuick 2.9
import QtQuick.Layouts 1.3
import "ThemedControls"

RowLayout {
    anchors.fill: parent
    spacing: 0

    MSideBar {
        id: sidebar
        Layout.minimumWidth: 155

        MSideBarItem {
            text: qsTr("Home")
            iconSource: "qrc:/Resources/icon-home.png"
        }
        MSideBarItem {
            text: qsTr("News")
            iconSource: "qrc:/Resources/icon-news.png"
        }
        MSideBarItem {
            text: qsTr("Settings")
            iconSource: "qrc:/Resources/icon-settings.png"
        }
    }

    Rectangle {
        color: "#333333"
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.minimumHeight: 200
        Layout.minimumWidth: 400

        StackLayout {
            currentIndex: sidebar.currentIndex
            anchors.fill: parent

            Launcher2Home {}
            Launcher2News {}
            Launcher2Settings {}
        }
    }
}
