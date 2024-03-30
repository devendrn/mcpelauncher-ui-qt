import QtQuick 2.9
import QtQuick.Layouts 1.3
import "ThemedControls"
import "../"

ColumnLayout {
    RowLayout {
        id: googleAcountRow
        property bool accountNotNull: googleLoginHelperInstance.account !== null
        Text {
            text: qsTr("Google Account")
            color: "#fff"
            font.pointSize: parent.labelFontSize
        }

        Text {
            id: googleAccountIdLabel
            text: googleAcountRow.accountNotNull ? googleLoginHelperInstance.account.accountIdentifier : ""
            color: "#fff"
            Layout.alignment: Qt.AlignRight
            font.pointSize: parent.labelFontSize
        }

        MButton {
            id: googlesigninbtn
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 20
            text: googleAcountRow.accountNotNull ? qsTr("Sign out") : qsTr("Sign in")
            onClicked: {
                if (googleAcountRow.accountNotNull)
                    googleLoginHelperInstance.signOut()
                else
                    googleLoginHelperInstance.acquireAccount(window)
            }
        }
    }

    MCheckBox {
        Layout.topMargin: 15
        text: qsTr("Show log when starting the game")
        Component.onCompleted: checked = launcherSettings.startOpenLog
        onCheckedChanged: launcherSettings.startOpenLog = checked
    }

    MCheckBox {
        text: qsTr("Hide the launcher when starting the game")
        Component.onCompleted: checked = launcherSettings.startHideLauncher
        onCheckedChanged: launcherSettings.startHideLauncher = checked
    }

    MCheckBox {
        id: disableGameLog
        text: qsTr("Disable the GameLog")
        Component.onCompleted: checked = launcherSettings.disableGameLog
        onCheckedChanged: launcherSettings.disableGameLog = checked
    }

    MCheckBox {
        text: qsTr("Enable checking for updates (on opening)")
        Component.onCompleted: checked = launcherSettings.checkForUpdates
        onCheckedChanged: launcherSettings.checkForUpdates = checked
    }

    MCheckBox {
        text: qsTr("Show Notification banner")
        Component.onCompleted: checked = launcherSettings.showNotifications
        onCheckedChanged: launcherSettings.showNotifications = checked
    }

    MCheckBox {
        text: qsTr("Use new Experimental UI")
        font.pointSize: parent.labelFontSize
        Layout.columnSpan: 2
        Component.onCompleted: checked = launcherSettings.useExperimentalUi
        onCheckedChanged: launcherSettings.useExperimentalUi = checked
    }

    MButton {
        Layout.topMargin: 15
        text: qsTr("Run troubleshooter")
        onClicked: troubleshooterWindow.findIssuesAndShow()
    }

    MButton {
        text: qsTr("Open GameData Folder")
        onClicked: Qt.openUrlExternally(launcherSettings.gameDataDir)
    }

    MButton {
        text: qsTr("Open Gamepad Tool")
        onClicked: gamepadTool.show()
    }

    GampadTool {
        id: gamepadTool
    }
}
