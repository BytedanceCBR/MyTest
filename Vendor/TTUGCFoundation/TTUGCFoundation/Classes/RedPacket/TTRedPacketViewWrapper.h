//
//  TTRedPacketViewWrapper.h
//  Article
//
//  Created by lipeilun on 2017/7/11.
//
//

#import "SSThemed.h"

@class FRRedpackStructModel;
@class TTRedPacketTrackModel;
@class FRRedpacketOpenResultStructModel;
typedef NS_ENUM(NSInteger, TTRedPacketViewStyle) {
    TTRedPacketViewStyleDefault = 1,
    TTRedPacketViewStyleOpening = 2,    //如果以后直接进红包结果页，可用
    TTRedPacketViewStyleShortVideoBonus = 3, //小视频
};

@protocol TTRedPacketViewWrapperDelegate <NSObject>

- (void)redPacketClickCloseButton;
- (void)redPacketClickOpenButton;
- (void)redPacketClickAvatar;
- (void)redPacketClickRules;

@end

@interface TTRedPacketViewWrapper : SSThemedView
@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong, readonly) SSThemedButton *openButton;
@property (nonatomic, weak) id<TTRedPacketViewWrapperDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                        style:(TTRedPacketViewStyle)style
                    redpacket:(FRRedpackStructModel *)redpacket;
- (void)resetOpenState;
- (void)openRedPacketAnimationBegin;
- (void)showRedPacketFail:(FRRedpacketOpenResultStructModel *)data;
- (void)refreshUIForNight:(BOOL)night;
@end
