//
//  TTActionPopView.m
//  Article
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTActionPopView.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"



// MARK: - Consts
inline CGFloat kCornerRadius() {
    return 6.f;
}

inline CGFloat kPopButtonWidth() {
//    switch ([TTDeviceHelper getDeviceType]) {
        return [TTDeviceUIUtils tt_newPadding:140.f];
//    }
}

inline CGFloat kPopButtonHeight() {
//    switch ([TTDeviceHelper getDeviceType]) {
//        case TTDeviceModePad: return 32;
//        case TTDeviceMode736: return 32;
//        case TTDeviceMode667: return 32;
//        case TTDeviceMode568: return 30;
//        case TTDeviceMode480: return 30;
//    }
    return [TTDeviceUIUtils tt_newPadding:40.f];
}

inline CGFloat kButtonFontSize() {
//    switch ([TTDeviceHelper getDeviceType]) {
//        case TTDeviceModePad: return 17;
//        case TTDeviceMode736: return 17;
//        case TTDeviceMode667: return 17;
//        case TTDeviceMode568: return 15;
//        case TTDeviceMode480: return 15;
//    }
    return [TTDeviceUIUtils tt_newFontSize:14.f];
}

inline CGFloat kTitleLabelFontSize() {
//    switch ([TTDeviceHelper getDeviceType]) {
//        case TTDeviceModePad: return 15;
//        case TTDeviceMode736: return 15;
//        case TTDeviceMode667: return 15;
//        case TTDeviceMode568: return 13;
//        case TTDeviceMode480: return 13;
//    }
    return [TTDeviceUIUtils tt_newFontSize:14.f];
}

inline CGFloat kSubtitleLabelFontSize() {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 13;
        case TTDeviceMode736: return 13;
        case TTDeviceMode667:
        case TTDeviceMode812: return 12;
        case TTDeviceMode568: return 11;
        case TTDeviceMode480: return 11;
    }
}

inline CGFloat kDislikeButtonGapX() {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 18;
        case TTDeviceMode736: return 18;
        case TTDeviceMode667:
        case TTDeviceMode812: return 17;
        case TTDeviceMode568: return 16;
        case TTDeviceMode480: return 16;
    }
}

inline CGFloat kArrowOffsetY() {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 9;
        case TTDeviceMode736: return 9;
        case TTDeviceMode667:
        case TTDeviceMode812: return 8;
        case TTDeviceMode568: return 7;
        case TTDeviceMode480: return 7;
    }
}

static TTActionPopView * _Nullable tt_actionPopView;
static NSMutableArray<TTFeedDislikeWord *> * _Nullable tt_lastDislikeWords;
static NSNumber * _Nullable tt_lastGroupId;
static BOOL tt_enable = YES;

// MARK: - TTActionPopView
@implementation TTActionPopView

+ (TTActionPopView *)shareView {
    return tt_actionPopView;
}

+ (NSMutableArray<TTFeedDislikeWord *> *)shareLastDislikeWords {
    return tt_lastDislikeWords;
}

+ (NSNumber *)shareGroupId {
    return tt_lastGroupId;
}

+ (BOOL)shareEnable {
    return tt_enable;
}

/** 箭头背景 */
- (UIView *)arrowBackgroundView {
    if (_arrowBackgroundView == nil) {
        _arrowBackgroundView = [[UIView alloc] init];
        _arrowBackgroundView.backgroundColor = [UIColor clearColor];
        _arrowBackgroundView.width = self.width;
        [self addSubview:_arrowBackgroundView];
    }
    return _arrowBackgroundView;
}

/** 箭头 */
- (SSThemedImageView *)arrowView {
    if (_arrowView == nil) {
        _arrowView = [[SSThemedImageView alloc] init];
        _arrowView.imageName = @"ugc_pop_corner";
        [_arrowView sizeToFit];
        [self.arrowBackgroundView addSubview:_arrowView];
    }
    return _arrowView;
}

/** 内容背景 */
- (SSThemedView *)contentBackgroundView {
    if (_contentBackgroundView == nil) {
        _contentBackgroundView = [[SSThemedView alloc] init];
        _contentBackgroundView.backgroundColorThemeKey = kColorBackground4;
        _contentBackgroundView.width = self.width;
        _contentBackgroundView.layer.cornerRadius = 0.f;
        _contentBackgroundView.clipsToBounds = YES;
        [self insertSubview:_contentBackgroundView aboveSubview:self.arrowBackgroundView];
    }
    return _contentBackgroundView;
}


