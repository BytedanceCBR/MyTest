//
//  FHMessageNotificationTipsManager.h
//  Article
//
//  Created by lizhuoli on 17/3/24.
//
//

#import <Foundation/Foundation.h>
@class FHUnreadMsgDataUnreadModel;

extern NSString * const kTTMessageNotificationTipsChangeNotification;

@interface FHMessageNotificationTipsManager : NSObject

@property (nonatomic, strong, readonly) FHUnreadMsgDataUnreadModel * tipsModel;

+ (instancetype)sharedManager;

/** 使用Model更新tips和未读数 */
- (void)updateTipsWithModel:(FHUnreadMsgDataUnreadModel *)model;

/** 手动清除"我的"Tab相关tips数据 */
- (void)clearTipsModel;

-(NSInteger)unreadNumber;

@end
