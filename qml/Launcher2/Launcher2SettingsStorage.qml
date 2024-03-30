import QtQuick 2.9
import QtQuick.Layouts 1.3
import "ThemedControls"

ColumnLayout {
    Layout.fillWidth: true
    Text {
        Layout.fillWidth: true
        text: qsTr("If qt5 fails to open the folder it doesn't report back: https://doc.qt.io/qt-5/qml-qtqml-qt.html#openUrlExternally-method")
        color: "#fff"
        font.pointSize: 10
        wrapMode: Text.WordWrap
    }

    GridLayout {
        Layout.fillWidth: true
        columns: (parent.width < 600) ? 2 : 4

        MButton {
            text: qsTr("Open Data Root")
            Layout.columnSpan: 1
            onClicked: Qt.openUrlExternally(window.getCurrentGameDataDir())
        }
        MButton {
            text: qsTr("Open Worlds")
            Layout.columnSpan: 1
            onClicked: Qt.openUrlExternally(
                           window.getCurrentGameDataDir(
                               ) + "/games/com.mojang/minecraftWorlds")
        }
        MButton {
            text: qsTr("Open Resource Packs")
            Layout.columnSpan: 1
            onClicked: Qt.openUrlExternally(
                           window.getCurrentGameDataDir(
                               ) + "/games/com.mojang/resource_packs")
        }
        MButton {
            text: qsTr("Open Behavior Packs")
            Layout.columnSpan: 1
            onClicked: Qt.openUrlExternally(
                           window.getCurrentGameDataDir(
                               ) + "/games/com.mojang/behavior_packs")
        }
    }
}