/** 功能列表 */
- (TTActionListView *)actionListView {
    if (_actionListView == nil) {
        _actionListView = [[TTActionListView alloc] initWithWidth:self.width];
        _actionListView.backgroundColor = [UIColor clearColor];
        [self.contentBackgroundView addSubview:_actionListView];
    }
    return _actionListView;
}

- (TTDislikePopView *)dislikeView {
    if (_dislikeView == nil) {
        _dislikeView = [[TTDislikePopView alloc] initWithWidth:self.width];
        _dislikeView.backgroundColor = [UIColor clearColor];
        _dislikeView.hidden = YES;
        [self.contentBackgroundView addSubview:_dislikeView];
    }
    return _dislikeView;
}

- (instancetype)initWithActionItems:(NSArray<TTActionListItem *> *)actionItems width:(CGFloat)width {
    [TTActionPopView dismissIfVisible];
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.width = width;
        self.actionListView.actionItem = actionItems;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize) name:kRootViewWillTransitionToSize object:nil];
    }
    return self;
}

- (void)dealloc {
    tt_actionPopView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRootViewWillTransitionToSize object:nil];
}

- (void)viewWillDisappear {
    tt_lastDislikeWords = self.dislikeView.dislikewords;
}

+ (void)dismissIfVisible {
    if (tt_actionPopView != nil) {
        [tt_actionPopView dismiss:NO];
        tt_actionPopView = nil;
    }
}

- (void)rootViewWillTransitionToSize {
    [TTActionPopView dismissIfVisible];
}

- (void)showAtPoint:(CGPoint)point fromView:(UIView *)fromView animation:(BOOL)animation completeBock:(void (^)(void))completeBock {
    if (tt_enable == NO) {
        NSLog(@"数据等可能存在问题，不显示");
        return;
    }
    UIWindow *window = [TTUIResponderHelper mainWindow];
    if (window == nil) {
        NSLog(@"获取window失败");
        return;
    }
    CGSize windowSize = [TTUIResponderHelper windowSize];
    tt_actionPopView = self;
    
    if (self.maskView == nil) {
        self.maskView = [UIButton buttonWithType:UIButtonTypeCustom];
        self.maskView.frame = window.bounds;
        [self fixIOS7];
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.maskView addTarget:self action:@selector(clickMask) forControlEvents:UIControlEventTouchUpInside];
        [self.maskView addSubview:self];
    }
    self.maskView.tag = 20140912;
    
    [window addSubview:self.maskView];
    [window bringSubviewToFront:self.maskView];
    
    CGPoint p = [self.maskView convertPoint:point fromView:fromView.superview];
    self.arrowPoint = p;
    
    if (p.y >= windowSize.height / 2) {
        p.y -= kArrowOffsetY();
        self.arrowDirection = TTFeedPopupViewArrowDown;
    } else {
        p.y += kArrowOffsetY();
        self.arrowDirection = TTFeedPopupViewArrowUp;
    }
    
    self.left = (self.maskView.width - self.width) / 2;
    [self refreshUI];
    
    if (self.arrowDirection == TTFeedPopupViewArrowUp) {
        self.top = p.y;
    } else {
        self.bottom = p.y;
    }
    
    CGPoint arrowPoint = [self convertPoint:p fromView:self.maskView];
    if (self.width > 0 && self.height > 0) {
        CGRect frame = self.frame;
        self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.width, arrowPoint.y / self.height);
        self.frame = frame;
    }
    
    self.layer.cornerRadius = 0.f;
    self.alpha = 1;
    
    if (animation) {
        self.maskView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.maskView.alpha = 1;
        } completion:^(BOOL finished) {
            self.maskView.alpha = 1;
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (completeBock) {
                    completeBock();
                }
            }];
        }];
        return;
    }
    
    self.maskView.alpha = 1;
    self.transform = CGAffineTransformIdentity;
    if (completeBock) {
        completeBock();
    }
}

- (void)showAtPoint:(CGPoint)point fromView:(UIView *)fromView {
    [self showAtPoint:point fromView:fromView animation:YES completeBock:nil];
}

