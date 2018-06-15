import QtQuick 2.0
import QtQuick.Layouts 1.11
import QtQuick.Window 2.3
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

Item {
    id: root

    property GoogleLoginHelper googleLoginHelper
    property bool acquiringAccount: false

    signal finished()

    Image {
        anchors.fill: parent
        smooth: false
        fillMode: Image.Tile
        source: "Resources/noise.png"
    }

    Rectangle {
        property real xPadding: 5
        property real yPadding: 20
        id: rectangle
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        width: Math.min(500, parent.width)
        height: childrenRect.height + yPadding * 2
        radius: 4

        ColumnLayout {
            id: container
            x: rectangle.xPadding
            y: rectangle.yPadding
            width: parent.width - rectangle.xPadding * 2
            spacing: 0

            Text {
                text: "Sign in"
                font.pointSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.topMargin: 4
            }

            Text {
                text: "To use this launcher, you must purchase Minecraft on Google Play and sign in."
                wrapMode: Text.WordWrap
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.topMargin: 16
            }

            PlayButton {
                text: "Sign in with Google"
                leftPadding: 50
                rightPadding: 50
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 22
                onClicked: function() {
                    acquiringAccount = true
                    googleLoginHelper.acquireAccount(window)
                }
            }

            RowLayout {
                id: alternativeOptions

                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                spacing: 25

                property int buttonWidth: Math.max(children[0].implicitWidth, children[1].implicitWidth)

                TransparentButton {
                    text: "Use .apk".toUpperCase()
                    textColor: "#0aa82f"
                    Layout.preferredWidth: alternativeOptions.buttonWidth
                    font.pointSize: 12
                    onClicked: root.finished()
                }

                TransparentButton {
                    text: "Get help".toUpperCase()
                    textColor: "#0aa82f"
                    Layout.preferredWidth: alternativeOptions.buttonWidth
                    font.pointSize: 12
                    onClicked: Qt.openUrlExternally("https://github.com/minecraft-linux/")
                }

            }

        }
    }

    Text {
        text: "This is an unofficial Linux launcher for the Minecraft Bedrock codebase.\nThis project is not affiliated with Minecraft, Mojang or Microsoft."
        color: "#fff"
        y: parent.height - height - 10
        width: parent.width
        wrapMode: Text.WordWrap
        font.pointSize: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.2
        visible: acquiringAccount

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Connections {
        target: googleLoginHelper
        onAccountAcquireFinished: function(acc) {
            acquiringAccount = false;
            console.log(acc);
        }
    }

}
