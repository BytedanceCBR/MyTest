//
//  NewsDetailConstant.m
//  Article
//
//  Created by 冯靖君 on 15/5/14.
//
//

#import "NewsDetailConstant.h"

NSString *const kNewsDetailConditionKey = @"NewsDetailConditionKey";
NSString *const kNewsArticleKey         = @"NewsArticleKey";
NSString *const kNewsOrderedDataKey     = @"NewsOrderedDataKey";
NSString *const kNewsFromSourceKey      = @"NewsFromSourceKey";
NSString *const kNewsAdOpenUrlKey       = @"NewsAdOpenUrlKey";
NSString *const kNewsShowCommentKey     = @"NewsShowCommentKey";
NSString *const kEscapeBarButtonKey     = @"EscapeBarButtonKey";
NSString *const kMoreBarButtonKey       = @"MoreBarButtonKey";

//初始化时需要的category ID， 非必须传
NSString *const kNewsDetailViewConditionCategoryIDKey     = @"kNewsDetailViewConditionCategoryIDKey";
//初始化时需要的ad ID， 非必须传
NSString *const kNewsDetailViewConditionADIDKey           = @"kNewsDetailViewConditionADIDKey";

//初始化时需要的ad log_extra， 非必须传
NSString *const kNewsDetailViewConditionADLogExtraKey           = @"kNewsDetailViewConditionADLogExtraKey";
/**
 *  相关阅读的来源，非必须
 */
NSString *const kNewsDetailViewConditionRelateReadFromGID = @"kNewsDetailViewConditionRelateReadFromGIDKey";

/**
 *  状态栏的隐藏状态
 */
NSString *const kNewsDetailViewConditionOriginalStatusBarHidden = @"kNewsDetailViewConditionOriginalStatusBarHidden";

/**
 *  状态栏的style
 */
NSString *const kNewsDetailViewConditionOriginalStatusBarStyle = @"kNewsDetailViewConditionOriginalStatusBarStyle";

/**
 *  相关阅读中的专栏，非必须
 */
NSString *const kNewsDetailViewConditionRelateReadFromAlbumKey = @"kNewsDetailViewConditionRelateReadFromAlbumKey";

/**
 *  自定义统计key-value
 */
NSString *const kNewsDetailViewCustomStatParamsKey        = @"kNewsDetailViewCustomStatParamsKey";

@implementation NewsDetailConstant

@end
