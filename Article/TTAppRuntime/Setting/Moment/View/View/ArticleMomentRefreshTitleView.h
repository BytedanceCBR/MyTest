//
//  ArticleMomentRefreshTitleView.h
//  Article
//
//  Created by Huaqing Luo on 17/12/14.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"

@class ArticleMomentRefreshTitleView;
@protocol ArticleMomentRefreshTitleViewDelegate <NSObject>

- (void)rotationViewDidClicked:(ArticleMomentRefreshTitleView*)view;

@end

@interface ArticleMomentRefreshTitleView : SSViewBase

@property(nonatomic, weak)id<ArticleMomentRefreshTitleViewDelegate> delegate;

- (void)startAnimation;
- (void)stopAnimation;

- (void)setTitle:(NSString *)title;

@end
