//
//  ArticleImpressionHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-6-24.
//
//

#import <Foundation/Foundation.h>
#import <TTImpression/SSImpressionManager.h>
#import "TTCommentModelProtocol.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTGroupModel.h"

//impression中微头条的style， 1 纯文字，2 有图，3 视频；如果是转发的微头条，则以被转发的样式作为判断标准；如果是有链接（文章），则按纯文字处理；
typedef NS_ENUM(NSUInteger, TTWeitoutiaoCellStyle) {
    TTWeitoutiaoCellStyleUnknown = 0,
    TTWeitoutiaoCellStyleText = 1,
    TTWeitoutiaoCellStyleImage = 2,
    TTWeitoutiaoCellStyleVideo = 3,
};

/**
    SSImpressionManager针对头条项目的帮助类，减少重复代码, 主要作用是将Article 转换为SSImpressionManager需要的值
 */

@interface ArticleImpressionHelper : NSObject

/**
*  混排列表impression
*/
+ (void)recordGroupForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

/**
 *  混排列表impression 排除水平卡片
 */
+ (void)recordGroupExcludeHorizontalCardForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

/**
 *  火山达人频道impression
 */
+ (void)recordHuoShanTalentForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

/**
 *  火山小视频tab impression
 */
+ (void)recordShortVideoForExploreOrderedData:(ExploreOrderedData *)orderedData status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

+ (void)recordCommentForCommentModel:(id<TTCommentModelProtocol>)comment
                              status:(SSImpressionStatus)status
                          groupModel:(TTGroupModel *)groupModel;


/**
 视频重构列表
 */

+ (void)recordGroupWithUniqueID:(NSString *)uniqueID adID:(NSString *)adID groupModel:(TTGroupModel *)groupModel status:(SSImpressionStatus)status params:(SSImpressionParams *)params;

@end
