//
//  ExploreSubscribePGCCellView.m
//  Article
//
//  Created by Huaqing Luo on 24/11/14.
//
//

#import "ExploreSubscribePGCCellView.h"
#import "SSThemed.h"
#import "ExploreEntry.h"
#import "TTImageView.h"
#import "ExploreCellHelper.h"
//#import "ExploreEntryHelper.h"
#import "TTBadgeNumberView.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"



#define fNameLabelFontSize 18.f
#define fLatestItemTitleLabelFontSize 12.f
#define fLatestUpdateTimeLabelFontSize 11.f

#define fIconImageLeftPadding 15.f
#define fIconImageTopPadding 15.f
#define fIconImageWidth 50.f
#define fIconImageHeight 50.f
#define fNameLabelLeftPadding 12.f
#define fLatestItemTitleLabelTopPadding 8.f
#define fLatestUpdateTimeLabelRightPadding 15.f

#define fWholeViewHeight (fIconImageTopPadding * 2.f + fIconImageHeight) // 80.f

@interface ExploreSubscribePGCCellView()

@property(nonatomic, strong) TTImageView * iconImageView;

@property(nonatomic, strong) SSThemedLabel * nameLabel;
@property(nonatomic, strong) SSThemedLabel * latestItemTitleLabel;
@property(nonatomic, strong) SSThemedLabel * latestUpdateTimeLabel;
@property(nonatomic, strong) TTBadgeNumberView * iconBadgeView;
@property(nonatomic, strong) SSThemedView * bottomLine;

@property(nonatomic, strong) ExploreEntry * entry;

@end

@implementation ExploreSubscribePGCCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        
        self.iconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(fIconImageLeftPadding, fIconImageTopPadding, fIconImageWidth, fIconImageHeight)];
        self.iconImageView.layer.cornerRadius = 8.0f;
        self.iconImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.iconImageView.clipsToBounds = YES;
        [self addSubview:self.iconImageView];
        
        self.nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.font = [UIFont systemFontOfSize:fNameLabelFontSize];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        
        self.latestItemTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.latestItemTitleLabel.font = [UIFont systemFontOfSize:fLatestItemTitleLabelFontSize];
        self.latestItemTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.latestItemTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.latestItemTitleLabel];
        
        self.latestUpdateTimeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        self.latestUpdateTimeLabel.font = [UIFont systemFontOfSize:fLatestUpdateTimeLabelFontSize];
        self.latestUpdateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.latestUpdateTimeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.latestUpdateTimeLabel];
        
        self.iconBadgeView = [[TTBadgeNumberView alloc] initWithFrame:CGRectZero];
        self.iconBadgeView.backgroundColorThemeKey = kColorBackground7;
        self.iconBadgeView.badgeTextColorThemeKey = kColorText7;

        [self addSubview:self.iconBadgeView];
        
        CGFloat bottomLineWidth = self.width - fIconImageLeftPadding - fLatestUpdateTimeLabelRightPadding;
        self.bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(fIconImageLeftPadding, fWholeViewHeight - [TTDeviceHelper ssOnePixel], bottomLineWidth, [TTDeviceHelper ssOnePixel])];
        self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)updateLatestUpdateTimeLabelWithTimeInterval:(double)timeInterval
{
//    NSTimeInterval midnightInterval = [[ExploreCellHelper sharedInstance] midInterval];
//    
//    NSString *publishTime =  [NSString stringWithFormat:@"%@", midnightInterval > 0 ?
//                              [TTBusinessManager customtimeStringSince1970:timeInterval midnightInterval:midnightInterval] :
//                              [TTBusinessManager customtimeStringSince1970:timeInterval]];
    NSString *publishTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:timeInterval];
    self.latestUpdateTimeLabel.text = publishTime;
}