- (void)showDislikeView:(id)aOrderedData dislikeWords:(NSArray<TTFeedDislikeWord *> *)dislikeWords groupID:(NSNumber *)groupID transformAnimation:(BOOL)transformAnimation {
    NSString *categoryId;
    ExploreOrderedData *orderedData = (ExploreOrderedData *)aOrderedData;
    
    if (orderedData) {
        categoryId = orderedData.categoryID;
    }
    
    if (dislikeWords.count == 0) {
        self.contentBackgroundView.backgroundColor = [UIColor clearColor];
        self.arrowView.hidden = YES;
        self.dislikeView.titleLabel.hidden = YES;
    }
    
    if ([tt_lastGroupId isEqualToNumber:groupID] && [tt_lastDislikeWords count] > 0) {
        self.dislikeView.dislikewords = tt_lastDislikeWords;
    } else {
        self.dislikeView.dislikewords = [NSMutableArray arrayWithArray:dislikeWords];
    }
    tt_lastGroupId = groupID;
    self.dislikeView.hidden = NO;
    
    self.actionListView.alpha = 1;
    self.dislikeView.alpha = 0;
    if (self.arrowDirection != TTFeedPopupViewArrowUp) {
        self.dislikeView.bottom = self.actionListView.bottom;
    }
    
    if (transformAnimation) {
        self.actionListView.alpha = 0;
        self.actionListView.hidden = YES;
        
        self.dislikeView.alpha = 1;
        self.contentBackgroundView.height = self.dislikeView.height;
        if (self.arrowDirection != TTFeedPopupViewArrowUp) {
            self.dislikeView.top = 0;
            self.actionListView.bottom = self.dislikeView.height;
            self.arrowBackgroundView.top = self.dislikeView.height;
            self.top += (self.actionListView.height - self.dislikeView.height);
        }
        self.height = self.dislikeView.height + self.arrowBackgroundView.height;
        
        self.maskView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.maskView.alpha = 1;
        } completion:^(BOOL finished) {
            self.maskView.alpha = 1;
            
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.actionListView.alpha = 0;
        self.dislikeView.alpha = 1;
        self.contentBackgroundView.height = self.dislikeView.height;
        if (self.arrowDirection != TTFeedPopupViewArrowUp) {
            self.dislikeView.top = 0;
            self.actionListView.bottom = self.dislikeView.height;
            self.arrowBackgroundView.top = self.dislikeView.height;
            self.top += (self.actionListView.height - self.dislikeView.height);
        }
        self.height = self.dislikeView.height + self.arrowBackgroundView.height;
    } completion:^(BOOL finished) {
        self.actionListView.alpha = 1;
        self.actionListView.hidden = YES;
    }];
}

- (void)showDislikeView:(id)aOrderedData dislikeWords:(NSArray<TTFeedDislikeWord *> *)dislikeWords groupID:(NSNumber *)groupID {
    [self showDislikeView:aOrderedData dislikeWords:dislikeWords groupID:groupID transformAnimation:NO];
}

- (void)refreshUI {
    [self refreshArrowUI];
    self.contentBackgroundView.height = self.actionListView.height;
    if (self.arrowDirection == TTFeedPopupViewArrowUp) {
        self.arrowBackgroundView.origin = CGPointMake(0, 0);
        self.contentBackgroundView.origin = CGPointMake(0, self.arrowBackgroundView.bottom);
    } else {
        self.contentBackgroundView.origin = CGPointMake(0, 0);
        self.arrowBackgroundView.origin = CGPointMake(0, self.contentBackgroundView.bottom);
    }
    self.height = self.arrowBackgroundView.height + self.contentBackgroundView.height;
}

- (void)refreshArrowUI {
    CGFloat angle = (self.arrowDirection == TTFeedPopupViewArrowUp ? 0 : M_PI);
    self.arrowView.transform = CGAffineTransformMakeRotation(angle);
    self.arrowBackgroundView.height = self.arrowView.height;
    self.arrowBackgroundView.top = (self.arrowDirection == TTFeedPopupViewArrowUp ? 1 : -1);
    CGPoint arrowPoint = [self convertPoint:self.arrowPoint fromView:self.maskView];
    self.arrowView.centerX = arrowPoint.x;
}

