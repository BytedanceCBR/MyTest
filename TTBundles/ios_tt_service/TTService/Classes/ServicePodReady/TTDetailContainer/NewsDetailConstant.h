//
//  NewsDetailConstant.h
//  Article
//
//  Created by 冯靖君 on 15/5/14.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kNewsDetailConditionKey;
extern NSString *const kNewsArticleKey;
extern NSString *const kNewsOrderedDataKey;
extern NSString *const kNewsFromSourceKey;
extern NSString *const kNewsAdOpenUrlKey;
extern NSString *const kNewsShowCommentKey;
extern NSString *const kEscapeBarButtonKey;
extern NSString *const kMoreBarButtonKey;

//初始化时需要的category ID， 非必须传
extern NSString *const kNewsDetailViewConditionCategoryIDKey;
//初始化时需要的ad ID， 非必须传
extern NSString *const kNewsDetailViewConditionADIDKey;

//初始化时需要的ad log_extra， 非必须传
extern NSString *const kNewsDetailViewConditionADLogExtraKey;

/**
 *  相关阅读的来源，非必须
 */
extern NSString *const kNewsDetailViewConditionRelateReadFromGID;
/**
 *  状态栏的隐藏状态
 */
extern NSString *const kNewsDetailViewConditionOriginalStatusBarHidden;
/**
 *  状态栏的style
 */
extern NSString *const kNewsDetailViewConditionOriginalStatusBarStyle;

/**
 *  相关阅读中的专栏，非必须
 */
extern NSString *const kNewsDetailViewConditionRelateReadFromAlbumKey;

/**
 *  自定义统计key-value
 */
extern NSString *const kNewsDetailViewCustomStatParamsKey;

@interface NewsDetailConstant : NSObject

@end
