//
//  ExploreCommentView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-21.
//
//

#import "ExploreCommentView.h"
#import "SSCommentModel.h"
#import "ExploreCommentCell.h"
#import "ArticleCommentHeaderView.h"
#import "SSCommentInputHeader.h"

#import "NetworkUtilities.h"
#import "UIImageAdditions.h"
#import "NewsUserSettingManager.h"
#import "SSImpressionManager.h"
#import "ArticleImpressionHelper.h"
#import "ExploreDeleteManager.h"
#import "SSUserModel.h"

#import <TTAccountBusiness.h>

#import "TTCommentWriteView.h"

#import "ExploreCommentTagView.h"

//#import "FRRouteHelper.h"
#import "UIScrollView+Refresh.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"

#import "TTRoute.h"
#import "TTForumModel.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#define kCommentViewLoadMoreCellHeight 44.f

#define kCommentViewEmptyMinHeight 200.f

#define kCommentViewPullToActionHeight 60.f

#define CommentHeaderCellSpacing 20

#define kDeleteCommentActionSheetTag 10

typedef enum ExploreCommentEmptyViewType{
    ExploreCommentEmptyViewTypeHidden,
    ExploreCommentEmptyViewTypeEmpty,
    ExploreCommentEmptyViewTypeNotNetwork,
    ExploreCommentEmptyViewTypeFailed,
    ExploreCommentEmptyViewShowForceShowCommentButton,
    ExploreCommentEmptyViewTypeLoading,
}ExploreCommentEmptyViewType;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreCommentSectionCellView : SSViewBase
@property(nonatomic, strong)ArticleCommentHeaderView * headerView;
@property(nonatomic, strong)UIView *bottomLineView;
@property(nonatomic, strong)UIView *bottomRedLineView;
@end

@implementation ExploreCommentSectionCellView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headerView = [[ArticleCommentHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        CGFloat lineOriY = self.headerView.height-1;
        self.bottomRedLineView = [[UIView alloc] initWithFrame:CGRectMake(15.f, lineOriY, 32, [TTDeviceHelper ssOnePixel])];
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(47.f, lineOriY, self.width - 62, [TTDeviceHelper ssOnePixel])];
        [self addSubview:_headerView];
        [self addSubview:_bottomRedLineView];
        [self addSubview:_bottomLineView];
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _bottomRedLineView.backgroundColor = SSGetThemedColorWithKey(kColorLine2);
    _bottomLineView.backgroundColor = SSGetThemedColorWithKey(kColorLine10);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ExploreCommentSectionCell : SSThemedTableViewCell
@property(nonatomic, strong)ExploreCommentSectionCellView *sectionCellView;
@end

@implementation ExploreCommentSectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.sectionCellView = [[ExploreCommentSectionCellView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), [ArticleCommentHeaderView heightForHeaderView])];
        [self.contentView addSubview:self.sectionCellView];
        [self themeChanged:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - ExploreCommentEmptyView

@class ExploreCommentEmptyView;

@protocol ExploreCommentEmptyViewDelegate <NSObject>

- (void)emptyView:(ExploreCommentEmptyView *)view buttonClickedForType:(ExploreCommentEmptyViewType)type;

@end

@interface ExploreCommentEmptyView : SSViewBase

@property(nonatomic, strong)UIImageView * emptyImageView;
@property(nonatomic, strong)UILabel * emptyTipLabel;
@property(nonatomic, strong)UIButton * emptyButton;
@property(nonatomic, strong)UIActivityIndicatorView *indicator;
@property(nonatomic, strong)ExploreCommentSectionCellView *sectionCellView;
@property(nonatomic, weak)id<ExploreCommentEmptyViewDelegate>delegate;
#pragma mark -- private
@property(nonatomic, assign)ExploreCommentEmptyViewType type;

- (void)refreshType:(ExploreCommentEmptyViewType)type;

@end

@implementation ExploreCommentEmptyView

- (void)dealloc
{
    
    self.delegate = nil;
    [_emptyButton removeObserver:self forKeyPath:@"highlighted"];
    self.emptyButton = nil;
    self.emptyTipLabel = nil;
    self.emptyImageView = nil;
    self.sectionCellView = nil;
    self.indicator = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _emptyTipLabel.centerX = self.centerX;
    _emptyButton.centerX = self.centerX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.sectionCellView = [[ExploreCommentSectionCellView alloc] initWithFrame:CGRectMake(0, 0, self.width, [ArticleCommentHeaderView heightForHeaderView])];
        [_sectionCellView.headerView refreshTitle:@"评论"];
        [self addSubview:_sectionCellView];
        
        // emptyButton
        self.emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.frame = CGRectMake(0, _sectionCellView.height, self.width, self.height);
        _emptyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _emptyButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _emptyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _emptyButton.backgroundColor = [UIColor clearColor];
        [_emptyButton addTarget:self action:@selector(emptyButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_emptyButton addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
        [self addSubview:_emptyButton];
        
        // emptyImageView
        self.emptyImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_emptyImageView];
        
        // emptyTipLabel
        self.emptyTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyTipLabel.backgroundColor = [UIColor clearColor];
        _emptyTipLabel.font = [UIFont systemFontOfSize:15.f];
        _emptyTipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyTipLabel];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
        [self addSubview:_indicator];

        [self reloadThemeUI];
    }
    return self;
}

