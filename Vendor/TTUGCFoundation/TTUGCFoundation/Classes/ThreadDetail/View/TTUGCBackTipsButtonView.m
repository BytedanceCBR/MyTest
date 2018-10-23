//
//  TTUGCBackTipsButtonView.m
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/2/1.
//

#import "TTUGCBackTipsButtonView.h"
#import <TTBadgeNumberView.h>
#import <TTThemeManager.h>


@interface TTUGCBackTipsButtonView()

@property(nonatomic, retain) TTBadgeNumberView *badgeNumberView;

@end


@implementation TTUGCBackTipsButtonView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 150, 44)];
    if (self) {
        //self.backgroundColor = [UIColor orangeColor];
        [self loadSubViews];
    }
    
    return self;
}

- (void)loadSubViews
{
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 50, 44)];
    //_tipLabel.backgroundColor = [UIColor grayColor];
    _tipLabel.font = [UIFont systemFontOfSize:16];
    _tipLabel.userInteractionEnabled = YES;
    _tipLabel.text = @"新内容";
    _tipLabel.hidden = YES;
    [self addSubview:_tipLabel];
    [self refreshLabelTextColor];
    
    _badgeNumberView = [[TTBadgeNumberView alloc] initWithFrame:CGRectMake(85, 13, 18, 18)];
    _badgeNumberView.badgeNumber = 0;
    _badgeNumberView.badgeViewStyle = TTBadgeNumberViewStyleProfile;
    [self addSubview:_badgeNumberView];
    
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self refreshLabelTextColor];
}

- (void)refreshLabelTextColor {
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (isDayModel) {
        _tipLabel.textColor  = [UIColor blackColor];
    } else {
        _tipLabel.textColor  = [UIColor colorWithWhite:0.792157 alpha:1];
    }
}

- (void)showCloseButton:(BOOL)show
{
    self.closeButton.hidden = !show;
    
    if (self.badgeNumberView.badgeNumber > 0) {
        _tipLabel.hidden = show;
        _badgeNumberView.hidden = show;
    } else {
        _tipLabel.hidden = YES;
        _badgeNumberView.hidden = YES;
    }
    
    [self sizeToFit];
}

- (void)setTipsCount:(NSInteger)count
{
    if (self.badgeNumberView && self.closeButton.hidden) {
        self.badgeNumberView.badgeNumber = count;
        self.tipLabel.hidden = !(count > 0);
    }
}

- (NSInteger)getBadgeNumber
{
    return _badgeNumberView.badgeNumber;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(150, 44);
}

@end
