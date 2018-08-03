//
//  TTSFRedPacketViewController.h
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSViewControllerBase.h>
#import "TTSFRedpacketDetailView.h"
#import "TTSFRedPacketViewModel.h"
#import "TTSFHelper.h"

@class TTSponsorModel;

@interface TTSFRedPacketViewController : SSViewControllerBase

- (instancetype)initWithViewModel:(TTSFRedPacketViewModel *)viewModel;
// 不展示拆红包弹窗，用于我的红包入口
- (instancetype)initWithViewModel:(TTSFRedPacketViewModel *)viewModel
                disableTransition:(BOOL)disableTransition
                     dismissBlock:(RPDetailDismissBlock)dismissBlock;

@end
