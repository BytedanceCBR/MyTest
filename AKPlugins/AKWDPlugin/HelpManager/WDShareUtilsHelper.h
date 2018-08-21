//
//  WDShareUtilsHelper.h
//  Article
//
//  Created by xuzichao on 2017/6/13.
//
//

#import "DetailActionRequestManager.h"
#import "TTActivityProtocol.h"

@interface WDShareUtilsHelper : NSObject

+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success;
+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity;
+ (DetailActionRequestType)requestTypeForShareActivityType:(id<TTActivityProtocol>)activity;
+ (UIImage *)weixinSharedImageForWendaShareImg:(NSDictionary *)wendaShareInfo;
@end
