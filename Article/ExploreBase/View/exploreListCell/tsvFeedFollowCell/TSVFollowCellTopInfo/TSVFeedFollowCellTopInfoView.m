//
//  TSVFeedFollowCellTopInfoView.m
//  Article
//
//  Created by dingjinlu on 2017/12/7.
//

#import "TSVFeedFollowCellTopInfoView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVFeedFollowCellTopInfoViewModel.h"
#import "TTArticleCellHelper.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "UIViewAdditions.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTShortVideoHelper.h"
#import "ExploreMixListDefine.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoDetailTracker.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTFollowThemeButton.h"
#import "AWEVideoPlayAccountBridge.h"
#import "AWEVideoUserInfoManager.h"
#import "HTSVideoPlayToast.h"
#import "AWEUserModel.h"
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
//#import "TSVShortVideoAction.h"
#import "TTUGCTrackerHelper.h"
#import "TTRouteService.h"
#import "TTIndicatorView.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "AWEVideoDetailTracker.h"

#define kTitleLabelFontSize     [TTDeviceUIUtils tt_newFontSize:14.f]
#define kInfoLabelFontSize      [TTDeviceUIUtils tt_newFontSize:12.f]
#define kUnInterestedButtonW    60.f
#define kUnInterestedButtonH    44.f
#define kUnInterestedIconW      17.f
#define kTopPadding             8.f
#define kAvatarSize             36.f
#define kAvatarLeftPadding      15.f
#define kAvatarTopPadding       12.f

#define kTitleLeftGap           7.f


@interface TSVFeedFollowCellTopInfoView()

@property (nonatomic, strong) TSVFeedFollowCellTopInfoViewModel *viewModel;

@property (nonatomic, strong) UIView                        *containerView;
@property (nonatomic, strong) SSThemedLabel                 *titleLabel;
@property (nonatomic, strong) SSThemedLabel                 *infoLabel;
@property (nonatomic, strong) TTFollowThemeButton           *followButton;
@property (nonatomic, strong) TTAlphaThemedButton           *unInterestedButton;
@property (nonatomic, strong) TTAsyncCornerImageView        *avatarImageView;

@end

@implementation TSVFeedFollowCellTopInfoView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [[[[RACObserve(self, viewModel.model.author.isFollowing)
            distinctUntilChanged]
           takeUntil:[self rac_willDeallocSignal]]
           deliverOn:[RACScheduler mainThreadScheduler]]
          subscribeNext:^(id x) {
             @strongify(self);
             BOOL isFollowing = [x boolValue];
             self.followButton.followed = isFollowing;
             if (!isFollowing) {
                 self.infoLabel.text = [self.viewModel info];
                 self.followButton.hidden = NO;
             }
             [self setNeedsLayout];
         }];
    }
    return self;
}

- (void)refreshWithData:(ExploreOrderedData *)data
{
    self.viewModel = [[TSVFeedFollowCellTopInfoViewModel alloc] initWithOrderedData:data];
    
    [self refreshUIData];
}

