//
//  TTRepostDefine.h
//  TTRepostService
//
//  Created by jinqiushi on 2018/8/16.
//

#ifndef TTRepostDefine_h
#define TTRepostDefine_h


typedef NS_ENUM(NSUInteger, TTRepostOperationItemType) {
    TTRepostOperationItemTypeNone = 0,
    TTRepostOperationItemTypeArticle = 1,
    TTRepostOperationItemTypeComment = 2,
    TTRepostOperationItemTypeReply = 3,
    TTRepostOperationItemTypeThread = 4,
    TTRepostOperationItemTypeShortVideo = 5,
    TTRepostOperationItemTypeWendaAnswer = 6,
};

typedef NS_ENUM(NSUInteger, TTThreadRepostType) {
    TTThreadRepostTypeNone = 0,                        // 当前帖子并非转发
    TTThreadRepostTypeArticle = 211,                   // 当前帖子实际转发的是一个文章
    TTThreadRepostTypeThread = 212,                    // 当前帖子实际转发的是一个帖子
    TTThreadRepostTypeShortVideo = 213,                // 当前帖子实际转发的是一个小视频
    TTThreadRepostTypeWendaAnswer = 214,               // 当前帖子实际转发的是一个问答（注：211和214的原内容都对应Thread中的originGroup）
    TTThreadRepostTypeLink = 215,                      // 内链转发
    TTThreadRepostTypeConcern = 216,                   // 转发话题
    TTThreadRepostTypeLive = 217,                      // 转发直播
    TTThreadRepostTypeWendaQuestion = 218,             // 转发问题
    TTThreadRepostTypeMicroApp = 219,                  // 转发小程序
    TTThreadRepostTypeSubscribedColumn = 220,          // 转发付费内容
    TTThreadRepostTypeLearning = 221,                  // 转发好好学习
    TTThreadRepostTypeMicroGame = 222,                 // 转发小游戏
    //222被占了，不能用
    TTThreadRepostTypeLongVideo = 223,                 // 转发长视频
};


#endif /* Header_h */
