//
//  TTPersonalHomeSinglePlatformFollowersInfoCell.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTPersonalHomeSinglePlatformFollowersInfoCell.h"
#import "TTPersonalHomeSinglePlatformFollowersInfoViewModel.h"
#import "TTImageView.h"
#import <SSThemed.h>
#import <ReactiveObjC.h>

@interface TTPersonalHomeSinglePlatformFollowersInfoCell()

@property (nonatomic, strong) SSThemedLabel *followersCountLabel;
@property (nonatomic, strong) SSThemedLabel *appNameLabel;
@property (nonatomic, strong) TTImageView *appIconImageView;

@end

@implementation TTPersonalHomeSinglePlatformFollowersInfoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
        
        self.followersCountLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
            
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentLeft;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
            label.textColorThemeKey = kColorText15;
            
            label;
        });
        [self.contentView addSubview:self.followersCountLabel];
        
        self.appIconImageView = ({
            TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
            
            imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:3];
            
            imageView;
        });
        [self.contentView addSubview:self.appIconImageView];
        
        self.appNameLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
            
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentLeft;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
            label.textColorThemeKey = kColorText15;
            
            label;
        });
        [self.contentView addSubview:self.appNameLabel];
        
        [self bindRAC];
        
        [self refreshThemedColor];
    }
    
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    [RACObserve(self, viewModel.displayName) subscribeNext:^(NSString *displayName) {
        @strongify(self);
        self.appNameLabel.text = displayName;
        [self setNeedsLayout];
    }];
    
    [RACObserve(self, viewModel.followersCountDisplayStr) subscribeNext:^(NSString *followersCountDisplayStr) {
        @strongify(self);
        self.followersCountLabel.text = followersCountDisplayStr;
        [self setNeedsLayout];
    }];
    
    [RACObserve(self, viewModel.iconURLStr) subscribeNext:^(NSString *iconURLStr) {
        @strongify(self);
        [self.appIconImageView setImageWithURLString:iconURLStr];
        [self setNeedsLayout];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self);
         [self refreshThemedColor];
     }];
}

- (void)refreshThemedColor
{
    self.contentView.backgroundColor = SSGetThemedColorInArray(@[@"f8f8f8", @"303030"]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.followersCountLabel sizeToFit];
    [self.appNameLabel sizeToFit];
    self.appIconImageView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:14.f], [TTDeviceUIUtils tt_newPadding:14.f]);
    CGFloat iconAndAppNameSpacing = [TTDeviceUIUtils tt_newPadding:4.f];
    
    if (self.viewModel.uiStyle == TTPersonalHomePlatformFollowersInfoViewStyle1) {
        CGFloat appNameAndFollowersCountSpacing = [TTDeviceUIUtils tt_newPadding:10.f];
        
        self.appNameLabel.width = MIN(self.appNameLabel.width, self.contentView.width - self.appIconImageView.width - iconAndAppNameSpacing - appNameAndFollowersCountSpacing);
        self.followersCountLabel.width = MAX(0, MIN(self.followersCountLabel.width, self.contentView.width - self.appIconImageView.width - iconAndAppNameSpacing - self.appNameLabel.width - appNameAndFollowersCountSpacing));
        
        CGFloat containerWidth = self.appIconImageView.width + iconAndAppNameSpacing + self.appNameLabel.width + appNameAndFollowersCountSpacing + self.followersCountLabel.width;
        
        self.appIconImageView.left = self.contentView.width / 2 - containerWidth / 2;
        self.appIconImageView.centerY = self.contentView.height / 2;
        
        self.appNameLabel.left = self.appIconImageView.right + iconAndAppNameSpacing;
        self.appNameLabel.centerY = self.appIconImageView.centerY;
        
        self.followersCountLabel.left = self.appNameLabel.right + appNameAndFollowersCountSpacing;
        self.followersCountLabel.centerY = self.appIconImageView.centerY;
    } else {
        CGFloat containerHeight = self.followersCountLabel.height + [TTDeviceUIUtils tt_newPadding:7.f] + self.appIconImageView.height;
        self.followersCountLabel.width = MIN(self.followersCountLabel.width, self.contentView.width);
        self.followersCountLabel.top = self.contentView.height / 2 - containerHeight / 2;
        self.followersCountLabel.centerX = self.contentView.width / 2;
        
        self.appNameLabel.width = MIN(self.appNameLabel.width, self.contentView.width - self.appIconImageView.width - iconAndAppNameSpacing);
        CGFloat containerWidth = self.appIconImageView.width + iconAndAppNameSpacing + self.appNameLabel.width;
        self.appIconImageView.left = self.contentView.width / 2 - containerWidth / 2;
        self.appIconImageView.top = self.followersCountLabel.bottom + [TTDeviceUIUtils tt_newPadding:7.f];

        self.appNameLabel.centerY = self.appIconImageView.centerY;
        self.appNameLabel.left = self.appIconImageView.right + iconAndAppNameSpacing;
    }
}

@end