- (void)refreshUIData
{
    self.titleLabel.text = [self.viewModel title];
    self.followButton.followed = [self.viewModel isFollowing];
    
    if ([self.viewModel isFollowing] && !isEmptyString([self.viewModel info])) {
        self.infoLabel.text =  [@"已关注·" stringByAppendingString:[self.viewModel info]];
        self.followButton.hidden = YES;
    } else if ([self.viewModel isFollowing]) {
        self.infoLabel.text = @"已关注";
        self.followButton.hidden = YES;
    } else {
        self.infoLabel.text = [self.viewModel info];
        self.followButton.hidden = NO;
    }
    
    [self.avatarImageView tt_setImageWithURLString:[self.viewModel imageURL]];
    [self.avatarImageView showOrHideVerifyViewWithVerifyInfo:self.viewModel.model.author.userAuthInfo decoratorInfo:self.viewModel.model.author.userDecoration sureQueryWithID:YES userID:nil disableNightCover:NO];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    self.containerView.hidden = NO;
    self.containerView.frame = self.bounds;
    
    self.avatarImageView.frame = CGRectMake(kAvatarLeftPadding, kAvatarTopPadding, kAvatarSize, kAvatarSize);
    
    CGFloat maxWidth = self.containerView.width - 2 * kAvatarLeftPadding  - kAvatarSize - kUnInterestedButtonW - self.followButton.width;
    [self.titleLabel sizeToFit];
    self.titleLabel.width = MIN(self.titleLabel.width, maxWidth);
    self.titleLabel.left =  self.avatarImageView.right + kTitleLeftGap;
    
    
    if (isEmptyString(self.infoLabel.text)) {
        self.infoLabel.hidden = YES;
        self.titleLabel.centerY = self.avatarImageView.centerY;
    } else {
        self.titleLabel.top = self.avatarImageView.top;
        
        self.infoLabel.hidden = NO;
        [self.infoLabel sizeToFit];
        self.infoLabel.width = MIN(self.infoLabel.width, maxWidth);
        self.infoLabel.left = self.titleLabel.left;
        self.infoLabel.bottom = self.avatarImageView.bottom;
    }
    
    self.unInterestedButton.left = self.width - kAvatarLeftPadding - (kUnInterestedButtonW / 2 + kUnInterestedIconW / 2);
    self.unInterestedButton.centerY = self.titleLabel.centerY;
    
    self.followButton.centerY = self.titleLabel.centerY;
    self.followButton.right = self.unInterestedButton.left;
}

