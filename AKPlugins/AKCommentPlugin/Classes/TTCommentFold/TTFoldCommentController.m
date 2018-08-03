//
//  TTFoldCommentController.m
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import "TTFoldCommentController.h"
#import "TTFoldCommentCell.h"
#import "TTFoldCommentControllerViewModel.h"
#import <TTThemed/SSThemed.h>
#import <TTRoute/TTRoute.h>
#import <TTUIWidget/UIViewController+Refresh_ErrorHandler.h>
#import <TTBaseLib/TTLabelTextHelper.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTUIWidget/TTUGCAttributedLabel.h>
#import <TTUIWidget/UIScrollView+Refresh.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>


@interface _TTFoldCommentTableViewHeader: SSThemedView<TTUGCAttributedLabelDelegate>
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedImageView *promptImageView;
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;
@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, copy) void(^linkTextOnClicked)();
@end

@implementation _TTFoldCommentTableViewHeader

- (void)dealloc {
    self.contentLabel.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.backgroundView];
//    [self addSubview:self.promptImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
//    [self addSubview:self.separator];
    self.separatorAtBottom = YES;
    self.borderColorThemeKey = kColorLine1;
    self.titleLabel.text = @"评论为什么被折叠？";
    [self reloadThemeUI];
//    __weak __typeof(self)weakSelf = self;
//    [self.contentLabel addLinkToURL:nil withRange:[self.contentLabel.attributedText.string rangeOfString:@"「评论为什么被折叠」"]].linkTapBlock = ^(TTUGCAttributedLabel *label, TTUGCAttributedLabelLink *link) {
//        if (weakSelf.linkTextOnClicked) {
//            weakSelf.linkTextOnClicked();
//        }
//    };
}

- (CGSize)sizeThatFits:(CGSize)size {
//    self.promptImageView.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:43.f], [TTDeviceUIUtils tt_newPadding:2.f]);
    CGFloat labelWidth = size.width - (2 * [TTDeviceUIUtils tt_newPadding:62.f]);
    self.titleLabel.frame = CGRectMake(nearbyint((size.width - labelWidth) / 2.f), 0, labelWidth, [TTDeviceUIUtils tt_newPadding:18.f]);
    CGSize contentSize = [TTUGCAttributedLabel sizeThatFitsAttributedString:self.contentLabel.attributedText withConstraints:CGSizeMake(labelWidth, CGFLOAT_MAX) limitedToNumberOfLines:0];
    self.contentLabel.width = ceil(contentSize.width);
    self.contentLabel.height = ceil(contentSize.height);
    self.contentLabel.centerX = CGRectGetMidX(self.bounds);
    self.contentLabel.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:4.f];
    size.height = self.contentLabel.bottom + [TTDeviceUIUtils tt_newPadding:23.f];
    return size;
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundView.bottom = 0.f;
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.contentLabel.attributedText = ({
        NSMutableAttributedString *attriText = [[NSMutableAttributedString alloc] initWithAttributedString:[TTLabelTextHelper attributedStringWithString:@"脏话、刻意人身攻击、没缘由的发泄性言辞，会被折叠" fontSize:[TTDeviceUIUtils tt_newFontSize:14.f] lineHeight:[TTDeviceUIUtils tt_newPadding:18.f]]];
        [attriText addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText1) range:NSMakeRange(0, attriText.length)];
        attriText.copy;
    });
//    self.contentLabel.linkAttributes = ({
//        NSMutableDictionary *linkAttr = [[NSMutableDictionary alloc] initWithCapacity:2];
//        [linkAttr setValue:@(NO) forKey:(NSString *)kCTUnderlineStyleAttributeName];
//        [linkAttr setValue:SSGetThemedColorWithKey(kColorText5) forKey:NSForegroundColorAttributeName];
//        [linkAttr copy];
//    });
//    self.contentLabel.activeLinkAttributes = ({
//        NSMutableDictionary *linkAttr = [[NSMutableDictionary alloc] initWithCapacity:2];
//        [linkAttr setValue:SSGetThemedColorWithKey(kColorText5Highlighted) forKey:NSForegroundColorAttributeName];
//        [linkAttr copy];
//    });
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        if ([TTDeviceHelper OSVersionNumber] >= 8.2f) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f] weight:UIFontWeightMedium];
#pragma clang diagnostic pop
        } else {
            _titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]];
        }
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0.f;
        _contentLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    }
    return _contentLabel;
}

- (SSThemedView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[SSThemedView alloc] init];
        _backgroundView.width = self.width;
        _backgroundView.height = [UIScreen mainScreen].bounds.size.height;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _backgroundView.backgroundColorThemeKey = kColorBackground4;
    }
    return _backgroundView;
}

- (SSThemedImageView *)promptImageView {
    if (!_promptImageView) {
        _promptImageView = [[SSThemedImageView alloc] init];
        _promptImageView.imageName = @"fold_comment_header";
        [_promptImageView sizeToFit];
    }
    return _promptImageView;
}
@end



