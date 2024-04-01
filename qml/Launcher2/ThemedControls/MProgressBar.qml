import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Templates 2.1 as T
import QtQuick.Window 2.3

T.ProgressBar {
    id: control
    property string label: ""
    padding: 2

    // implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    // implicitHeight: 28
    // baselineOffset: contentItem.y + contentItem.baselineOffset
    background: Rectangle {
        implicitWidth: 200
        anchors.fill: parent
        implicitHeight: 6
        color: "#1e1e1e"
    }

    contentItem: Item {
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "#008643"
        }

        Text {
            text: control.label
            color: "#fff"
            font.pointSize: 10
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
