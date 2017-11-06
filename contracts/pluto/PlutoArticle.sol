pragma solidity ^0.4.17;

import "./PlutoUtilsLibrary.sol";


contract PlutoArticle {
    struct Article {
        uint articleId;
        uint createdBy;
        string articleType;
        string title;
        string summary;
        string link;
        string source;
        string note;
        uint64 createdAt;
        uint64 updatedAt;
        uint64 dbArticleId;
    }

    uint mNumArticles = 0;
    mapping(uint => Article) mArticleStorage;

    function addArticle(
        uint _createdBy,
        string _articleType,
        string _title,
        string _summary,
        string _link,
        string _source,
        string _note,
        uint64 _createdAt,
        uint64 _updatedAt,
        uint64 _dbArticleId
    )
        public
    {
        uint articleId = mNumArticles;
        mNumArticles = mNumArticles + 1;

        Article memory article = Article(articleId, _createdBy, _articleType, 
        _title, _summary, _link, _source, _note, _createdAt, _updatedAt, _dbArticleId);
        mArticleStorage[articleId] = article;
    }

    function packArticleData(Article article)
        public
        returns (bytes oArticleData)
    {
        uint bytesLen = 32 + 
                        32 + 
                        32 + bytes(article.articleType).length + 
                        32 + bytes(article.title).length + 
                        32 + bytes(article.summary).length +
                        32 + bytes(article.link).length + 
                        32 + bytes(article.source).length + 
                        32 + bytes(article.note).length + 
                        8 +
                        8 +
                        8;
        uint position = 0;
        oArticleData = new bytes(bytesLen);

        position = PlutoUtilsLibrary.packUint(article.articleId, oArticleData, position);
        position = PlutoUtilsLibrary.packUint(article.createdBy, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.articleType, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.title, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.summary, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.link, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.source, oArticleData, position);
        position = PlutoUtilsLibrary.packString(article.note, oArticleData, position);
        position = PlutoUtilsLibrary.packUint64(article.createdAt, oArticleData, position);
        position = PlutoUtilsLibrary.packUint64(article.updatedAt, oArticleData, position);
        position = PlutoUtilsLibrary.packUint64(article.dbArticleId, oArticleData, position);
    }

    function unpackArticleData(bytes _articleData)
        public
        returns (Article oArticle)
    {
        uint position = 0;
        uint articleId;
        position = PlutoUtilsLibrary.unpackUint(_articleData, articleId, position);

        uint createdBy;
        position = PlutoUtilsLibrary.unpackUint(_articleData, createdBy, position);

        string memory articleType;
        position = PlutoUtilsLibrary.unpackString(_articleData, articleType, position);

        string memory title;
        position = PlutoUtilsLibrary.unpackString(_articleData, title, position);

        string memory summary;
        position = PlutoUtilsLibrary.unpackString(_articleData, summary, position);

        string memory link;
        position = PlutoUtilsLibrary.unpackString(_articleData, link, position);

        string memory source;
        position = PlutoUtilsLibrary.unpackString(_articleData, source, position);

        string memory note;
        position = PlutoUtilsLibrary.unpackString(_articleData, note, position);

        uint64 createdAt;
        position = PlutoUtilsLibrary.unpackUint64(_articleData, createdAt, position);

        uint64 updatedAt;
        position = PlutoUtilsLibrary.unpackUint64(_articleData, updatedAt, position);

        uint64 dbArticleId;
        position = PlutoUtilsLibrary.unpackUint64(_articleData, dbArticleId, position);

        oArticle = Article(articleId, createdBy, articleType, title, summary, 
        link, source, note, createdAt, updatedAt, dbArticleId);
    }
}