@interface TTFoldCommentController ()<UITableViewDelegate, UITableViewDataSource, UIViewControllerErrorHandler, TTFoldCommentCellDelegate>
@property (nonatomic, strong) TTFoldCommentControllerViewModel *viewModel;
@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) _TTFoldCommentTableViewHeader *header;

@end

@implementation TTFoldCommentController

+ (void)load {
    RegisterRouteObjWithEntryName(@"fold_comment");
}

- (instancetype)initWithGroupID:(NSString *)groupID itemID:(NSString *)itemID aggrType:(NSInteger)aggrType zzids:(NSString *)zzids {
    self = [super init];
    if (self) {
        _viewModel = [[TTFoldCommentControllerViewModel alloc] initWithGroupID:groupID groupType:TTCommentsGroupTypeArticle itemID:itemID forumID:@"" aggrType:aggrType zzids:zzids];
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *param = paramObj.allParams;
        NSString *groupID = [param tt_stringValueForKey:@"groupID"];
        NSString *itemID = [param tt_stringValueForKey:@"itemID"];
        NSString *zzids = [param tt_stringValueForKey:@"zzids"];
        NSInteger aggrType = [param tt_integerValueForKey:@"aggrType"];
        TTCommentsGroupType groupType = [param tt_intValueForKey:@"groupType"];
        NSString *forumID = [param tt_stringValueForKey:@"forumID"];
        _viewModel = [[TTFoldCommentControllerViewModel alloc] initWithGroupID:groupID groupType:groupType itemID:itemID forumID:forumID aggrType:aggrType zzids:zzids];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self loadCommentIfNeed];
    self.ttNeedHideBottomLine = YES;
}

- (void)loadCommentIfNeed {
    __weak __typeof(self)weakSelf = self;
    if (!self.viewModel.layouts.count) {
        [self tt_startUpdate];
    }
    [self.viewModel loadCommentWithCompletionHandler:^(NSError *error, BOOL hasMore) {
        if (error) {
            return;
        }
        [weakSelf tt_endUpdataData];
        weakSelf.tableView.hasMore = hasMore;
        [weakSelf.tableView reloadData];
    }];
}

- (void)setupViews {
    self.viewModel.cellWidth = self.view.width;
    [self.view addSubview:self.tableView];
    __weak __typeof(self)weakSelf = self;
    self.header.linkTextOnClicked = ^(){
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
        [extra setValue:weakSelf.viewModel.itemID forKey:@"item_id"];
        wrapperTrackEventWithCustomKeys(@"fold_comment_reason", @"click", weakSelf.viewModel.groupID, nil, extra);
    };
}

#pragma mark - TTFoldCommentCellDelegate
- (void)commentCell:(TTFoldCommentCell *)cell avatarViewOnClickWithModel:(id<TTCommentModelProtocol>)model {
    if (![model conformsToProtocol:@protocol(TTCommentModelProtocol) ]) {
        return;
    }
    
    if ([model.userID longLongValue] <= 0) {
        return;
    }
    
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:model.userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://pgcprofile"] userInfo:TTRouteUserInfoWithDict(condition)];
}

- (void)commentCell:(TTFoldCommentCell *)cell nameViewOnClickWithModel:(id<TTCommentModelProtocol>)model {
    if (![model conformsToProtocol:@protocol(TTCommentModelProtocol) ]) {
        return;
    }
    
    if ([model.userID longLongValue] <= 0) {
        return;
    }
    
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:model.userID forKey:@"uid"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://pgcprofile"] userInfo:TTRouteUserInfoWithDict(condition)];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: impression
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: impression
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewModel.layouts[indexPath.row].cellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {

    if (section != 0) {
        return;
    }
    
    [self.viewModel sendHeaderShowTrackerIfNeed];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [TTDeviceUIUtils tt_newPadding:8.f];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.commentModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TTFoldCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTFoldCommentCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell refreshWithModel:self.viewModel.commentModels[indexPath.row] layout:self.viewModel.layouts[indexPath.row]];
    
    return cell;
}

#pragma mark - UIViewControllerErrorHandler
- (BOOL)tt_hasValidateData {
    return !!self.viewModel.layouts.count;
}

#pragma mark - getter & setter
- (SSThemedTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColorThemeKey = kColorBackground3;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.header;
        [_tableView registerClass:[TTFoldCommentCell class] forCellReuseIdentifier:kTTFoldCommentCellIdentifier];
        __weak __typeof(self)weakSelf = self;
        [_tableView tt_addPullUpLoadMoreWithNoMoreText:@"" withHandler:^{
            [weakSelf loadCommentIfNeed];
        }];
    }
    
    return _tableView;
}

- (_TTFoldCommentTableViewHeader *)header {
    if (!_header) {
        _header = [[_TTFoldCommentTableViewHeader alloc] init];
        _header.width = _tableView.width;
        [_header sizeToFit];
    }
    return _header;
}
@end
