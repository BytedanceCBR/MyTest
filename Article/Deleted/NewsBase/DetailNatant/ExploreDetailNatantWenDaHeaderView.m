//
//  ExploreDetailNatantWenDaHeaderView.m
//  Article
//
//  Created by 冯靖君 on 15/12/22.
//
//

#import "ExploreDetailNatantWenDaHeaderView.h"
#import "ArticleCommentHeaderView.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"


@interface ExploreDetailNatantWenDaHeaderView ()
@property(nonatomic, strong)ArticleCommentHeaderView * headerView;
@property(nonatomic, strong)UIView *bottomLineView;
@property(nonatomic, strong)UIView *bottomRedLineView;
@end

@implementation ExploreDetailNatantWenDaHeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _headerView = [[ArticleCommentHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [_headerView refreshTitle:@"问答"];
        CGFloat lineOriY = self.headerView.height-1;
        self.bottomRedLineView = [[UIView alloc] initWithFrame:CGRectMake(15.f, lineOriY, 32, [TTDeviceHelper ssOnePixel])];
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(47.f, lineOriY, self.width - 62, [TTDeviceHelper ssOnePixel])];
        [self addSubview:_headerView];
        [self addSubview:_bottomRedLineView];
        [self addSubview:_bottomLineView];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _bottomRedLineView.backgroundColor = SSGetThemedColorWithKey(kColorLine2);
    _bottomLineView.backgroundColor = [UIColor colorWithDayColorName:@"dddddd" nightColorName:@"363636"];
}

@end
