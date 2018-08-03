//
//  TTVReplyView.m
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyView.h"
#import "SSNavigationBar.h"
#import "TTIndicatorView.h"
#import "TTUIResponderHelper.h"
#import "TTVReplyViewModel.h"
#import "TTVReplyListItem.h"
#import "TTVReplyListCell.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "NetworkUtilities.h"
#import "SSImpressionManager.h"
#import "TTCommentDetailModelProtocol.h"

#define kCellElementBgColorKey kColorBackground4

#define kPostCommentViewHeight 40

#define kCellAvatarViewLeftPadding          [TTDeviceUIUtils tt_paddingForMoment:15]

#define kSectionHeaderHeight                [TTDeviceUIUtils tt_paddingForMoment:40]

static CGFloat globalCustomWidth = 0;

extern CGFloat fr_postCommentButtonHeight(void);

@interface TTVReplyView()<UITableViewDelegate , UITableViewDataSource,SSImpressionProtocol>
{
    NSTimeInterval _midnightInterval;
}

@property (nonatomic, strong)SSNavigationBar    *navigationBar;

@property(nonatomic, assign)BOOL showWriteComment;
// 统计用 作者的mediaId，uid
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;

@property(nonatomic, assign)BOOL isViewAppear;

@property (nonatomic, strong) TTVReplyViewModel *viewModel;

@property (nonatomic, weak) id <TTVReplyListCellDelegate> cellDelegate;

@end

@implementation TTVReplyView
#pragma mark - Init

- (id)initWithFrame:(CGRect)frame viewModel:(TTVReplyViewModel *)viewModel showWriteComment:(BOOL)show cellDelegate:(id<TTVReplyListCellDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.viewModel = viewModel;
        self.cellDelegate = delegate;
        
        self.showWriteComment = show;
        [self commonInitialization];
        
        //注册Impression
        [self tt_registerToImpressionManager:self];
    }
    
    return self;
}

- (void)commonInitialization {
    
    [self commentListViewInitialization];
    
    [self postCommonButtonInitialization];
    id<TTVCommentModelProtocol, TTCommentDetailModelProtocol> commentModel = nil;
    if (self.viewModel.commentModel == nil || [self.viewModel.commentModel conformsToProtocol:@protocol(TTCommentDetailModelProtocol)]) {
        commentModel = (id<TTVCommentModelProtocol, TTCommentDetailModelProtocol> )self.viewModel.commentModel;
    } else {
        NSAssert(NO, @"please check model class whether conforms to TTCommentDetailModelProtocol");
    }
    
    if ([commentModel respondsToSelector:@selector(banEmojiInput)]) {
        self.toolBar.banEmojiInput = [commentModel banEmojiInput] || self.isBanEmoji;
    } else {
        self.toolBar.banEmojiInput = self.isBanEmoji;
    }

    [self reloadThemeUI];
    
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"没有网络连接", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged:) name:kSettingFontSizeChangedNotification object:nil];
}

- (void)commentListViewInitialization {
    
    UITableViewStyle style = UITableViewStyleGrouped;
    self.commentListView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.navigationBar.frame)) style:style];
    self.commentListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _commentListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _commentListView.delegate = self;
    _commentListView.dataSource = self;
    _commentListView.contentInset = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    _commentListView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, kPostCommentViewHeight, 0);
    [self addSubview:_commentListView];
}

