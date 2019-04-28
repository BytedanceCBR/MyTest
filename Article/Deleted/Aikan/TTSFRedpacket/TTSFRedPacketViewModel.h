//
//  TTSFRedPacketViewModel.h
//  Article
//
//  Created by 冯靖君 on 2017/12/6.
//

#import <Foundation/Foundation.h>
#import "TTSponsorModel.h"

/**
 *  红包详情页样式
 */
typedef NS_ENUM(NSInteger,TTSFRedPacketViewType){
    TTSFRedPacketViewTypeMahjongWinner, //麻将开奖红包样式
    TTSFRedPacketViewTypeRain,          //红包雨红包样式
    TTSFRedPacketViewTypePostTinyVideo, //发布小视频红包样式
    TTSFRedPacketViewTypeTinyVideo,     //收到小视频红包样式
    TTSFRedPacketViewTypeInviteNewUser, //拉新红包
    TTSFRedPacketViewTypeNewbee,        //新人红包
    TTSFRedPacketViewTypeSunshine       //阳光普照红包
};

@interface TTSFRedPacketViewModel : NSObject

@property (nonatomic, copy)NSString                     *token;
@property (nonatomic, assign)TTSFRedPacketViewType      viewType;
@property (nonatomic, strong)TTSponsorModel             *sponsor;
@property (nonatomic, copy)  NSDictionary               *shareInfo;
@property (nonatomic, copy)  NSString                   *amount;
@property (nonatomic, copy)  NSString                   *repacketTitle;

//发小视频的好友信息及下一步动作信息（buttonTitle, scheme）,用于小视频红包
@property (nonatomic, strong) NSDictionary              *senderUserInfo;

@property (nonatomic, strong) NSNumber                  *newbeeType;

@property (nonatomic, copy) NSString                    *invitorUserID;

@property (nonatomic, copy) NSNumber                    *batch;

- (instancetype)initWithSponsor:(TTSponsorModel *)sponsor shareInfo:(NSDictionary *)shareInfo amount:(NSInteger)amount type:(TTSFRedPacketViewType)viewType token:(NSString *)token;

@end
