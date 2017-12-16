/*
    Copyright (c) 2016 Oleg Linkin <MaledictusDeMagog@gmail.com>

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
import Sailfish.Silica 1.0
import harbour.linksbag 1.0

Page {
    id: bookmarksPage

    property BookmarksFilter bookmarksFilter : getFilterByKey(applicationSettings
            .value("bookmarks_filter", "all"))

    function getFilterByKey(key) {
        for (var i = 0; i < bookmarksFilters.length; ++i) {
            if (bookmarksFilters[i].key === key) {
                return bookmarksFilters[i]
            }
        }

        return allBookmarksFilter;
    }


    property BookmarksFilter allBookmarksFilter: BookmarksFilter {
        key: "all"
        name: qsTr("All")
    }

    property BookmarksFilter readBookmarksFilter: BookmarksFilter {
        key: "read"
        name: qsTr("Read")
    }

    property BookmarksFilter unreadBookmarksFilter: BookmarksFilter {
        key: "unread"
        name: qsTr("Unread")
    }

    property BookmarksFilter favoriteBookmarksFilter: BookmarksFilter {
        key: "favorite"
        name: qsTr("Favorite")
    }

    property variant bookmarksFilters: [
        allBookmarksFilter,
        readBookmarksFilter,
        unreadBookmarksFilter,
        favoriteBookmarksFilter
    ]

    onBookmarksFilterChanged: {
        if (bookmarksFilter.key == "all")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.All)
        }
        else if (bookmarksFilter.key == "read")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Read)
        }
        else if (bookmarksFilter.key == "unread")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Unread)
        }
        else if (bookmarksFilter.key == "favorite")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Favorite)
        }

        applicationSettings.setValue("bookmarks_filter", bookmarksFilter.key)
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: linksbagManager.busy
        visible: running
    }

    SilicaListView {
        id: bookmarksView

        anchors.fill: parent

        property bool showSearchField: applicationSettings
                .value("searchFieldVisibility", true)

        header: Column {
            id: headerColumn
            width: bookmarksView.width
            PageHeader {
                title: qsTr("Bookmarks: ") + bookmarksFilter.name
            }

            SearchField {
                id: search

                visible: bookmarksView.showSearchField

                anchors.left: parent.left
                anchors.right: parent.right

                placeholderText: qsTr("Search")

                onTextChanged: {
                    linksbagManager.filterBookmarks(text)
                    search.forceActiveFocus()
                    bookmarksView.currentIndex = -1
                }
            }
        }

        ViewPlaceholder {
            enabled: !bookmarksView.count && !linksbagManager.busy
            text: qsTr("There are no bookmarks. Pull down to refresh.")
        }

        PullDownMenu {
            visible: !linksbagManager.busy

            MenuItem {
                text: bookmarksView.showSearchField ?
                        qsTr("Hide search field") :
                        qsTr("Show search field")

                onClicked: {
                    bookmarksView.showSearchField = !applicationSettings
                            .value("searchFieldVisibility", true)
                    applicationSettings.setValue("searchFieldVisibility",
                            bookmarksView.showSearchField)
                }
            }

            MenuItem {
                text: qsTr("View: %1").arg(bookmarksFilter.name)

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FilterSelectorPage.qml"),
                        { bookmarksPage : bookmarksPage });
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: {
                    linksbagManager.refreshBookmarks()
                }
            }
        }

        currentIndex: -1

        model: linksbagManager.filterModel

        delegate: ListItem {
            id: rootDelegateItem

            width: bookmarksView.width
            contentHeight: contentItem.childrenRect.height

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Copy url to clipboard")
                    onClicked: {
                        Clipboard.text = bookmarkUrl
                        linksbagManager.notify(qsTr("Url copied into clipboard"))
                    }
                }

                MenuItem {
                    text: qsTr("Open in external browser")
                    onClicked: {
                        Qt.openUrlExternally(bookmarkUrl)
                    }
                }

                MenuItem {
                    text: qsTr ("Remove")
                    onClicked: {
                        remove()
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: favoriteImage.left
                anchors.rightMargin: Theme.paddingMedium

                Label {
                    id: titleLabel

                    width: parent.width

                    font.family: Theme.fontFamilyHeading
                    font.pixelSize:  Theme.fontSizeMedium
                    font.bold: true
                    elide: Text.ElideRight

                    text: bookmarkTitle
                }

                Label {
                    id: urlLabel

                    width: parent.width

                    font.pixelSize:  Theme.fontSizeTiny
                    elide: Text.ElideRight

                    text: {
                        var matches = bookmarkUrl.toString()
                                .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                        return matches ? matches[1] : bookmarkUrl
                    }
                }

                Row {
                    width: parent.width

                    Image {
                        id: tagsIcon

                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/images/icon-s-tag.png"

                        visible: bookmarkTags != ""
                    }

                    Label {
                        id: tagsLabel

                        anchors.verticalCenter: parent.verticalCenter

                        font.pixelSize:  Theme.fontSizeTiny
                        font.italic: true
                        elide: Text.ElideRight

                        text: bookmarkTags
                    }
                }
            }

            IconButton {
                id: favoriteImage
                anchors.right: readImage.left
                anchors.rightMargin: Theme.paddingMedium
                icon.source: bookmarkFavorite ?
                    "image://Theme/icon-m-favorite-selected" :
                    "image://Theme/icon-m-favorite"
                onClicked: {
                    linksbagManager.markAsFavorite(bookmarkID, !bookmarkFavorite)
                }
            }

            IconButton {
                id: readImage
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                icon.source: bookmarkRead ?
                    "image://Theme/icon-m-certificates" :
                    "image://Theme/icon-m-mail"
                onClicked: {
                    linksbagManager.markAsRead(bookmarkID, !bookmarkRead)
                }
            }

            function remove () {
                remorse.execute(rootDelegateItem, qsTr("Remove"),
                        function() {
                            linksbagManager.removeBookmark(bookmarkID)
                        })
            }

            RemorseItem { id: remorse }

            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("BookmarkViewPage.qml"),
                        { bookmarkId: bookmarkID })
            }
        }

        VerticalScrollDecorator {}
    }
}