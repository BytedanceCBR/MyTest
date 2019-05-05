//
//  TTSFRedpacketDetailView.h
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTRedPacketDetailBaseView.h"
#import "TTSFRedPacketViewController.h"
#import "TTSponsorModel.h"
#import "TTSFRedPacketViewModel.h"
#import "TTVBasePlayVideo.h"
#import "TTHProjectSharePanelTipView.h"
#import "TTInterfaceTipHProjectBaseModel.h"
#import "TTSFHelper.h"

#define kPaddingBottomPlayerView            [TTDeviceUIUtils tt_newPadding:48.f]
#define kPaddingLeftPlayerView              [TTDeviceUIUtils tt_newPadding:27.5f]

@interface TTSFRedpacketDetailViewModel : TTRedPacketDetailBaseViewModel

@property (nonatomic, strong)NSString    *imageURL;         //红包信息预留占位图
@property (nonatomic, strong)NSDictionary  *shareInfo;      //是否有分享信息
@property (nonatomic, copy)TTSponsorModel  *sponsor;        //赞助商落地页URL
@property (nonatomic, strong)NSDictionary  *senderUserInfo; //红包发送者信息
@property (nonatomic, assign)NSNumber      *success;        //是否领取成功

@end

@interface TTSFRedpacketDetailView : TTRedPacketDetailBaseView

@property (nonatomic, strong)TTSFRedpacketDetailViewModel *rpViewModel;

@property (nonatomic, strong)UIButton                    *myRpTipButton;
@property (nonatomic, strong)UIView                      *curveBackView;
@property (nonatomic, strong)UIButton                    *shareButton;
@property (nonatomic, strong) TTHProjectSharePanelTipView *sharePanel;

@property (nonatomic, strong)TTVBasePlayVideo       *playVideo;
@property (nonatomic, strong)UIImageView            *playVideoBgView;

- (void)redPacketDidFinishTransitionAnimation;
+ (TTSFRedpacketDetailView *)createDetailViewWithViewType:(enum TTSFRedPacketViewType)viewType withFrame:(CGRect)frame;

- (void)startVideoIfNeed;
- (void)stopVideoIfNeed;
@end
