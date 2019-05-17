//
//  ExploreArticleVideoCellCommentView.m
//  Article
//
//  Created by Chen Hong on 15/6/28.
//
//

#import "ExploreArticleVideoCellCommentView.h"

@implementation ExploreArticleVideoCellCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.borderWidth = 0;
    }
    return self;
}

- (void)updateContentWithNormalColor
{
    [super updateContentWithNormalColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    self.contentLabel.frame = self.bounds;
}

@end