- (void)fixIOS7 {
    if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat rotateRadian;
        switch (orientation) {
            case UIInterfaceOrientationLandscapeLeft:
                rotateRadian = -M_PI_2;
                break;
            case UIInterfaceOrientationLandscapeRight:
                rotateRadian = M_PI_2;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                rotateRadian = M_PI;
                break;
            case UIInterfaceOrientationPortrait:
                rotateRadian = 0;
                break;
            case UIInterfaceOrientationUnknown:
                rotateRadian = 0;
                break;
        }
        CGSize windowSize = [TTUIResponderHelper windowSize];
        self.maskView.bounds = CGRectMake(0, 0, windowSize.width, windowSize.height);
        self.maskView.transform = CGAffineTransformMakeRotation(rotateRadian);
    }
}

- (void)clickMask {
    [self dismiss:YES];
    if ([[tt_actionPopView delegate] respondsToSelector:@selector(dislikeCancelClicked:onlyOne:)]) {
        [[tt_actionPopView delegate] dislikeCancelClicked:self.dislikeView.selectedWords onlyOne:NO];
    }
    tt_actionPopView = nil;
}

- (void)dismiss:(BOOL)animated {
    if (animated) {
        [self viewWillDisappear];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.maskView removeFromSuperview];
            self.maskView = nil;
        }];
    } else {
        [super dismiss:animated];
    }
}

@end

// MARK: - TTActionListView
@implementation TTActionListView
- (void)setActionItem:(NSArray<TTActionListItem *> *)actionItem {
    _actionItem = actionItem;
    if ([_actionItem count] > 0) {
        self.height = [_actionItem count] * 49.f;
        [self reloadData];
        tt_enable = YES;
    } else {
        tt_enable = NO;
    }
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (self) {
        self.width = width;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollEnabled = NO;
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.actionItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTActionListItem *item = self.actionItem[indexPath.row];
    SSThemedTableViewCell *cell = [[SSThemedTableViewCell alloc] init];
    cell.backgroundColorThemeKey = kColorBackground4;
    if (![SSCommonLogic transitionAnimationEnable]) {
        cell.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    SSThemedImageView *iconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
    iconView.imageName = item.iconName;
    iconView.centerY = 24.5;
    [cell addSubview:iconView];
    
    SSThemedLabel *descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(iconView.right + 15, 0, 0, 16)];
    descLabel.text = item.descrip;
    descLabel.font = [UIFont tt_fontOfSize:16];
    descLabel.textColorThemeKey = kColorText1;
    [descLabel sizeToFit];
    descLabel.centerY = 24.5;
    [cell addSubview:descLabel];
    
    if (indexPath.row + 1 != [self.actionItem count]) {
        SSThemedView *bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(55, 49 - [TTDeviceHelper ssOnePixel], self.width - 55, [TTDeviceHelper ssOnePixel])];
        bottomLine.backgroundColorThemeKey = kColorLine1;
        [cell addSubview:bottomLine];
    }
    
    if (item.hasSub) {
        SSThemedImageView *accessoryView = [[SSThemedImageView alloc] init];
        accessoryView.imageName = @"arrow_right_setup";
        accessoryView.backgroundColor = [UIColor clearColor];
        [accessoryView sizeToFit];
        accessoryView.centerY = 24.5;
        accessoryView.right = self.width - 15;
        [cell addSubview:accessoryView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTActionListItem *item = self.actionItem[indexPath.row];
    [item action]();
    if (!item.hasSub) {
        [tt_actionPopView dismiss:YES];
    }
}

@end

// MARK: - TTDislikePopView
@implementation TTDislikePopView

@synthesize dislikewords = _dislikewords;

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont tt_fontOfSize:kTitleLabelFontSize()];
        _titleLabel.text = NSLocalizedString(@"可选理由，精准屏蔽", @"");
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedButton *)okBtn {
    if (_okBtn == nil) {
        _okBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kPopButtonWidth(), kPopButtonHeight())];
        _okBtn.titleLabel.font = [UIFont tt_fontOfSize:kButtonFontSize()];
        [_okBtn setTitle:NSLocalizedString(@"不喜欢", @"") forState:UIControlStateNormal];
        [_okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _okBtn.backgroundColorThemeKey = kColorBackground7;
        _okBtn.highlightedBackgroundColorThemeKey = kColorBackground7Highlighted;
        _okBtn.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:20.f];
        [self addSubview:_okBtn];
    }
    return _okBtn;
}

