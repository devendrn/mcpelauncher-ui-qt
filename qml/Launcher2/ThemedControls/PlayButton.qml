import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Templates 2.1 as T

T.Button {
    id: control
    property string subText: ""

    // implicitWidth: 10 / 9 * contentItem.implicitWidth + leftPadding + rightPadding
    // implicitHeight: 10 / 9 * contentItem.implicitHeight + topPadding + bottomPadding
    implicitHeight: contentItem.implicitHeight + 25
    implicitWidth: contentItem.implicitWidth + 30 < 200 ? 200 : contentItem + 30

    // baselineOffset: contentItem.y + contentItem.baselineOffset
    background: BorderImage {
        id: buttonBackground
        source: "qrc:/Resources/green-button-new.png"
        smooth: false
        border {
            left: 8
            top: 8
            right: 8
            bottom: 8
        }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    contentItem: Item {
        implicitWidth: content.implicitWidth
        implicitHeight: content.implicitHeight
        ColumnLayout {
            id: content
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                id: textItem
                text: control.text
                font.pointSize: 16
                font.bold: true
                opacity: enabled ? 1.0 : 0.3
                color: "#fff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                id: subTextItem
                visible: control.subText.length > 0
                text: control.subText
                font.pointSize: 9
                opacity: enabled ? 1.0 : 0.3
                color: "#fff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    states: [
        State {
            name: "normal"
            when: !(control.hovered || control.activeFocus)
        },
        State {
            name: "hovered"
            when: (control.hovered || control.activeFocus)
            PropertyChanges {
                target: buttonBackground
                scale: 1.0
            }
            // PropertyChanges { target: buttonBackgroundOverlay
            //     opacity: 1
            // }
        }
    ]

    transitions: [
        Transition {
            from: "normal"
            to: "hovered"
            PropertyAnimation {
                target: buttonBackground
                property: "scale"
                duration: 100
                easing.type: Easing.InSine
            }
            // PropertyAnimation {
            //     target: buttonBackgroundOverlay
            //     property: "opacity"
            //     duration: 100
            //     easing.type: Easing.InSine
            // }
        },
        Transition {
            from: "hovered"
            to: "normal"
            PropertyAnimation {
                target: buttonBackground
                property: "scale"
                duration: 100
                easing.type: Easing.OutSine
            }
            // PropertyAnimation {
            //     target: buttonBackgroundOverlay
            //     property: "opacity"
            //     duration: 100
            //     easing.type: Easing.OutSine
            // }
        }
    ]
}
