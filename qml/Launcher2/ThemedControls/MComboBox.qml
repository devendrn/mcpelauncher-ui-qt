import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Templates 2.1 as T
import QtQuick.Window 2.2

T.ComboBox {
    id: control

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: 36
    baselineOffset: contentItem.y + contentItem.baselineOffset
    leftPadding: 8
    rightPadding: 36

    background: Rectangle {
        border.color: control.hovered ? "#666" : "#555"
        color: "#1e1e1e"
    }

    contentItem: Text {
        id: textItem
        text: control.displayText
        font.pointSize: 11
        opacity: enabled ? 1.0 : 0.3
        color: "#fff"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    delegate: ItemDelegate {
        width: control.width
        contentItem: Text {
            text: modelData
            color: "#fff"
            font.pointSize: 11
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
        background: Rectangle {
            anchors.fill: parent
            color: parent.hovered ? "#333" : "#1e1e1e"
        }
    }

    indicator: Canvas {
        id: canvas
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        width: 13
        height: 6
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() {
                canvas.requestPaint()
            }
        }

        onPaint: {
            context.reset()
            context.lineWidth = 2
            context.strokeStyle = "#bbb"
            context.moveTo(0, 0)
            context.lineTo(width / 2, height)
            context.lineTo(width, 0)
            context.stroke()
        }
    }
    popup: T.Popup {
        y: control.height
        width: control.width
        height: Math.min(contentItem.implicitHeight + topPadding + bottomPadding, control.Window.height - topMargin - bottomMargin)
        topMargin: 6
        bottomMargin: 6
        padding: 4

        contentItem: ListView {
            ScrollBar.vertical: ScrollBar {}
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
        }

        background: Rectangle {
            color: "#1e1e1e"
            radius: 3
            border.color: "#555"
        }
    }
}
