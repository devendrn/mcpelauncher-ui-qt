#include "launcherapp.h"
#include <QIcon>
#include <QFileOpenEvent>
#include <QDebug>
#include "profilemanager.h"
#include "versionmanager.h"
#include "gamelauncher.h"
#include "googleversionchannel.h"

LauncherApp::LauncherApp(int &argc, char **argv) : QApplication(argc, argv) {
    auto appdir = getenv("APPDIR");
    if(appdir != nullptr)
        setWindowIcon(QIcon(QString::fromUtf8(appdir) + "/mcpelauncher-ui-qt.png"));
}

bool LauncherApp::event(QEvent *event) {
    if (event->type() == QEvent::Close) {
        AppCloseEvent qmlEvent;
        emit closing(&qmlEvent);
        if (!qmlEvent.isAccepted()) {
            event->setAccepted(false);
            return true;
        }
    } else if (event->type() == QEvent::FileOpen) {
        QFileOpenEvent *openEvent = static_cast<QFileOpenEvent *>(event);
        auto url = openEvent->url();
        qDebug() << "Open Url " << url;
        if(url.isLocalFile()) {
            launchProfileFile("", url.toLocalFile(), false);
        } else if(url.isValid()) {
            launchProfileFile("", url.toString(), false);
        } else {
            launchProfileFile("", openEvent->file(), false);
        }
    }
    return QApplication::event(event);
}

int LauncherApp::launchProfileFile(QString profileName, QString filePath, bool startEventLoop) {
    VersionManager vmanager;
    ProfileManager manager;
    ProfileInfo * profile = nullptr;
    if(profileName.length() > 0) {
        for(auto&& pro : manager.profiles()) {
            if(((ProfileInfo *)pro)->name == profileName) {
                profile = (ProfileInfo *)pro;
            }
        }
        if(profile == nullptr) {
            printf("Profile not found: %s\n", profileName.toStdString().data());
            return 1;
        }
    } else {
        profile = manager.activeProfile();
    }

    GameLauncher launcher;
    launcher.logAttached();
    QObject::connect(&launcher, &GameLauncher::logAppended, [](QString str) {
        printf("%s", str.toStdString().data());
    });
    int exitCode = -1;
    bool exited = false;
    auto shouldExit = [&](int code) {
        exitCode = code;
        exited = true;
        this->exit(code);
    };
    QObject::connect(&launcher, &GameLauncher::stateChanged, [&]() {
        if(!launcher.running() && startEventLoop) {
            this->exit(launcher.crashed() ? 1 : 0);
        }
    });
    QObject::connect(&launcher, &GameLauncher::launchFailed, [&]() {
        if(startEventLoop) {
            shouldExit(1);
        }
    });
    QSettings m_settings;
    auto trialMode = m_settings.value("trialMode", false).toBool();
    m_settings.beginGroup("googleversionchannel");
    auto m_latestVersion = m_settings.value("latest_version").toString();
    auto m_latestVersionCode = m_settings.value("latest_version_code").toInt();
    auto m_latestVersionIsBeta = m_settings.value("latest_version_isbeta").toBool();
    if(!trialMode && m_settings.value("latest_version_id").toString() != (m_latestVersion + QChar((char)m_latestVersionCode) + QChar(m_latestVersionIsBeta))) {
        printf("Something went wrong\n");
        shouldExit(1);
    }
    QObject::connect(&launcher, &GameLauncher::fileStarted, [&](bool success) {
        if(success) {
            if(startEventLoop) {
                shouldExit(success ? 0 : 1);
            }
        } else {
            launcher.start(false, profile->arch, !trialMode, filePath);
        }
    });
    launcher.setProfile(profile);
    if(profile->versionType == ProfileInfo::LATEST_GOOGLE_PLAY) {
        GoogleVersionChannel playChannel;
        auto versionInfo = vmanager.versionList()->get(playChannel.latestVersionCode());
        if(versionInfo == nullptr) {
            printf("Couldn't find Google Play Latest version %d\n", playChannel.latestVersionCode());
            versionInfo = vmanager.versionList()->latestDownloadedVersion();
        }
        if(versionInfo == nullptr) {
            printf("Couldn't find any Latest Downloaded version!\n");
        }
        launcher.setGameDir(vmanager.getDirectoryFor(versionInfo));
    } else if(profile->versionType == ProfileInfo::LOCKED_NAME) {
        launcher.setGameDir(vmanager.getDirectoryFor(profile->versionDirName));
    } else if(profile->versionType == ProfileInfo::LOCKED_CODE && profile->versionCode) {
        launcher.setGameDir(vmanager.getDirectoryFor(vmanager.versionList()->get(profile->versionCode)));
    }
    
    if(filePath.length() > 0) {
        launcher.startFile(filePath);
    } else {
        launcher.start(false, profile->arch, !trialMode);
    }
    return exited ? exitCode : startEventLoop ? this->exec() : 0;
}


#ifndef __APPLE__
void LauncherApp::setVisibleInDock(bool) {
    // stub
}
#endif
