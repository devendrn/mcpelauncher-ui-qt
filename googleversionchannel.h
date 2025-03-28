#ifndef GOOGLEVERSIONCHANNEL_H
#define GOOGLEVERSIONCHANNEL_H

#include <QObject>
#include <QSettings>
#include "googleplayapi.h"

class GooglePlayApi;

class GoogleVersionChannel : public QObject {
    Q_OBJECT
    Q_PROPERTY(GooglePlayApi* playApi MEMBER m_playApi WRITE setPlayApi)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY latestVersionChanged)
    Q_PROPERTY(qint32 latestVersionCode READ latestVersionCode NOTIFY latestVersionChanged)
    Q_PROPERTY(bool latestVersionIsBeta READ latestVersionIsBeta NOTIFY latestVersionChanged)
    Q_PROPERTY(GoogleVersionChannelStatus status READ getStatus NOTIFY statusChanged)
    Q_PROPERTY(bool trialMode MEMBER m_trialMode WRITE setTrialMode NOTIFY statusChanged)
    Q_PROPERTY(bool hasVerifiedLicense MEMBER m_hasVerifiedLicense NOTIFY statusChanged)
    Q_PROPERTY(GoogleVersionChannelLicenceStatus licenseStatus READ getLicenseStatus NOTIFY statusChanged)

public:
    enum class GoogleVersionChannelStatus {
        NOT_READY, PENDING, FAILED, SUCCEDED
    };
    Q_ENUM(GoogleVersionChannelStatus)
    enum class GoogleVersionChannelLicenceStatus {
        NOT_READY, PENDING, FAILED, SUCCEDED, OFFLINE
    };
    Q_ENUM(GoogleVersionChannelLicenceStatus)
private:
    QSettings m_settings;
    GooglePlayApi* m_playApi = nullptr;
    QString m_latestVersion;
    qint32 m_latestVersionCode;
    qint32 m_latestVersionIsBeta;
    bool m_hasVerifiedLicense = false;
    bool m_trialMode = false;
    GoogleVersionChannelStatus status = GoogleVersionChannelStatus::NOT_READY;
    GoogleVersionChannelLicenceStatus licenseStatus = GoogleVersionChannelLicenceStatus::NOT_READY;

    void onApiReady();
    void onStatusChanged();

    void onAppInfoReceived(QString const& packageName, QString const& version, int versionCode, bool isBeta);
    void onAppInfoFailed(QString const& packageName, const QString &errorMessage);
    void setStatus(GoogleVersionChannelStatus status) {
        if (this->status != status) {
            this->status = status;
            statusChanged();
        }
    }

    void setTrialMode(bool trialMode) {
        if (m_trialMode != trialMode ) {
            m_trialMode = trialMode;
            onStatusChanged();
        }
    }

public:
    GoogleVersionChannel();

    void setPlayApi(GooglePlayApi* value);

    QString const& latestVersion() const { return m_latestVersion; }
    qint32 latestVersionCode() const { return m_latestVersionCode; }
    bool latestVersionIsBeta() const { return m_latestVersionIsBeta; }
    GoogleVersionChannelStatus getStatus() const { return status; }
    GoogleVersionChannelLicenceStatus getLicenseStatus() const { return licenseStatus; }

public slots:

signals:
    void latestVersionChanged();

    void statusChanged();

};

#endif // GOOGLEVERSIONCHANNEL_H
