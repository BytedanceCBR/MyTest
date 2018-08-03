//
//  TTRecommendUserCardCell.m
//  Article
//
//  Created by SongChai on 02/06/2017.
//
//

#import "TTRecommendUserCardCell.h"

#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "SSThemed.h"
#import "TTFollowThemeButton.h"
#import "FRApiModel.h"
#import "TTLabelTextHelper.h"
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"
#import "TTIndicatorView.h"
#import "FriendDataManager.h"
#import "TTDeviceHelper.h"
#import "TTRecommendUserCardFlowLayout.h"

#define kVerifiedLogoLeftSpace 3.f

NSString *const TTRecommendUserCardCellIdentifier = @"TTRecommendUserCardCellIdentifier";

@interface TTRecommendUserCardCell ()

@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeButton;
@property (nonatomic, strong) UIView *nameView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;

@end

@implementation TTRecommendUserCardCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dislikeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(self.width - 9 - 10, 9, 10, 10)];
        _dislikeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        _dislikeButton.imageName = @"dislikeicon_details";
        [_dislikeButton addTarget:self action:@selector(dislikeAction) forControlEvents:UIControlEventTouchUpInside];
        
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, [TTDeviceUIUtils tt_newPadding:10] , [TTDeviceUIUtils tt_newPadding:66], [TTDeviceUIUtils tt_newPadding:66]) allowCorner:YES];
        _avatarView.cornerRadius = _avatarView.width / 2;
        [_avatarView setupVerifyViewForLength:[TTDeviceUIUtils tt_newPadding:66] adaptationSizeBlock:nil];
        _avatarView.userInteractionEnabled = NO;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        
        _nameView = [[UIView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15], _avatarView.bottom + [TTDeviceUIUtils tt_newPadding:7], self.width - [TTDeviceUIUtils tt_newPadding:30], [TTDeviceUIUtils tt_newPadding:20])];
        
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width - [TTDeviceUIUtils tt_newPadding:30] - [TTDeviceUIUtils tt_newPadding:kVerifiedLogoLeftSpace], _nameView.height)];
        
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:15], _nameView.bottom + [TTDeviceUIUtils tt_newPadding:4], self.width - [TTDeviceUIUtils tt_newPadding:30], [TTDeviceUIUtils tt_newPadding:36])];
        
        _subscribeButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101
                                                                  followedType:TTFollowedType101
                                                            followedMutualType:TTFollowedMutualType101];
        
        [_subscribeButton addTarget:self action:@selector(subscribePressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        self.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:6];
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        [self.contentView addSubview:_dislikeButton];
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
    
    _avatarView.centerX = self.contentView.centerX;//[TTDeviceUIUtils tt_newPadding:142.f] / 2;
    
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.numberOfLines = 1;
    _nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    _nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    
    _descLabel.textAlignment = NSTextAlignmentCenter;
    _descLabel.numberOfLines = 2;
    _descLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
    _descLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)themeChanged {
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.descLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)refreshPGCSubscribeState:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    ExploreEntry *entry = [userInfo objectForKey:kEntrySubscribeStatusChangedNotificationUserInfoEntryKey];
    NSString *uid = [userInfo stringValueForKey:kRelationActionSuccessNotificationUserIDKey defaultValue:@""];
    NSNumber *type = [userInfo tt_objectForKey:kRelationActionSuccessNotificationActionTypeKey];
    BOOL isFollowing = type.unsignedIntegerValue == FriendActionTypeFollow;
    
    if (!entry || [entry.mediaID longLongValue] == 0) {
        if ([uid isEqualToString:self.model.user.info.user_id]) {
            if (self.model.user.relation.is_following.boolValue != isFollowing) {
                self.model.user.relation.is_following = @(isFollowing);
                if (isFollowing && self.model.activity.redpack) {
                    //该推人卡片的人已经被关注，清空关联的红包
                    self.model.activity.redpack = nil;
                }
            }
        }
    } else {
        if ([[entry.mediaID stringValue] isEqualToString:self.model.user.info.user_id]) {
            if (self.model.user.relation.is_following.boolValue != [entry.subscribed boolValue]) {
                self.model.user.relation.is_following = entry.subscribed;
                if (entry.subscribed && self.model.activity.redpack) {
                    //该推人卡片的人已经被关注，清空关联的红包
                    self.model.activity.redpack = nil;
                }
            }
        }
    }
    
    [self updateSubscribeButton];
}

- (void)configWithModel:(FRRecommendCardStructModel *)model {
    self.model = model;
    self.avatarView.placeholderName = @"default_sdk_login";
    [self.avatarView tt_setImageWithURLString:model.user.info.avatar_url];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:model.user.info.user_auth_info decoratorInfo:model.user.info.user_decoration sureQueryWithID:NO userID:nil];

    self.descLabel.attributedText = [TTLabelTextHelper attributedStringWithString:model.recommend_reason fontSize:[TTDeviceUIUtils tt_newFontSize:12] lineHeight:[TTDeviceUIUtils tt_newPadding:14] lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:NO firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    self.descLabel.height = [TTLabelTextHelper heightOfText:model.recommend_reason fontSize:[TTDeviceUIUtils tt_newFontSize:12] forWidth:self.descLabel.width forLineHeight:[TTDeviceUIUtils tt_newPadding:14] constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    
    self.subscribeButton.centerX = self.width / 2;
    self.subscribeButton.bottom = self.height - [TTDeviceUIUtils tt_newPadding:10.f];
    
    [self updateSubscribeButton];
    
    self.nameLabel.width = self.nameView.width;
    self.nameLabel.left = 0;
    self.nameLabel.centerX = self.nameView.width / 2;
    self.nameLabel.text = model.user.info.name;
}

- (void)dislikeAction {
    if (_delegate && [_delegate respondsToSelector:@selector(onClickDislike:)]) {
        [_delegate onClickDislike:self];
    }
}

- (void)subscribePressed {
    if (_delegate && [_delegate respondsToSelector:@selector(onClickFollow:)]) {
        [_delegate onClickFollow:self];
    }
}

- (void)updateSubscribeButton {
    if (self.model.activity.redpack) {
        self.subscribeButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.model.activity.redpack.button_style.integerValue defaultType:TTUnfollowedType201];
    }else {
        self.subscribeButton.unfollowedType = TTUnfollowedType101;
    }
    self.subscribeButton.followed = self.model.user.relation.is_following.boolValue;
    self.subscribeButton.beFollowed = self.model.user.relation.is_followed.boolValue;
    self.subscribeButton.constWidth = self.width - [TTDeviceUIUtils tt_newPadding:30];
    self.subscribeButton.width = self.subscribeButton.constWidth;
    self.subscribeButton.centerX = self.width / 2;
    [self.subscribeButton refreshUI];
    
}

- (BOOL)isEqual:(TTRecommendUserCardCell *)other {
    if (![other isKindOfClass:[TTRecommendUserCardCell class]]) {
        return NO;
    }
    if (other == self) {
        return YES;
    }
    if ([other.model.user.info.user_id isEqual:self.model.user.info.user_id]) {
        return YES;
    }
    return NO;
}

//- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    if ([layoutAttributes isKindOfClass:[TTRecommendUserCardLayoutAttributes class]]) {
//        TTRecommendUserCardLayoutAttributes *attributes = (TTRecommendUserCardLayoutAttributes *)layoutAttributes;
//        [[self layer] addAnimation:attributes.transformAnimation forKey:@"transform"];
//    } else {
//        [super applyLayoutAttributes:layoutAttributes];
//    }
//}

@end
