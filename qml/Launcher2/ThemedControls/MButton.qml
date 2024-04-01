import QtQuick 2.9
import QtQuick.Templates 2.1 as T

T.Button {
    id: control

    padding: 10
    width: 12 + contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: 40

    contentItem: Text {
        text: control.text
        padding: 8
        font.pointSize: 10
        opacity: enabled ? 1.0 : 0.3
        color: "#fff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30
        opacity: enabled ? 1 : 0.3
        border.color: control.down ? "#888" : (control.hovered ? "#666" : "#555")
        color: control.down ? "#333" : "#1e1e1e"
        border.width: 1
        radius: 2
    }
}