- (void)emptyButtonClicked
{
    if (_delegate && [_delegate respondsToSelector:@selector(emptyView:buttonClickedForType:)]) {
        [_delegate emptyView:self buttonClickedForType:_type];
    }
}

- (void)forceShowCommentButtonClicked
{
    if (_delegate && [_delegate respondsToSelector:@selector(emptyView:buttonClickedForType:)]) {
        [_delegate emptyView:self buttonClickedForType:_type];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    _emptyTipLabel.textColor = SSGetThemedColorWithKey(kColorText5);
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    [self refreshType:_type];
}

- (void)refreshType:(ExploreCommentEmptyViewType)type
{
    self.type = type;
    _emptyImageView.hidden = NO;
    _emptyTipLabel.hidden = NO;
    _emptyTipLabel.backgroundColor = [UIColor clearColor];
    _emptyButton.enabled = YES;
    [_indicator stopAnimating];
    switch (type) {
            case ExploreCommentEmptyViewTypeEmpty:
        {
//            _emptyImageView.hidden = YES;
            _emptyImageView.image = [UIImage themedImageNamed:@"soft_details.png"];
            _emptyTipLabel.text = NSLocalizedString(@"暂无评论，点击抢沙发", nil);
            _emptyTipLabel.size = CGSizeMake(130, 30);
            [self _changEmptyTipLabelControlStateTo:UIControlStateNormal];
            [_emptyTipLabel sizeToFit];
            
        }
            break;
            case ExploreCommentEmptyViewTypeLoading:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.hidden = YES;
            [_indicator startAnimating];
        }
            break;
            case ExploreCommentEmptyViewTypeNotNetwork:
        {
            _emptyImageView.hidden = YES;
            _emptyTipLabel.text = NSLocalizedString(@"没有网络连接", nil);
            [_emptyTipLabel sizeToFit];
        }
            break;
        case ExploreCommentEmptyViewTypeFailed:
        {
            _emptyTipLabel.text = NSLocalizedString(@"网络连接异常，点击重试", nil);
            [_emptyTipLabel sizeToFit];
        }
            break;
            case ExploreCommentEmptyViewShowForceShowCommentButton:
        {
            _emptyImageView.image = [UIImage themedImageNamed:@"review_details.png"];
            _emptyTipLabel.text = NSLocalizedString(@"点击显示评论", nil);
            _emptyTipLabel.size = CGSizeMake(130, 30);
            [self _changEmptyTipLabelControlStateTo:UIControlStateNormal];
        }
            break;
            case ExploreCommentEmptyViewTypeHidden:
        {
        }
            break;
        default:
            break;
    }
    [_emptyImageView sizeToFit];
    _emptyImageView.origin = CGPointMake((self.frame.size.width - _emptyImageView.frame.size.width) / 2.f, 30 + _sectionCellView.height);
    _emptyTipLabel.origin = CGPointMake((self.frame.size.width - _emptyTipLabel.frame.size.width) / 2.f, 24.f + _sectionCellView.height);
    _indicator.center = _emptyTipLabel.center;
    self.hidden = NO;
}

#pragma mark -- kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"highlighted"]) {
        BOOL isHighlighted = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isHighlighted) {
            [self _changEmptyTipLabelControlStateTo:UIControlStateHighlighted];
        }
        else {
            [self _changEmptyTipLabelControlStateTo:UIControlStateNormal];
        }
    }
}

