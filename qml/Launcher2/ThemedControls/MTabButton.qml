import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Templates 2.1 as T

T.TabButton {
    id: control
    padding: 15
    width: 12 + contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: 40
    anchors.bottom: parent.bottom

    background: Rectangle {
        color: "#9c6"
        width: 30
        height: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        visible: checked
    }

    contentItem: Text {
        id: textItem
        text: control.text
        font.pointSize: 11
        font.bold: checked
        opacity: enabled ? (checked ? 1.0 : 0.7) : 0.3
        color: "#fff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
