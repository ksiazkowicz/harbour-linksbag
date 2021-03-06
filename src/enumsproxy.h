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

#pragma once

#include <QObject>

namespace LinksBag
{
enum ErrorType
{
    ETGeneral = 0,
    ETGetPocket
};

enum BookmarksStatusFilter
{
    StatusAll = 0x01,
    StatusRead = 0x02,
    StatusUnread = 0x04,
    StatusFavorite = 0x08
};

enum BookmarksContentTypeFilter
{
    ContentTypeAll = 0x01,
    ContentTypeArticles = 0x02,
    ContentTypeImages = 0x04,
    ContentTypeVideos = 0x08
};

enum ReadingView
{
    RVBest = 0,
    RVWeb,
    RVArticle
};

class EnumsProxy : public QObject
{
    Q_OBJECT

    Q_ENUMS(ErrorTypeProxy)
    Q_ENUMS(BookmarksStatusFilterProxy)
    Q_ENUMS(BookmarksContentTypeFilterProxy)
    Q_ENUMS(ReadingViewProxy)

public:
    enum ErrorTypeProxy
    {
        GeneralError = ETGeneral,
        GetPockerError = ETGetPocket
    };

    enum BookmarksStatusFilterProxy
    {
        AllStatus = StatusAll,
        ReadStatus = StatusRead,
        UnreadStatus = StatusUnread,
        FavoriteStatus = StatusFavorite
    };

    enum BookmarksContentTypeFilterProxy
    {
        AllContentType = ContentTypeAll,
        ArticlesContentType = ContentTypeArticles,
        ImagesContentType = ContentTypeImages,
        VideosContentType = ContentTypeVideos
    };

    enum ReadingViewProxy
    {
        BestView = RVBest,
        WebView = RVWeb,
        ArticleView = RVArticle
    };
};
}