- (void)_changEmptyTipLabelControlStateTo:(UIControlState)state {
    if (self.type == ExploreCommentEmptyViewShowForceShowCommentButton) {
        
        UIImage * backgroundImage = nil;
        if (state == UIControlStateNormal) {
            backgroundImage = [UIImage imageWithSize:CGSizeMake(130, 30)
                                        cornerRadius:0
                                         borderWidth:0
                                         borderColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e7e7e7" nightColorName:@"303030"]]
                                    backgroundColors:@[
                                                       [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"fafafa" nightColorName:@"2b2b2b"]],
                                                       [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f8f8f8" nightColorName:@"252525"]]]];
        }
        else {
            backgroundImage = [UIImage imageWithSize:CGSizeMake(130, 30)
                                        cornerRadius:0
                                         borderWidth:0
                                         borderColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"e7e7e7" nightColorName:@"303030"]]
                                     backgroundColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f5f5f5" nightColorName:@"2b2b2b"]]];
        }
        _emptyTipLabel.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    else {
        _emptyTipLabel.backgroundColor = [UIColor clearColor];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface ExploreCommentView()<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, ExploreCommentViewCellBaseDelegate, ExploreCommentEmptyViewDelegate, TTCommentWriteManagerDelegate, ExploreCommentTagViewDelegate, UIActionSheetDelegate>

@property(nonatomic, strong, readwrite)UITableView * commentTableView;

@property(nonatomic, strong)UIView * tableHeaderContainerView;
@property(nonatomic, strong)ExploreCommentEmptyView * emptyView;
@property(nonatomic, assign)BOOL enableImpressionRecording; //default is NO
@property(nonatomic, assign)BOOL isEssay;

@property(nonatomic, strong)UIPopoverController * padAccountPopOverController;
// Ugly code for bug fix
@property(nonatomic, weak)ExploreCommentCell * currentClickedCell;

@property(nonatomic, strong)SSCommentModel * needDeleteCommentModel;
@end


#pragma mark - SSCommentView
@interface ExploreCommentView () {
    BOOL _scrollToTopComment;
    BOOL _scrollToTopCommentWithAnimation;
    BOOL _isShowingForController;       //是否给用户展示了， 即使为yes,也不一定已经展示给了用户，还需要判断_isShowingForNatant = YES
    BOOL _isShowingForNatant;           //是否给用户展示了， 即使为yes,也不一定已经展示给了用户，还需要判断_isShowingForController = YES
    
}

@property (nonatomic, strong) NSIndexPath *selectedCommentIndexPath;
@property (nonatomic, strong) ExploreCommentTagView * commentTagView;

@property (nonatomic, strong) TTCommentWriteView *commentWriteView;

@end
@implementation ExploreCommentView

- (void)dealloc
{
    [self.commentManager removeObserver:self forKeyPath:@"changedFlag"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)unregisterFromImpressionManager {
    if (_enableImpressionRecording) {
        [[SSImpressionManager shareInstance] removeRegist:self];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame enableImpressionRecording:NO];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame enableImpressionRecording:(BOOL)enable
{
    self = [self initWithFrame:frame commentManager:nil fromEssay:NO enableImpressionRecording:enable];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame commentManager:(SSCommentManager *)manager
{
    self = [self initWithFrame:frame commentManager:manager fromEssay:NO enableImpressionRecording:NO];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame commentManager:(SSCommentManager *)manager fromEssay:(BOOL)isEssay
{
    self = [self initWithFrame:frame commentManager:manager fromEssay:isEssay enableImpressionRecording:NO];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame commentManager:(SSCommentManager *)manager fromEssay:(BOOL)isEssay enableImpressionRecording:(BOOL)enable
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableImpressionRecording = enable;
        _enableInputedScrollToComment = NO;
        _isEssay = isEssay;
        self.backgroundColor = [UIColor redColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged:) name:kSettingFontSizeChangedNotification object:nil];
        
        if (manager != nil) {
            self.commentManager = manager;
        }
        else {
            self.commentManager = [[SSCommentManager alloc] init];
        }
        
        [self.commentManager addObserver:self forKeyPath:@"changedFlag" options:NSKeyValueObservingOptionNew context:nil];
        
        self.commentTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _commentTableView.backgroundView = nil;
        _commentTableView.backgroundColor = [UIColor clearColor];
        _commentTableView.delegate = self;
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTableView.dataSource = self;
        _commentTableView.estimatedRowHeight = 0;
        _commentTableView.estimatedSectionFooterHeight = 0;
        _commentTableView.estimatedSectionHeaderHeight = 0;
        if ([TTDeviceHelper isPadDevice]) {
            _commentTableView.showsVerticalScrollIndicator = NO;
        }
        __weak typeof(self) wself = self;
        [_commentTableView tt_addPullUpLoadMoreWithNoMoreText:@"已显示全部评论" withHandler:^{
            
            __strong typeof(self) sself = wself;
            
            BOOL needLoadingUpdate = [sself.commentManager needLoadingUpdateCommentModels];
            BOOL needLoadingMore = [sself.commentManager needLoadingMoreCommentModels];
            
            if (!sself.commentManager.loading && (needLoadingUpdate || needLoadingMore)) {
                //新鲜列表自动load more

                if ([sself.commentManager curCommentModels].count > 0) {
                    [wself commentWillLoadMore];
                }
                    
                [sself.commentManager loadMore];
                 
            }
            else {
                [sself.commentTableView finishPullUpWithSuccess:NO];
            }

        }];

        _commentTableView.hasMore = YES;
        
        
//        //非段子引用时初始化设置NO防止文章较短时评论成为firstResponder
        _commentTableView.scrollEnabled = _isEssay;
        _commentTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_commentTableView];
        
        if (_enableImpressionRecording) {
            [[SSImpressionManager shareInstance] addRegist:self];
        }
        
        if (manager != nil) {
            [_commentTableView reloadData];
        }
        [self reloadThemeUI];
    }
    return self;
}


- (void)commentTagViewRefreshWithIndex:(NSInteger)index
{
    self.commentManager.curTabIndex = index;
    if (![_commentManager currentCommentManagerObject].hasReload) {
        [self.commentManager reloadCommentWithTagIndex:_commentManager.curTabIndex];
    }
    else {
        [self.commentManager forceCurrentObjectShouldLoadMore];
        [self reloadData];
    }
}
- (void)fontChanged:(NSNotification*)notification
{
    [_commentTableView reloadData];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self trySSLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        _commentTagView.frame = CGRectMake(self.width - 87, 21, 72, 20);
    }
}

- (void)ssLayoutSubviews
{
    [super ssLayoutSubviews];
    // _padCommentInputView.frame = [self frameForPadCommentInputView];
}

- (void)commentWillLoadMore
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewWillLoadMore:)]) {
        [_delegate performSelector:@selector(commentViewWillLoadMore:) withObject:self];
    }
}

- (void)willAppear
{
    [super willAppear];
    _isShowingForController = YES;
    
    if (_enableImpressionRecording && _isShowingForNatant) {
        [[SSImpressionManager shareInstance] enterCommentViewForGroupID:self.commentManager.groupModel.impressionDescription];
    }

    //清除选中的comment标记
    [self clearSelectedCommentIndexPath];
}

