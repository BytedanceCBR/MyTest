//
//  TTForumTopicCell.m
//  Article
//
//  Created by yuxin on 4/9/15.
//
//

#import "TTProfileFunctionCell.h"
#import "TTDeviceHelper.h"
#import "TTSettingConstants.h"
#import "TTBadgeTrackerHelper.h"

@implementation TTProfileFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.badgeView setBadgeViewStyle:TTBadgeNumberViewStyleProfile];
    self.titleLb.font = [UIFont systemFontOfSize:[self.class fontSizeOfTitle]];
    self.accessoryLb.font = [UIFont systemFontOfSize:[self.class fontSizeOfAccessory]];
    
    self.titleLeftMargin.constant = [TTDeviceUIUtils tt_padding:30.f/2];
    if (![SSCommonLogic transitionAnimationEnable]) {
        self.backgroundSelectedColorThemeKey = @"BackgroundSelectedColor1";
    }
    
    if (!isEmptyString(self.backgroundColorThemeKey)) {
        self.contentView.backgroundColor = SSGetThemedColorUsingArrayOrKey(nil, self.backgroundColorThemeKey);
        self.backgroundColor = self.contentView.backgroundColor;
    }
}

- (UISwitch *)rightSwitch {
    if (!_rightSwitch) {
        _rightSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_rightSwitch addTarget:self action:@selector(rightSwitchChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _rightSwitch;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLeftMargin.constant = [TTDeviceUIUtils tt_padding:30.f/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshHintWithEntry:(TTSettingMineTabEntry *)entry{
    
    NSString *style = nil;
    switch (entry.hintStyle) {
        case TTSettingHintStyleNone:
            self.badgeView.hidden = YES;
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
        case TTSettingHintStyleRedPoint:
            self.badgeView.hidden = NO;
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
            style = @"red_tips";
            break;
        case TTSettingHintStyleNewFlag:
            self.badgeView.hidden = NO;
            self.badgeView.badgeValue = @"NEW";
            style = @"red_tips";
            break;
        case TTSettingHintStyleNumber:
            self.badgeView.hidden = NO;
            self.badgeView.badgeNumber = (NSInteger)entry.hintCount;
            style = @"num_tips";
            break;
        default:
            self.badgeView.hidden = YES;
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
    }
    
    NSString *position = nil;
    if ([entry.key isEqualToString:@"mall"]) {
        position = @"mine_tab_mall";
    }
    else if ([entry.key isEqualToString:@"jd"]) {
        position = @"mine_tab_jd";
    }
    else if ([entry.key isEqualToString:@"gossip"]) {
        position = @"mine_tab_gossip";
    }
    else if ([entry.key isEqualToString:@"feedback"]) {
        position = @"mine_tab_feed_back";
    }
    else if ([entry.key isEqualToString:@"config"]) {
        position = @"mine_tab_settings";
    }
    if (!isEmptyString(position) && !isEmptyString(style) && entry.isTrackForShow) {
        entry.isTrackForShow = NO;//发过一次后不再发了
        [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"show" position:position style:style];
    }
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        [self.rightSwitch setOn:NO];
    } else {
        [self.rightSwitch setOn:YES];
    }
    
}


- (void)setCellImageName:(NSString*)imageName {
    
    self.cellImageView.hidden = NO;
    self.cellImageView.imageName = imageName;
    self.titleLeftMargin.constant = 110;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView * downloadLabel = (UILabel *)[self.contentView viewWithTag:TTExploreMyDownloadLabelTag];
    if (downloadLabel && !downloadLabel.hidden) {
        downloadLabel.frame = CGRectMake(100, 0, CGRectGetWidth(self.frame) - 150, CGRectGetHeight(self.frame));
    }
}

- (void)rightSwitchChanged {
    if (self.switchChanged) {
        self.switchChanged();
    }
}

+ (CGFloat)fontSizeOfTitle {
    return [TTDeviceUIUtils tt_fontSize:kTTSettingTitleFontSize];
}

+ (CGFloat)fontSizeOfAccessory {
    return [TTDeviceUIUtils tt_fontSize:28.f/2];
}

@end
