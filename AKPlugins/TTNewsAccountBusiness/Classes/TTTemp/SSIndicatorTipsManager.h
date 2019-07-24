//
//  SSIndicatorTipsManager.h
//  Article
//
//  Created by Huaqing Luo on 18/3/15.
//
//

#import <Foundation/Foundation.h>

// 拉黑（被拉黑）后执行限制操作的的提示内容
#define kTipForActionToBlockingUser @"TipForActionToBlockingUser"
#define kTipForActionToBlockedUser @"TipForActionToBlockedUser"

@interface SSIndicatorTipsManager : NSObject

+ (SSIndicatorTipsManager *)shareInstance;
- (void)setIndicatorTipsWithDictionary:(NSDictionary *)tipsDict;

- (NSString *)indicatorTipsForKey:(NSString *)key;

@end
