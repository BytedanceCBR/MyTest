//
//  ArticleCommentHeaderView.m
//  Article
//
//  Created by Zhang Leonardo on 13-8-6.
//
//

#import "ArticleCommentHeaderView.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"


#define kTopMargin              24
#define kBottomMargin           (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kTitleFontSize          16
#define kHeight                 (kTopMargin + kBottomMargin + kTitleFontSize)
#define kIconViewRightPadding   6


@interface ArticleCommentHeaderView()
//@property(nonatomic, retain) UIView * leftIndicatorView;
@property(nonatomic, retain) UILabel * titleLabel;
@end

@implementation ArticleCommentHeaderView

- (void)dealloc
{
//    self.leftIndicatorView = nil;
    self.titleLabel = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.leftIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopMargin, 6, kTitleFontSize)];
//        [self addSubview:_leftIndicatorView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [TTDeviceHelper isPadDevice] ? [UIFont systemFontOfSize:18.f] : [UIFont systemFontOfSize:15.f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_titleLabel];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
//    _leftIndicatorView.backgroundColor = [UIColor colorWithDayColorName:@"fe3232" nightColorName:@"935656"];
    _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    //self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

+ (CGFloat)heightForHeaderView
{
    return kHeight;
}

- (void)refreshTitle:(NSString *)title
{
    NSString * titleStr = nil;
    if (!isEmptyString(title)) {
        titleStr = [NSString stringWithFormat:@"%@", title];
    }
    [_titleLabel setText:titleStr];
    [self refreshTitleUI];
}

- (void)refreshTitleUI
{
    [_titleLabel sizeToFit];
    _titleLabel.origin = CGPointMake(16, kTopMargin - 1);
}

@end
