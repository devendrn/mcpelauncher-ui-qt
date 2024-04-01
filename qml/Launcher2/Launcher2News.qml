import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import "ThemedControls"

// import "../"
ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0
    BaseHeader {
        Layout.fillWidth: true
        title: qsTr("News")
        content: TabBar {
            id: tabs
            background: null
            anchors.fill: parent

            MTabButton {
                text: qsTr("Minecraft")
            }
        }
    }

    StackLayout {
        id: content
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabs.currentIndex
        clip: true

        ListView {
            id: newsGrid
            Layout.alignment: Qt.AlignCenter
            spacing: 15

            model: null

            delegate: MouseArea {
                height: Math.max(newsImage.height, newsText.height)
                width: parent.width > 660 + 30 ? 660 : parent.width - 30
                cursorShape: Qt.PointingHandCursor
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: newsImage
                    source: modelData.image
                    width: parent.width
                    height: (width * sourceSize.height) / sourceSize.width
                    fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    width: parent.width
                    height: newsText.height
                    y: Math.max(newsImage.height - height, 0)
                    color: "#A0000000"

                    Text {
                        id: newsText
                        font.weight: Font.Bold
                        width: parent.width
                        text: modelData.name
                        color: "#fff"
                        elide: Text.ElideRight
                        padding: 8
                    }
                }

                function isLoading() {
                    return newsImage.status != Image.Ready
                }

                onClicked: Qt.openUrlExternally(modelData.url)
            }

            BusyIndicator {
                height: 50
                width: 50
                opacity: 0.6
                x: content.width / 2 - width / 2
                y: content.height / 2 - height / 2
                visible: newsGrid.model === null
            }
        }

        function loadNews() {
            var req = new XMLHttpRequest()
            req.open("GET", "https://www.minecraft.net/content/minecraft-net/_jcr_content.articles.grid?tileselection=auto&tagsPath=minecraft:article/news,minecraft:article/insider,minecraft:article/culture,minecraft:article/merch,minecraft:stockholm/news,minecraft:stockholm/guides,minecraft:stockholm/events,minecraft:stockholm/minecraft-builds,minecraft:stockholm/marketplace,minecraft:stockholm/deep-dives,minecraft:stockholm/merch,minecraft:stockholm/earth,minecraft:stockholm/dungeons,minecraft:stockholm/realms-plus,minecraft:stockholm/minecraft,minecraft:stockholm/realms-java,minecraft:stockholm/nether&propResPath=/content/minecraft-net/language-masters/en-us/jcr:content/root/generic-container/par/bleeding_page_sectio_1278766118/page-section-par/grid&count=2000&pageSize=20&lang=/content/minecraft-net/language-masters/en-us", true)
            req.onerror = function () {
                console.log("Failed to load news")
            }
            req.onreadystatechange = function () {
                if (req.readyState === XMLHttpRequest.DONE) {
                    if (req.status === 200)
                        parseNewsResponse(JSON.parse(req.responseText))
                    else
                        req.onerror()
                }
            }
            req.send()
        }

        function parseNewsResponse(resp) {
            var entries = []
            for (var i = 0; i < resp.article_grid.length; i++) {
                var e = resp.article_grid[i]
                var t = e.preferred_tile || e.default_tile
                if (!t)
                    continue
                entries.push({
                                 "name": t.title || t.text,
                                 "image": "https://www.minecraft.net/" + t.image.imageURL,
                                 "url": "https://minecraft.net/" + e.article_url.substr(1)
                             })
                console.log(t.title)
            }
            newsGrid.model = entries
        }

        Component.onCompleted: loadNews()
    }
}
