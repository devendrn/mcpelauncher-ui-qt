import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Templates 2.2 as T

T.TabBar {
    id: control
    Layout.fillHeight: true
    Layout.minimumHeight: parent.height

    background: Rectangle {
        color: "#1e1e1e"
    }

    contentItem: ListView {
        model: control.contentModel
        currentIndex: control.currentIndex

        spacing: control.spacing
        orientation: ListView.Vertical
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.AutoFlickIfNeeded
        snapMode: ListView.SnapToItem

        highlightMoveDuration: 0
        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 40
        preferredHighlightEnd: height - 40
    }
}