- (TTFeedDislikeKeywordsView *)keywordsView {
    if (_keywordsView == nil) {
        _keywordsView = [[TTFeedDislikeKeywordsView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _keywordsView.backgroundColor = [UIColor clearColor];
        _keywordsView.delegate = self;
        [self addSubview:_keywordsView];
    }
    return _keywordsView;
}

- (NSMutableArray<TTFeedDislikeWord *> *)dislikewords {
    if (_dislikewords == nil) {
        _dislikewords = [[NSMutableArray<TTFeedDislikeWord *> alloc] init];
    }
    return _dislikewords;
}

- (void)setDislikewords:(NSMutableArray<TTFeedDislikeWord *> *)dislikewords {
    _dislikewords = dislikewords;
    [self.keywordsView refreshWithData:_dislikewords];
    self.selectedKeywordsCount = [self.selectedWords count];
    [self refreshContentUI];
}

- (instancetype)initWithWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.width = width;
    }
    return self;
}

- (NSArray<NSString *> *)selectedWords {
    NSMutableArray<NSString *> *array = [[NSMutableArray<NSString *> alloc] init];
    for (TTFeedDislikeWord *word in self.dislikewords) {
        if ([word isSelected]) {
            [array addObject:word.ID];
        }
    }
    return array;
}

- (void)refreshContentUI {
    [self refreshOKBtn];
    [self refreshTitleLabel];
    
    self.keywordsView.origin = CGPointMake(0, 12);
    self.okBtn.origin = CGPointMake(self.width - [self leftPadding] - self.okBtn.width, self.keywordsView.bottom + 12);
    self.titleLabel.centerX = self.width / 4;
    self.okBtn.centerX = self.width * 3 / 4;
    self.titleLabel.centerY = self.okBtn.centerY;
    self.height = self.okBtn.bottom + 12;
}

- (void)refreshOKBtn {
    if (self.selectedKeywordsCount > 0) {
        [self.okBtn setTitle:@"确定" forState:UIControlStateNormal];
    } else {
        [self.okBtn setTitle:@"不喜欢" forState:UIControlStateNormal];
    }
}

- (void)refreshTitleLabel {
    if (self.selectedKeywordsCount > 0) {
        NSString *title = [NSString stringWithFormat:@"已选%ld个理由", (long)self.selectedKeywordsCount];
        NSRange range = NSMakeRange(2, 1);
        NSMutableAttributedString *atrrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        [atrrTitle setAttributes:@{NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText4]} range:range];
        self.titleLabel.attributedText = atrrTitle;
    } else {
        self.titleLabel.text = @"可选理由，精准屏蔽";
    }
    [self.titleLabel sizeToFit];
//    self.titleLabel.left = [self leftPadding];
    self.titleLabel.centerX = self.width / 4;
}

- (CGFloat)leftPadding {
    return 14.f; // Iphone5下12
}

- (void)okBtnClicked:(id)sender {
    [[tt_actionPopView delegate] dislikeButtonClicked:self.selectedWords onlyOne:NO];
    [tt_actionPopView dismiss:YES];
    tt_lastDislikeWords = [[NSMutableArray<TTFeedDislikeWord *> alloc] init];
    tt_lastGroupId = nil;
}

- (void)dislikeKeywordsSelectionChanged {
    self.selectedKeywordsCount = [self.selectedWords count];
    [self refreshOKBtn];
    [self refreshTitleLabel];
}

@end

// MARK: - TTActionListItem
@interface TTActionListItem ()

@property (nonatomic, copy, readwrite) void(^action)(void);
@property (nonatomic, strong, readwrite) NSString *descrip;
@property (nonatomic, strong, readwrite) NSString *iconName;
@property (nonatomic, readwrite) BOOL hasSub;

@end

@implementation TTActionListItem

- (instancetype)initWithDescription:(NSString *)descrip iconName:(NSString *)iconName hasSub:(BOOL)hasSub action:(void (^)(void))action {
    self = [super init];
    if (self) {
        self.descrip = descrip;
        self.iconName = iconName;
        self.action = action;
        self.hasSub = hasSub;
    }
    return self;
}

- (instancetype)initWithDescription:(NSString *)descrip iconName:(NSString *)iconName action:(void (^)(void))action {
    self = [self initWithDescription:descrip iconName:iconName hasSub:NO action:action];
    return self;
}

@end
