//
//  UIButton+FHUGCMultiDigg.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/9/18.
//

#import "UIButton+FHUGCMultiDigg.h"
#import <TTMultiDigManager.h>
#import <TTAccountManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Masonry/Masonry.h>
@implementation UIButton (FHUGCMultiDigg)


-(void)enableMulitDiggEmojiAnimation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TTMultiDiggManager registerAnimationImageIfNeedWithImageNames:[self imageArray]];
    });
    if(![TTMultiDiggManager isMulitDiggEmojiAnimationAlreadyRegisteredWithButton:self]) {
        [TTMultiDiggManager registMulitDiggEmojiAnimationWithButton:self withTransformAngle:0 contentInset:nil buttonPosition:TTMultiDiggButtonPositionRight];
        self.manualMultiDiggDisableBlock = ^BOOL{
            return ![TTAccountManager isLogin];
        };
        [self.diggView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}


-(NSArray *)imageArray {
    return @[@"emoji_2", @"emoji_8", @"emoji_11", @"emoji_15", @"emoji_16", @"emoji_17", @"emoji_18", @"emoji_21", @"emoji_24", @"emoji_28", @"emoji_32", @"emoji_46", @"emoji_52", @"emoji_53", @"emoji_54", @"emoji_58", @"emoji_65", @"emoji_96"];
}

@end