- (void)willDisappear
{
    [super willDisappear];
    _isShowingForController = NO;
    
    if (_enableImpressionRecording) {
        [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:self.commentManager.groupModel.impressionDescription];
    }
}

#pragma mark -- public

- (void)showStatusChanged:(BOOL)isShowing
{
    if (_isShowingForNatant == isShowing) {
        return;
    }
    _isShowingForNatant = isShowing;
    if (_enableImpressionRecording) {
        if (isShowing) {
            if (_isShowingForController) {
                [[SSImpressionManager shareInstance] enterCommentViewForGroupID:self.commentManager.groupModel.impressionDescription];
            }
        }
        else {
            [[SSImpressionManager shareInstance] leaveCommentViewForGroupID:self.commentManager.groupModel.impressionDescription];
        }
    }
}

- (void)scrollToOriginY:(CGFloat)originY animated:(BOOL)animated
{
    [_commentTableView setContentOffset:CGPointMake(0, originY) animated:animated];
}

- (void)scrollToRecentCommentAnimated:(BOOL)animated
{
    //有最新评论
    if ([_commentManager numberOfRowsForCurCommentManagerObject] > 0) {
        [_commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:([_commentTableView numberOfSections] - 1)] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (void)scrollToTopCommentAnimated:(BOOL)animated {
    _scrollToTopComment = YES;
    _scrollToTopCommentWithAnimation = animated;
    
    [self _scrollToTopCommentAnimated:animated];
}

- (void)_scrollToTopCommentAnimated:(BOOL)animated
{
    NSInteger hotSectionIndex = [_commentTableView numberOfSections] - 2;
    
    if ([_commentManager numberOfRowsForCurCommentManagerObject] > 0 && hotSectionIndex >= 0) {
        [_commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:hotSectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
    else if ([_commentTableView numberOfSections] > 0 && [_commentTableView numberOfRowsInSection:0] > 0){
        [_commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (void)scrollToTopHeaderAnimated:(BOOL)animated
{
    if ([_commentTableView numberOfSections] > 0 && [_commentTableView numberOfRowsInSection:0] > 0) {
        [_commentTableView setContentOffset:CGPointMake(0, 0) animated:animated];
    }
}

- (void)tryForceShowAndReload
{
    if (!_commentManager.forceShowComment) {
        self.commentManager.forceShowComment = YES;
        [self reloadData];
    }
}

- (void)reloadData
{
    [_commentTableView reloadData];
}

- (void)setScrollToTopEnable:(BOOL)enable
{
    _commentTableView.scrollsToTop = enable;
}

- (void)clearSelectedCommentIndexPath
{
    self.selectedCommentIndexPath = nil;
}

- (void)recordSelectedCommentIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCommentIndexPath = indexPath;
}

- (void)addHeaderView:(UIView *)headerView
{
    _commentTableView.tableHeaderView = nil;
    self.tableHeaderContainerView = nil;
    self.tableHeaderContainerView = headerView;
    
    _commentTableView.tableHeaderView = _tableHeaderContainerView;
    [self reloadFooterViewIfNeeded];
}

- (void)reloadFooterViewIfNeeded
{
    //解决空评论文章更新headerView后没有刷新footerView高度的问题
    if (_tableHeaderContainerView.height > 0 &&
        [_commentManager curCommentModels].count == 0) {
        [self reloadData];
    }
}

- (void)openReplyInputViewWithGroupModel:(TTGroupModel *)groupModel
                         commentModel:(SSCommentModel *)model
                          bannComment:(BOOL)bann
                              itemTag:(NSString *)tag
{
    NSString *text = model.commentContent;
    
    if([text length] > forwardCommentMaxLength)
    {
        text = [NSString stringWithFormat:@"%@...", [text substringToIndex:forwardCommentMaxLength]];
    }
    
    NSString * userName = [model.userName length] > 0 ? model.userName : @"";
    NSString *content = [NSString stringWithFormat:@" //@%@:%@", userName, text];
    NSString * cID = [NSString stringWithFormat:@"%@", model.commentID];
    
    [self openInputViewWithContent:content
                        inputTitle:sReplyCommentTitle
                           groupModel:groupModel
                         commentID:cID
                           itemTag:tag
                   itemBannComment:bann];
}

- (void)openCommentWithCondition:(NSDictionary *)condition {
    TTGroupModel *groupModel = [condition tt_objectForKey:kQuickInputViewConditionGroupModel];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = groupModel.groupID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:nil];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.banEmojiInput = self.banEmojiInput;
    [self.commentWriteView showInView:topController.view animated:YES];
}


- (void)openInputViewWithContent:(NSString *)content
                      inputTitle:(NSString *)title
                         groupModel:(TTGroupModel *)groupModel
                       commentID:(NSString *)cID
                         itemTag:(NSString *)iTag
                 itemBannComment:(BOOL)bann
{
//    if (self.commentManager.bannComment || bann) {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:sBannCommentTip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
//        return;
//    }
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:3];
    [condition setValue:groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:content forKey:kQuickInputViewConditionInputViewText];
    if (!isEmptyString(cID)) {
        [condition setValue:cID forKey:kQuickInputViewConditionReplyToCommentID];
    }
    
    
    if (!isEmptyString(iTag)) {
        [condition setValue:iTag forKey:kQuickInputViewConditionItemTag];
    }
    
    [condition setValue:@(self.isShowRepostEntrance) forKey:kQuickInputViewConditionShowRepostEntrance];
    
    [self openCommentWithCondition:condition];
}

- (void)showMomentDetailViewWithComment:(id<TTCommentModelProtocol>)comment atIndexPath:(NSIndexPath *)indexPath showWriteComment:(BOOL)show
{
    if (!isEmptyString(comment.openURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:comment.openURL]];
    }
    else {
        BOOL shouldShow = show && !comment.replyCount.intValue;
        ArticleMomentDetailViewController *detailVC = [[ArticleMomentDetailViewController alloc] initWithComment:comment groupModel:comment.groupModel momentModel:[self genSimpleMomentModelWithComment:comment] delegate:self showWriteComment:shouldShow];
        [self.navigationController pushViewController:detailVC animated:YES];
        
        wrapperTrackEventWithCustomKeys(@"update_detail", @"enter_detail", comment.commentID.stringValue, nil, nil);
    }
    //记录入口的comment信息
    [self recordSelectedCommentIndexPath:indexPath];
}

- (ArticleMomentModel *)genSimpleMomentModelWithComment:(id<TTCommentModelProtocol>)comment
{
    //for preload
    ArticleMomentModel *momentModel = [[ArticleMomentModel alloc] init];
    momentModel.content = comment.commentContent;
    momentModel.diggsCount = [comment.digCount intValue];
    momentModel.digged = comment.userDigged;
    momentModel.createTime = [comment.commentCreateTime doubleValue];
    momentModel.group = nil;
    SSUserModel *user = [[SSUserModel alloc] init];
    user.name = comment.userName;
    user.avatarURLString = comment.userAvatarURL;
    user.ID = [comment.userID stringValue];
    momentModel.user = user;
    return momentModel;
}

- (BOOL)shouldPushMomentDetailView
{
    return self.commentManager.goTopicDetail;
}

#pragma mark -- Track

- (void)sendShowTrackForModel:(id)model
{
    //发送嵌入广告和帖子的统计
    NSString *event = @"concern_page";
    SSCommentModel *commentModel = (SSCommentModel *)model;
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
    [extra setValue:_commentManager.groupModel.groupID forKey:@"ext_value"];
    [extra setValue:commentModel.forumModel.forumID forKey:@"forum_id"];
    [TTTrackerWrapper category:@"umeng"
                  event:event
                  label:@"show_detail_comment"
                   dict:extra];
}

- (void)sendCommentClickTrackWithTagIndex:(NSInteger)index
{
    NSString *label;
    if (index) {
        label = @"time_order_comment";
    }
    else {
        label = @"smart_order_comment";
    }
    NSString *tag = [[_commentManager curentArticle] isImageSubject]?@"slide_detail":@"detail";
    wrapperTrackEvent(tag, label);
}

- (void)sendShowTrackForVisibleCellsIfNeeded
{
    NSArray *visibleCells = [_commentTableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(UITableViewCell * cell, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [_commentTableView indexPathForCell:cell];
        [self _sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
    }];
}

/*
 *  实际发送show track的方法，内部调用
 */
- (void)_sendShowTrackForEmbeddedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray * showAry = [_commentManager curCommentModels];
    if ([showAry count] > 0 && indexPath.row - 1 < [showAry count]) {
        id dataModel = [showAry objectAtIndex:indexPath.row - 1];
        ExploreCommentCell *commentCell = (ExploreCommentCell *)cell;
        SSCommentModel *commentModel = (SSCommentModel *)dataModel;
        if ([commentCell respondsToSelector:@selector(hasShown)] && !commentCell.hasShown && commentModel.forumModel) {
            [self sendShowTrackForModel:dataModel];
            commentCell.hasShown = YES;
        }
    }
}

#pragma mark -- KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"changedFlag"]) {
        
        if (![_commentManager requestRaiseError]) {
            [_commentTableView finishPullUpWithSuccess:YES];
            
            if (self.commentManager.commentsCount == 0) {
                self.commentTagView.hidden = YES;
            }
            else if([_commentManager curCommentModels].count == 0) {
                self.commentTagView.hidden = NO;
            }
            
            [self reloadData];
            
            BOOL needLoadingUpdate = [_commentManager needLoadingUpdateCommentModels];
            BOOL needLoadingMore = [_commentManager needLoadingMoreCommentModels];
            
            if (needLoadingUpdate || needLoadingMore) {
                _commentTableView.hasMore = YES;
            }
            else
                _commentTableView.hasMore = NO;
            
            NSNumber *changeFlag = self.commentManager.changedFlag;
            BOOL shouldIgnoreScrollToTopComment = [changeFlag isEqual:kChangedFlagDoneForLoadMore] ||
            [changeFlag isEqual:kChangedFlagFailed];
            if (_scrollToTopComment && !shouldIgnoreScrollToTopComment) {
                _scrollToTopComment = NO;
                [self _scrollToTopCommentAnimated:_scrollToTopCommentWithAnimation];
            }
            
            //进入视频详情页后首次刷新评论列表后，如果需要则定位到评论区
            if ([self.commentManager.changedFlag isEqual:kChangedFlagDoneForFirstLoad] &&
                self.commentManager.commentManagerObjects.count == 1 &&
                _delegate && [_delegate respondsToSelector:@selector(commentView:didFetchCommentsWithManager:)]) {
                [_delegate commentView:self didFetchCommentsWithManager:self.commentManager];
            }
        }
        else
            [_commentTableView finishPullUpWithSuccess:NO];
    }
}

#pragma mark -- UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * models = [_commentManager curCommentModels];
  
    NSInteger count = [models count];
    if (count > 0) {
        count ++;       //section view placeholder
    }
 
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self shouldPushMomentDetailView]) {
        NSArray * showAry = [_commentManager curCommentModels];
        if ([showAry count] > 0 && indexPath.row - 1 < [showAry count]) {
            id model = [showAry objectAtIndex:indexPath.row - 1];
            if ([model isKindOfClass:[SSCommentModel class]]) {
                SSCommentModel *comment = ((SSCommentModel *)[showAry objectAtIndex:indexPath.row - 1]);
                [self showMomentDetailViewWithComment:comment atIndexPath:indexPath showWriteComment:NO];
            }
            else if ([model isKindOfClass:[ArticleMomentModel class]]) {
                ArticleMomentModel *momentModel = (ArticleMomentModel *)model;
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:momentModel.momentURL]];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * showAry = [_commentManager curCommentModels];
    
    if ([showAry count] > 0 && indexPath.row == 0) {
        return [ArticleCommentHeaderView heightForHeaderView];
    }
    
    if ([showAry count] > 0 && indexPath.row - 1 < [showAry count]) {
        CGFloat height = 0;
        id dataModel = [showAry objectAtIndex:MAX(0, indexPath.row - 1)];
        if ([dataModel isKindOfClass:[SSCommentModel class]]) {
            height = [ExploreCommentCell heightForModel:dataModel width:self.frame.size.width];
        }
        return height;
    }
    else {
        return kCommentViewLoadMoreCellHeight;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * commentCellIdentifier = @"commentCellIdentifier";
    static NSString * sectionViewIdentifier = @"sectionViewIdentifier";
//    static NSString * embeddedCellIdentifier = @"embeddedCellIdentifier";
    
    NSArray * showAry = [_commentManager curCommentModels];
    
    if ([showAry count] > 0 && indexPath.row == 0) {
        // section view
        NSString * secTitle = @"评论";
        ExploreCommentSectionCell * cell = [tableView dequeueReusableCellWithIdentifier:sectionViewIdentifier];
        if (!cell) {
            cell = [[ExploreCommentSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sectionViewIdentifier frame:CGRectMake(0, 0, self.width, 0)];
            //此处注意cell默认size是320*44，layout到tableView之后才会更新，不要使用此时cell的frame值布局subViews
            self.commentTagView = [[ExploreCommentTagView alloc] initWithFrame:CGRectMake(self.width - 87, 21, 72, 20) tagItems:_commentManager.commentTabs];
            self.commentTagView.delegate = self;
            self.commentTagView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            [cell.contentView addSubview:self.commentTagView];
        }
        [cell.sectionCellView.headerView refreshTitle:secTitle];
        
        return cell;
    }
    else if ([showAry count] > 0 && indexPath.row - 1 < [showAry count]) {
        id dataModel = [showAry objectAtIndex:indexPath.row - 1];
        ExploreCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        
        if (!cell) {
            cell = [[ExploreCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:commentCellIdentifier
                                                       frame:CGRectMake(0, 0, self.width, 0)
                                                     isEssay:_isEssay];
            cell.delegate = self;
        }
        else {
            if (_enableImpressionRecording) {
                [ArticleImpressionHelper recordCommentForCommentModel:((ExploreCommentCell *)cell).commentModel status:SSImpressionStatusEnd groupModel:self.commentManager.groupModel];
            }
        }
        
        SSCommentModel *commentModel = (SSCommentModel *)dataModel;
        [cell refreshCondition:commentModel];
        if (_enableImpressionRecording) {
            SSImpressionStatus impressionStatus = (_isShowingForNatant && _isShowingForController) ? SSImpressionStatusRecording : SSImpressionStatusSuspend;
            [ArticleImpressionHelper recordCommentForCommentModel:((ExploreCommentCell *)cell).commentModel status:impressionStatus groupModel:self.commentManager.groupModel];
        }
        return cell;
    }
    else {
        return [[UITableViewCell alloc] init];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasSelfShown) {
        [self _sendShowTrackForEmbeddedCell:cell atIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (![self shouldShowFooterViewInSection:section]) {
        
        self.commentTableView.pullUpView.hidden = NO;
        return nil;
    }
    CGRect frame = [self frameForFooterInSection:section];
    if (!_emptyView) {
        self.emptyView = [[ExploreCommentEmptyView alloc] initWithFrame:frame];
        _emptyView.delegate = self;
    }
    
    if (!TTNetworkConnected()){
        [_emptyView refreshType:ExploreCommentEmptyViewTypeNotNetwork];
    }
    else if ([_commentManager.changedFlag isEqual:kChangedFlagFailed]) {
        [_emptyView refreshType:ExploreCommentEmptyViewTypeFailed];
    }
    else if (_commentManager.loading) {
        [_emptyView refreshType:ExploreCommentEmptyViewTypeLoading];
    }
    else if (_commentManager.detailNoComment && _commentManager.commentsCount > 0) {
        [_emptyView refreshType:ExploreCommentEmptyViewShowForceShowCommentButton];
    }
    else {
        self.commentTableView.pullUpView.hidden = YES;
        [_emptyView refreshType:ExploreCommentEmptyViewTypeEmpty];
    }
    _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    return _emptyView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self shouldShowFooterViewInSection:section]) {
        return 0;
    }
    return [self frameForFooterInSection:section].size.height;
}

- (CGRect)frameForFooterInSection:(NSInteger)section
{
    if (![self shouldShowFooterViewInSection:section]) {
        return CGRectZero;
    }
    CGRect rect = self.bounds;
    if (_tableHeaderContainerView) {
        rect.size.height -= _tableHeaderContainerView.frame.size.height;
        if (rect.size.height < kCommentViewEmptyMinHeight) {
            rect.size.height = kCommentViewEmptyMinHeight;
        }
    }
    return rect;
}

- (BOOL)shouldShowFooterViewInSection:(NSInteger)section
{
    NSInteger numberOfSelfSections;
    if ([_commentManager curCommentModels].count) {
        numberOfSelfSections = 1;
    }
    else {
        numberOfSelfSections = 0;
    }
    if (numberOfSelfSections == 0 && section == 0 && [self tableView:_commentTableView numberOfRowsInSection:0] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldShowHeaderViewInSection:(NSInteger)section
{
    if ([[_commentManager curCommentModels] count] == 0) {
        return NO;
    }
    return YES;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:scrollViewDidScroll:)]) {
        [_delegate commentView:self scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:scrollViewDidEndDecelerating:)]) {
        [_delegate commentView:self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:scrollViewWillBeginDragging:)]) {
        [_delegate commentView:self scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:scrollViewDidEndScrollingAnimation:)]) {
        [_delegate commentView:self scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < - kCommentViewPullToActionHeight && _delegate && [_delegate respondsToSelector:@selector(commentViewPullToActionDone:)]) {
        [_delegate commentViewPullToActionDone:self];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate commentView:self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

#pragma mark -- ExploreCommentTagViewDelegate

- (void)exploreCommentTagView:(id)commentTagView didSelectTagViewAtIndex:(NSInteger)index
{
    [self commentTagViewRefreshWithIndex:index];
    [self sendCommentClickTrackWithTagIndex:index];
}
 

#pragma mark -- ExploreMomentListCellUserActionItemDelegate

- (void)didDigMoment:(ArticleMomentModel *)model
{
    //刷新评论model及缓存
    if (nil != self.selectedCommentIndexPath &&
        self.selectedCommentIndexPath.row) {
        NSMutableArray * mShowAry = [_commentManager curCommentModels];
        
        SSCommentModel *comment = mShowAry[self.selectedCommentIndexPath.row - 1];
        comment.digCount = @(model.diggsCount);
        comment.userDigged = model.digged;
        [mShowAry replaceObjectAtIndex:(self.selectedCommentIndexPath.row - 1)
                            withObject:comment];
        [self.commentTableView reloadData];
//        [self.commentTableView reloadRowsAtIndexPaths:@[self.selectedCommentIndexPath]
//                                     withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)didSendCommentToMoment:(ArticleMomentModel *)model
{
    //fix crash：当选中相关评论进入动态详情页时才响应刷新
    if (nil != self.selectedCommentIndexPath &&
        self.selectedCommentIndexPath.row) {
        NSMutableArray * mShowAry = [_commentManager curCommentModels];
        SSCommentModel *comment = mShowAry[self.selectedCommentIndexPath.row - 1];
        comment.replyCount = @(model.commentsCount);
        [mShowAry replaceObjectAtIndex:(self.selectedCommentIndexPath.row - 1)
                            withObject:comment];
        
        [self.commentTableView reloadData];
//        [self.commentTableView reloadRowsAtIndexPaths:@[self.selectedCommentIndexPath]
//                                     withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark -- ExploreCommentViewCellBaseDelegate

- (void)commentViewCellBase:(ExploreCommentCell *)view deleteCommentWithCommentModel:(SSCommentModel *)model
{
    if (model.commentID) {
        BOOL useThemedActionSheet = NO;
        if (useThemedActionSheet) {
            TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"确定删除此评论?", nil) message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
            [actionSheet addActionWithTitle:@"取消" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
            [actionSheet addActionWithTitle:@"确认删除" actionType:TTThemedAlertActionTypeDestructive actionBlock:^{
                if ([model.commentID longLongValue] != 0) {
                    if (!TTNetworkConnected()) {
                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                    }
                    else {
                        wrapperTrackEvent(@"delete", @"comment");
                        [[ExploreDeleteManager shareManager] deleteArticleCommentForCommentID:[NSString stringWithFormat:@"%@", model.commentID] isAnswer:NO isNewComment:NO];
                        if (model) {
                            [self.commentManager removeCommentForModel:model];
                        }
                    }
                }
            }];
            [actionSheet showFrom:self.viewController animated:YES];
        }
        else {
            self.needDeleteCommentModel = model;
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"确定删除此评论?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认删除" otherButtonTitles:nil, nil];
            sheet.tag = kDeleteCommentActionSheetTag;
            [sheet showInView:self];
        }
    }
    else {
        self.needDeleteCommentModel = nil;
    }
}

- (void)commentViewCellBase:(ExploreCommentCell *)view replyButtonClickedWithModel:(SSCommentModel *)model
{
    if ([self shouldPushMomentDetailView]) {
        NSIndexPath *indexPath = [self.commentTableView indexPathForCell:view];
        if (indexPath) {
            [self showMomentDetailViewWithComment:model atIndexPath:indexPath showWriteComment:YES];
        }
    }
}

- (void)commentViewCellBase:(ExploreCommentCell *)view showMoreButtonClickedWithModel:(SSCommentModel *)model
{
    NSIndexPath *indexPath = [self.commentTableView indexPathForCell:view];
    if (indexPath) {
        [self showMomentDetailViewWithComment:model atIndexPath:indexPath showWriteComment:NO];
    }
}

- (void)commentViewCellBase:(ExploreCommentCell *)view avatarTappedWithCommentModel:(SSCommentModel *)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentView:avatarTappedWithCommentModel:)]) {
        [_delegate commentView:self avatarTappedWithCommentModel:model];
    }
}

- (void)commentViewCellBase:(ExploreCommentCell *)view replyListClickedWithModel:(SSCommentModel *)model
{
    NSIndexPath *indexPath = [_commentTableView indexPathForCell:view];
    if (indexPath) {
        [self tableView:_commentTableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)commentViewCellBase:(ExploreCommentCell *)view replyListAvatarClickedWithUserID:(NSString *)userID commentModel:(SSCommentModel *)model
{
     ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:userID];
     controller.from = kFromNewsDetailComment;
     UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
     [topController.navigationController pushViewController:controller animated:YES];
}

/*
#pragma mark -- SSCommentInputViewDelegate

- (void)commentInputView:(SSCommentInputView *)inputView responsedReceived:(NSNotification *)notification
{
    if (inputView == _padCommentInputView) {
        if(![[notification userInfo] objectForKey:@"error"])
        {
            NSMutableDictionary *commentData = [NSMutableDictionary dictionaryWithDictionary:[[notification userInfo] objectForKey:@"data"]];
            [self.commentManager insertCommentDictToTop:commentData forType:SSCommentManagerTypeRecent];
        }
        
        [inputView removeFromSuperview];
    }
    
}
*/

#pragma mark -- SSCommentEmptyViewDelegate

- (void)emptyView:(ExploreCommentEmptyView *)view buttonClickedForType:(ExploreCommentEmptyViewType)type
{
    if (type == ExploreCommentEmptyViewShowForceShowCommentButton) {
        [self tryForceShowAndReload];
    }
    else if (type == ExploreCommentEmptyViewTypeFailed) {
        
        [_emptyView refreshType:ExploreCommentEmptyViewTypeLoading];
        [self.commentManager reloadCommentWithTagIndex:_commentManager.curTabIndex];
    }
    else if (type == ExploreCommentEmptyViewTypeEmpty) {
        [self openInputViewWithContent:nil inputTitle:NSLocalizedString(@"评论", nil) groupModel:_commentManager.groupModel commentID:nil itemTag:nil itemBannComment:_commentManager.bannComment];
    }
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions
{
    if (!_enableImpressionRecording) {
        return;
    }
    
    for (UITableViewCell * cell in [_commentTableView visibleCells]) {
        if ([cell isKindOfClass:[ExploreCommentCell class]]) {
            if (_isShowingForController && _isShowingForNatant) {
                [ArticleImpressionHelper recordCommentForCommentModel:((ExploreCommentCell *)cell).commentModel status:SSImpressionStatusRecording groupModel:self.commentManager.groupModel];
            }
            else {
                [ArticleImpressionHelper recordCommentForCommentModel:((ExploreCommentCell *)cell).commentModel status:SSImpressionStatusSuspend groupModel:self.commentManager.groupModel];
            }
        }
    }
}

#pragma mark -- TTCommentWriteManagerDelegate

- (void)commentView:(TTCommentWriteView *) commentView commentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedReceived:(NSDictionary *)notifyDictioanry {

    if(![notifyDictioanry objectForKey:@"error"]) {
        NSMutableDictionary * commentData = [NSMutableDictionary dictionaryWithDictionary:[notifyDictioanry objectForKey:@"data"]];

        [self.commentManager insertCommentDictToTop:commentData];
    }

    [commentView dismissAnimated:YES];
    commentWriteManager.delegate = nil;
    self.hasSelfShown = YES;
    if (_enableInputedScrollToComment) {
        [self scrollToRecentCommentAnimated:NO];
    }
}

- (void)applicationStatusBarOrientationDidChanged
{
    [self.commentTableView reloadData];
}

#pragma mark -- UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(![TTAccountManager isLogin])
    {
        wrapperTrackEvent(@"login", @"login_pop_close");
    }
}


#pragma mark -- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kDeleteCommentActionSheetTag) {
        if ([_needDeleteCommentModel.commentID longLongValue] != 0 &&
            buttonIndex != actionSheet.cancelButtonIndex) {
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络连接" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
            }
            else {
                wrapperTrackEvent(@"delete", @"comment");
                [[ExploreDeleteManager shareManager] deleteArticleCommentForCommentID:[NSString stringWithFormat:@"%@", _needDeleteCommentModel.commentID] isAnswer:NO isNewComment:NO];
                if (_needDeleteCommentModel) {
                    [self.commentManager removeCommentForModel:_needDeleteCommentModel];
                }
            }
        }
        self.needDeleteCommentModel = nil;
    }
}


@end
