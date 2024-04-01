import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import "ThemedControls"
import "../"

ColumnLayout {
    Layout.fillWidth: true
    spacing: 10

    Flow {
        spacing: 10
        MButton {
            text: qsTr("Delete selected")
            onClicked: {
                if (versions.currentIndex == -1)
                    return
                versionManagerInstance.removeVersion(versions.model[versions.currentIndex])
            }
        }

        MButton {
            property bool enableApkImport: googleLoginHelperInstance.account !== null && playVerChannel.hasVerifiedLicense || !LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK
            text: enableApkImport ? qsTr("Import .apk") : qsTr("<s>Import .apk</s> ( Unable to validate ownership )")
            onClicked: apkImportWindow.pickFile()
            enabled: enableApkImport
        }

        MButton {
            text: qsTr("Remove Incompatible Versions")
            onClicked: {
                var abis = googleLoginHelperInstance.getAbis(false)
                for (var i = 0; i < versions.model.length; ++i) {
                    var foundcompatible = false
                    var incompatible = []
                    for (var j = 0; j < versions.model[i].archs.length; ++j) {
                        var found = false
                        for (var k = 0; k < abis.length; ++k) {
                            if (found = versions.model[i].archs[j] === abis[k]) {
                                break
                            }
                        }
                        if (!found) {
                            incompatible.push(versions.model[i].archs[j])
                        } else {
                            foundcompatible = true
                        }
                    }
                    if (!foundcompatible) {
                        versionManagerInstance.removeVersion(versions.model[i])
                    } else if (incompatible.length) {
                        versionManagerInstance.removeVersion(versions.model[i], incompatible)
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "#1e1e1e"

        ListView {
            id: versions
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            flickableDirection: Flickable.VerticalFlick
            model: versionManagerInstance.versions.getAll().sort(function (a, b) {
                return b.versionCode - a.versionCode
            })
            delegate: ItemDelegate {
                id: control
                width: parent.width
                height: 32
                font.pointSize: 11
                text: modelData.versionName + " (" + modelData.archs.join(", ") + ")"
                onClicked: versions.currentIndex = index
                highlighted: ListView.isCurrentItem
                background: Rectangle {
                    color: control.highlighted ? "#226322" : (control.down ? "#338833" : "transparent")
                }
            }
            highlightResizeVelocity: -1
            highlightMoveVelocity: -1
            currentIndex: -1
            ScrollBar.vertical: ScrollBar {}
        }
    }

    ApkImportWindow {
        id: apkImportWindow
        versionManager: versionManagerInstance
        allowIncompatible: launcherSettings.showUnsupported
    }
}
