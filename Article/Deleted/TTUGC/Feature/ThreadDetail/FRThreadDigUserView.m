//
//  FRThreadDigUserView.m
//  Article
//
//  Created by 徐霜晴 on 17/2/7.
//
//

#import "FRThreadDigUserView.h"
#import "ArticleAvatarView.h"
#import "ArticleMomentHelper.h"
#import "SSNavigationBar.h"
#import "SSThemed.h"
#import "TTUserInfoView.h"

#import "FRDiggManager.h"
#import "SSAvatarView+VerifyIcon.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"

#define SIZE_FIT(size6, size5)
#define kLoadOnceCount 20

#define kLoadMoreCellHeight 44
#define kCellHeight                                                            \
  [FRThreadDigUsersViewCellUIHelper fitSizeWithiPhone6:52.f iPhone5:48.f]

#define kCellRightPadding 15

#define kCellAvatarViewNormalWidth 36.f
#define kCellAvatarViewWidth                                                   \
  [FRThreadDigUsersViewCellUIHelper fitSizeWithiPhone6:36.f iPhone5:32.f]
#define kCellAvatarViewHeight                                                  \
  [FRThreadDigUsersViewCellUIHelper fitSizeWithiPhone6:36.f iPhone5:32.f]
#define kCellAvatarViewLeftPadding 15
#define kCellAvatarViewRightPadding 12
#define kCellNameLabelFontSize                                                 \
  [FRThreadDigUsersViewCellUIHelper fitSizeWithiPhone6:14.f iPhone5:13.f]
#define kCellDescLabelFontSize                                                 \
  [FRThreadDigUsersViewCellUIHelper fitSizeWithiPhone6:12.f iPhone5:12.f]
#define kCellNameLabelBottomPadding 5
@interface FRThreadDigUsersViewCellUIHelper : NSObject
@end
@implementation FRThreadDigUsersViewCellUIHelper
+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone5:(CGFloat)size5 {
  switch ([TTDeviceHelper getDeviceType]) {
  case TTDeviceModePad:
    return size6 * 1.3;
  case TTDeviceMode736:
  case TTDeviceMode667:
    return size6;
  case TTDeviceMode568:
  case TTDeviceMode480:
    return size5;
  default:
    return size6;
  }
}
@end

@interface FRThreadDigUsersViewCell : SSThemedTableViewCell

@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, strong) TTUserInfoView *nameView;
@property(nonatomic, strong) SSThemedLabel *descLabel;
@property(nonatomic, strong) ArticleAvatarView *avatarView;
@property(nonatomic, strong) FRUserStructModel *userModel;

@end

@implementation FRThreadDigUsersViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (![SSCommonLogic transitionAnimationEnable]) {
      self.backgroundSelectedColorThemeKey = kColorBackground10Highlighted;
    }
    self.backgroundColorThemeKey = kColorBackground3;
    self.needMargin = YES;
    self.avatarView = [[ArticleAvatarView alloc]
        initWithFrame:CGRectMake(kCellAvatarViewLeftPadding, 0,
                                 kCellAvatarViewWidth, kCellAvatarViewHeight)];
    self.avatarView.centerY = self.centerY;
    self.avatarView.avatarStyle = SSAvatarViewStyleRound;
    self.avatarView.avatarImgPadding = 0.f;
    self.avatarView.userInteractionEnabled = NO;
    self.avatarView.avatarButton.enabled = NO;
    [self.avatarView setupVerifyViewForLength:kCellAvatarViewNormalWidth
                          adaptationSizeBlock:^CGSize(CGSize standardSize) {
                            return [TTVerifyIconHelper tt_newSize:standardSize];
                          }];
    [self.contentView addSubview:_avatarView];

    self.descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    self.descLabel.font = [UIFont systemFontOfSize:kCellDescLabelFontSize];
    self.descLabel.textColorThemeKey = kColorText3;
    self.descLabel.numberOfLines = 1;
    [self.contentView addSubview:_descLabel];
  }
  return self;
}