- (void)postCommonButtonInitialization {
    CGFloat toolbarHeight = ExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    _toolBar = [[ExploreDetailToolbarView alloc] initWithFrame:CGRectMake(0, self.height - toolbarHeight, self.width, toolbarHeight)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolBar.toolbarType = ExploreDetailToolbarTypeCommentDetail;
    _toolBar.viewStyle = TTDetailViewStyleCommentDetail;
    [_toolBar.writeButton setTitle:NSLocalizedString(@"写评论...", nil) forState:UIControlStateNormal];
    [_toolBar.digButton addTarget:self action:@selector(toolbarDigButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.writeButton addTarget:self action:@selector(toolbarWriteButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar.emojiButton addTarget:self action:@selector(toolbarWriteButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _toolBar.digButton.selected = _viewModel.commentModel.userDigged;
    [self addSubview:_toolBar];
}

#pragma mark - Getters & Setters

#pragma mark - Life Cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.commentListView = nil;
    self.navigationBar = nil;
    self.loadMoreCell = nil;
    self.delegate = nil;
    self.cellDelegate = nil;
    
    //解除Impression
    [self tt_unregisterFromImpressionManager:self];
}

- (void)didAppear
{
    [super didAppear];
    _isViewAppear = YES;
    [self performSelector:@selector(markShowCommentViewTimeout) withObject:nil afterDelay:0.4];
    [self showWriteCommentIfNeed];
    
    //Impression进入
    [self tt_enterCommentImpression];
}

- (void)willDisappear{
    [super willDisappear];
    _isViewAppear = NO;
    
    //Impression退出
    [self tt_leaveCommentImpression];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice])
    {
        [_viewModel refreshLayoutsWithWidth:self.commentListView.width];
        [self.toolBar setNeedsLayout];
    }
}

- (void)setIsBanEmoji:(BOOL)isBanEmoji{
    _isBanEmoji = isBanEmoji;

    if ([self.viewModel.commentModel respondsToSelector:@selector(banEmojiInput)]) {
        self.toolBar.banEmojiInput = [self.viewModel.commentModel banEmojiInput] || _isBanEmoji;
    } else {
        self.toolBar.banEmojiInput = _isBanEmoji;
    }
}

#pragma mark - Public Methods

+ (void)configGlobalCustomWidth:(CGFloat)width
{
    globalCustomWidth = width;
}

- (void)reloadListViewData
{
    [self reloadThemeUI];
    [_commentListView reloadData];
    if ([self.viewModel needMarkedIndexPath]) {
        [_commentListView scrollToRowAtIndexPath:[self.viewModel needMarkedIndexPath] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Private Methods

static CGRect splitViewFrameForView(UIView *view)
{
    CGRect frame = [TTUIResponderHelper splitViewFrameForView:view];
    if (globalCustomWidth > 0) {
        frame.origin.x = (view.width - globalCustomWidth) / 2;
        frame.size.width = globalCustomWidth;
    }
    return frame;
}

- (void)markShowCommentViewTimeout {
    _showWriteComment = NO;
    _showComment = NO;
}

- (void)showWriteCommentIfNeed {
    if (_showWriteComment && !isEmptyString(self.viewModel.commentModel.commentIDNum.stringValue) && _isViewAppear) {
        _showWriteComment = NO;
        [self toolbarWriteButtonOnClicked:_toolBar.writeButton];
    }
}

- (TTVReplyListItem *)getCurReplyListItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.section == 0 && indexPath.row < [[_viewModel curHotReplyItems] count]) ||
        (indexPath.section == 1 && indexPath.row < [[_viewModel curAllReplyItems] count])) {
        
        return (indexPath.section == 0) ? [_viewModel curHotReplyItems][indexPath.row]:
        ((indexPath.section == 1) ? [_viewModel curAllReplyItems][indexPath.row]: nil);
    }
    
    return nil;
}

#pragma mark - UI

#pragma mark - Actions

- (void)themeChanged:(NSNotification *)notification
{
    _commentListView.backgroundColor = [UIColor tt_themedColorForKey:kCellElementBgColorKey];
}

- (void)fontSizeChanged:(NSNotification *)notification
{
//    [self refreshHeaderView];
    [self.commentListView reloadData];
}

- (void)toolbarWriteButtonOnClicked:(id)sender
{
    if ([_delegate respondsToSelector:@selector(replyView:commentButtonClicked:)]) {
        
        [_delegate replyView:self commentButtonClicked:sender];
    }
}

- (void)userInfoDiggButtonClicked:(UIButton *)sender{
    if (![sender isSelected]){
        wrapperTrackEvent(@"update_detail", @"top_digg_click");
    }
    
    if ([_delegate respondsToSelector:@selector(replyView:userInfoDiggButtonClicked:)]) {
        
        [_delegate replyView:self userInfoDiggButtonClicked:sender];
    }
}

- (void)toolbarDigButtonOnClicked:(id)sender {
        
    if ([_delegate respondsToSelector:@selector(replyView:userInfoDiggButtonClicked:)]) {
        
        [_delegate replyView:self userInfoDiggButtonClicked:nil];
    }
}

#pragma mark -- observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"diggUsers"] ||
        [keyPath isEqualToString:@"commentsCount"]) {
        [self reloadThemeUI];
    }
}

