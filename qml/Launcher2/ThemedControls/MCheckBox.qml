import QtQuick 2.9
import QtQuick.Templates 2.1 as T

T.CheckBox {
    id: control

    padding: 8
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: Math.max(contentItem.implicitHeight,
                             indicator.implicitHeight)
    baselineOffset: contentItem.y + contentItem.baselineOffset
    font.pointSize: 11

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        color: "#1e1e1e"
        border.color: control.down ? "#888" : (control.hovered ? "#666" : "#555")

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 10
            height: 10
            radius: 2
            color: "#50a060"
            visible: control.checked
        }
    }

    contentItem: Text {
        id: textItem
        text: control.text
        font.pointSize: 10
        opacity: enabled ? 1.0 : 0.3
        color: "#fff"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        leftPadding: 32
    }
}