#pragma mark -

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (SSThemedLabel *)titleLabel
{
    if(!_titleLabel){
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText15;
        _titleLabel.backgroundColorThemeKey = kColorBackground4;
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.font = [UIFont boldSystemFontOfSize:kTitleLabelFontSize];
        UITapGestureRecognizer *tapTitle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserInfo:)];
        _titleLabel.userInteractionEnabled = YES;
        [_titleLabel addGestureRecognizer:tapTitle];
        [self.containerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)infoLabel
{
    if(!_infoLabel){
        _infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _infoLabel.textColorThemeKey = kColorText3;
        _infoLabel.backgroundColorThemeKey = kColorBackground4;
        _infoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _infoLabel.numberOfLines = 1;
        _infoLabel.font = [UIFont systemFontOfSize:kInfoLabelFontSize];
        UITapGestureRecognizer *tapInfo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserInfo:)];
        _infoLabel.userInteractionEnabled = YES;
        [_infoLabel addGestureRecognizer:tapInfo];
        [self.containerView addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (TTAsyncCornerImageView *)avatarImageView
{
    if(!_avatarImageView){
        _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(kAvatarLeftPadding, kAvatarTopPadding, kAvatarSize, kAvatarSize) allowCorner:YES];
        _avatarImageView.cornerRadius = kAvatarSize / 2.f;
        _avatarImageView.placeholderName = @"default_avatar";
        [_avatarImageView addTouchTarget:self action:@selector(tapAvatar:)];
        [_avatarImageView setupVerifyViewForLength:kAvatarSize adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        [self.containerView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (TTAlphaThemedButton *)unInterestedButton
{
    if (!_unInterestedButton) {
        _unInterestedButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, kUnInterestedButtonW, kUnInterestedButtonH)];
        _unInterestedButton.imageName = @"add_textpage.png";
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

- (TTFollowThemeButton *)followButton
{
    if (!_followButton) {
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType102
                                                               followedType:TTFollowedType102
                                                         followedMutualType:TTFollowedMutualType101];
        [_followButton addTarget:self action:@selector(handleFollowClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:_followButton];
    }
    return _followButton;
}

#pragma mark - profile

- (void)tapAvatar:(id)sender
{
    [self sendClickEventWithEventName:@"rt_click_avatar" orderedData:[self.viewModel data]];
    [self tapAvatarOrName];
}

- (void)tapUserInfo:(id)sender
{
    [self sendClickEventWithEventName:@"rt_click_nickname" orderedData:[self.viewModel data]];
    [self tapAvatarOrName];
}

- (void)tapAvatarOrName
{
    ExploreOrderedData *orderedData = [self.viewModel data];
    NSString *schema = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:orderedData.shortVideoOriginalData.shortVideo.author.schema
                                                               categoryName:orderedData.categoryID fromPage:@"list_short_video"
                                                                    groupId:orderedData.shortVideoOriginalData.shortVideo.groupID
                                                              profileUserId:nil];
    if (!isEmptyString(schema)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:schema]];
    }
    
}

- (void)sendClickEventWithEventName:(NSString *)eventName orderedData:(ExploreOrderedData *)orderedData;
{
    NSMutableDictionary *logParams = [[NSMutableDictionary alloc] initWithDictionary:[self trackParamsDict]];
    [logParams setValue:@"list" forKey:@"position"];
    [AWEVideoDetailTracker trackEvent:eventName
                                model:orderedData.shortVideoOriginalData.shortVideo
                      commonParameter:[logParams copy]
                       extraParameter:nil];
}

- (NSDictionary *)trackParamsDict
{
    return [self trackParamsDictForData:[self.viewModel data]];
}

- (NSDictionary *)trackParamsDictForData:(ExploreOrderedData *)data
{
    NSString *categoryName = data.categoryID ?: @"";
    
    NSString *enterFrom;
    if ([data.categoryID isEqualToString:@"__all__"]) {
        enterFrom = @"click_headline";
    } else {
        enterFrom = @"click_category";
    }
    
    return @{@"category_name" : categoryName,
             @"enter_from" : enterFrom,
             };
}

#pragma mark - unInterestButton action
- (void)unInterestButtonClicked:(id)sender
{
    [TTShortVideoHelper uninterestFormView:self.unInterestedButton point:self.unInterestedButton.center withOrderedData:[self.viewModel data]];
}

#pragma mark - followButtonClicked


- (void)handleFollowClick:(TTFollowThemeButton *)sender
{
    TTShortVideoModel *model = [self.viewModel shortVideoModel];
    
    if (sender.isLoading || !model) {
        return;
    }
    
    NSString *userId = model.author.userID;
    NSString *position = @"list";
    
    if ([AWEVideoPlayAccountBridge isCurrentLoginUser:model.author.userID]) {
        return;
    }
    
    //  该方法不能准确判断是否登录
//    if (![AWEVideoPlayAccountBridge isLogin]) {
//        [AWEVideoPlayAccountBridge showLoginView];
//        return;
//    }
    
    [sender startLoading];
    
    if (!model.author.isFollowing) {
        @weakify(self);
        //关注
        [AWEVideoDetailTracker trackEvent:@"rt_follow"
                                    model:model
                          commonParameter:[self trackParamsDict]
                           extraParameter:@{
                                            @"position": position,
                                            @"follow_type": @"from_group",
                                            @"to_user_id": model.author.userID ?: @"",
                                            }];
        
        [AWEVideoUserInfoManager followUser:model.author.userID completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                model.author.isFollowing = user.isFollowing;
                sender.followed = YES;
                [model save];
                [HTSVideoPlayToast show:@"关注成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @11
                                                                             }
                 ];
            }
            [sender stopLoading:nil];
        }];
    } else { //取消关注
        [AWEVideoDetailTracker trackEvent:@"rt_unfollow"
                                    model:model
                          commonParameter:[self trackParamsDict]
                           extraParameter:@{
                                            @"position": position,
                                            @"follow_type": @"from_group",
                                            @"to_user_id": userId,
                                            }];
        
        @weakify(self);
        [AWEVideoUserInfoManager unfollowUser:userId completion:^(AWEUserModel *user, NSError *error) {
            @strongify(self);
            if (self && error) {
                NSString *prompts = error.userInfo[@"prompts"] ?: @"取消关注失败，请稍后重试";
                [HTSVideoPlayToast show:prompts];
            } else if (self) {
                
                model.author.isFollowing = user.isFollowing;
                sender.followed = NO;
                [model save];
                [HTSVideoPlayToast show:@"取消关注成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RelationActionSuccessNotification" object:self
                                                                  userInfo:@{
                                                                             @"kRelationActionSuccessNotificationUserIDKey": userId ?: @"",
                                                                             @"kRelationActionSuccessNotificationActionTypeKey": @12 }
                 ];
            }
            [sender stopLoading:nil];
        }];
    }
}
@end
