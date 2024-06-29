import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "ThemedControls"
import io.mrarm.mcpelauncher 1.0

ColumnLayout {
    default property alias content: container.data
    property alias headerContent: baseHeader.content
    property bool hasUpdate: false
    property string updateDownloadUrl: ""
    property bool progressbarVisible: false
    property string progressbarText: ""
    property string warnMessage: ""
    property string warnUrl: ""
    property var setProgressbarValue: function (value) {
        downloadProgress.value = value
    }

    id: rowLayout
    spacing: 0

    BaseHeader {
        id: baseHeader
        Layout.fillWidth: true
        title: qsTr("Unofficial *nix launcher for Minecraft")
        subtitle: LAUNCHER_VERSION_NAME ? qsTr("%1 (build %2)").arg(LAUNCHER_VERSION_NAME).arg((LAUNCHER_VERSION_CODE || "Unknown").toString()) : ""
    }

    Rectangle {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: children[0].implicitHeight + 20
        color: hasUpdate && !(progressbarVisible || updateChecker.active) ? "#23a" : "#a22"
        visible: launcherSettings.showNotifications && (hasUpdate && !(progressbarVisible || updateChecker.active) || warnMessage.length > 0)
        Text {
            width: parent.width
            height: parent.height
            text: hasUpdate && !(progressbarVisible || updateChecker.active) ? qsTr("A new version of the launcher is available. Click to download the update.") : warnMessage
            color: "#fff"
            font.pointSize: 9
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: hasUpdate && !(progressbarVisible || updateChecker.active) || rowLayout.warnUrl.length > 0 ? Qt.PointingHandCursor : Qt.Pointer
            onClicked: {
                if (hasUpdate && !(progressbarVisible || updateChecker.active)) {
                    if (updateDownloadUrl.length == 0) {
                        updateCheckerConnectorBase.enabled = true
                        updateChecker.startUpdate()
                    } else {
                        Qt.openUrlExternally(updateDownloadUrl)
                    }
                } else if (rowLayout.warnUrl.length > 0) {
                    Qt.openUrlExternally(rowLayout.warnUrl)
                }
            }
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: children[0].implicitHeight + 20
        color: "#a72"
        visible: {
            if (!launcherSettings.showNotifications) {
                return false
            }
            for (var i = 0; i < GamepadManager.gamepads.length; i++) {
                if (!GamepadManager.gamepads[i].hasMapping) {
                    return true
                }
            }
            return false
        }

        Text {
            width: parent.width
            height: parent.height
            text: {
                var ret = []
                for (var i = 0; i < GamepadManager.gamepads.length; i++) {
                    if (!GamepadManager.gamepads[i].hasMapping) {
                        ret.push(GamepadManager.gamepads[i].name)
                    }
                }
                if (ret.length === 1) {
                    return qsTr("One Joystick can not be used as Gamepad Input: %1. Open Settings to configure it.").arg(ret.join(", "))
                }
                return qsTr("%1 Joysticks can not be used as Gamepad Input: %2. Open Settings to configure them.").arg(ret.length).arg(ret.join(", "))
            }
            color: "#fff"
            font.pointSize: 9
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    property string googleLoginError: ""

    Connections {
        target: playApiInstance

        onAppInfoReceived: function (app, det) {
            googleLoginError = ""
        }

        onInitError: function (err) {
            googleLoginError = qsTr("<b>Cannot initialize Google Play Access</b>, Details:<br/>%1").arg(err)
        }

        onAppInfoFailed: function (app, err) {
            googleLoginError = qsTr("<b>Cannot Access App Details</b> (%1), Details:<br/>%2").arg(app).arg(err)
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: children[0].implicitHeight + 20
        color: "#b62"
        visible: {
            if (!launcherSettings.showNotifications) {
                return false
            }
            return googleLoginError.length > 0 || playVerChannel.licenseStatus == 2
        }

        Text {
            width: parent.width
            height: parent.height
            text: {
                return (googleLoginError || playVerChannel.licenseStatus == 2 && qsTr("Access to the Google Play Apk Library has been rejected")) + qsTr("<br/>You can try this launcher for free by enabling the trial mode")
            }
            color: "#fff"
            font.pointSize: 9
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: children[0].implicitHeight + 20
        color: "#b62"
        visible: {
            if (!launcherSettings.showNotifications) {
                return false
            }
            return launcherSettings.trialMode
        }

        Text {
            width: parent.width
            height: parent.height
            text: {
                return qsTr("Disable Trial Mode to launch the full version") + (playVerChannel.licenseStatus == 4 ? qsTr(", you also have to buy the trial for free on an android device/vm to download it here") : "")
            }
            color: "#fff"
            font.pointSize: 9
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    /* utility functions */
    function launcherLatestVersionBase() {
        var abis = googleLoginHelper.getAbis(launcherSettings.showUnsupported)
        for (var i = 0; i < versionManager.archivalVersions.versions.length; i++) {
            var ver = versionManager.archivalVersions.versions[i]
            if (playVerChannel.latestVersionIsBeta && launcherSettings.showBetaVersions || !ver.isBeta) {
                for (var j = 0; j < abis.length; j++) {
                    if (ver.abi === abis[j]) {
                        return ver
                    }
                }
            }
        }
        if (abis.length == 0) {
            console.log("Unsupported Device")
        } else {
            console.log("Bug: No version")
        }
        return { versionName: "Invalid", versionCode: 0 }
    }

    Rectangle {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.preferredHeight: children[0].implicitHeight + 20
        color: "#b62"
        visible: {
            if (!launcherSettings.showNotifications) {
                return false
            }
            return launcherLatestVersionBase().versionCode > playVerChannelInstance.latestVersionCode
        }

        Text {
            width: parent.width
            height: parent.height
            text: {
                return qsTr("Google Play Version Channel is behind %1 expected %2").arg(playVerChannelInstance.latestVersion).arg(launcherLatestVersionBase().versionName)
            }
            color: "#fff"
            font.pointSize: 9
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
        }
    }

    ColumnLayout {
        id: container
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    MProgressBar {
        property bool showProgressbar: progressbarVisible || updateChecker.active
        Layout.fillWidth: true
        id: downloadProgress
        label: progressbarVisible ? progressbarText : qsTr("Please wait...")
        width: parent.width
        visible: showProgressbar || closeAnim.running
        indeterminate: value < 0.005

        states: State {
            name: "visible"
            when: downloadProgress.showProgressbar
        }

        transitions: [
            Transition {
                to: "visible"
                NumberAnimation {
                    target: downloadProgress
                    property: "Layout.preferredHeight"
                    to: 35
                    duration: 200
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: downloadProgress
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
            },
            Transition {
                id: closeAnim
                to: "*"
                NumberAnimation {
                    target: downloadProgress
                    property: "Layout.preferredHeight"
                    to: 0
                    duration: 200
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: downloadProgress
                    property: "opacity"
                    to: 0
                    duration: 100
                }
            }
        ]
    }

    MessageDialog {
        id: updateError
        title: "Update Error"
    }

    Connections {
        id: updateCheckerConnectorBase
        target: updateChecker
        enabled: false
        onUpdateError: function (error) {
            updateCheckerConnectorBase.enabled = false
            updateError.text = error
            updateError.open()
        }
        onProgress: downloadProgress.value = progress
    }
}
