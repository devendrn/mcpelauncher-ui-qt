#include "googleversionchannel.h"
#include "googleplayapi.h"
#include "googleloginhelper.h"

GoogleVersionChannel::GoogleVersionChannel() {
    m_settings.beginGroup("googleversionchannel");
    m_latestVersion = m_settings.value("latest_version").toString();
    m_latestVersionCode = m_settings.value("latest_version_code").toInt();
    m_latestVersionIsBeta = m_settings.value("latest_version_isbeta").toBool();
}

void GoogleVersionChannel::setPlayApi(GooglePlayApi *value) {
    licenseStatus = GoogleVersionChannelLicenceStatus::NOT_READY;
    setStatus(GoogleVersionChannelStatus::NOT_READY);
    if (m_playApi != nullptr) {
        disconnect(m_playApi, &GooglePlayApi::ready, this, &GoogleVersionChannel::onApiReady);
        disconnect(m_playApi, &GooglePlayApi::appInfoReceived, this, &GoogleVersionChannel::onAppInfoReceived);
        disconnect(m_playApi, &GooglePlayApi::appInfoFailed, this, &GoogleVersionChannel::onAppInfoFailed);
    }
    m_playApi = value;
    if (value) {
        connect(value, &GooglePlayApi::ready, this, &GoogleVersionChannel::onApiReady);
        connect(value, &GooglePlayApi::appInfoReceived, this, &GoogleVersionChannel::onAppInfoReceived);
        connect(value, &GooglePlayApi::appInfoFailed, this, &GoogleVersionChannel::onAppInfoFailed);
        if (value->getStatus() == GooglePlayApi::GooglePlayApiStatus::SUCCEDED) {
            onApiReady();
        }
    }
}

void GoogleVersionChannel::onApiReady() {
    setStatus(GoogleVersionChannelStatus::PENDING);
    m_playApi->requestAppInfo("com.mojang.minecraftpe");
}

void GoogleVersionChannel::onAppInfoReceived(const QString &packageName, const QString &version, int versionCode, bool isBeta) {
    if (packageName == "com.mojang.minecraftpe") {
        m_latestVersion = version;
        m_latestVersionCode = versionCode;
        m_latestVersionIsBeta = isBeta;
        m_settings.setValue("latest_version", m_latestVersion);
        m_settings.setValue("latest_version_code", m_latestVersionCode);
        m_settings.setValue("latest_version_isbeta", m_latestVersionIsBeta);
        emit latestVersionChanged();
        licenseStatus = GoogleVersionChannelLicenceStatus::PENDING;
        setStatus(GoogleVersionChannelStatus::SUCCEDED);
        m_playApi->validateLicense("com.mojang.minecraftpe", versionCode, [this](bool hasVerifiedLicense) {
            if(m_playApi->getLogin()->isChromeOS() && !hasVerifiedLicense) {
                m_playApi->getLogin()->setChromeOS(false);
                licenseStatus = GoogleVersionChannelLicenceStatus::NOT_READY;
                setStatus(GoogleVersionChannelStatus::NOT_READY);
                return;
            }
            this->m_hasVerifiedLicense |= hasVerifiedLicense;
            licenseStatus = hasVerifiedLicense ? GoogleVersionChannelLicenceStatus::SUCCEDED : GoogleVersionChannelLicenceStatus::FAILED;
            m_settings.setValue("latest_version_id", hasVerifiedLicense ? (m_latestVersion + QChar((char)m_latestVersionCode) + QChar(m_latestVersionIsBeta)) : "");
            statusChanged();
        });
    }
}

void GoogleVersionChannel::onAppInfoFailed(QString const& packageName, const QString &errorMessage) {
    if(errorMessage.contains("401") || errorMessage.contains("403")) {
        licenseStatus = GoogleVersionChannelLicenceStatus::FAILED;
        m_hasVerifiedLicense = false;
        m_settings.setValue("latest_version_id", "");
    } else if(m_settings.value("latest_version_id").toString() == (m_latestVersion + QChar((char)m_latestVersionCode) + QChar(m_latestVersionIsBeta))) {
        m_hasVerifiedLicense = true;
        licenseStatus = GoogleVersionChannelLicenceStatus::OFFLINE;
    }
    setStatus(GoogleVersionChannelStatus::FAILED);
}
