//
//  ArticleVideoPosterView.h
//  Article
//
//  Created by Chen Hong on 15/8/27.
//
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "SSThemed.h"
#import "TTVideoDetailHeaderPosterViewProtocol.h"

@interface ArticleVideoPosterView : UIView <TTVideoDetailHeaderPosterViewProtocol>

@property (nonatomic, strong) SSThemedButton *playButton;
@property (nonatomic, assign) BOOL isAD;
@property (nonatomic, assign) BOOL showSourceLabel;
@property (nonatomic, assign) BOOL showPlayButton;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL forbidLayout;

- (void)refreshWithArticle:(Article *)article;
- (void)refreshUI;
+ (float)heightForImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth;
- (void)updateFrame;

- (UIImage *)logoImage;
- (void)removeAllActions;

@end
