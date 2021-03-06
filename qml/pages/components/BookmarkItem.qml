/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
import harbour.linksbag 1.0

ListItem {
    id: bookmarkItem

    enabled: model.bookmarkSelected ? !removeRemorse.visible : true

    property color labelColor: highlighted ? Theme.highlightColor : Theme.primaryColor
    property color secondaryLabelColor: highlighted ? Theme.secondaryHighlightColor :
            Theme.secondaryColor
    property bool selectMode: false

    width: parent.width
    contentHeight: Math.max(textColumn.height, typeIcon.height)

    highlighted: menuOpen || down || model.bookmarkSelected

    menu: IconContextMenu {
        IconMenuItem {
            width: parent.width / 6
            text: qsTr("Tags")
            icon.source: "image://theme/icon-m-edit"
            onClicked: {
                bookmarkItem.closeMenu()
                var dialog = pageStack.push("../../dialogs/EditTagDialog.qml",
                        { tags: model.bookmarkTags })
                dialog.accepted.connect(function () {
                    linksbagManager.updateTags(model.bookmarkID, dialog.tags)
                })
            }
        }

        IconMenuItem {
            width: parent.width / 6
            text: model.bookmarkRead ? qsTr("Unread") : qsTr("Read")
            icon.source: model.bookmarkRead ?
                "image://theme/icon-m-add" :
                "image://theme/icon-m-acknowledge"
            onClicked: {
                bookmarkItem.closeMenu()
                linksbagManager.markAsRead(model.bookmarkID, !model.bookmarkRead)
            }
        }

        IconMenuItem {
            width: parent.width / 6
            text: model.bookmarkFavorite ? qsTr("Unfavorite") : qsTr("Favorite")
            icon.source: "image://Theme/icon-m-favorite" +
                (!model.bookmarkFavorite ? "-selected": "")
            onClicked: {
                bookmarkItem.closeMenu()
                linksbagManager.markAsFavorite(model.bookmarkID, !model.bookmarkFavorite)
            }
        }

        IconMenuItem {
            width: parent.width / 6
            text: qsTr("Remove")
            icon.source: "image://theme/icon-m-delete"
            onClicked: {
                bookmarkItem.closeMenu()
                remorse.execute(bookmarkItem, qsTr("Remove"), function() {
                    linksbagManager.removeBookmark(model.bookmarkID)
                })
            }
        }

        IconMenuItem {
            width: parent.width / 6
            text: qsTr("Copy url")
            icon.source: "image://theme/icon-m-clipboard"
            onClicked: {
                bookmarkItem.closeMenu()
                Clipboard.text = model.bookmarkUrl
                linksbagManager.notify(qsTr("Url copied into clipboard"))
            }
        }

        IconMenuItem {
            width: parent.width / 6
            text: qsTr("Browser")
            icon.source: "image://theme/icon-m-region"
            onClicked: {
                bookmarkItem.closeMenu()
                Qt.openUrlExternally(encodeURI(model.bookmarkUrl))
            }
        }
    }

    Rectangle {
        visible: mainWindow.settings.showBackgroundImage && !selectMode ? model.bookmarkThumbnail != "" : false
        color: mainWindow.lightTheme ? "#fff" : "#000"
        anchors.fill: parent
        z: -1

        Image {
            id: backgroundImage
            cache: true
            smooth: false
            asynchronous: true
            source: model.bookmarkThumbnail
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            visible: parent.visible
            opacity: 0.4
        }

    }

    GlassItem {
        id: unreadIndicator
        width: Theme.itemSizeExtraSmall
        height: width
        anchors.horizontalCenter: parent.left
        y: titleLabel.y + Theme.paddingLarge - height/2
        color: Theme.highlightColor
        visible: !model.bookmarkRead
        radius: 0.14
        falloffRadius: 0.13
    }

    Column {
        Item {
            width: parent.width
            height: mainWindow.settings.bookmarksViewItemSize
        }

        id: textColumn
        property real margin: Theme.paddingMedium
        anchors {
            left: !model.bookmarkRead ? unreadIndicator.right : parent.left
            leftMargin:!model.bookmarkRead ? Theme.paddingSmall : Theme.horizontalPageMargin
            right: typeIcon.visible ? typeIcon.left : parent.right
            rightMargin: typeIcon.visible ? Theme.paddingSmall : Theme.horizontalPageMargin
        }

        Label {
            id: titleLabel
            color: labelColor
            width: parent.width
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.WordWrap
            text: model.bookmarkTitle
        }

        Item {
            width: Math.min(parent.width - 2 * textColumn.margin,
                    sourceLabel.paintedWidth + 2 * Theme.paddingSmall)
            height: sourceLabel.paintedHeight
            Rectangle {
                y: 1
                opacity: 0.7
                width: parent.width
                height: parent.height - y
                radius: Theme.paddingSmall / 2
                color: 'black'
                visible: mainWindow.settings.showBackgroundImage && !selectMode
            }
            Label {
                id: sourceLabel
                x: Theme.paddingSmall
                font.pixelSize: Theme.fontSizeExtraSmall
                color: mainWindow.settings.showBackgroundImage ? 'white' : labelColor
                elide: Text.ElideRight
                maximumLineCount: 1
                text: {
                    var matches = model.bookmarkUrl.toString()
                            .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                    return matches ? matches[1] : model.bookmarkUrl
                }
            }
            Image {
                visible: model.bookmarkHasContent
                anchors {
                    left: sourceLabel.right
                    leftMargin: Theme.paddingLarge
                    verticalCenter: sourceLabel.verticalCenter
                }
                source: "image://Theme/icon-s-cloud-download?" + (highlighted ?
                        Theme.highlightColor : Theme.primaryColor)
            }
        }
        Item {
            width: Math.min(parent.width - 2 * textColumn.margin,
                    tagsRow.childrenRect.width + 2 * Theme.paddingSmall)
            height: tagsRow.childrenRect.height
            visible: model.bookmarkTags != ""
            Rectangle {
                y: 1
                radius: Theme.paddingSmall / 2
                width: parent.width
                height: parent.height - y
                opacity: 0.5
                color: 'black'
                visible: mainWindow.settings.showBackgroundImage && !selectMode
            }
            Row {
                id: tagsRow
                x: Theme.paddingSmall
                spacing: Theme.paddingSmall
                width: parent.width
                clip: true

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/images/icon-s-tag.png"
                    visible: model.bookmarkTags != ""
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize:  Theme.fontSizeTiny
                    font.italic: true
                    elide: Text.ElideRight
                    color: mainWindow.settings.showBackgroundImage ? 'white' : labelColor
                    text: model.bookmarkTags
                }
            }
        }

        Item {
            width: parent.width
            height: mainWindow.settings.bookmarksViewItemSize
        }
    }

    Image {
        id: typeIcon
        visible: mainWindow.settings.showContentType
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        height: Theme.iconSizeMedium
        width: Theme.iconSizeMedium
        source: {
            var src
            switch(bookmarkContentType) {
            case Bookmark.CTArticle: src = "image://Theme/icon-m-document?"; break
            case Bookmark.CTImage: src = "image://Theme/icon-m-image?"; break
            case Bookmark.CTVideo: src = "image://Theme/icon-m-video?"; break
            case Bookmark.CTNoType:
            default:
                src = "image://Theme/icon-m-region?"; break
            }
            return src + (highlighted ? Theme.highlightColor : Theme.primaryColor)
        }
    }

    RemorseItem { id: remorse }

    onClicked: {
        if (!selectMode) {
            var page = pageStack.push(Qt.resolvedUrl("../BookmarkViewPage.qml"),
                    { bookmarkId: model.bookmarkID, currentBookmark: model.bookmarkBookmark })
        }
    }
}
