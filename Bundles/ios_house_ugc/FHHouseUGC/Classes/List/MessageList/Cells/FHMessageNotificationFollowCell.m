//
//  TTMessageNotificationFollowCell.m
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import "FHMessageNotificationFollowCell.h"
#import "TTMessageNotificationModel.h"
#import "TTFollowThemeButton.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import "FHMessageNotificationCellHelper.h"
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTThemed/UIImage+TTThemeExtension.h>

NS_INLINE CGFloat kFollowButtonTopPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:17.f];
}

NS_INLINE CGFloat kFollowButtonWidth(){
    return [FHMessageNotificationCellHelper tt_newPadding:72.f];
}

NS_INLINE CGFloat kFollowButtonHeight(){
    return [FHMessageNotificationCellHelper tt_newPadding:29.f];
}

NS_INLINE CGFloat kFollowButtonRightPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:15.f];
}

NS_INLINE CGFloat kActionTextLabelLeftPadding(){
    return [FHMessageNotificationCellHelper tt_newPadding:5.f];
}

NS_INLINE CGFloat kActionTextLabelFontSize(){
    return [FHMessageNotificationCellHelper tt_newFontSize:14.f];
}

NS_INLINE CGFloat kTimeLabelTopPaddingWithoutContactInfo(){
    return FHMNContactInfoLabelTopPadding();
}

@implementation FHMessageNotificationFollowCell

+ (Class)cellViewClass{
    return [FHMessageNotificationFollowCellView class];
}

@end

@interface FHMessageNotificationFollowCellView()

@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) SSThemedLabel *actionTextLabel;

@end

@implementation FHMessageNotificationFollowCellView

+ (CGFloat)heightForData:(TTMessageNotificationModel *)data cellWidth:(CGFloat)width{
    if ([data.cachedHeight floatValue] > 0){
        return [data.cachedHeight floatValue];
    }
    CGFloat height = 0.f;
    
    height += FHMNRoleInfoViewTopPadding();
    height += FHMNRoleInfoViewHeight();
    
    if(!isEmptyString(data.user.contactInfo)){
        height += FHMNContactInfoLabelTopPadding();
        height += FHMNContactInfoLabelHeight();
        height += FHMNTimeLabelTopPadding();
    }
    else{
        height += kTimeLabelTopPaddingWithoutContactInfo();
    }
    
    height += FHMNTimeLabelHeight();
    
    if([data.style integerValue]== TTMessageNotificationStyleFollowMerge){
        height += FHMNMultiTextViewTopPadding();
        height += FHMNMultiTextViewHeight();
    }
    
    height = MAX(height, FHMNAvatarImageViewSize() + FHMNAvatarImageViewTopPadding());
    
    if(!isEmptyString(data.content.refText)){
        height = MAX(height, kFollowButtonTopPadding() + kFollowButtonHeight());
    }
    
    height += FHMNTimeLabelBottomPadding();
    
    data.cachedHeight = @(height);
    
    return height;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    }
    return self;
}

