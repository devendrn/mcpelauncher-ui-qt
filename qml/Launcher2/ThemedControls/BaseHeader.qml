import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1

Rectangle {
    property string title
    property variant content: Item {}

    color: "#282828"
    Layout.fillWidth: true
    Layout.minimumHeight: contents.height

    ColumnLayout {
        id: contents
        spacing: 0

        Text {
            leftPadding: 20
            topPadding: 20
            text: title
            color: "#fff"
            font.bold: true
            font.capitalization: "AllUppercase"
            font.pointSize: 12
        }

        Control {
            Layout.fillWidth: true
            contentItem: content
        }
    }
}
