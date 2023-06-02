import QtQuick
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

ScrollView {
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true
    property GoogleVersionChannel playVerChannel
    id: ldevsettings
    GridLayout {
        columns: 2
        columnSpacing: 20
        rowSpacing: 8
        id: gridLayout12
        property int labelFontSize: 12
        Layout.fillWidth: true

        MCheckBox {
            text: qsTr("Show unverified versions")
            font.pointSize: parent.labelFontSize
            Layout.columnSpan: 2
            Component.onCompleted: checked = launcherSettings.showUnverified
            onCheckedChanged: launcherSettings.showUnverified = checked
        }

        MCheckBox {
            text: qsTr("Show incompatible versions")
            font.pointSize: parent.labelFontSize
            Layout.columnSpan: 2
            Component.onCompleted: checked = launcherSettings.showUnsupported
            onCheckedChanged: launcherSettings.showUnsupported = checked
        }

        MCheckBox {
            text: qsTr("Show Beta Versions")
            font.pointSize: parent.labelFontSize
            Layout.columnSpan: 2
            Component.onCompleted: checked = ldevsettings.playVerChannel.latestVersionIsBeta && launcherSettings.showBetaVersions
            onCheckedChanged: launcherSettings.showBetaVersions = checked
            enabled: ldevsettings.playVerChannel.latestVersionIsBeta
        }

        MComboBox {
            Layout.columnSpan: 2

            id: profileTexturePatch
            Layout.fillWidth: true

            textRole: "name"
            model: ListModel {                
                ListElement {
                    name: ""
                }

                ListElement {
                    name: "armeabi-v7a"
                }

                ListElement {
                    name: "arm64-v8a"
                }

                ListElement {
                    name: "x86"
                }

                ListElement {
                    name: "x86_64"
                }
            }

            Component.onCompleted: {
                console.log("launcherSettings.singleArch " + launcherSettings.singleArch);
                for(var i = 0; i < model.count; i++) {
                    if(launcherSettings.singleArch == model.get(i).name) {
                        currentIndex = i;
                        break;
                    }
                }
            }

            onActivated: {
                console.log("onActivated");
                console.log(currentValue);
                launcherSettings.singleArch = currentValue;
            }
        }

        Text {
            text: qsTr("Versions feed base url")
            font.pointSize: parent.labelFontSize
            Layout.columnSpan: 1
        }
        MTextField {
            id: versionsFeedBaseUrl
            Layout.columnSpan: 1
            Layout.fillWidth: true
            Component.onCompleted: versionsFeedBaseUrl.text = launcherSettings.versionsFeedBaseUrl
            onEditingFinished: {
                launcherSettings.versionsFeedBaseUrl = versionsFeedBaseUrl.text;
                versionManagerInstance.downloadLists(googleLoginHelperInstance.getAbis(true), launcherSettings.versionsFeedBaseUrl);
            }
        }

        MCheckBox {
            text: qsTr("Download only the apk")
            font.pointSize: parent.labelFontSize
            Layout.columnSpan: 2
            Component.onCompleted: checked = launcherSettings.downloadOnly
            onCheckedChanged: launcherSettings.downloadOnly = checked
        }
    }
}
