import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.9
import "ThemedControls"

ScrollView {
    Layout.fillHeight: true
    Layout.fillWidth: true
    contentWidth: availableWidth

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width > 800 + 30 ? 800 : parent.width - 30
        spacing: 10

        MButton {
            text: qsTr("Add new profile")
            Layout.topMargin: 15
            onClicked: {
                profileEditWindow.reset()
                profileEditWindow.show()
            }
        }

        ListView {
            id: profileList

            property var profiles: profileManagerInstance.profiles
            Layout.fillWidth: true
            Layout.minimumHeight: profileList.contentHeight

            model: {
                var ret = []
                for (var i = 0; i < profiles.length; i++)
                    ret.push(profiles[i].name)
                return ret
            }

            delegate: ItemDelegate {
                id: control
                width: parent.width
                height: 60
                onClicked: profileList.currentIndex = index
                highlighted: ListView.isCurrentItem
                contentItem: Rectangle {
                    color: control.highlighted ? "#242" : (control.down ? "#252" : (control.hovered ? "#282828" : "#252525"))
                    anchors.fill: parent
                    RowLayout {
                        spacing: 10
                        anchors.fill: parent
                        anchors.margins: 10
                        Image {
                            source: "qrc:/Resources/icon-home.png"
                            height: 25
                            width: 25
                            Layout.rightMargin: 5
                        }

                        Text {
                            text: modelData
                            color: "#fff"
                            Layout.fillWidth: true
                        }

                        MButton {
                            text: qsTr("Edit")
                            Layout.alignment: Qt.AlignRight
                            visible: control.highlighted
                        }

                        MButton {
                            text: qsTr("Delete")
                            Layout.alignment: Qt.AlignRight
                            visible: control.highlighted
                        }
                    }
                }
            }

            focus: true
        }
    }

    EditProfileWindow {
        id: profileEditWindow
        // onClosing: profileComboBox.onAddProfileResult(profileEditWindow.profile)
        versionManager: versionManagerInstance
        profileManager: profileManagerInstance
        playVerChannel: playVerChannel
        modality: Qt.WindowModal
    }
}
