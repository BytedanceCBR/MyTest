//
//  TTVideoDetailHeaderPosterView.h
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTVArticleProtocol.h"
#import "TTVideoDetailHeaderPosterViewProtocol.h"

@interface TTVideoDetailHeaderPosterView : UIView <TTVideoDetailHeaderPosterViewProtocol>

@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, assign) BOOL isAD;
@property (nonatomic, assign) BOOL showSourceLabel;
@property (nonatomic, assign) BOOL showPlayButton;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL forbidLayout;

- (void)refreshWithArticle:(id<TTVArticleProtocol> )article;
- (void)refreshUI;
+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth;
- (void)updateFrame;

- (UIImage *)logoImage;
- (void)removeAllActions;

@end
