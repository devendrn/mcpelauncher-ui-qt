import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import io.mrarm.mcpelauncher 1.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Linux Minecraft Launcher")
    color: "#333333"
    property bool hasUpdate: false
    property bool hasAskedForKey: false
    property string updateDownloadUrl: ""
    property bool isVersionsInitialized: false
    property string currentGameDataDir: ""

    StackView {
        id: stackView
        anchors.fill: parent
    }

    GoogleLoginHelper {
        id: googleLoginHelperInstance
        includeIncompatible: launcherSettings.showUnsupported
        singleArch: launcherSettings.singleArch
        chromeOS: launcherSettings.chromeOSMode || launcherSettings.trialMode
    }

    VersionManager {
        id: versionManagerInstance
    }

    ProfileManager {
        id: profileManagerInstance
    }

    Component {
        id: panelLogin

        LauncherLogin {
            googleLoginHelper: googleLoginHelperInstance
            versionManager: versionManagerInstance
            onFinished: stackView.replace(panelMain)
        }
    }

    GooglePlayApi {
        id: playApi
        login: googleLoginHelperInstance

        property string googleLoginError: ""

        onAppInfoReceived: function (app, det) {
            playApi.googleLoginError = ""
        }

        onInitError: function (err) {
            playApi.googleLoginError = qsTr("<b>Cannot initialize Google Play Access</b>, Details:<br/>%1").arg(err)
        }

        onAppInfoFailed: function (app, err) {
            playApi.googleLoginError = qsTr("<b>Cannot Access App Details</b> (%1), Details:<br/>%2").arg(app).arg(err)
        }
    }

    GoogleVersionChannel {
        id: playVerChannelInstance
        playApi: playApi
        trialMode: launcherSettings.trialMode
    }

    Component {
        id: panelMain

        Launcher {}
    }

    Component {
        id: panelError

        LauncherUnsupported {
            googleLoginHelper: googleLoginHelperInstance
            onFinished: {
                if (needsToLogIn()) {
                    stackView.push(panelLogin)
                } else {
                    stackView.push(panelMain)
                }
            }
            hasUpdate: window.hasUpdate
            updateDownloadUrl: window.updateDownloadUrl
        }
    }

    Component {
        id: panelUnlock

        LauncherUnlock {
            onFinished: {
                next()
            }
        }
    }


    Component {
        id: panelChangelog

        LauncherChangeLog {
            onFinished: {
                launcherSettings.lastVersion = LAUNCHER_VERSION_CODE
                next()
            }
            hasUpdate: window.hasUpdate
            updateDownloadUrl: window.updateDownloadUrl
        }
    }

    LauncherSettings {
        id: launcherSettings
    }

    MessageDialog {
        id: playDownloadError
        title: qsTr("Connecting to Google Play failed")
    }

    MessageDialog {
        id: errorDialog
        title: qsTr("Launcher Error")
    }

    TroubleshooterWindow {
        id: troubleshooterWindow
        googleLoginHelper: googleLoginHelperInstance
        playVerChannel: playVerChannelInstance
    }

    GoogleTosApprovalWindow {
        id: googleTosApprovalWindow

        onDone: playApi.setTosApproved(approved, marketing)
    }

    MessageDialog {
        id: corruptedInstallDialog
        title: qsTr("Unsupported Minecraft Version")
        text: qsTr("The Minecraft Version you are trying to run is unsupported.<br/><b>if you wanted to play a new Release please wait patiently for an update,<br/>please choose a compatible version from the profile Editor</b>")
    }



    GameLauncher {
        id: gameLauncher

        property var pendingFiles: []

        onLaunchFailed: {
            exited()
            showLaunchError(qsTr("Could not execute the game launcher. Please make sure it's dependencies are properly installed.<br><a href=\"%1\">Click here for more information Linux</a>").arg("https://github.com/minecraft-linux/mcpelauncher-manifest/issues/796"))
        }
        onStateChanged: {
            if (!running) {
                exited()
            }
            if (crashed) {
                application.setVisibleInDock(true)
            }
            importFiles()
        }
        onFileStarted: {
            importFiles()
        }

        onCorruptedInstall: {
            corruptedInstallDialog.open()
        }
        function exited() {
            application.setVisibleInDock(true)
            window.show()
        }
        function importFiles() {
            if (running) {
                if(pendingFiles.length > 0) {
                    var file = pendingFiles.shift()
                    startFile(file)
                }
            }
        }
    }

    MessageDialog {
        id: closeRunningDialog
        title: qsTr("Game is running")
        text: qsTr("Minecraft is currently running. Would you like to forcibly close it?\nHint: Press ignore to just close the Launcher UI")
        standardButtons: StandardButton.Ignore | StandardButton.Yes | StandardButton.No
        modality: Qt.ApplicationModal

        onYes: {
            gameLauncher.kill()
            application.quit()
        }

        onAccepted: {
            if(window.visible) {
                window.hide();
            }
        }
    }

    MessageDialog {
        id: restartDialog
        title: qsTr("Please restart")
        text: qsTr("Update finished, please restart the AppImage")
    }

    UpdateChecker {
        id: updateChecker

        onUpdateAvailable: {
            window.hasUpdate = true
            window.updateDownloadUrl = downloadUrl
        }
        onRequestRestart: {
            restartDialog.open()
        }
    }

    Connections {
        target: googleLoginHelperInstance
        onLoginError: function (err) {
            playDownloadError.text = qsTr("The Launcher failed to sign you in\nPlease login again\n%1").arg(err)
            playDownloadError.open()
        }
    }

    Connections {
        target: window
        onClosing: {
            if (true) {
                if (gameLauncher.running) {
                    close.accepted = false
                    closeRunningDialog.open()
                } else {
                    application.quit()
                }
            }
        }
    }

    function needsToLogIn() {
        return googleLoginHelperInstance.account == null && !googleLoginHelperInstance.hasEncryptedCredentials && versionManagerInstance.versions.size === 0
    }

    Component.onCompleted: {
        if (launcherSettings.checkForUpdates) {
            updateChecker.checkForUpdates()
        }
        versionManagerInstance.archivalVersions.versionsChanged.connect(function () {
            isVersionsInitialized = true
            console.log("Versionslist initialized")
        })
        versionManagerInstance.downloadLists(googleLoginHelperInstance.getAbis(true), launcherSettings.versionsFeedBaseUrl)
        if (LAUNCHER_CHANGE_LOG.length !== 0 && launcherSettings.lastVersion < LAUNCHER_VERSION_CODE) {
            stackView.push(panelChangelog)
        } else {
            next()
        }
    }

    function next() {
        if (!googleLoginHelperInstance.isSupported()) {
            stackView.push(panelError)
        } else if(googleLoginHelperInstance.hasEncryptedCredentials && !hasAskedForKey) {
            hasAskedForKey = true
            stackView.push(panelUnlock)
        } else {
            defaultnext()
        }
    }

    function defaultnext() {
        if (needsToLogIn()) {
            stackView.push(panelLogin)
        } else {
            stackView.push(panelMain)
        }
    }

    function showLaunchError(message) {
        errorDialog.text = message
        errorDialog.open()
    }

    function getCurrentGameDataDir() {
        if (window.currentGameDataDir && window.currentGameDataDir.length > 0) {
            return window.currentGameDataDir
        }
        return launcherSettings.gameDataDir
    }
}