- (void)followNotification:(NSNotification *)notification{
    NSString * userID = notification.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if (!isEmptyString(userID) && [userID isEqualToString:self.messageModel.user.userID]) {
        NSInteger actionType = [(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];

        if (actionType == FriendActionTypeFollow) {
            self.followButton.followed = YES;
            self.messageModel.hasFollowed = @(1);
        }else if (actionType == FriendActionTypeUnfollow) {
            self.followButton.followed = NO;
            self.messageModel.hasFollowed = @(0);
        }
        BOOL is_followed = [(NSNumber *)notification.userInfo[kRelationActionSuccessNotificationBeFollowedStateKey] boolValue];
        self.followButton.beFollowed = is_followed;
        self.messageModel.hasBeFollowed = @(is_followed);
    }

}

- (TTFollowThemeButton *)followButton{
    if(!_followButton){
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101 followedMutualType:TTFollowedMutualType101];
        _followButton.constHeight = kFollowButtonHeight();
        _followButton.constWidth = kFollowButtonWidth();
        [_followButton addTarget:self action:@selector(followButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followButton];
    }
    return _followButton;
}

- (void)followButtonOnClick:(id)sender{
    if (self.followButton.isLoading) {
        return;
    }
    [self.followButton startLoading];
    
    FriendActionType actionType = [self.messageModel.hasFollowed boolValue] ? FriendActionTypeUnfollow : FriendActionTypeFollow;
    
    NSMutableDictionary * extraDic = @{}.mutableCopy;
    NSString * followEvent = nil;
    if(actionType == FriendActionTypeUnfollow){
        followEvent = @"rt_unfollow";
    }else{
        followEvent = @"rt_follow";
    }
    [extraDic setValue:@"from_others"
                forKey:@"follow_type"];
    [extraDic setValue:self.messageModel.user.userID
                forKey:@"to_user_id"];
    [extraDic setValue:@"message_cell"
                forKey:@"source"];
    [extraDic setValue:@(TTFollowNewSourceMessageList)
                forKey:@"server_source"];
    [TTTrackerWrapper eventV3:followEvent
                       params:extraDic];
    
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:actionType userID:self.messageModel.user.userID platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(TTFollowNewSourceMessageList) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
        StrongSelf;
        [self.followButton stopLoading:^{
            StrongSelf;
            if (!error) {
                NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
                NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
                NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
                BOOL isFollowed = [user tt_boolValueForKey:@"is_followed"];
                BOOL isFollowing = [user tt_boolValueForKey:@"is_following"];
                self.followButton.followed = isFollowing;  //代表我是否关注当前uid
                self.followButton.beFollowed = isFollowed; //代表当前uid是否关注我
                self.messageModel.hasFollowed = @(isFollowing);
                self.messageModel.hasBeFollowed = @(isFollowed);
            }
            else {
                NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                if (isEmptyString(hint)) {
                    hint = NSLocalizedString(actionType == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                }
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }];
         
    }];

}

- (void)updateFollowButton{
    self.followButton.followed = [self.messageModel.hasFollowed boolValue];
    self.followButton.beFollowed = [self.messageModel.hasBeFollowed boolValue];
}

- (SSThemedLabel *)actionTextLabel{
    if(!_actionTextLabel){
        _actionTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _actionTextLabel.font = [UIFont systemFontOfSize:kActionTextLabelFontSize()];
        _actionTextLabel.textColorThemeKey = kColorText1;
        _actionTextLabel.numberOfLines = 1;
        _actionTextLabel.textAlignment = NSTextAlignmentLeft;
        _actionTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_actionTextLabel];
    }
    return _actionTextLabel;
}

- (void)updateActionTextLabel{
    if(!isEmptyString(self.messageModel.content.actionText)){
        self.actionTextLabel.text = self.messageModel.content.actionText;
    }
    else{
        self.actionTextLabel.text = nil;
    }
}

- (void)refreshWithData:(TTMessageNotificationModel *)data{
    self.messageModel = data;
    
    if(self.messageModel){
        [self updateAvatarImageView];
        
        [self updateActionTextLabel];
        
        if(!isEmptyString(self.messageModel.user.contactInfo)){
            [self updateContactInfoLabel];
        }
        
        if([self.messageModel.style integerValue] == TTMessageNotificationStyleFollowMerge){
            [self updateMultiTextView];
        }
        
        [self updateTimeLabel];
        
        [self updateFollowButton];
    }
}

