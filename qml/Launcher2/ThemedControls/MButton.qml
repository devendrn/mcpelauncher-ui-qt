import QtQuick 2.9
import QtQuick.Templates 2.1 as T

T.Button {
    id: control
    padding: 10
    height: 40
    implicitWidth: 12 + contentItem.implicitWidth + leftPadding + rightPadding
    opacity: enabled ? 1 : 0.3

    contentItem: Text {
        height: control.height
        text: control.text
        font.pointSize: 10
        color: "#fff"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        width: control.width
        height: control.height
        border.color: control.down ? "#888" : (control.hovered ? "#666" : "#555")
        color: control.down ? "#333" : "#1e1e1e"
        radius: 2
    }
}
