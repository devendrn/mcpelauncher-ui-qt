import QtQuick 2.9
import QtQuick.Layouts 1.2
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

ColumnLayout {
    id: columnlayout
    width: parent.width
    spacing: 10

    TextEdit {
        Layout.fillWidth: true
        text: qsTr("If Qt6 fails to open the folder it doesn't report back") + ": https://doc.qt.io/qt-6/qml-qtqml-qt.html#openUrlExternally-method"
        color: "#fff"
        font.pointSize: 10
        readOnly: true
        wrapMode: Text.WordWrap
        selectByMouse: true
    }

    HorizontalDivider {}

    Text {
        Layout.fillWidth: true
        text: qsTr("Game Directories")
        font.bold: true
        font.pointSize: 10
        color: "#fff"
    }

    GridLayout {
        Layout.fillWidth: true
        columns: parent.width < 600 ? 2 : 4

        MButton {
            text: qsTr("Open Data Root")
            Layout.fillWidth: true
            onClicked: Qt.openUrlExternally(window.getCurrentGameDataDir())
        }
        MButton {
            text: qsTr("Open Worlds")
            Layout.fillWidth: true
            onClicked: Qt.openUrlExternally(window.getCurrentGameDataDir() + "/games/com.mojang/minecraftWorlds")
        }
        MButton {
            text: qsTr("Open Resource Packs")
            Layout.fillWidth: true
            onClicked: Qt.openUrlExternally(window.getCurrentGameDataDir() + "/games/com.mojang/resource_packs")
        }
        MButton {
            text: qsTr("Open Behavior Packs")
            Layout.fillWidth: true
            onClicked: Qt.openUrlExternally(window.getCurrentGameDataDir() + "/games/com.mojang/behavior_packs")
        }
    }

    Flickable {
        id: flick

        Layout.fillWidth: true; height: 100;
        contentWidth: edit.contentWidth
        contentHeight: edit.contentHeight
        clip: true

        function ensureVisible(r)
        {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }

        TextEdit {
            id: edit
            focus: true
            wrapMode: TextEdit.Wrap
            onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
            text: qsTr("Data Root: %1\nWorlds: %2\nResource Packs: %3\nBehavior Packs: %4").arg(QmlUrlUtils.urlToLocalFile(window.getCurrentGameDataDir())).arg("games/com.mojang/minecraftWorlds").arg("games/com.mojang/resource_packs").arg("games/com.mojang/behavior_packs")
            color: "white"
            readOnly: true
            selectByMouse: true
        }
    }
}
