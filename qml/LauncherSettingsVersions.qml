import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

ColumnLayout {
    width: parent.width
    spacing: 10
    Keys.forwardTo: versions
    id: layout

    Popup {
       id: downloadApk
       background: Rectangle {
           color: "#333"
       }
       height: layout.height
       width: layout.width
       modal: true
       clip: true


       Overlay.modal: Rectangle {
           id: popupOverlay
           color: "#8f181818"
       }
       ColumnLayout {
           id: scope

           MComboBox {
               id: versionBox
               property var codes: []
               model: {
                   var ret = []
                   var ncodes = []
                   for (var i = 0; i < versionManager.archivalVersions.versions.length; i++) {
                       var ver = versionManager.archivalVersions.versions[i]
                       if (playVerChannel.latestVersionIsBeta && launcherSettings.showBetaVersions || !ver.isBeta) {
                            ret.push(ver.versionName + " (" + ver.abi + ")")
                            ncodes.push(ver.versionCode)
                       }
                   }
                   codes = ncodes
                   return ret
               }
           }

           MCheckBox {
                id: isChromeOS
                text: qsTr("IsChromeOS")
                Layout.bottomMargin: 10
           }

           GoogleLoginHelper {
               id: manualgoogleLoginHelperInstance
               includeIncompatible: true
               singleArch: ""
               unlockkey: googleLoginHelperInstance.unlockkey
               chromeOS: isChromeOS.checked
           }

           GooglePlayApi {
               id: manualplayApi
               login: manualgoogleLoginHelperInstance

               onInitError: function (err) {
                   console.log("Failed " + err)
               }
           }

           property var apkUrls: ""

           GoogleApkDownloadTask {
               id: manualPlayDownloadTask
               playApi: manualplayApi
               packageName: "com.mojang.minecraftpe"
               keepApks: false
               dryrun: true
               versionCode: versionBox.codes[versionBox.currentIndex]
               onActiveChanged: {
               }
               onDownloadInfo: function (url) {
                   scope.apkUrls = url
               }
               onError: function (err) {
                   console.log(err)
               }
               onFinished: {
                   console.log("done")
               }
           }

            GoogleVersionChannel {
                id: manualplayVerChannelInstance
                playApi: manualplayApi
            }

           MButton {
               text: qsTr("Get Download Info")
               onClicked: manualPlayDownloadTask.start()
           }


           TextEdit {
               visible: scope.apkUrls && scope.apkUrls.length > 0
               text: "<style type=\"text/css\">a { color: lightblue; }</style>" +scope.apkUrls
               color: "white"
               textFormat: Text.RichText
               readOnly: true
               selectByMouse: true
               onLinkActivated: Qt.openUrlExternally(link)

               MouseArea {
                   anchors.fill: parent
                   cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                   acceptedButtons: Qt.NoButton
               }
           }
       }
    }

    Flow {
        Layout.fillWidth: true
        spacing: 10

        MButton {
            Layout.fillWidth: true
            text: qsTr("Delete selected")
            onClicked: {
                if (versions.currentIndex == -1)
                    return
                versionManager.removeVersion(versions.model[versions.currentIndex])
            }
        }

        MButton {
            Layout.fillWidth: true
            text: (googleLoginHelper.account !== null) ? qsTr("Download .apk") : "<s>" + qsTr("Download .apk") + "</s>"
            onClicked: downloadApk.open()
            enabled: (googleLoginHelper.account !== null)
        }

        MButton {
            Layout.fillWidth: true
            text: (googleLoginHelper.account !== null && playVerChannel.hasVerifiedLicense || !LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK) ? qsTr("Import .apk") : "<s>" + qsTr("Import .apk") + "</s>"
            onClicked: apkImportWindow.pickFile()
            enabled: (googleLoginHelper.account !== null && playVerChannel.hasVerifiedLicense || !LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK)
        }

        MButton {
            Layout.fillWidth: true
            text: qsTr("Remove Incompatible Versions")
            onClicked: {
                var abis = googleLoginHelper.getAbis(false)
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
                        versionManager.removeVersion(versions.model[i])
                    } else if (incompatible.length) {
                        versionManager.removeVersion(versions.model[i], incompatible)
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: Math.max(window.height - 180, 150)
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
                contentItem: Text {
                    text: modelData.versionName + " (" + modelData.archs.join(", ") + ")"
                    color: "#fff"
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: versions.currentIndex = index
                highlighted: ListView.isCurrentItem
                background: Rectangle {
                    color: control.highlighted ? "#226322" : (control.down ? "#338833" : (control.hovered ? "#222" : "transparent"))
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
