//
//  TTRedPacketManager.h
//  Article
//
//  Created by lipeilun on 2017/7/11.
//
//

#import <Foundation/Foundation.h>
#import "TTRedPacketViewWrapper.h"

/**
 红包开启的通知，无论是否领到钱都会发通知
 */
extern NSString * const TTRedpackOpenedNotification;
extern NSString * const TTRedpackNotifyKeyStyle;

@class FRRedpackStructModel;


/**
 红包埋点的参数f
 */
@interface TTRedPacketTrackModel : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, assign) CGFloat money;
@property (nonatomic, copy) NSDictionary *gdExtJson;
@end

@interface TTRedPacketManager : NSObject
@property (nonatomic ,assign)BOOL isShowingRedpacketView;
+ (TTRedPacketManager *)sharedManager;

/**
 如果是从各种详情页展开红包，要用这个方法，传viewController

 @param redpacket 红包
 @param source 埋点用的
 @param fromViewController 弹红包的VC
 */
- (void)presentRedPacketWithRedpacket:(FRRedpackStructModel *)redpacket
                               source:(TTRedPacketTrackModel *)source
                       viewController:(UIViewController *)fromViewController;

- (void)presentRedPacketWithStyle:(TTRedPacketViewStyle)style
                        redpacket:(FRRedpackStructModel *)redpacket
                           source:(TTRedPacketTrackModel *)source
                   viewController:(UIViewController *)fromViewController;

+ (void)trackRedPacketPresent:(TTRedPacketTrackModel *)redpacket
                   actionType:(NSString *)actiontype;
@end