#pragma mark -- SSImpressionManager And Proctol

- (void)needRerecordImpressions
{
    if (self.isViewAppear) {
        for (id cell in [self.commentListView visibleCells]) {
            
            NSIndexPath *indexPath = [self.commentListView  indexPathForCell:cell];
            TTVReplyListItem *item = [self getCurReplyListItemAtIndexPath:indexPath];
            [self tt_recordForComment:item
                               status:SSImpressionStatusRecording];
        }
    }
}


- (void)tt_registerToImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] addRegist:object];
}

- (void)tt_unregisterFromImpressionManager:(id)object
{
    [[SSImpressionManager shareInstance] removeRegist:object];
}

- (void)tt_enterCommentImpression
{
    [[SSImpressionManager shareInstance] enterCommentViewForGroupID:self.viewModel.commentModel.groupModel.groupID];
}

- (void)tt_leaveCommentImpression
{
    [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:self.viewModel.commentModel.groupModel.groupID];
}

- (void)tt_recordForComment:(TTVReplyListItem *)replyItem status:(SSImpressionStatus)status
{
    if ([replyItem.model.commentID longLongValue] != 0 && self.viewModel.commentModel.groupModel.groupID != 0) {
        NSString * cIDStr = [NSString stringWithFormat:@"%@", replyItem.model.commentID];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:@"comment_detail" forKey:@"comment_position"];
        [extra setValue:@"comment_reply" forKey:@"comment_type"];
        [extra setValue:self.viewModel.commentModel.groupModel.itemID forKey:@"item_id"];
        [extra setValue:@(self.viewModel.commentModel.groupModel.aggrType) forKey:@"aggr_type"];
        [[SSImpressionManager shareInstance] recordCommentDetailReplyImpressionGroupID:self.viewModel.commentModel.groupModel.groupID commentID:cIDStr status:status userInfo:@{@"extra":extra}];
    }
}


