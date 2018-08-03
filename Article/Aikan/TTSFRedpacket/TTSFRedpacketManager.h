//
//  TTSFRedpacketManager.h
//  Article
//
//  Created by chenjiesheng on 2017/12/1.
//

#import <Foundation/Foundation.h>
#import "TTSFRedPacketViewController.h"
#import "TTSFRedPackageConfig.h"
#import "TTSFHelper.h"
#import "TTSFTracker.h"

// 新人红包类型
typedef NS_ENUM(NSInteger, TTSFNewbeeRedPacketType)
{
    TTSFNewbeeRedPacketTypeWX,          //要求微信登录
    TTSFNewbeeRedPacketTypeSF           //要求任意方式登录
};

typedef void(^TTSFUnpackRedPacketSuccessBlock)(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo);
typedef void(^TTSFUnpackRedPacketFailBlock)(NSString *errorDesc);

@interface TTSFRedpacketManager : NSObject

@property (nonatomic, assign) BOOL shouldShowSunshineRedPacket;
@property (nonatomic, copy) NSString *sunshineRedPacketToken;

+ (instancetype)sharedManager;

+ (void)registerRedPackageAction;

// 胡麻将红包。disableTransition控制是否出拆红包弹窗
- (void)showMahjongWinnerRedpacketWith:(TTSponsorModel *)sponsor
                             shareInfo:(NSDictionary *)shareInfo
                                amount:(NSInteger)amount
                     disableTransition:(BOOL)disableTransition;

// 红包雨红包
- (void)showRainRedpacketWithToken:(NSString *)token
                         timeStamp:(int64_t)timeStamp
                            amount:(NSInteger)amount
                         sponsorID:(NSNumber *)sponsorID
                         shareInfo:(NSDictionary *)shareInfo
                 disableTransition:(BOOL)disableTransition
                      dismissBlock:(RPDetailDismissBlock)dismissBlock;

// 发布小视频红包
- (void)showPostTinyVideoRedpacketWithSponsor:(TTSponsorModel *)sponsor
                                    shareInfo:(NSDictionary *)shareInfo
                                       amount:(NSInteger)amount
                            disableTransition:(BOOL)disableTransition;

// 发布小视频红包token, 用于反作弊
- (NSString *)postTinyAntiSpamToken;

- (void)savePostTinyAntiSpamToken:(NSString *)token;

///**
// *  更新发布小视频红包后端状态到本地
// */
//- (void)updatePostTinyRedPacketStateByServer;

/**
 *  是否已领取过发布小视频红包（本地）
 */
- (BOOL)hasShownPostTinyRedPacket;

/**
 *  设置已领取过发布小视频红包，防止每次发小视频后复发请求到后端
 */
- (void)setHasShownPostTinyRedPacket;

// 收到小视频红包
- (void)showTinyVideoRedpacketWithToken:(NSString *)token
                                 amount:(NSInteger)amount
                             senderInfo:(NSDictionary *)senderInfo
                              shareInfo:(NSDictionary *)shareInfo
                      disableTransition:(BOOL)disableTransition;

// 拉新红包。通过应用push，点击弹出红包封皮
- (void)showInviteNewUserRedpacketWithToken:(NSString *)token
                                     amount:(NSInteger)amount
                                  shareInfo:(NSDictionary *)shareInfo
                          disableTransition:(BOOL)disableTransition;

// 新人红包。有拆动作
- (void)showNewbeeRedpacketWithSponsor:(TTSponsorModel *)sponsor
                                amount:(NSInteger)amount
                                  type:(enum TTSFNewbeeRedPacketType)type
                                 token:(NSString *)token
                         invitorUserID:(NSString *)invitorUserID
                             shareInfo:(NSDictionary *)shareInfo
                     disableTransition:(BOOL)disableTransition;

// 阳光普照红包。有拆
- (void)showSunshineRedpacketWithToken:(NSString *)token
                                amount:(NSInteger)amount
                     disableTransition:(BOOL)disableTransition;

/**
 *  拆红包雨红包
 */
- (void)unpackRainRedPacketWithToken:(NSString *)token
                         withConcern:(BOOL)concern
                     completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                           failBlock:(TTSFUnpackRedPacketFailBlock)failBlock;

/**
 *  拆小视频观众红包
 */
- (void)unpackTinyPacketWithToken:(NSString *)token
                  completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                        failBlock:(TTSFUnpackRedPacketFailBlock)failBlock;


/**
 *  拆拉新红包
 */
- (void)unpackInviteNewUserPacketWithToken:(NSString *)token
                           completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                                 failBlock:(TTSFUnpackRedPacketFailBlock)failBlock;

/**
 *  申请新人红包。剪贴板，或验证渠道符合条件两种情况吊起
 */
- (void)applyNewbeeRedPacketWithType:(TTSFNewbeeRedPacketType)type
                       invitorUserID:(NSString *)invitorUserID;

/**
 *  申请阳光普照红包。但并不展示，通过预热弹窗触发
 */
- (void)applySunshineRedPacket;

/**
 *  拆新人红包
 */
- (void)unpackNewBeeRedPacketWithType:(enum TTSFNewbeeRedPacketType)type
                                token:(NSString *)token
                        invitorUserID:(NSString *)invitorUserID
                      completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                            failBlock:(TTSFUnpackRedPacketFailBlock)failBlock;

/**
 *  拆阳光普照红包
 */
- (void)unpackSunshineRedPacketWithToken:(NSString *)token
                         completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                               failBlock:(TTSFUnpackRedPacketFailBlock)failBlock;

/**
 *  是否已申请过新人红包
 */
- (BOOL)hasShownNewBeeRedPacket;

/**
 *  设置已申请过新人红包，防止每次启动重复发请求到后端
 */
- (void)setHasShownNewBeeRedPacket;

/**
 *  是否已申请过阳光普照红包
 */
- (BOOL)hasApplySunshineRedPacket;

/**
 *  设置已申请过阳光普照红包
 */
- (void)setHasApplySunshineRedPacket;

/**
 *  关注指定红包赞助商的头条号
 */
- (void)followRedPacketPGCAccountWithMID:(NSString *)mid;

- (enum TTSpringActivityEventType)trackEventTypeWithRpViewType:(TTSFRedPacketViewType)viewType newbeeType:(TTSFNewbeeRedPacketType)newbeeType;

@end
