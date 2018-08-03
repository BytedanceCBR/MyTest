//
//  TTRecommendCollectionViewCell.m
//  Article
//
//  Created by zhaoqin on 18/12/2016.
//
//

#import "TTRecommendCollectionViewCell.h"
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "SSThemed.h"
#import "TTFollowThemeButton.h"
#import "TTRecommendModel.h"
#import "TTLabelTextHelper.h"
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"
#import "TTIndicatorView.h"
#import "FriendDataManager.h"

#define kVerifiedLogoLeftSpace 3.f

NSString *const TTRecommendCollectionViewCellIdentifier = @"TTRecommendCollectionViewCellIdentifier";

@interface TTRecommendCollectionViewCell ()
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) UIView *nameView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@end

@implementation TTRecommendCollectionViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:15] , [TTDeviceUIUtils tt_newPadding:50], [TTDeviceUIUtils tt_newPadding:50]) allowCorner:YES];
        _avatarView.cornerRadius = _avatarView.width / 2;
        [_avatarView setupVerifyViewForLength:50 adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        
        _nameView = [[UIView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15], _avatarView.bottom + [TTDeviceUIUtils tt_newPadding:7], self.width - [TTDeviceUIUtils tt_newPadding:30], [TTDeviceUIUtils tt_newPadding:20])];
        
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width - [TTDeviceUIUtils tt_newPadding:30] - [TTDeviceUIUtils tt_newPadding:kVerifiedLogoLeftSpace], _nameView.height)];
        
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:10], _nameView.bottom + [TTDeviceUIUtils tt_newPadding:1], self.width - [TTDeviceUIUtils tt_newPadding:20], [TTDeviceUIUtils tt_newPadding:36])];
        
        _subscribeButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101 followedMutualType:TTFollowedMutualType101];
        
        [_subscribeButton addTarget:self action:@selector(subscribePressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        self.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:6];
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        [self.contentView addSubview:_avatarView];
        [self.contentView addSubview:_nameView];
        [self.contentView addSubview:_descLabel];
        [self.contentView addSubview:_subscribeButton];
        
        [_nameView addSubview:_nameLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:kEntrySubscribeStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPGCSubscribeState:) name:RelationActionSuccessNotification object:nil];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _avatarView.centerX = self.width / 2;
    
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 1;
    _nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    _nameLabel.textColorThemeKey = kColorText1;
    
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 2;
    _descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
    _descLabel.textColorThemeKey = kColorText3;
    
    _subscribeButton.centerX = self.width / 2;
}

- (void)themeChanged {
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)refreshPGCSubscribeState:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    ExploreEntry *entry = [userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    FriendActionType type = [userInfo tt_intValueForKey:kRelationActionSuccessNotificationActionTypeKey];
    
    if (!entry || [entry.mediaID longLongValue] == 0) {           //处理 RelationActionSuccessNotification
        if (!isEmptyString(uid)) {
            if ([uid isEqualToString:self.model.userID]) {
                if (type == FriendActionTypeUnfollow) {
                    self.model.isFollowing = NO;
                } else if (type == FriendActionTypeFollow) {
                    self.model.isFollowing = YES;
                }
                
            }
        }
    }
    else {                                                      //处理 kEntrySubscribeStatusChangedNotification
        if ([[entry.mediaID stringValue] isEqualToString:self.model.userID]) {
            if (self.model.isFollowing != [entry.subscribed boolValue]) {
                self.model.isFollowing = [entry.subscribed boolValue];
            }
        }
    }
    
    [self updateSubscribeButton];
    
}

- (void)configWithModel:(TTRecommendModel *)model {
    self.model = model;
    self.avatarView.placeholderName = @"big_defaulthead_head";
    [self.avatarView tt_setImageWithURLString:model.avatarUrlString];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    self.descLabel.attributedText = [TTLabelTextHelper attributedStringWithString:model.reasonString fontSize:[TTDeviceUIUtils tt_newFontSize:12] lineHeight:[TTDeviceUIUtils tt_newPadding:18] lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:NO firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    self.descLabel.height = [TTLabelTextHelper heightOfText:model.reasonString fontSize:[TTDeviceUIUtils tt_newFontSize:12] forWidth:self.descLabel.width forLineHeight:[TTDeviceUIUtils tt_newPadding:18] constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
//    NSInteger numberOfLines = ceilf(self.descLabel.height / [TTDeviceUIUtils tt_newPadding:18]);
//    if (numberOfLines == 1) {
//        self.subscribeButton.top = self.descLabel.bottom + ceilf([TTDeviceUIUtils tt_newPadding:26]);
//    }
//    else {
//        self.subscribeButton.top = self.descLabel.bottom + ceilf([TTDeviceUIUtils tt_newPadding:8]);
//    }

    self.subscribeButton.bottom = self.bottom - [TTDeviceUIUtils tt_newPadding:14.f];
    
    [self updateSubscribeButton];
    self.nameLabel.width = self.nameView.width;
    self.nameLabel.left = 0;
    self.nameLabel.centerX = self.nameView.width / 2;
    self.nameLabel.text = model.nameString;
    
}

- (void)subscribePressed {
    if (self.followPressed) {
        [self.subscribeButton startLoading];
        self.followPressed();
    }
}

- (void)updateSubscribeButton {
    self.subscribeButton.followed = self.model.isFollowing;
    self.subscribeButton.beFollowed = self.model.isFollowed;
    self.subscribeButton.centerX = self.width / 2;
}

- (BOOL)isEqual:(TTRecommendCollectionViewCell *)other {
    if (![other isKindOfClass:[TTRecommendCollectionViewCell class]]) {
        return NO;
    }
    if (other == self) {
        return YES;
    }
    if ([other.model.userID isEqual:self.model.userID]) {
        return YES;
    }
    return NO;
}

@end