- (void)refreshWithData:(id)data
{
    self.bottomLine.hidden = NO;
    
    if ([data isKindOfClass:[ExploreEntry class]])
    {
        self.entry = (ExploreEntry *)data;
#pragma mark - update "iconImageView"
        if (!isEmptyString(self.entry.imageURLString))
        {
            [self.iconImageView setImageWithURLString:self.entry.imageURLString];
            self.iconImageView.imageContentMode = TTImageViewContentModeScaleToFill;
        }
        else
        {
            [self.iconImageView setImage:nil];
        }
        
#pragma mark - update and layout "latestUpdateTimeLabel"
        CGFloat x, y;
        if (self.entry.lastTime)
        {
            double time = [self.entry.lastTime doubleValue];
            [self updateLatestUpdateTimeLabelWithTimeInterval:time];
            [self.latestUpdateTimeLabel sizeToFit];
            x = self.width - fLatestUpdateTimeLabelRightPadding - self.latestUpdateTimeLabel.width;
            y = fIconImageTopPadding;
            self.latestUpdateTimeLabel.origin = CGPointMake(x, y);
        }
        
#pragma mark - update and layout "nameLabel"
        self.nameLabel.text = self.entry.name;
        [self.nameLabel sizeToFit];
        x = fIconImageLeftPadding + fIconImageWidth + fNameLabelLeftPadding;
        y = fIconImageTopPadding + 2;
        CGFloat maxWidth = self.latestUpdateTimeLabel.left - x;
        CGFloat width = self.nameLabel.width;
        CGFloat height = self.nameLabel.height;
        width = width < maxWidth ? width : maxWidth;
        self.nameLabel.frame = CGRectMake(x, y, width, height);
        
#pragma mark - update and layout "latestItemTitleLabel"
        if (!self.entry.itemDesc || self.entry.itemDesc.length == 0)
        {
            self.latestItemTitleLabel.text = self.entry.desc;
            self.latestUpdateTimeLabel.hidden = YES;
        }
        else
        {
            self.latestItemTitleLabel.text = self.entry.itemDesc;
            self.latestUpdateTimeLabel.hidden = NO;
        }
        
        [self.latestItemTitleLabel sizeToFit];
        y = self.nameLabel.bottom + fLatestItemTitleLabelTopPadding;
        maxWidth = maxWidth + self.latestUpdateTimeLabel.width;
        width = self.latestItemTitleLabel.width;
        width = width < maxWidth ? width : maxWidth;
        height = self.latestItemTitleLabel.height;
        self.latestItemTitleLabel.frame = CGRectMake(x, y, width, height);
        
#pragma mark - update and layout "iconBadgeView"
        if ([self.entry.isNewSubscibed boolValue])
        {
            [self.iconBadgeView setBadgeValue:@"NEW"];
        }
        else if ([self.entry.badgeCount intValue] > 0)
        {
            NSInteger badgeCount = [self.entry.badgeCount integerValue];
            [self.iconBadgeView setBadgeNumber:badgeCount];

        }
        else
        {
            [self.iconBadgeView setBadgeNumber:TTBadgeNumberHidden];
        }
        self.iconBadgeView.center = CGPointMake(self.iconImageView.frame.origin.x+ self.iconImageView.frame.size.width,self.iconImageView.frame.origin.y);
        
        [self reloadThemeUI];
    }
}


- (void)refreshUI {
    if ([self.entry isKindOfClass:[ExploreEntry class]])
    {
#pragma mark - update and layout "latestUpdateTimeLabel"
        CGFloat x, y;
        if (self.entry.lastTime)
        {
            x = self.width - fLatestUpdateTimeLabelRightPadding - self.latestUpdateTimeLabel.width;
            y = fIconImageTopPadding;
            self.latestUpdateTimeLabel.origin = CGPointMake(x, y);
        }
        
#pragma mark - update and layout "nameLabel"
        x = fIconImageLeftPadding + fIconImageWidth + fNameLabelLeftPadding;
        y = fIconImageTopPadding + 2;
        CGFloat maxWidth = self.latestUpdateTimeLabel.left - x;
        CGFloat width = self.nameLabel.width;
        CGFloat height = self.nameLabel.height;
        width = width < maxWidth ? width : maxWidth;
        self.nameLabel.frame = CGRectMake(x, y, width, height);
        
#pragma mark - update and layout "latestItemTitleLabel"
        y = self.nameLabel.bottom + fLatestItemTitleLabelTopPadding;
        maxWidth = maxWidth + self.latestUpdateTimeLabel.width;
        width = self.latestItemTitleLabel.width;
        width = width < maxWidth ? width : maxWidth;
        height = self.latestItemTitleLabel.height;
        self.latestItemTitleLabel.frame = CGRectMake(x, y, width, height);
        
#pragma mark - update and layout "iconBadgeView"
        self.iconBadgeView.center = CGPointMake(self.iconImageView.frame.origin.x+ self.iconImageView.frame.size.width,self.iconImageView.frame.origin.y);
    } else {
        self.nameLabel.width = 0;
        self.latestUpdateTimeLabel.width = 0;
        self.latestItemTitleLabel.width = 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshUI];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];

    self.iconImageView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground3].CGColor;
    self.nameLabel.textColors = @[@"303030", @"707070"];
    self.latestItemTitleLabel.textColors = @[@"999999", @"505050"];
    self.latestUpdateTimeLabel.textColors = @[@"999999", @"505050"];
    self.bottomLine.backgroundColors = @[@"dddddd", @"363636"];
}

- (void)doHideBottomLine
{
    self.bottomLine.hidden = YES;
}

- (void)hideBadge
{
    self.iconBadgeView.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if(highlighted)
    {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4Highlighted];
    }
    else
    {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

- (id)cellData
{
    return self.entry;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType;
{
    return fWholeViewHeight;
}

@end
