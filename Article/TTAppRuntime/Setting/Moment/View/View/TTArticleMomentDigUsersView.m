//
//  TTArticleMomentDigUsersView.m
//  Article
//
//  Created by zhaoqin on 27/12/2016.
//
//

#import "TTArticleMomentDigUsersView.h"
#import "SSThemed.h"
#import "ArticleAvatarView.h"
#import "SSUserModel.h"
#import "SSNavigationBar.h"
#import "ArticleMomentHelper.h"
#import "TTUserInfoView.h"

#import "TTDeviceUIUtils.h"
#import "UIScrollView+Refresh.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "UIColor+TTThemeExtension.h"


#import "TTRoute.h"

#define SIZE_FIT(size6, size5)
#define kLoadOnceCount 20

#define kLoadMoreCellHeight 44
#define kCellHeight [TTArticleMomentDigUsersViewCellUIHelper fitSizeWithiPhone6:52.f iPhone5:48.f]
#define kCellAvatarViewNormalLength 36.f
#define kCellRightPadding 15
#define kCellAvatarViewWidth [TTArticleMomentDigUsersViewCellUIHelper fitSizeWithiPhone6:36.f iPhone5:32.f]
#define kCellAvatarViewHeight [TTArticleMomentDigUsersViewCellUIHelper fitSizeWithiPhone6:36.f iPhone5:32.f]
#define kCellAvatarViewLeftPadding 15
#define kCellAvatarViewRightPadding 12
#define kCellNameLabelFontSize [TTArticleMomentDigUsersViewCellUIHelper fitSizeWithiPhone6:14.f iPhone5:13.f]
#define kCellDescLabelFontSize [TTArticleMomentDigUsersViewCellUIHelper fitSizeWithiPhone6:12.f iPhone5:12.f]
#define kCellNameLabelBottomPadding 5

@interface TTArticleMomentDigUsersViewCellUIHelper : NSObject
@end
@implementation TTArticleMomentDigUsersViewCellUIHelper
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

+ (CGSize)fitSizeForVerifyLogo:(CGSize)standardSize{
    CGFloat vWidth = ceil(standardSize.width * kCellAvatarViewWidth / kCellAvatarViewNormalLength);
    CGFloat vHeight = ceil(standardSize.height * kCellAvatarViewHeight / kCellAvatarViewNormalLength);
    return CGSizeMake(vWidth, vHeight);
}
@end

@interface TTArticleMomentDigUsersViewCell : SSThemedTableViewCell

@property(nonatomic, retain)TTUserInfoView * nameView;
@property(nonatomic, retain)SSThemedLabel * descLabel;
@property(nonatomic, retain)ArticleAvatarView * avatarView;
@property(nonatomic, retain)SSUserModel * userModel;
@property(nonatomic, assign)BOOL isBanShowAuthor;

@end

@implementation TTArticleMomentDigUsersViewCell

- (void)dealloc {
    self.userModel = nil;
    self.nameView = nil;
    self.descLabel = nil;
    self.avatarView = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (![SSCommonLogic transitionAnimationEnable]){
            self.backgroundSelectedColorThemeKey = kColorBackground10Highlighted;
        }
        self.backgroundColorThemeKey = kColorBackground4;
        self.needMargin = YES;
        self.avatarView = [[ArticleAvatarView alloc] initWithFrame:CGRectMake(kCellAvatarViewLeftPadding, 0, kCellAvatarViewWidth, kCellAvatarViewHeight)];
        self.avatarView.centerY = self.centerY;
        _avatarView.avatarStyle = SSAvatarViewStyleRound;
        _avatarView.avatarImgPadding = 0.f;
        
        _avatarView.userInteractionEnabled = NO;
        _avatarView.avatarButton.enabled = NO;
        [_avatarView setupVerifyViewForLength:kCellAvatarViewNormalLength adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTArticleMomentDigUsersViewCellUIHelper fitSizeForVerifyLogo:standardSize];
        }];
        [self.contentView addSubview:_avatarView];
        
        self.descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:kCellDescLabelFontSize];
        _descLabel.textColorThemeKey = kColorText3;
        _descLabel.numberOfLines = 1;
        [self.contentView addSubview:_descLabel];
    }
    return self;
}

