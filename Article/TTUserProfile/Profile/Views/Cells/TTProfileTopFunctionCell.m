
//
//  TTForumTopicCell.m
//  Article
//
//  Created by yuxin on 4/9/15.
//
//

#import "TTProfileTopFunctionCell.h"
#import "TTThemeManager.h"
#import "UIButton+TTAdditions.h"

static const CGFloat topFunctionFontSize = (28.f/2);

@interface TTProfileTopFunctionCell ()

@end

@implementation TTProfileTopFunctionCell


- (void)dealloc {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.historyBtn.imageName = @"history_profile.png";
    self.historyBtn.enableHighlightAnim = YES;
    self.historyBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22);
    self.historyBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:topFunctionFontSize]];
    [self.historyBtn setTitle:@"历 史" forState:UIControlStateNormal];
    [self.historyBtn setTitle:@"历 史" forState:UIControlStateHighlighted];
    
    self.favBtn.imageName = @"favoriteicon_profile.png";
    self.favBtn.enableHighlightAnim = YES;
    self.favBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22);
    self.favBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:topFunctionFontSize]];
    [self.favBtn setTitle:@"收 藏" forState:UIControlStateNormal];
    [self.favBtn setTitle:@"收 藏" forState:UIControlStateHighlighted];
  
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.nightSwitchBtn.imageName = @"dayicon_profile.png";
        [self.nightSwitchBtn setTitle:@"日 间" forState:UIControlStateNormal];
        [self.nightSwitchBtn setTitle:@"日 间" forState:UIControlStateHighlighted];

    }
    else {
        self.nightSwitchBtn.imageName = @"nighticon_profile.png";
        [self.nightSwitchBtn setTitle:@"夜 间" forState:UIControlStateNormal];
        [self.nightSwitchBtn setTitle:@"夜 间" forState:UIControlStateHighlighted];

    }
    self.nightSwitchBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:topFunctionFontSize]];
    self.nightSwitchBtn.enableHighlightAnim = YES;
    self.nightSwitchBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-22, -22, -22, -22);
    
    [self.favBtn sizeToFit];
    [self.historyBtn sizeToFit];
    [self.nightSwitchBtn sizeToFit];
 
    self.favBtn.center = CGPointMake(self.contentView.width / 6, self.contentView.centerY);
    self.historyBtn.center = CGPointMake(self.contentView.width / 2, self.contentView.centerY);
    self.nightSwitchBtn.center = CGPointMake(self.contentView.width * 5 / 6, self.contentView.centerY);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.favBtn sizeToFit];
    [self.historyBtn sizeToFit];
    [self.nightSwitchBtn sizeToFit];
    self.favBtn.frame = CGRectMake(0, 0, 42, 42);
    self.historyBtn.frame = CGRectMake(0, 0, 42, 42);
    self.nightSwitchBtn.frame = CGRectMake(0, 0, 42, 42);
   
    self.favBtn.center = CGPointMake(self.contentView.width / 6, self.contentView.centerY);
    self.historyBtn.center = CGPointMake(self.contentView.width / 2, self.contentView.centerY);
    self.nightSwitchBtn.center = CGPointMake(self.contentView.width * 5 / 6, self.contentView.centerY);
}

- (IBAction)enterTouched:(id)sender {
    if (self.enterTouchHandler) {
        self.enterTouchHandler();
    }
}

- (void)themeChanged:(NSNotification *)notification {
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.nightSwitchBtn.imageName = @"dayicon_profile.png";
        [self.nightSwitchBtn setTitle:@"日 间" forState:UIControlStateNormal];
        [self.nightSwitchBtn setTitle:@"日 间" forState:UIControlStateHighlighted];
        
        
    }
    else {
        self.nightSwitchBtn.imageName = @"nighticon_profile.png";
        [self.nightSwitchBtn setTitle:@"夜 间" forState:UIControlStateNormal];
        [self.nightSwitchBtn setTitle:@"夜 间" forState:UIControlStateHighlighted];
    }
}

@end
