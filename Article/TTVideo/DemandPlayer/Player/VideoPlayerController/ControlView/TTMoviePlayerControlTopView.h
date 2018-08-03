//
//  TTMoviePlayerControlTopView.h
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTMoviePlayerControlTopView : UIView

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong ,readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *playTimesLabel;
@property (nonatomic, assign) BOOL isSmallFontSizeForTitle;
@property (nonatomic, assign) BOOL isFull;
@property (nonatomic, assign) BOOL showFullscreenStatusBar;
@property (nonatomic, assign) NSInteger shouldShowShareMore;
@property (nonatomic, strong) SSThemedButton *moreButton;
@property (nonatomic, strong) SSThemedButton *shareButton;

@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;


- (void)updateFrame;

/**
 @param style TTVideoTitleFontStyle
 */
- (void)setTitle:(NSString *)title fontSizeStyle:(NSInteger)style;
- (void)setWatchCount:(NSString *)count;
@end
