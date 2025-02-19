import QtQuick
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.platform
import Qt.labs.folderlistmodel
import "Components"
import io.mrarm.mcpelauncher 1.0

BaseScreen {
    id: rowLayout

    property GoogleLoginHelper googleLoginHelper
    property VersionManager versionManager
    property ProfileManager profileManager
    property GooglePlayApi playApiInstance
    property GoogleVersionChannel playVerChannel

    property bool isVersionsInitialized: false
    property bool progressbarVisible: playDownloadTask.active || apkExtractionTask.active
    property bool hasUpdate: false
    property string updateDownloadUrl: ""
    property string warnMessage: ""
    property string warnUrl: ""
    property var setProgressbarValue: function (value) {
        downloadProgress.value = value
    }

    headerContent: TabBar {
        background: null
        MTabButton {
            text: qsTr("Play")
        }
    }

    Image {
        Layout.fillWidth: true
        Layout.fillHeight: true
        id: backgroundArt
        source: wallpaperFolderModel.getRandomImage()
        smooth: true
        fillMode: Image.PreserveAspectCrop

        FolderListModel {
            id: wallpaperFolderModel
            nameFilters: ["*.jpg", "*.jpeg", "*.png"]
            folder: launcherSettings.gameDataDir + "/background_art"
            showDirs: false
            showOnlyReadable: true

            function getRandomImage() {
                if (count > 0) {
                    return "file://" + get(Math.random() * count, "filePath")
                }
                return "qrc:/Resources/noise.png"
            }
        }

        Flickable {
            height: Math.min(parent.height, contentHeight)
            width: Math.min(parent.width - 30, 640)
            contentWidth: width
            contentHeight: notifyColumn.height
            x: (parent.width - width) / 2
            visible: launcherSettings.showNotifications

            Column {
                id: notifyColumn
                width: parent.width
                spacing: 10
                topPadding: 15
                bottomPadding: 15

                NotifyBanner {
                    color: "#832"
                    title: qsTr("Warning")
                    description: warnMessage
                    actionText: rowLayout.warnUrl ? qsTr("See Wiki") : ""
                    visible: warnMessage
                    dismissable: false
                    onClicked: {
                        Qt.openUrlExternally(rowLayout.warnUrl)
                    }
                }

                NotifyBanner {
                    color: "#444"
                    title: qsTr("Unconfigured Joysticks Found")
                    description: {
                        const ret = GamepadManager.gamepads.filter(gamepad => !gamepad.hasMapping).map(gamepad => gamepad.name)
                        if (ret.length === 1)
                            return qsTr("One Joystick cannot be used as Gamepad Input:\n%1.").arg(ret.join(", "))
                        return qsTr("%1 Joysticks cannot be used as Gamepad Input:\n%2.").arg(ret.length).arg(ret.join(", "))
                    }
                    actionText: "Configure"
                    visible: GamepadManager.gamepads.some(gamepad => !gamepad.hasMapping)
                    onClicked: gamepadTool.show()
                }

                NotifyBanner {
                    color: "#652"
                    visible: launcherSettings.trialMode
                    dismissable: false
                    title: qsTr("Trial Mode Enabled")
                    description: {
                        const msg = qsTr("Disable trial mode from settings to launch the full version instead. ")
                        return playVerChannel.licenseStatus == 4 ? qsTr("You must first buy \"Minecraft Trial\" on an Android device or VM to download it here. ") + msg : msg
                    }
                }

                NotifyBanner {
                    color: "#832"
                    title: qsTr("Play Version is behind")
                    description: qsTr("Google Play Version Channel is behind. Got %1. Expected %2.").arg(playVerChannelInstance.latestVersion).arg(launcherLatestVersionBase().versionName)
                    visible: (googleLoginHelper.account !== null) && launcherLatestVersionBase().versionCode > playVerChannelInstance.latestVersionCode
                }

                NotifyBanner {
                    visible: hasUpdate && !(progressbarVisible || updateChecker.active)
                    title: qsTr("Update available")
                    description: qsTr("A new version of the launcher is available.")
                    actionText: qsTr("Download")
                    onClicked: {
                        if (updateDownloadUrl.length == 0) {
                            updateCheckerConnectorBase.enabled = true
                            updateChecker.startUpdate()
                        } else {
                            Qt.openUrlExternally(updateDownloadUrl)
                        }
                    }
                }

                NotifyBanner {
                    color: "#832"
                    dismissable: false
                    title: qsTr("Error")
                    visible: playApiInstance.googleLoginError.length > 0 || playVerChannel.licenseStatus == 2
                    description: {
                        var msg = playApiInstance.googleLoginError || playVerChannel.licenseStatus == 2 && qsTr("Access to the Google Play Apk Library has been rejected.")
                        if (!launcherSettings.trialMode && (playVerChannel.licenseStatus == 2))
                            msg += qsTr("\nYou can try this launcher for free by enabling the trial mode.")
                        return msg
                    }
                }
            }
        }
    }

    ProfileEditPopup {
        id: profileEditPopup
        onAboutToHide: profileComboBox.onAddProfileResult(profileEditPopup.profile)
        versionManager: rowLayout.versionManager
        profileManager: rowLayout.profileManager
        playVerChannel: rowLayout.playVerChannel
    }

    Rectangle {
        color: '#282828'
        Layout.fillWidth: true
        height: 66

        RowLayout {
            spacing: -1
            anchors.verticalCenter: parent.verticalCenter
            height: 44
            x: 10

            ProfileComboBox {
                property bool loaded: false
                id: profileComboBox
                Layout.preferredWidth: 170
                Layout.fillHeight: true
                onAddProfileSelected: {
                    profileEditPopup.reset()
                    profileEditPopup.open()
                }
                Component.onCompleted: {
                    setProfile(profileManager.activeProfile)
                    window.currentGameDataDir = Qt.binding(function () {
                        return (profileManager.activeProfile && profileManager.activeProfile.dataDirCustom) ? QmlUrlUtils.localFileToUrl(profileManager.activeProfile.dataDir) : ""
                    })
                    loaded = true
                }
                onCurrentProfileChanged: {
                    if (loaded && currentProfile !== null) {
                        profileManager.activeProfile = currentProfile
                    }
                }

                enabled: !(playDownloadTask.active || apkExtractionTask.active || gameLauncher.running)
            }

            MButton {
                Layout.preferredHeight: parent.height
                Layout.preferredWidth: parent.height
                z: hovered ? 1 : -1
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/Resources/icon-edit.svg"
                    height: 24
                    width: 24
                    opacity: enabled ? 1.0 : 0.3
                }
                enabled: !(playDownloadTask.active || apkExtractionTask.active || gameLauncher.running)
                onClicked: {
                    profileEditPopup.setProfile(profileComboBox.getProfile())
                    profileEditPopup.open()
                }
            }
        }

        PlayButton {
            id: pbutton
            x: parent.width > 700 ? (parent.width - width) / 2 : (parent.width - width - 12)
            y: 54 - height
            width: Math.min(Math.max(Math.max(implicitWidth, 230), rowLayout.width / 4), 320)
            Layout.alignment: Qt.AlignHCenter

            property bool canDownload: googleLoginHelper.account !== null && playVerChannel.licenseStatus == 3
            property bool statusChecking: !isVersionsInitialized || playVerChannel.licenseStatus === 0 || playVerChannel.licenseStatus === 1
            property string displayedVersionName: getDisplayedVersionName()

            text: {
                if (statusChecking)
                    return ""

                if (gameLauncher.running)
                    return qsTr("Game is running").toUpperCase()

                if (googleLoginHelper.account === null)
                    return qsTr("Sign in").toUpperCase()

                if (!playVerChannel.hasVerifiedLicense && LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK && !launcherSettings.trialMode)
                    return qsTr("Ask Google Again").toUpperCase()

                if (!displayedVersionName)
                    return ""

                if (!checkSupport())
                    return qsTr("Unsupported Version").toUpperCase()

                if (needsDownload()) {
                    if (profileManager.activeProfile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY && googleLoginHelper.hideLatest)
                        return qsTr("Please sign in again").toUpperCase()
                    return qsTr("Download and play").toUpperCase()
                }

                return qsTr("Play").toUpperCase()
            }

            subText: {
                if (statusChecking)
                    return ""

                if (displayedVersionName)
                    return "Minecraft " + displayedVersionName

                if (googleLoginHelper.account === null || (needsDownload() && profileManager.activeProfile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY && googleLoginHelper.hideLatest))
                    return ""

                return qsTr("Please wait")
            }

            enabled: !(gameLauncher.running || statusChecking || playDownloadTask.active || apkExtractionTask.active || updateChecker.active || !checkSupport() || !displayedVersionName)

            onClicked: {
                if ((!playVerChannel.hasVerifiedLicense || (!canDownload && needsDownload())) && LAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK) {
                    if (googleLoginHelper.account !== null) {
                        playVerChannel.playApi = playApiInstance
                    } else {
                        googleLoginHelper.acquireAccount(window)
                    }
                } else if (needsDownload()) {
                    playDownloadTask.versionCode = getDownloadVersionCode()
                    if (playDownloadTask.versionCode === 0)
                        return

                    setProgressbarValue(0)
                    const rawname = getRawVersionsName()
                    const partialDownload = !needsFullDownload(rawname)
                    if (partialDownload)
                        apkExtractionTask.versionName = rawname

                    playDownloadTask.start(partialDownload)
                } else {
                    launchGame()
                }
            }
        }
    }

    MProgressBar {
        id: downloadProgress
        property bool showProgressbar: progressbarVisible || updateChecker.active
        Layout.fillWidth: true
        label: {
            if (playDownloadTask.active)
                return qsTr("Downloading Minecraft...")
            if (apkExtractionTask.active)
                return qsTr("Extracting Minecraft...")
            return qsTr("Please wait...")
        }
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

    GoogleApkDownloadTask {
        id: playDownloadTask
        playApi: playApiInstance
        packageName: launcherSettings.trialMode ? "com.mojang.minecrafttrialpe" : "com.mojang.minecraftpe"
        keepApks: launcherSettings.downloadOnly || launcherSettings.keepApks
        onProgress: setProgressbarValue(progress)
        onError: function (err) {
            if (playDownloadError.visible) {
                playDownloadError.text += "\n" + err
            } else {
                playDownloadError.text = err
                playDownloadError.open()
            }
        }
        onFinished: {
            if (!launcherSettings.downloadOnly) {
                apkExtractionTask.sources = filePaths
                apkExtractionTask.start()
            }
        }
    }

    MessageDialog {
        id: playDownloadError
        title: qsTr("Download failed")
    }

    ApkExtractionTask {
        id: apkExtractionTask
        versionManager: rowLayout.versionManager
        onProgress: setProgressbarValue(progress)
        allowIncompatible: launcherSettings.showUnsupported
        onError: function (err) {
            playDownloadError.text = qsTr("Error while extracting the downloaded file(s), <a href=\"https://github.com/minecraft-linux/mcpelauncher-ui-manifest/issues\">please report this error</a>: %1").arg(err)
            playDownloadError.open()
        }
        onFinished: launchGame()
        allowedPackages: {
            var packages = ["com.mojang.minecrafttrialpe", "com.mojang.minecraftedu"]
            if (!launcherSettings.trialMode)
                packages.push("com.mojang.minecraftpe")
            return packages
        }
    }

    MessageDialog {
        id: updateError
        title: "Update Error"
    }

    Connections {
        id: updateCheckerConnectorBase
        target: updateChecker
        enabled: false
        function onUpdateError(error) {
            updateCheckerConnectorBase.enabled = false
            updateError.text = error
            updateError.open()
        }
        function onProgress() {
            downloadProgress.value = progress
        }
    }

    /* utility functions */
    function launcherLatestVersion() {
        const showBeta = playVerChannel.latestVersionIsBeta && launcherSettings.showBetaVersions
        const versions = showBeta ? versionManager.archivalVersions.versions : versionManager.archivalVersions.versions.filter(ver => !ver.isBeta)

        const abis = googleLoginHelper.getAbis(launcherSettings.showUnsupported)
        console.log("launcherAbis: " + JSON.stringify(abis))

        const latestVersion = versions.find(ver => abis.includes(ver.abi))
        if (latestVersion) {
            console.log("launcherLatestVersion: " + JSON.stringify(latestVersion))
            return latestVersion
        }

        console.log(abis.length === 0 ? "Unsupported Device" : "Bug: No version")

        return null
    }

    function launcherLatestVersionBase() {
        return launcherLatestVersion() ?? {
            "versionName": "Invalid",
            "versionCode": 0
        }
    }

    function launcherLatestVersionscode() {
        console.log("Query version")
        if (!isVersionsInitialized) {
            return 0
        }
        if (checkGooglePlayLatestSupport()) {
            console.log("Use play version")
            return rowLayout.playVerChannel.latestVersionCode
        } else {
            console.log("Use compat version")
            const ver = launcherLatestVersion()
            return ver ? ver.versionCode : 0
        }
    }

    function needsDownload() {
        const profile = profileManager.activeProfile
        if (profile.versionType == ProfileInfo.LATEST_GOOGLE_PLAY)
            return !versionManager.versions.contains(launcherLatestVersionscode())
        if (profile.versionType == ProfileInfo.LOCKED_CODE) {
            const dver = versionManager.versions.get(profile.versionCode)
            return !dver || !launcherSettings.showUnsupported && !versionManager.checkSupport(dver)
        }
        if (profile.versionType == ProfileInfo.LOCKED_NAME)
            return false
        return false
    }

    function getRawVersionsName() {
        const profile = profileManager.activeProfile
        if (profile.versionType == ProfileInfo.LATEST_GOOGLE_PLAY) {
            return getDisplayedNameForCode(launcherLatestVersionscode())
        }
        if (profile.versionType == ProfileInfo.LOCKED_CODE) {
            const ver = findArchivalVersion(profile.versionCode)
            if (ver !== null) {
                return ver.versionName
            }
        }
        return null
    }

    /* Skip downloading assets, only download missing native libs */
    function needsFullDownload(vername) {
        if (!vername)
            return true
        return !versionManager.versions.getAll().some(version => version.versionName === vername)
    }

    function findArchivalVersion(code) {
        const versions = versionManager.archivalVersions.versions
        for (var i = versions.length - 1; i >= 0; --i) {
            if (versions[i].versionCode === code || versions[i].versionCode === (code - 1000000000))
                return versions[i]
        }
        return null
    }

    function getDisplayedNameForCode(code) {
        const archiveInfo = findArchivalVersion(code)
        const ver = versionManager.versions.get(code)
        if (archiveInfo !== null && (ver === null || ver.archs.length === 1 && ver.archs[0] === archiveInfo.abi)) {
            return archiveInfo.versionName + " (" + archiveInfo.abi + ((archiveInfo.isBeta ? ", beta" : "") + ")")
        }
        if (code === rowLayout.playVerChannel.latestVersionCode)
            return rowLayout.playVerChannel.latestVersion + (playVerChannel.latestVersionIsBeta ? " (beta)" : "")
        if (ver !== null) {
            const profile = profileManager.activeProfile
            return qsTr("%1  (%2, %3)").arg(ver.versionName).arg(code).arg(profile.arch.length ? profile.arch : ver.archs.join(", "))
        }
    }

    function getDisplayedVersionName() {
        const profile = profileManager.activeProfile
        if (profile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY)
            return getDisplayedNameForCode(launcherLatestVersionscode()) || ("Unknown (" + launcherLatestVersionscode() + ")")
        if (profile.versionType === ProfileInfo.LOCKED_CODE)
            return getDisplayedNameForCode(profile.versionCode) || ((profile.versionDirName ? profile.versionDirName : "Unknown") + " (" + profile.versionCode + ")")
        if (profile.versionType === ProfileInfo.LOCKED_NAME)
            return profile.versionDirName || "Unknown Version"
        return "Unknown"
    }

    function getDownloadVersionCode() {
        const profile = profileManager.activeProfile
        if (profile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY)
            return launcherLatestVersionscode()
        if (profile.versionType === ProfileInfo.LOCKED_CODE)
            return profile.versionCode
        return null
    }

    function getCurrentGameDir(profile) {
        if (profile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY)
            return versionManager.getDirectoryFor(versionManager.versions.get(launcherLatestVersionscode()))
        if (profile.versionType === ProfileInfo.LOCKED_CODE)
            return versionManager.getDirectoryFor(versionManager.versions.get(profile.versionCode))
        if (profile.versionType === ProfileInfo.LOCKED_NAME)
            return versionManager.getDirectoryFor(profile.versionDirName)
        return null
    }

    // Tests if it really works
    function checkLauncherLatestSupport() {
        const latestCode = launcherLatestVersionscode()
        return versionManager.archivalVersions.versions.length === 0 || launcherSettings.showUnsupported || (launcherSettings.showUnverified || findArchivalVersion(latestCode) !== null || checkRollForward(latestCode))
    }

    function checkRollForward(code) {
        return versionManager.archivalVersions.rollforwardVersionRange.some(range => range.minVersionCode <= code && code <= range.maxVersionCode)
    }

    // Tests for raw Google Play latest (previous default, always true)
    function checkGooglePlayLatestSupport() {
        if (versionManager.archivalVersions.versions.length === 0) {
            console.log("Bug errata 1")
            rowLayout.warnMessage = qsTr("mcpelauncher-versiondb not loaded. Cannot check Minecraft version compatibility.")
            rowLayout.warnUrl = ""
            return true
        }

        if (launcherSettings.showUnsupported || versionManager.archivalVersions.versions.length === 0) {
            console.log("Bug errata 2")
            return true
        }

        // Handle latest is beta, beta isn't enabled
        if (playVerChannel.latestVersionIsBeta && !launcherSettings.showBetaVersions) {
            rowLayout.warnMessage = qsTr("Latest Minecraft Version %1 is a beta version, which is hidden by default.").arg(playVerChannel.latestVersion + (playVerChannel.latestVersionIsBeta ? " (beta)" : ""))
            rowLayout.warnUrl = "https://github.com/minecraft-linux/mcpelauncher-manifest/issues/797"
            return false
        }

        if (launcherSettings.showUnverified) {
            console.log("Bug errata 3")
            return true
        }

        if (checkRollForward(playVerChannel.latestVersionCode))
            return true

        const archiveInfo = findArchivalVersion(playVerChannel.latestVersionCode)
        if (archiveInfo !== null) {
            if (playVerChannel.latestVersionIsBeta && (launcherSettings.showBetaVersions || launcherSettings.showUnsupported) || !archiveInfo.isBeta) {
                if (googleLoginHelper.getAbis(launcherSettings.showUnsupported).includes(archiveInfo.abi)) {
                    rowLayout.warnMessage = ""
                    rowLayout.warnUrl = ""
                    return true
                }
            }
        }

        rowLayout.warnMessage = qsTr("Compatibility for latest Minecraft version %1 is unknown. Support for new Minecraft versions is a feature request.").arg(playVerChannel.latestVersion + (playVerChannel.latestVersionIsBeta ? " (beta)" : ""))
        rowLayout.warnUrl = "https://github.com/minecraft-linux/mcpelauncher-manifest/issues/797"
        return false
    }

    function checkSupport() {
        const profile = profileManager.activeProfile

        if (profile.versionType === ProfileInfo.LATEST_GOOGLE_PLAY)
            return checkLauncherLatestSupport()

        if (profile.versionType === ProfileInfo.LOCKED_CODE) {
            const dver = versionManager.versions.get(profile.versionCode)
            if (dver && dver.archs.length > 0 && launcherSettings.showUnsupported)
                return true

            const ver = findArchivalVersion(profile.versionCode)
            if (ver !== null && (playVerChannel.latestVersionIsBeta && (launcherSettings.showBetaVersions || launcherSettings.showUnsupported) || !ver.isBeta)) {
                if (googleLoginHelper.getAbis(launcherSettings.showUnsupported).includes(ver.abi))
                    return true
            }

            return launcherSettings.showUnverified || launcherSettings.showUnsupported
        }

        if (profile.versionType === ProfileInfo.LOCKED_NAME)
            return launcherSettings.showUnsupported || launcherSettings.showUnverified && versionManager.checkSupport(profile.versionDirName)

        console.log("Failed")
        return false
    }

    function showLaunchError(message) {
        errorDialog.text = message.toString()
        errorDialog.open()
    }

    function launchGame() {
        const profile = profileManager.activeProfile

        if (gameLauncher.running) {
            showLaunchError("The game is already running.")
            return
        }

        gameLauncher.profile = profile

        const gameDir = getCurrentGameDir(profile)
        console.log("Game dir = " + gameDir)
        if (gameDir === null || gameDir.length <= 0) {
            showLaunchError("Could not find the game directory.")
            return
        }
        gameLauncher.gameDir = gameDir

        if (launcherSettings.startHideLauncher) {
            window.hide()
            application.setVisibleInDock(false)
        }

        gameLauncher.start(launcherSettings.disableGameLog, profile.arch, !launcherSettings.trialMode)
    }
}
