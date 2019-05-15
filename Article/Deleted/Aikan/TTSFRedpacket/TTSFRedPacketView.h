//
//  TTSFRedPacketView.h
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTRedPacketBaseView.h"
#import "TTSFRedPacketViewModel.h"

@interface TTSFRedPacketParam : NSObject
@property (nonatomic, copy) NSString *redpacketId;
@property (nonatomic, copy) NSString *redpacketToken;
@property (nonatomic, copy) NSString *redpacketTitle;
@property (nonatomic, copy) NSString *redpacketLogoUrl;
@property (nonatomic, copy) NSString *redpacketName;
@property (nonatomic, assign)BOOL     showFollowSelectedButton;
@property (nonatomic, copy) NSString *mpName;
@property (nonatomic, strong) NSNumber *type;

+ (TTSFRedPacketParam *)paramWithDict:(NSDictionary *)dict;
@end

@interface TTSFRedPacketView : TTRedPacketBaseView

@property (nonatomic, strong, readonly)UIButton                   *followSelectedButton;

- (instancetype)initWithFrame:(CGRect)frame param:(TTSFRedPacketParam *)param;

// 刷新红包提示语，用于异常情况
- (void)refreshWithExeptionTitle:(NSString *)title;

- (void)playLottieView;

@end