- (void)refreshUI{
    [self layoutAvatarImageView];
    
    CGFloat actionTextLabelRightPadding = 0.f;
    CGFloat contactInfoRightPadding = 0.f;
    CGFloat timeLabelRightPadding = 0.f;
    CGFloat multiTextViewRightPadding = 0.f;
    
    if(!isEmptyString(self.messageModel.content.refText)){
        self.followButton.hidden = NO;
        self.followButton.origin = CGPointMake(self.width - kFollowButtonWidth() - kFollowButtonRightPadding(), kFollowButtonTopPadding());
        actionTextLabelRightPadding = FHMNRoleInfoViewRightPaddingWithRef();
        contactInfoRightPadding = FHMNContactInfoLabelRightPaddingWithRef();
        timeLabelRightPadding = FHMNTimeLabelRightPaddingWithRef();
        multiTextViewRightPadding = FHMNMultiTextViewRightPaddingWithRef();
    }
    else{
        self.followButton.hidden = YES;
        actionTextLabelRightPadding = FHMNRoleInfoViewDefaultRightPadding();
        contactInfoRightPadding = FHMNContactInfoLabelDefaultRightPadding();
        timeLabelRightPadding = FHMNTimeLabelDefaultRightPadding();
        multiTextViewRightPadding = FHMNMultiTextViewDefaultRightPadding();
    }
    
    self.roleInfoView.hidden = NO;
    if(!isEmptyString(self.messageModel.content.actionText)){
        self.actionTextLabel.hidden = NO;
        [self.actionTextLabel sizeToFit];
        self.actionTextLabel.width = MIN(self.actionTextLabel.width, self.width - FHMNRoleInfoViewLeftPadding() -  actionTextLabelRightPadding - kActionTextLabelLeftPadding());
        CGFloat maxRoleInfoViewWidth = self.width - FHMNRoleInfoViewLeftPadding() - actionTextLabelRightPadding - kActionTextLabelLeftPadding() - self.actionTextLabel.width;
        if(maxRoleInfoViewWidth <= FHMNUserNameLabelMinWidth()){
            // 极端case保护，避免一个字显示不全的情况
            self.roleInfoView.hidden = YES;
            self.roleInfoView.width = 0.f;
            self.roleInfoView.height = FHMNRoleInfoViewHeight();
            [self layoutRoleInfoView];
            self.actionTextLabel.top = self.roleInfoView.top;
            self.actionTextLabel.left = self.roleInfoView.right;
        }
        else{
            [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
            [self layoutRoleInfoView];
            self.actionTextLabel.top = self.roleInfoView.top;
            self.actionTextLabel.left = self.roleInfoView.right + kActionTextLabelLeftPadding();
        }
    }
    else{
        self.actionTextLabel.hidden = YES;
        CGFloat maxRoleInfoViewWidth = self.width - FHMNRoleInfoViewLeftPadding() - actionTextLabelRightPadding;
        [self updateRoleInfoViewForMaxWidth:maxRoleInfoViewWidth];
        [self layoutRoleInfoView];
    }
    
    if(!isEmptyString(self.messageModel.user.contactInfo)){
        self.contactInfoLabel.hidden = NO;
        
        [self layoutContactInfoLabelWithOrigin:CGPointMake(FHMNContactInfoLabelLeftPadding(), self.roleInfoView.bottom + FHMNContactInfoLabelTopPadding()) maxWitdh:self.width - FHMNContactInfoLabelLeftPadding() - contactInfoRightPadding];
        
        [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.contactInfoLabel.bottom + FHMNTimeLabelTopPadding()) maxWidth:self.width - FHMNTimeLabelLeftPadding() - timeLabelRightPadding];
    }
    else{
        self.contactInfoLabel.hidden = YES;
        
        [self layoutTimeLabelWithOrigin:CGPointMake(FHMNTimeLabelLeftPadding(), self.roleInfoView.bottom + kTimeLabelTopPaddingWithoutContactInfo()) maxWidth: self.width - FHMNTimeLabelLeftPadding() - timeLabelRightPadding];
    }
    
    if([self.messageModel.style integerValue] == TTMessageNotificationStyleFollowMerge){
        self.multiTextView.hidden = NO;
        
        [self layoutMultiTextViewWithOrigin: CGPointMake(FHMNMultiTextViewLeftPadding(), self.timeLabel.bottom + FHMNMultiTextViewTopPadding()) maxWitdh:self.width - FHMNMultiTextViewLeftPadding() - multiTextViewRightPadding];
    }
    else{
        self.multiTextView.hidden = YES;
    }
    
    [self layoutBottomLine];
}

@end