- (CGRect)_separatorLineFrame {
    CGFloat left = kCellAvatarViewLeftPadding + kCellAvatarViewWidth + kCellAvatarViewRightPadding;
    return CGRectMake(left, self.height - [TTDeviceHelper ssOnePixel], self.width - left, [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshUserModel:self.userModel width:CGRectGetWidth(self.frame)];
//    self.frame = [TTUIResponderHelper splitViewFrameForView:self];
}

- (void)refreshUserModel:(SSUserModel *)userModel width:(CGFloat)width {
    self.userModel = userModel;
    
    [_avatarView showAvatarByURL:userModel.avatarURLString];
    [_avatarView showOrHideVerifyViewWithVerifyInfo:userModel.userAuthInfo decoratorInfo:userModel.userDecoration sureQueryWithID:YES userID:nil];
    
    NSString *text = [userModel.name isKindOfClass:[NSString class]] ? userModel.name : nil;
    CGFloat maxWidth = width - CGRectGetMaxX(_avatarView.frame) - kCellAvatarViewRightPadding - kCellRightPadding;
    if (!_nameView) {
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(_avatarView.right + kCellAvatarViewRightPadding, 0) maxWidth:maxWidth limitHeight:kCellNameLabelFontSize + 2 title:text fontSize:kCellNameLabelFontSize verifiedInfo:nil appendLogoInfoArray:userModel.authorBadgeList];
        _nameView.isBanShowAuthor = self.isBanShowAuthor;
        [_nameView setTextColorThemedKey:kColorText1];
        [self.contentView addSubview:_nameView];
    }
    else {
        _nameView.isBanShowAuthor = self.isBanShowAuthor;
        [_nameView refreshWithTitle:text relation:[self getRelationStr:userModel] verifiedInfo:nil verified:NO owner:userModel.isOwner maxWidth:0 appendLogoInfoArray:userModel.authorBadgeList];
    }

    [_nameView clickTitleWithAction:^(NSString *title) {
        NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
        [baseCondition setValue:userModel.ID forKey:@"uid"];
        [baseCondition setValue:kFromFeedDetailDig forKey:@"from"];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
        wrapperTrackEvent(@"update_detail", @"diggers_profile");
    }];
    _avatarView.left = kCellAvatarViewLeftPadding;
    _avatarView.centerY = self.contentView.centerY;
    NSString *descStr = nil;
    if (!isEmptyString(userModel.verifiedReason)) {
        descStr = userModel.verifiedReason;
    } else if (!isEmptyString(userModel.userDescription)) {
        descStr = userModel.userDescription;
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

- (NSString *)getRelationStr:(SSUserModel *)userModel {
    NSString *relation = nil;
    if (userModel.isFollowing && userModel.isFollowed) {
        relation = @"(互相关注)";
    }
    if(userModel.isFollowing && !userModel.isFollowed) {
        relation = @"(已关注)";
    }
    return relation;
}
@end

@interface TTArticleMomentDigUsersView()<UITableViewDataSource, UITableViewDelegate, UIViewControllerErrorHandler>

@property(nonatomic, strong) NSString *commentID;
@property(nonatomic, assign) NSUInteger loadOffset;
@property(nonatomic, assign)BOOL isLoading;
@end
@implementation TTArticleMomentDigUsersView

- (void)dealloc
{
    self.diggManger = nil;
    
    _listView.delegate = nil;
    _listView.dataSource = nil;
    self.listView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame commentID:(NSString *)commentID {
    self = [self initWithFrame:frame];
    if (self) {
        _commentID = commentID;
        _diggManger = [[ArticleMomentDiggManager alloc] initWithCommentID:_commentID];
        [self refreshData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.loadOffset = 0;
        
        self.listView = [[SSThemedTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.backgroundColorThemeKey = kColorBackground4;
        _listView.hasMore = YES;
        _listView.contentInset = UIEdgeInsetsMake(_listView.contentInset.top, _listView.contentInset.left, _listView.contentInset.bottom + [UIApplication sharedApplication].delegate.window.tt_safeAreaInsets.bottom, _listView.contentInset.right);
        [self addSubview:_listView];
        
        __weak typeof(self) wself = self;
        [self.listView tt_addDefaultPullUpLoadMoreWithHandler:^{
            [wself loadMoreData];
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.listView.frame = self.bounds;
    [self.listView setNeedsLayout];
}

- (void)leftButtonClicked {
    [[TTUIResponderHelper topNavigationControllerFor: self] popViewControllerAnimated:YES];
}


- (void)refreshListUI {
    [_listView reloadData];
}

- (NSArray *)currentMomentDiggUsers {
    return [self.diggManger diggUsers];
}

- (SSUserModel *)userForIndex:(NSUInteger)index {
    if (index < [[self currentMomentDiggUsers] count]) {
        SSUserModel * model = [[self currentMomentDiggUsers] objectAtIndex:index];
        return model;
    }
    return nil;
}

- (BOOL)tt_hasValidateData {
    return YES;
}

- (void)refreshData {
    if (self.isLoading) {
        return;
    }
    [self tt_startUpdate];
    __weak typeof(self) wself = self;
    [self.diggManger startGetDiggedUsersWithOffset:0 count:kLoadOnceCount finishBlock:^(NSArray *users, NSInteger totalCount, NSInteger anonymousCount, BOOL hasMore, NSError *error) {
        wself.isLoading = NO;
        [wself tt_endUpdataData:NO error:error];
        [wself.listView finishPullDownWithSuccess:!error];
        wself.listView.hasMore = hasMore;
        
        if (!error) {
            wself.loadOffset = kLoadOnceCount;
            [wself refreshListUI];
        }
        else {
            wself.loadOffset = 0;
        }
    }];
}

- (void)loadMoreData {
    if (self.isLoading) {
        return;
    }
    [self tt_startUpdate];
    __weak typeof(self) wself = self;
    [self.diggManger startGetDiggedUsersWithOffset:(int)_loadOffset count:kLoadOnceCount finishBlock:^(NSArray *users, NSInteger totalCount, NSInteger anonymousCount, BOOL hasMore, NSError *error) {
        wself.isLoading = NO;
        [wself tt_endUpdataData:NO error:error];
        [wself.listView finishPullUpWithSuccess:!error];
        wself.listView.hasMore = hasMore;
        
        if (!error) {
            [wself refreshListUI];
            wself.loadOffset += kLoadOnceCount;
        }
    }];
    wrapperTrackEvent(@"update_detail", @"diggers_loadmore");
}

#pragma mark -- UITableViewDelegate & UITableVewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[self.diggManger diggUsers] count];
    if(self.diggManger.anonymousCount > 0) {
        count += 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[self.diggManger diggUsers] count]) {
        return kCellHeight;
    }
    return kLoadMoreCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSInteger count = [[self.diggManger diggUsers] count];
    if (count || self.diggManger.anonymousCount) {
        return CGFLOAT_MIN;
    }
    return 155;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSInteger count = [[self.diggManger diggUsers] count];
    if (count || self.diggManger.anonymousCount) {
        return nil;
    }
    SSThemedView *footer = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 198)];
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    label.textColorThemeKey = kColorText3;
    label.font = [UIFont systemFontOfSize:15.f];
    label.text = @"还没有人赞,快来点个赞吧!";
    [label sizeToFit];
    label.center = footer.center;
    [footer addSubview:label];
    
    return footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"ArticleMomentDigUsersViewCellIdentifier";
    static NSString * anonymousCountCellIdentifier = @"anonymousCountCellIdentifier";
    if (indexPath.row < [[self.diggManger diggUsers] count]) {
        TTArticleMomentDigUsersViewCell * cell  = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[TTArticleMomentDigUsersViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        SSUserModel * digUser = [[self.diggManger diggUsers] objectAtIndex:indexPath.row];
        cell.isBanShowAuthor = self.isBanShowAuthor;
        [cell refreshUserModel:digUser width:[TTUIResponderHelper splitViewFrameForView:self].size.width];
        return cell;
    }
    else {
        UITableViewCell *anonymousCountCell = [tableView dequeueReusableCellWithIdentifier:anonymousCountCellIdentifier];
//        anonymousCountCell.frame = [TTUIResponderHelper splitViewFrameForView:anonymousCountCell];
        if(!anonymousCountCell) {
            anonymousCountCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:anonymousCountCellIdentifier];
            
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
            label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
            label.textColorThemeKey = kColorText1;
            label.tag = 1;
            [anonymousCountCell addSubview:label];
        }
        
        SSThemedLabel *label = (SSThemedLabel *)[anonymousCountCell viewWithTag:1];
        
        label.text = [NSString stringWithFormat:NSLocalizedString(@"%d位游客也赞过", nil), self.diggManger.anonymousCount];
        [label sizeToFit];
        label.textColorThemeKey = kColorText1;
        label.centerY = anonymousCountCell.height / 2;
        label.left = 18;
        
        anonymousCountCell.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        anonymousCountCell.backgroundView = nil;
        
        
        return anonymousCountCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[self.diggManger diggUsers] count]) {
        SSUserModel * digUser = [[self.diggManger diggUsers] objectAtIndex:indexPath.row];
        NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
        [baseCondition setValue:digUser.ID forKey:@"uid"];
        [baseCondition setValue:kFromFeedDetailDig forKey:@"from"];
        [baseCondition setValue:self.categoryName forKey:@"category_name"];
        [baseCondition setValue:self.fromPage forKey:@"from_page"];
        [baseCondition setValue:self.groupId forKey:@"group_id"];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://profile"] userInfo:TTRouteUserInfoWithDict(baseCondition)];
        wrapperTrackEvent(@"update_detail", @"diggers_profile");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
