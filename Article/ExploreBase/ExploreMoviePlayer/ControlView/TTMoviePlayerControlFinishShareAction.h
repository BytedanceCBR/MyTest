//
//  TTMoviePlayerControlFinishShareAction.h
//  Article
//
//  Created by lishuangyang on 2017/7/5.
//
//
#import <Foundation/Foundation.h>
#import "TTActivity.h"
#import "SSThemed.h"
@class TTAlphaThemedButton;

typedef void(^shareActivityClickBlock)(NSString *activityType);

@interface TTMoviePlayerControlFinishShareAction : SSThemedView

@property (nonatomic, strong) TTAlphaThemedButton *replayBtn; // 重播按钮
@property (nonatomic, strong) TTAlphaThemedButton *moreButton; //播放结束时的更多按钮
@property (nonatomic, assign) BOOL isFullMode;
@property (nonatomic, strong)shareActivityClickBlock shareClicked;
@property (nonatomic, assign) BOOL isIndetail;
@property (nonatomic, strong) NSMutableArray *shareItemButtons;

- (instancetype)initWithBaseView:(UIView *)baseView;
- (void)layoutSubviews;
- (void)refreshSubViews:(BOOL)hasFinished;
- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height; // 兼容底部出现banner的情况
- (void)refreshShareItemButtons;

@end
