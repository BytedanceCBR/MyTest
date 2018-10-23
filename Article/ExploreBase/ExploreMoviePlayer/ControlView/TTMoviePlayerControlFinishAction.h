//
//  TTMoviePlayerControlFinishAction.h
//  Article
//
//  Created by songxiangwu on 16/9/6.
//
//

#import <Foundation/Foundation.h>
@class TTAlphaThemedButton;
@class SSThemedLabel;

@interface TTMoviePlayerControlFinishAction : NSObject

@property (nonatomic, strong) TTAlphaThemedButton *replayButton;
@property (nonatomic, strong) TTAlphaThemedButton *shareButton;
@property (nonatomic, strong) SSThemedLabel *replayLabel;
@property (nonatomic, strong) SSThemedLabel *shareLabel;

@property (nonatomic, strong) TTAlphaThemedButton *prePlayBtn; // 播放上一个 按钮
@property (nonatomic, strong) TTAlphaThemedButton *moreButton; //播放结束时的更多按钮

@property (nonatomic, assign) BOOL isFullMode;

- (instancetype)initWithBaseView:(UIView *)baseView;

- (void)refreshSubViews:(BOOL)hasFinished;
- (void)layoutSubviews;

- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height; // 兼容底部出现banner的情况

@end