#pragma mark - UITableViewDelegate , UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger hotComCnt = [_viewModel curHotReplyItems].count;
    NSUInteger comCnt = [_viewModel curAllReplyItems].count;
    
    if (section == 0) {
        return hotComCnt;
    } else {
        return comCnt + (_viewModel.hasMore ? 1 : 0);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([_viewModel curHotReplyItems].count == 0) {
            return 0.01;
        }
    } else {
        if ([_viewModel curAllReplyItems].count == 0) {
            return 0.01;
        }
    }
    return kSectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if ([_viewModel curHotReplyItems].count == 0) {
            return nil;
        }
    } else {
        if ([_viewModel curAllReplyItems].count == 0) {
            return nil;
        }
    }
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(splitViewFrameForView(self).origin.x, 0, splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(splitViewFrameForView(self).origin.x, 0, splitViewFrameForView(self).size.width, kSectionHeaderHeight)];
    [wrapperView addSubview:view];
    
    view.backgroundColorThemeKey = kCellElementBgColorKey;
    
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColorThemeKey = kCellElementBgColorKey;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.clipsToBounds = YES;
    
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSizeForMoment:16.f]];
    [wrapperView addSubview:titleLabel];
    
    if (section == 0) {
        titleLabel.text = NSLocalizedString(@"热门评论", nil);
    } else {
        titleLabel.text = NSLocalizedString(@"全部评论", nil);
    }
    [titleLabel sizeToFit];
    titleLabel.origin = CGPointMake(kCellAvatarViewLeftPadding + splitViewFrameForView(self).origin.x, [TTDeviceUIUtils tt_paddingForMoment:12.f]);
    
    return wrapperView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([_viewModel curHotReplyItems].count > 0 && indexPath.row < [_viewModel curHotReplyItems].count) {
            TTVReplyListItem *item = [[_viewModel curHotReplyItems] objectAtIndex:indexPath.row];
            return item.layout.cellHeight;
        } else {
            return 0;
        }
    } else {
        NSUInteger comCnt = [[_viewModel curAllReplyItems] count];
        if (comCnt == 0 && !_viewModel.hasMore) {
            return 0;
        }
        else if (indexPath.row < comCnt) {
            TTVReplyListItem *item = [[_viewModel curAllReplyItems] objectAtIndex:indexPath.row];
            return item.layout.cellHeight;
        }
        else {
            return kLoadMoreCellHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellIdentifier = @"kTTVReplyListCellIdentifier";
    static NSString * loadMoreCellIdentifier = @"loadMoreCellIdentifier";
    
    if ((indexPath.section == 0 && indexPath.row < [[_viewModel curHotReplyItems] count]) ||
        (indexPath.section == 1 && indexPath.row < [[_viewModel curAllReplyItems] count])) {
        
        TTVReplyListItem *item = [self getCurReplyListItemAtIndexPath:indexPath];
        if (_hasDeleteReplyPermission) {
            item.layout.deleteLayout.hidden = NO;
        }
        TTVReplyListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[TTVReplyListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.width = splitViewFrameForView(self).size.width;
        cell.delegate = self.cellDelegate;
        if (globalCustomWidth > 0) {
            cell.needMargin = NO;
        } else {
            cell.needMargin = YES;
        }
        
        if ([TTDeviceHelper isPadDevice]) {
            
            [item.layout setCellLayoutWithCommentModel:item.model containViewWidth:cell.width];
        }
        
        cell.item = item;
        
        return cell;
        
    } else {
        
        if (!self.loadMoreCell) {
            
            self.loadMoreCell = [[SSLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            self.loadMoreCell.labelStyle = SSLoadMoreCellLabelStyleAlignMiddle;
            [self.loadMoreCell addMoreLabel];
            self.loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return self.loadMoreCell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *needMarkedIndexPath = self.viewModel.needMarkedIndexPath;
    if (needMarkedIndexPath && [needMarkedIndexPath compare:indexPath] == NSOrderedSame) {
        self.viewModel.needMarkedIndexPath = nil;
        UIColor *previousColor = [cell.contentView.backgroundColor copy];
        [UIView animateWithDuration:0.35 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"0xFFFAD9"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35f animations:^{
                cell.contentView.backgroundColor = previousColor;
            }];
        }];
    }
    
    if (cell == self.loadMoreCell) {
        if (_viewModel.hasMore && ![_viewModel isLoading]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(replyView:loadMoreCellTrigger:)]) {
                [self.delegate replyView:self loadMoreCellTrigger:TTVReplyViewLoadMoreCellTriggerSourceCellWillDisplay];
            }
        }
    }
    else {
        
        TTVReplyListItem *item = [self getCurReplyListItemAtIndexPath:indexPath];
        [self tt_recordForComment:item
                           status:SSImpressionStatusRecording];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell != self.loadMoreCell) {

        TTVReplyListItem *item = [self getCurReplyListItemAtIndexPath:indexPath];
        [self tt_recordForComment:item
                           status:SSImpressionStatusEnd];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    wrapperTrackEvent(@"update_detail", @"reply_replier_content");
    
    TTVReplyListItem *item = [self getCurReplyListItemAtIndexPath:indexPath];
    
    if (!item) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(replyView:loadMoreCellTrigger:)]) {
            [self.delegate replyView:self loadMoreCellTrigger:TTVReplyViewLoadMoreCellTriggerSourceCellDidSelect];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if ([self.cellDelegate respondsToSelector:@selector(replyListCell:replyButtonClickedWithModel:)]) {
        [self.cellDelegate replyListCell:[tableView cellForRowAtIndexPath:indexPath] replyButtonClickedWithModel:item.model];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -- scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollViewDidScrollBlock) {
        self.scrollViewDidScrollBlock(scrollView);
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}

@end
