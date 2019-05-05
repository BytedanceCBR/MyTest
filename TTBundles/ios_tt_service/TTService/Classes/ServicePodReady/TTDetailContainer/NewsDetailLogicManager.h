//
//  NewsDetailLogicManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-10-28.
//
//

#import <Foundation/Foundation.h>
#import "ArticleDetailHeader.h"
#import "TTGroupModel.h"

#define kNewsDetailNatantSwitchChangedNotification @"kNewsDetailNatantSwitchChangedNotification"

@interface NewsDetailLogicManager : NSObject

+ (NewsDetailLogicManager *)shareInstance;

+ (NSString *)articleDetailEventLabelForSource:(NewsGoDetailFromSource)source categoryID:(NSString *)categoryID; 
//无法区分频道进入
+ (NewsGoDetailFromSource)fromSourceByString:(NSString *)string;

// added log v3.0
+ (NSString *)enterFromValueForLogV3WithClickLabel:(NSString *)clickLabel categoryID:(NSString *)categoryID;

+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue fromID:(NSNumber *)fromID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel;
+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue groupModel:(TTGroupModel *)groupModel;
+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue adID:(NSNumber *)adID groupModel:(TTGroupModel *)groupModel;
+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue fromID:(NSNumber *)fromID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel;
+ (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue groupModel:(TTGroupModel *)groupModel;
+ (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue fromGID:(NSNumber *)fromGID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel;

+ (NSString *)mainCategoryIDStr;

/**
    处理合作网站URL,添加参数
    内部不判断是否是合作网站，需要外部判断
 */
+ (NSString *)changegCooperationWapURL:(NSString *)originalURL;

@end
