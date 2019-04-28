//
//  AKRedPacketManager.h
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import <Foundation/Foundation.h>

extern NSInteger const kAKNewbeeRedPacketTaskID;
extern NSInteger const kAKNewbeeRedPacketShareInfoTaskID;

@interface AKRedPacketManager : NSObject

+ (instancetype)sharedManager;

- (void)applyNewbeeRedPacketIgnoreLocalFlag:(BOOL)ignore;

- (void)showNewbeeRedPacketWithAmount:(NSInteger)amount
                    withdrawMinAmount:(NSInteger)withdrawMinAmount
                    inviteBonusAmount:(NSInteger)bonusAmount
                        invitePageURL:(NSString *)invitePageURL
                            shareInfo:(NSDictionary *)shareInfo;

- (BOOL)hasShownNewbeeRedPacket;

- (void)setHasShownNewbeeRedPacket;

// 通知后端新人红包已领取
- (void)notifyNewbeeRedPacketUserGotWithCompletion:(void(^)(BOOL shouldGot))completionBlock;

@end
