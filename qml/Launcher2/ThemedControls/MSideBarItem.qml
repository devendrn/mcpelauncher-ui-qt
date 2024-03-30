import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Templates 2.1 as T

T.TabButton {
    id: control
    property string iconSource

    implicitHeight: 50
    width: contentItem.width
    baselineOffset: contentItem.y + contentItem.baselineOffset

    background: Rectangle {
        color: "#9c6"
        width: 3
        height: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        visible: checked
    }

    contentItem: RowLayout {
        spacing: 15

        Image {
            width: 30
            source: iconSource
            smooth: false
            fillMode: Image.PreserveAspectFit
            Layout.leftMargin: 18
        }

        Text {
            color: "#fff"
            text: control.text
            font.pointSize: 11
            font.bold: checked
            verticalAlignment: Text.AlignVCenter
            Layout.fillHeight: true
            Layout.rightMargin: 40
        }
    }
}
