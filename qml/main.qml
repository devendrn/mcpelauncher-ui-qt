import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import io.mrarm.mcpelauncher 1.0
import "Launcher2"

Window {
    id: window
    property bool hasUpdate: false
    property string updateDownloadUrl: ""
    property bool isVersionsInitialized: false

    visible: true
    width: 640
    height: 480
    title: qsTr("Linux Minecraft Launcher")

    Item {
        anchors.fill: parent

        Component {
            id: mainWindow
            Main {
                anchors.fill: parent
            }
        }

        Component {
            id: mainWindowExperimental
            Main2 {
                anchors.fill: parent
            }
        }

        Loader {
            anchors.fill: parent
            sourceComponent: launcherSettings.useExperimentalUi ? mainWindowExperimental : mainWindow
        }
    }

    GoogleLoginHelper {
        id: googleLoginHelperInstance
        includeIncompatible: launcherSettings.showUnsupported
        singleArch: launcherSettings.singleArch
    }

    VersionManager {
        id: versionManagerInstance
    }

    ProfileManager {
        id: profileManagerInstance
    }

    LauncherSettings {
        id: launcherSettings
    }

    GooglePlayApi {
        id: playApi
        login: googleLoginHelperInstance

        onInitError: function (err) {
            playDownloadError.text = qsTr("Please login again, Details:<br/>%1").arg(err)
            playDownloadError.open()
        }

        onTosApprovalRequired: function (tos, marketing) {
            googleTosApprovalWindow.tosText = tos
            googleTosApprovalWindow.marketingText = marketing
            googleTosApprovalWindow.show()
        }
    }

    GoogleVersionChannel {
        id: playVerChannel
        playApi: playApi
    }
}