- (CGRect)_separatorLineFrame {
  CGFloat left = kCellAvatarViewLeftPadding + kCellAvatarViewWidth +
                 kCellAvatarViewRightPadding;
  return CGRectMake(left, self.height - [TTDeviceHelper ssOnePixel],
                    self.width - left, [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self refreshUserModel:self.userModel
                   width:CGRectGetWidth(self.frame)
                 isOwner:self.isOwner];
}

- (void)refreshUserModel:(FRUserStructModel *)userModel
                   width:(CGFloat)width
                 isOwner:(BOOL)isOwner {
  self.userModel = userModel;
  self.isOwner = isOwner;

  [_avatarView showAvatarByURL:userModel.avatar_url];
  [_avatarView showOrHideVerifyViewWithVerifyInfo:userModel.user_auth_info decoratorInfo:userModel.user_decoration sureQueryWithID:NO userID:nil];

  NSMutableArray *icons = nil;
  if (userModel.user_role_icons.count > 0) {
    icons = [[NSMutableArray alloc] init];
    [userModel.user_role_icons
        enumerateObjectsUsingBlock:^(FRUserIconStructModel *_Nonnull obj,
                                     NSUInteger idx, BOOL *_Nonnull stop) {
          NSDictionary *dic = [obj.icon_url toDictionary];
          if (dic) {
            [icons addObject:dic];
          }
        }];
  }

  CGFloat maxWidth = width - CGRectGetMaxX(_avatarView.frame) -
                     kCellAvatarViewRightPadding - kCellRightPadding;
  if (!_nameView) {
    _nameView = [[TTUserInfoView alloc]
        initWithBaselineOrigin:CGPointMake(_avatarView.right +
                                               kCellAvatarViewRightPadding,
                                           0)
                      maxWidth:maxWidth
                   limitHeight:kCellNameLabelFontSize + 2
                         title:userModel.screen_name
                      fontSize:kCellNameLabelFontSize
                  verifiedInfo:nil
                      verified:NO
                         owner:NO
           appendLogoInfoArray:icons];
    [_nameView setTextColorThemedKey:kColorText1];
    [self.contentView addSubview:_nameView];
  } else {
    [_nameView refreshWithTitle:userModel.screen_name
                       relation:[self getRelationStr:userModel]
                   verifiedInfo:nil
                       verified:NO
                          owner:isOwner
                       maxWidth:0
            appendLogoInfoArray:icons];
  }

  _nameView.userInteractionEnabled = NO;

  _avatarView.left = kCellAvatarViewLeftPadding;
  _avatarView.centerY = self.contentView.centerY;
  NSString *descStr = nil;
  if (!isEmptyString(userModel.verified_content)) {
    descStr = userModel.verified_content;
  } else if (!isEmptyString(userModel.desc)) {
    descStr = userModel.desc;
  }
  _descLabel.text = descStr;
  _descLabel.size = CGSizeMake(maxWidth, kCellDescLabelFontSize + 2);
  _descLabel.left = _nameView.left;
  if (isEmptyString(_descLabel.text)) {
    _descLabel.hidden = YES;
    _nameView.centerY = self.contentView.centerY;
  } else {
    _nameView.bottom = _avatarView.centerY - 1.f;
    _descLabel.hidden = NO;
    _descLabel.top = _avatarView.centerY + 2.f;
  }
}

- (NSString *)getRelationStr:(FRUserStructModel *)userModel {
  NSString *relation = nil;
  if ([userModel.is_following integerValue] &&
      [userModel.is_friend integerValue]) {
    relation = @"(互相关注)";
  }
  if ([userModel.is_following integerValue] &&
      ![userModel.is_friend integerValue]) {
    relation = @"(已关注)";
  }
  return relation;
}
@end

@interface FRThreadDigUserView () <UITableViewDataSource, UITableViewDelegate,
                                   UIViewControllerErrorHandler>
@property(nonatomic, assign) NSUInteger loadOffset;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, copy) NSString *authorUserID;
@property(nonatomic, assign) int64_t threadID;
@property(nonatomic, strong) NSError *refreshError;
@end

@implementation FRThreadDigUserView

- (void)dealloc {
  self.listView.delegate = nil;
  self.listView.dataSource = nil;
  self.listView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
                     threadID:(int64_t)threadID
                 authorUserID:(NSString *)author {
  self = [super initWithFrame:frame];
  if (self) {
    self.diggManger = [[FRDiggManager alloc] initWithThreadID:threadID];
    self.threadID = threadID;
    self.authorUserID = author;

    self.loadOffset = 0;

    self.listView =
        [[SSThemedTableView alloc] initWithFrame:self.bounds
                                           style:UITableViewStylePlain];
    self.listView.delegate = self;
    self.listView.dataSource = self;
    self.listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listView.backgroundColorThemeKey = kColorBackground3;
    self.listView.hasMore = YES;
    [self addSubview:self.listView];

    WeakSelf;
    [self.listView tt_addDefaultPullUpLoadMoreWithHandler:^{
      StrongSelf;
      [self loadMoreData];
    }];

    [self refreshData];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.listView.frame = self.bounds;
  [self.listView setNeedsLayout];
}

- (void)leftButtonClicked {
  [[TTUIResponderHelper topNavigationControllerFor:self]
      popViewControllerAnimated:YES];
}

- (void)refreshListUI {
  [self.listView reloadData];
}

- (NSArray<FRUserStructModel *> *)currentMomentDiggUsers {
  return [self.diggManger diggUsers];
}

- (FRUserStructModel *)userForIndex:(NSUInteger)index {
  if (index < [[self currentMomentDiggUsers] count]) {
    FRUserStructModel *model =
        [[self currentMomentDiggUsers] objectAtIndex:index];
    return model;
  }
  return nil;
}

- (BOOL)tt_hasValidateData {
  if (self.refreshError || self.isLoading) {
    return self.diggManger.diggUsers.count > 0 ||
           self.diggManger.anonymousCount > 0;
  } else {
    return YES;
  }
}

- (void)refreshData {

  if (self.isLoading) {
    return;
  }

  self.isLoading = YES;
  [self tt_startUpdate];
  WeakSelf;
  [self.diggManger
      startGetDiggedUsersWithOffset:0
                              count:kLoadOnceCount
                        finishBlock:^(NSArray<FRUserStructModel *> *users,
                                      NSInteger totalCount,
                                      NSInteger anonymousCount, BOOL hasMore,
                                      NSError *error) {
                          StrongSelf;
                          self.isLoading = NO;
                          self.refreshError = error;
                          [self tt_endUpdataData:NO error:error];
                          [self.listView finishPullDownWithSuccess:!error];
                          self.listView.hasMore = hasMore;

                          if (!error) {
                            self.loadOffset = kLoadOnceCount;
                            [self refreshListUI];
                          } else {
                            self.loadOffset = 0;
                          }
                        }];
}

- (void)loadMoreData {
  if (self.isLoading) {
    return;
  }
  self.isLoading = YES;
  [self tt_startUpdate];
  WeakSelf;
  [self.diggManger
      startGetDiggedUsersWithOffset:(int)_loadOffset
                              count:kLoadOnceCount
                        finishBlock:^(NSArray<FRUserStructModel *> *users,
                                      NSInteger totalCount,
                                      NSInteger anonymousCount, BOOL hasMore,
                                      NSError *error) {
                          StrongSelf;
                          self.isLoading = NO;
                          [self tt_endUpdataData:NO error:error];
                          [self.listView finishPullUpWithSuccess:!error];
                          self.listView.hasMore = hasMore;

                          if (!error) {
                            [self refreshListUI];
                            self.loadOffset += kLoadOnceCount;
                          }
                        }];
  // wrapperTrackEvent(@"update_detail", @"diggers_loadmore");
}

#pragma mark-- UITableViewDelegate & UITableVewDataSource

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  NSInteger count = [[self.diggManger diggUsers] count];
  if (self.diggManger.anonymousCount > 0) {
    count += 1;
  }
  return count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < [[self.diggManger diggUsers] count]) {
    return kCellHeight;
  }
  return kLoadMoreCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
  NSInteger count = [[self.diggManger diggUsers] count];
  if (count || self.diggManger.anonymousCount || self.isLoading) {
    return CGFLOAT_MIN;
  } else {
    return 155;
  }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForFooterInSection:(NSInteger)section {
  NSInteger count = [[self.diggManger diggUsers] count];
  if (count || self.diggManger.anonymousCount || self.isLoading) {
    return nil;
  }
  SSThemedView *footer = [[SSThemedView alloc]
      initWithFrame:CGRectMake(0, 0, tableView.width, 198)];
  footer.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
  label.textColorThemeKey = kColorText3;
  label.font = [UIFont systemFontOfSize:15.f];
  label.text = @"还没有人赞,快来点个赞吧!";
  [label sizeToFit];
  label.center = footer.center;
  [footer addSubview:label];

  return footer;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"ArticleMomentDigUsersViewCellIdentifier";
  static NSString *anonymousCountCellIdentifier =
      @"anonymousCountCellIdentifier";
  if (indexPath.row < [[self.diggManger diggUsers] count]) {
    FRThreadDigUsersViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
      cell = [[FRThreadDigUsersViewCell alloc]
            initWithStyle:UITableViewCellStyleDefault
          reuseIdentifier:cellIdentifier];
    }
    FRUserStructModel *digUser =
        [[self.diggManger diggUsers] objectAtIndex:indexPath.row];
    [cell refreshUserModel:digUser
                     width:[TTUIResponderHelper splitViewFrameForView:self]
                               .size.width
                   isOwner:[[digUser.user_id stringValue]
                               isEqualToString:self.authorUserID]];
    return cell;
  } else {
    UITableViewCell *anonymousCountCell = [tableView
        dequeueReusableCellWithIdentifier:anonymousCountCellIdentifier];
    if (!anonymousCountCell) {
      anonymousCountCell =
          [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:anonymousCountCellIdentifier];

      SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
      label.font =
          [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
      label.textColorThemeKey = kColorText1;
      label.tag = 1;
      [anonymousCountCell addSubview:label];
    }

    UILabel *label = (UILabel *)[anonymousCountCell viewWithTag:1];

    label.origin =
        CGPointMake(kCellAvatarViewLeftPadding + kCellAvatarViewWidth +
                        kCellAvatarViewRightPadding,
                    (kLoadMoreCellHeight - 12) / 2);

    label.text =
        [NSString stringWithFormat:NSLocalizedString(@"%d位游客也赞过", nil),
                                   self.diggManger.anonymousCount];
    [label sizeToFit];
    label.textColor =
        [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt]
                                        selectFromDayColorName:@"707070"
                                                nightColorName:@"505050"]];

    anonymousCountCell.backgroundColor = [UIColor clearColor];
    anonymousCountCell.backgroundView = nil;
    return anonymousCountCell;
  }
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[self.diggManger diggUsers] count]) {
        FRUserStructModel *digUser =
        [[self.diggManger diggUsers] objectAtIndex:indexPath.row];
        ArticleMomentProfileViewController *controller =
        [[ArticleMomentProfileViewController alloc]
         initWithUserID:[digUser.user_id stringValue]];
        controller.from = kFromFeedDetailDig;
        controller.fromPage = @"detail_topic_comment_dig";
        controller.categoryName = [self.trackExtra tt_stringValueForKey:@"category_id"];
        controller.groupId = @(self.threadID).stringValue;
        UINavigationController *topController =
        [TTUIResponderHelper topNavigationControllerFor:self];
        [topController pushViewController:controller animated:YES];
        
        [TTTrackerWrapper event:@"talk_detail"
                          label:@"diggers_profile"
                          value:@(self.threadID)
                       extValue:digUser.user_id
                      extValue2:nil
                           dict:self.trackExtra];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
