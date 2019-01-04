//
//  TTThemedAlertController.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertController.h"
#import "TTThemedAlertActionModel.h"
#import "TTThemedAlertControllerActionCell.h"
#import "SSThemed.h"
#import "TTThemeConst.h"

#import "UIViewAdditions.h"
#import <objc/runtime.h>
#import "UIImage+TTThemeExtension.h"
#import "TTLabelTextHelper.h"
#import "TTKeyboardListener.h"
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"

@interface TTThemedAlertController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *visualEffectView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIView *actionSheetView;
@property (nonatomic, strong) UIPopoverController *iPadPopoverController;
@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *textFieldsView;
@property (nonatomic, strong) UIImageView *bannerImageView;
@property (nonatomic, strong) UIButton *actionSheetCancelButton;
@property (nonatomic, strong) UIView *actionSheetCancelButtonBgView;
@property (nonatomic, strong) UIViewController *showFromViewController;

@property (nonatomic, assign) TTThemedAlertControllerType alertType;
@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) CGFloat tableViewWidth;
@property (nonatomic, assign) BOOL isPopover;
@property (nonatomic, assign) BOOL isGrayCancelTitle;

@property (nonatomic, strong) NSMutableArray *actionBlockArr;
@property (nonatomic, strong) NSMutableArray *textFieldArr;
@property (nonatomic, copy) TTThemedAlertTextViewActionBlock textViewActionBlock;

@property (nonatomic, strong) TTThemedAlertActionModel *actionSheetCancelAction;

@property (nonatomic, strong) NSDictionary *alertUIConfiguration;

@end

@implementation TTThemedAlertController

#pragma mark - Initialize

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredType:(TTThemedAlertControllerType)type
{
    self = [super init];
    if (self) {
        _alertType = type;
        _alertTitle = title;
        _message = message;
        _tableViewWidth = (type == TTThemedAlertControllerTypeAlert) ? TTThemedAlertTableViewWidth : TTThemedActionSheetTableViewWidth;
        _visualEffectView = [[UIView alloc] init];
        _visualEffectView.frame = self.view.frame;
        _visualEffectView.backgroundColor = [UIColor blackColor];
        _visualEffectView.alpha = 0;
        _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

    #pragma mark ============= TODOP delete =============
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] >= 8.f) {
        [self layoutSubViewsInController];
    }
}

- (void)layoutSubViewsInController
{
    _visualEffectView.frame = self.view.frame;
    _contentTableView.frame = [self _tableViewFrame];
    self.headerView.frame = [self _headerViewFrame];
    self.textView.frame = [self frameOfToBeAddedTextElement:self.textView];
    [self settingAlertView];
    [self settingActionSheetFrame];
}

- (void)configViews
{
    [self configHeaderView];
    [self configContent];
}

- (void)buildContent
{
    [self arrangeActionBlockArr];
    [self configViews];
}

- (void)buildPopoverContent
{
    [self arrangeActionBlockArr];
    
    self.tableViewWidth = TTThemedPopoverWidth;
    [self configHeaderView];
    [self constructTableView];
    [self themedMainContentView:self.contentTableView];
}

#pragma mark - View life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initContainers];
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        [self addObservers];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutOniOS7WithOrientation:self.interfaceOrientation];
    [self layoutViewsWhenOrientationOccured];
}

- (void)layoutOniOS7WithOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        
        CGPoint alertCenter = CGPointMake(UIScreenWidth / 2.0, UIScreenHeight / 2.0);
        CGAffineTransform transform = CGAffineTransformIdentity;
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                alertCenter.y += [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                alertCenter.x -= [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(-M_PI/2);
                break;
            case UIInterfaceOrientationLandscapeRight:
                alertCenter.x += [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                transform = CGAffineTransformMakeRotation(M_PI/2);
                break;
            default:
                alertCenter.y -= [TTKeyboardListener sharedInstance].keyboardHeight / 2.0;
                break;
        }
        _alertView.transform = transform;
        CGPoint center = [[UIApplication sharedApplication].keyWindow convertPoint:alertCenter toView:_alertView.superview];
        _alertView.center = center;
    }
}

- (void)dealloc
{
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}

#pragma mark - View

- (UITextView *)uniqueTextView
{
    return self.textView;
}

- (CGRect)_headerViewFrame
{
    return CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.bounds), [self titleViewHeight]);
}

- (void)configTitleView
{
    self.headerView = [[UIView alloc] init];
    
    CGFloat width;
    CGFloat leftMargin;
    CGFloat topMargin;
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        if (self.bannerImageView) {
            leftMargin = 65;
            topMargin = 48;
            width = self.tableViewWidth - 90;
        }
        else {
            leftMargin = 22;
            topMargin = [self isSingleLineTitle] ? 19 : 21;
            width = self.tableViewWidth - 44;
        }
    }
    else {
        leftMargin = 15;
        topMargin = 10;
        width = self.tableViewWidth - 2 * leftMargin;
    }
    CGFloat lineHeight = 22.f;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, topMargin, width, 0)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = SSGetThemedColorWithKey(kColorText100);
    _titleLabel.numberOfLines = 2;
    CGFloat fontSize = self.alertUIConfiguration[TTThemedTitleFontKey] ? [self.alertUIConfiguration[TTThemedTitleFontKey] floatValue] : TTThemedAlertDefaultTitleFontSize;
    _titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.alertTitle fontSize:fontSize lineHeight:lineHeight lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:YES firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    CGSize textSize = CGSizeZero;
    
    textSize = CGSizeMake(width, [TTLabelTextHelper heightOfText:self.alertTitle fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentCenter]);
    
    CGFloat height = 20;
    CGFloat verticalMargin = self.bannerImageView ? 16 : 10;
    if (textSize.width > width) {
        height = 50;
        verticalMargin = self.bannerImageView ? 8 : 2;
    }
    _titleLabel.height = textSize.height;
    [self.headerView addSubview:_titleLabel];
    
    if (!isEmptyString(self.message)) {
        lineHeight = 22.f;
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom + TTThemedAlertControllerTitleSubTitleSpacing, width, 0)];
        subTitleLabel.backgroundColor = [UIColor clearColor];
        subTitleLabel.textColor = SSGetThemedColorWithKey(kColorText100);
        subTitleLabel.numberOfLines = 3;
        fontSize = self.alertUIConfiguration[TTThemedSubTitleFontKey] ? [self.alertUIConfiguration[TTThemedSubTitleFontKey] floatValue] : TTThemedAlertDefaultSubTitleFontSize;
        subTitleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.message fontSize:fontSize lineHeight:16.f lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:NO firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
        
        subTitleLabel.height = [TTLabelTextHelper heightOfText:self.message fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:3 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
        [self.headerView addSubview:subTitleLabel];
    }
    
    if (self.bannerImageView) {
        [self.headerView addSubview:self.bannerImageView];
    }
}

- (void)configHeaderView
{
    [self configTitleView];
    
    if (self.textView) {
        [self.headerView addSubview:self.textView];
    }
    
    [self.textFieldArr enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL *stop) {
        [self.headerView addSubview:textField];
    }];
    
    self.headerView.height = [self contentTableHeaderViewHeight];
    /**
     *  如果没有message，titleLabel居中
     */
    if (self.alertType == TTThemedAlertControllerTypeAlert && isEmptyString(self.message)) {
        _titleLabel.centerY = self.headerView.centerY;
    }
    
    CALayer *bottomLine = [CALayer layer];
    bottomLine.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame) - [TTDeviceHelper ssOnePixel], self.tableViewWidth, [TTDeviceHelper ssOnePixel]);
    bottomLine.backgroundColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
    [self.headerView.layer addSublayer:bottomLine];
    
    NSLog(@"headerViewHeight is %f", self.headerView.height);
}

- (CGRect)_tableViewFrame
{
    return CGRectMake(0, 0, self.tableViewWidth, [self contentTableViewHeight]);
}

- (void)constructTableView
{
    //called after selector(configHeaderView)
    self.contentTableView = [[UITableView alloc] initWithFrame:[self _tableViewFrame]
                                                         style:UITableViewStylePlain];
    self.contentTableView.dataSource = self;
    self.contentTableView.delegate = self;
    self.contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView.showsHorizontalScrollIndicator = NO;
    self.contentTableView.scrollEnabled = NO;
    [self.contentTableView registerClass:[TTThemedAlertControllerActionCell class]
                  forCellReuseIdentifier:TTThemedAlertControllerCellIdentifier];
    self.contentTableView.tableHeaderView = self.headerView;
    self.contentTableView.tableFooterView = [UIView new];
    
    //Pad 或 只有一行内容时，不展示底部separator
    if (self.isPopover || 1 == [self numberOfContentCells]) {
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (CGRect)_alertViewFrame
{
    return CGRectMake(0, 0, CGRectGetWidth(self.contentTableView.frame), CGRectGetHeight(self.contentTableView.frame));
}

- (void)settingAlertView
{
    self.alertView.frame = [self _alertViewFrame];
    if ([TTDeviceHelper OSVersionNumber] >= 8.f) {
        self.alertView.center = CGPointMake(UIScreenWidth / 2, (UIScreenHeight - [TTKeyboardListener sharedInstance].keyboardHeight) / 2);
    }
    else {
        [self layoutOniOS7WithOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }
}

- (void)settingActionSheetFrame
{
    CGFloat actionSheetWidth = CGRectGetWidth(self.contentTableView.frame);
    CGFloat actionsheetHeight = CGRectGetHeight(self.contentTableView.frame);
    
    if (self.actionSheetView) {
        actionsheetHeight += CGRectGetHeight(self.actionSheetCancelButtonBgView.bounds) + TTThemedAlertControllerActionSheetMidMargin;
    }
    self.actionSheetView.frame = CGRectMake((UIScreenWidth - actionSheetWidth) / 2, UIScreenHeight - actionsheetHeight, actionSheetWidth, actionsheetHeight);
}

- (void)configContent
{
    [self constructTableView];
    UIView *addedContentView = nil;
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        //alert:屏幕正中显示
        self.alertView = [[UIView alloc] init];
        [self settingAlertView];
        [self.alertView addSubview:self.contentTableView];
        addedContentView = self.alertView;
    }
    else {
        //actionSheet:屏幕底部显示
        self.actionSheetView = [[UIView alloc] init];
        if (self.actionSheetCancelAction) {
            self.actionSheetCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.actionSheetCancelButton.frame = CGRectMake(0, CGRectGetMaxY(self.contentTableView.frame) + TTThemedAlertControllerActionSheetMidMargin, CGRectGetWidth(self.contentTableView.frame), TTThemedAlertControllerCellHeight);
            self.actionSheetCancelButton.layer.cornerRadius = [TTThemedAlertControllerCommon ttthemedAlertControllerCellCornerRadius];
            [self.actionSheetCancelButton setTitle:self.actionSheetCancelAction.actionTitle forState:UIControlStateNormal];
            self.actionSheetCancelButton.titleLabel.font = self.actionSheetCancelAction.actionElementModel.elementFont;
            [self.actionSheetCancelButton addTarget:self
                                        action:@selector(actionSheetCancelActionTrigged)
                              forControlEvents:UIControlEventTouchUpInside];
            
            self.actionSheetCancelButtonBgView = [[UIView alloc] initWithFrame:self.actionSheetCancelButton.frame];
            self.actionSheetCancelButtonBgView.height += [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
            self.actionSheetCancelButtonBgView.layer.cornerRadius = [TTThemedAlertControllerCommon ttthemedAlertControllerCellCornerRadius];
            
            [self.actionSheetView addSubview:self.actionSheetCancelButtonBgView];
            [self.actionSheetView addSubview:self.actionSheetCancelButton];
            
            
        }
        
        [self.actionSheetView addSubview:self.contentTableView];
        addedContentView = self.actionSheetView;

        [self settingActionSheetFrame];
        //点击空白处dismiss
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSelfFromParentViewControllerDidCancel)];
        tap.delegate = self;
        [self.visualEffectView addGestureRecognizer:tap];
    }
    
    [self themedMainContentView:addedContentView];

    [self.visualEffectView.superview addSubview:addedContentView];
    [self layoutOniOS7WithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
//    self.view.frame = addedContentView.frame;
}

- (void)themedMainContentView:(UIView *)mainContentView
{
    //此处做UI自定义
    mainContentView.layer.cornerRadius = [TTThemedAlertControllerCommon ttthemedAlertControllerCellCornerRadius];
    self.contentTableView.layer.cornerRadius = [TTThemedAlertControllerCommon ttthemedAlertControllerCellCornerRadius];
    mainContentView.backgroundColor = SSGetThemedColorWithKey(kColorBackground2);
    
    self.contentTableView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.headerView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.contentTableView.separatorColor = SSGetThemedColorWithKey(kColorLine1);
    
    [self.actionSheetCancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.actionSheetCancelButton setBackgroundColor:SSGetThemedColorWithKey(kColorBackground4)];
    
    self.actionSheetCancelButtonBgView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)layoutViewsWhenOrientationOccured
{
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        if ([TTDeviceHelper OSVersionNumber] >= 8.f) {
            self.alertView.center = CGPointMake(self.parentViewController.view.bounds.size.width / 2, (self.parentViewController.view.bounds.size.height - [TTKeyboardListener sharedInstance].keyboardHeight) / 2);
        }
    }
    else {
        if (self.isPopover) {
            return;
        }
        
        self.contentTableView.frame = CGRectMake(0, 0, TTThemedActionSheetTableViewWidth, [self contentTableViewHeight]);
        CGFloat actionSheetWidth = CGRectGetWidth(self.contentTableView.frame);
        CGFloat actionsheetHeight = CGRectGetHeight(self.actionSheetView.frame);
        self.actionSheetView.frame = CGRectMake((UIScreenWidth - actionSheetWidth) / 2, UIScreenHeight - actionsheetHeight, actionSheetWidth, actionsheetHeight);
        
        [self layoutActionSheetViewSubViewsWhenOrientationOccured];
    }
}

- (void)layoutActionSheetViewSubViewsWhenOrientationOccured
{
    for (UIView * subView in self.actionSheetView.subviews) {
        [self restrictToTableViewWithForSubView:subView];
    }
    
    for (UIView * subView in self.headerView.subviews) {
        [self restrictToTableViewWithForSubView:subView];
    }
}

- (void)restrictToTableViewWithForSubView:(UIView *)subView
{
    CGRect rect = subView.frame;
    rect.size.width = TTThemedActionSheetTableViewWidth;
    subView.frame = rect;
}

- (void)adjustAlertViewLocationIfNeededWithFrameTop:(CGFloat)keyboardFrameTop
{
    if (keyboardFrameTop) {
        CGRect rect = self.alertView.frame;
        CGFloat y = (keyboardFrameTop - rect.size.height) /2;
        rect.origin.y = y;
        self.alertView.frame = rect;
    }
}

#pragma mark - Action

- (void)addBannerImage:(NSString *)bundleImageName
{
    if (self.alertType == TTThemedAlertControllerTypeActionSheet) {
        return;
    }
    
    UIImage *bannerImage = [UIImage themedImageNamed:bundleImageName];
    if (bannerImage) {
        self.bannerImageView = [[UIImageView alloc] initWithImage:bannerImage];
        self.bannerImageView.frame = CGRectMake(0, 0, bannerImage.size.width, bannerImage.size.height);
    }
}

- (void)addActionWithTitle:(NSString *)title actionType:(TTThemedAlertActionType)actionType actionBlock:(TTThemedAlertActionBlock)actionBlock
{
    if (title) {
        TTThemedAlertActionModel *action = [[TTThemedAlertActionModel alloc] initWithAlertType:self.alertType
                                                                                    actionType:actionType
                                                                                   actionTitle:title
                                                                                   actionBlock:actionBlock];
        [self.actionBlockArr addObject:action];
        
        //特殊处理actionSheet的cancelAction
        if (self.alertType == TTThemedAlertControllerTypeActionSheet &&
            actionType == TTThemedAlertActionTypeCancel) {
            self.actionSheetCancelAction = action;
        }
    }
}

- (void)addActionWithGrayTitle:(nullable NSString *)title actionType:(TTThemedAlertActionType)actionType actionBlock:(nullable TTThemedAlertActionBlock)actionBlock
{
    if (title) {
        TTThemedAlertActionModel *action = [[TTThemedAlertActionModel alloc] initWithAlertType:self.alertType
                                                                                    actionType:actionType
                                                                                   actionTitle:title
                                                                                   actionBlock:actionBlock];
        [self.actionBlockArr addObject:action];
        
        //特殊处理actionSheet的cancelAction
        if (self.alertType == TTThemedAlertControllerTypeActionSheet &&
            actionType == TTThemedAlertActionTypeCancel) {
            self.actionSheetCancelAction = action;
        }
        self.isGrayCancelTitle = YES;
    }
}

- (void)addTextFieldWithConfigurationHandler:(TTThemedAlertTextFieldActionBlock)actionBlock
{
    if (self.alertType == TTThemedAlertControllerTypeActionSheet) {
        return;
    }
    
    if (!self.textFieldArr) {
        self.textFieldArr = [NSMutableArray array];
    }
    
    UITextField *textField = [[UITextField alloc] init];
    [self.textFieldArr addObject:textField];

    textField.frame = [self frameOfToBeAddedTextElement:textField];
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderColor = [UIColorWithRGBA(210.0, 210.0, 216.0, 1) CGColor];
    textField.layer.borderWidth = 0.5;
    textField.backgroundColor = [UIColor whiteColor];
    textField.delegate = self;
    
    if (actionBlock) {
        objc_setAssociatedObject(textField, TTThemedAlertControllerTextFieldActionKey, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)addTextViewWithConfigurationHandler:(TTThemedAlertTextViewActionBlock)actionBlock
{
    if (self.alertType == TTThemedAlertControllerTypeActionSheet) {
        return;
    }
    
    self.textView = [[UITextView alloc] init];
    self.textView.frame = [self frameOfToBeAddedTextElement:self.textView];
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColorWithRGBA(210.0, 210.0, 216.0, 1) CGColor];
    self.textView.delegate = self;
    
    if (actionBlock) {
        self.textViewActionBlock = actionBlock;
    }
}

- (void)actionSheetCancelActionTrigged
{
    [self dismissSelfFromParentViewControllerWithComplectionBlock:self.actionSheetCancelAction.actionBlock];
}

- (void)addTTThemedAlertControllerUIConfig:(NSDictionary *)configuration
{
    self.alertUIConfiguration = configuration;
}

#pragma mark - Helper

- (void)initContainers
{
    self.actionBlockArr = [NSMutableArray array];
}

- (BOOL)shouldSortActionsVertically
{
    if (self.alertType == TTThemedAlertControllerTypeActionSheet) {
        return YES;
    }
    else {
        return self.actionBlockArr.count > 2;
    }
}

- (BOOL)showSingleLineCellHorizentally
{
    return ([self numberOfContentCells] == 1) && (self.actionBlockArr.count == 2);
}

- (NSInteger)numberOfContentCells
{
    return [self shouldSortActionsVertically] ? self.actionBlockArr.count : 1;
}

- (void)arrangeActionBlockArr
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.actionBlockArr];
    [self.actionBlockArr removeAllObjects];
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        //调整cancel按钮位置,且确保唯一
        __block TTThemedAlertActionModel *cancelActionModel = nil;
        __block BOOL shouldSkipMultiCancelAction = NO;
        [tmpArray enumerateObjectsUsingBlock:^(TTThemedAlertActionModel * _Nonnull actionModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (actionModel.actionType == TTThemedAlertActionTypeCancel) {
                if (!shouldSkipMultiCancelAction) {
                    cancelActionModel = actionModel;
                    shouldSkipMultiCancelAction = YES;
                }
            }
            else {
                [self.actionBlockArr addObject:actionModel];
            }
        }];
        
        if (cancelActionModel) {
            [self.actionBlockArr insertObject:cancelActionModel atIndex:0];
        }
    }
    else {
        //remove掉cancel按钮，单独处理
        [tmpArray enumerateObjectsUsingBlock:^(TTThemedAlertActionModel * _Nonnull actionModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (actionModel.actionType != TTThemedAlertActionTypeCancel) {
                [self.actionBlockArr addObject:actionModel];
            }
        }];
    }
}

- (CGFloat)contentTableViewHeight
{
    return [self contentTableHeaderViewHeight] + [self numberOfContentCells] * TTThemedAlertControllerCellHeight;
}

- (CGFloat)contentTableHeaderViewHeight
{
    CGFloat headerHeight = [self titleViewHeight];
    
    if (self.textView) {
        headerHeight += TTThemedAlertControllerTextViewHeight + TTThemedAlertControllerTextElementMidMargin;
    }
    
    if (self.textFieldArr.count) {
        headerHeight += self.textFieldArr.count * TTThemedAlertControllerTextFieldHeight + (self.textFieldArr.count - 1) * TTThemedAlertControllerTextElementMidMargin;
    }
    
    return headerHeight;
}

- (CGFloat)titleViewHeight
{
    if (self.alertType == TTThemedAlertControllerTypeAlert) {
        if (self.bannerImageView) {
            return TTThemedAlertControllerAlertTypeTitleViewHeight;
        }
        else {
            CGFloat margin = [self isSingleLineTitle] ? 19 : 21;
            CGFloat width = self.tableViewWidth - 44;
            CGFloat fontSize = self.alertUIConfiguration[TTThemedTitleFontKey] ? [self.alertUIConfiguration[TTThemedTitleFontKey] floatValue] : TTThemedAlertDefaultTitleFontSize;
            CGFloat contentHeight = margin + [TTLabelTextHelper heightOfText:self.alertTitle fontSize:fontSize forWidth:width forLineHeight:22.f constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
            if (!isEmptyString(self.message)) {
                fontSize = self.alertUIConfiguration[TTThemedSubTitleFontKey] ? [self.alertUIConfiguration[TTThemedSubTitleFontKey] floatValue] : TTThemedAlertDefaultSubTitleFontSize;
                contentHeight += TTThemedAlertControllerTitleSubTitleSpacing + [TTLabelTextHelper heightOfText:self.message fontSize:fontSize forWidth:width forLineHeight:16.f constraintToMaxNumberOfLines:3 firstLineIndent:0 textAlignment:NSTextAlignmentCenter] + TTThemedAlertControllerBottomMargin;
            }
            else {
                contentHeight += margin;
            }
            return MAX(TTThemedAlertControllerAlertTypeTitleViewHeight - 80, contentHeight);
        }
    }
    else {
        if (isEmptyString(_alertTitle) && isEmptyString(_message)) {
            return 0;
        }
        else if ((isEmptyString(_alertTitle) && !isEmptyString(_message)) ||
                 (!isEmptyString(_alertTitle) && isEmptyString(_message))) {
            return TTThemedAlertControllerSheetTypeTitleViewHeight/2;
        }
        else {
            return TTThemedAlertControllerSheetTypeTitleViewHeight;
        }
    }
}

- (CGRect)frameOfToBeAddedTextElement:(UIView *)elementView
{
    CGFloat padding = [self titleViewHeight];
    if (self.textView) {
        if ([elementView isKindOfClass:[UITextField class]]) {
            padding += CGRectGetHeight(self.textView.frame) + TTThemedAlertControllerTextElementMidMargin;
        }
    }
    
    if (self.textFieldArr.count) {
        NSInteger shouldPaddingTextFieldsCount = self.textFieldArr.count;
        if ([elementView isKindOfClass:[UITextField class]]) {
            shouldPaddingTextFieldsCount -= 1;
        }
        padding += shouldPaddingTextFieldsCount * (TTThemedAlertControllerTextFieldHeight + TTThemedAlertControllerTextElementMidMargin);
    }
    
    CGFloat elementHeight = [elementView isKindOfClass:[UITextView class]] ? TTThemedAlertControllerTextViewHeight : TTThemedAlertControllerTextFieldHeight;
    
    return CGRectMake(TTThemedAlertControllerTextElementMargin, padding, TTThemedAlertTableViewWidth - 2 * TTThemedAlertControllerTextElementMargin, elementHeight);
}

- (BOOL)isSingleLineTitle
{
    CGFloat lineHeight = 22.f;
    CGFloat width = self.tableViewWidth - 44;
    CGFloat fontSize = self.alertUIConfiguration[TTThemedTitleFontKey] ? [self.alertUIConfiguration[TTThemedTitleFontKey] floatValue] : TTThemedAlertDefaultTitleFontSize;
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:self.alertTitle fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    CGFloat titleSingleHeight = [TTLabelTextHelper heightOfText:self.alertTitle fontSize:fontSize forWidth:width forLineHeight:lineHeight constraintToMaxNumberOfLines:1 firstLineIndent:0 textAlignment:NSTextAlignmentCenter];
    return titleHeight == titleSingleHeight;
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.actionSheetView];
    NSLog(@"touchPoint is %@", NSStringFromCGPoint(touchPoint));
    return touchPoint.x < 0 || touchPoint.y < 0;
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfContentCells];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TTThemedAlertControllerCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTThemedAlertControllerActionCell *cell = [tableView dequeueReusableCellWithIdentifier:TTThemedAlertControllerCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[TTThemedAlertControllerActionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                        reuseIdentifier:TTThemedAlertControllerCellIdentifier];
    }
    
    TTThemedAlertActionModel *actionModel = self.actionBlockArr[indexPath.row];
    if ([self showSingleLineCellHorizentally]) {
        [cell configHorizentalCellWithLeftModel:self.actionBlockArr[0]
                                     leftAction:@selector(alertHorizentalLeftButtonPressed)
                                     rightModel:self.actionBlockArr[1]
                                    rightAction:@selector(alertHorizentalRightButtonPressed) target:self];
    }
    else {
        [cell configCellWithActionModel:actionModel isPopover:self.isPopover];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self showSingleLineCellHorizentally]) {
        [self didSelectActionAtIndex:indexPath.row];
    }
}

#pragma mark - UITextField
//可选回调触发block操作
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    TTThemedAlertTextFieldActionBlock textActionBlock = objc_getAssociatedObject(textField, TTThemedAlertControllerTextFieldActionKey);
    if (textActionBlock) {
        textActionBlock(textField);
    }
}

#pragma mark - UITextView
//可选回调触发block操作
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.textViewActionBlock) {
        self.textViewActionBlock(textView);
    }
}

#pragma mark - Keyboard notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    __block CGRect rect = self.alertView.frame;
    
    if (CGRectGetMaxY(rect) > screenHeight - keyboardSize.height) {
        
        CGFloat y = (screenHeight - keyboardSize.height - rect.size.height) / 2;
        if (y < 0) {
            y = 0;
        }
        rect.origin.y = y;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if ([TTDeviceHelper OSVersionNumber] >= 8.0f) {
                                 self.alertView.frame = rect;
                             }
                             else {
                                 [self layoutOniOS7WithOrientation:[UIApplication sharedApplication].statusBarOrientation];
                             }
                         }
                         completion:nil];
    }
}

#pragma mark - Actions

- (void)alertHorizentalLeftButtonPressed
{
    [self didSelectActionAtIndex:0];
}

- (void)alertHorizentalRightButtonPressed
{
    [self didSelectActionAtIndex:1];
}

- (void)didSelectActionAtIndex:(NSInteger)index
{
    //added 4.7:avoid expand-bound crash,but still could not find the reason,maybe didSelectRowAtIndexPath called when show cell single-horizentally unappropriately
    TTThemedAlertActionModel *actionModel = index < self.actionBlockArr.count ? self.actionBlockArr[index] : nil;
    [self dismissSelfFromParentViewControllerWithComplectionBlock:actionModel.actionBlock];
}

#pragma mark - Transition

- (void)showFrom:(UIViewController *)viewController animated:(BOOL)animated
{
    [self showFrom:viewController animated:animated keyboardPresentingWithFrameTop:([[UIScreen mainScreen] bounds].size.height - [TTKeyboardListener sharedInstance].keyboardHeight)];
}

- (void)showFrom:(UIViewController *)viewController animated:(BOOL)animated keyboardPresentingWithFrameTop:(CGFloat)keyboardFrameTop
{
    [self buildSelfAsChildViewControllerOfViewController:viewController];
    [self showSelfWithAnimated:animated];
    [self adjustAlertViewLocationIfNeededWithFrameTop:keyboardFrameTop];
}

- (void)showFrom:(UIViewController *)viewController sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect sourceBarButton:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated
{
    if (IS_PHONE) {
        [self showFrom:viewController animated:YES];
    }
    else {
        self.isPopover = YES;
        [self addSelfAsChildViewControllerOfViewController:viewController];
        [self buildPopoverContent];
        UITableViewController *contentTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        contentTableViewController.tableView = self.contentTableView;
        self.iPadPopoverController = [[UIPopoverController alloc] initWithContentViewController:contentTableViewController];
        CGSize contentSize = CGSizeMake(CGRectGetWidth(self.contentTableView.bounds), CGRectGetHeight(self.contentTableView.bounds));
        [self.iPadPopoverController setPopoverContentSize:contentSize animated:YES];
        if (barButtonItem) {
            [self.iPadPopoverController presentPopoverFromBarButtonItem:barButtonItem
                                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            [self.iPadPopoverController presentPopoverFromRect:sourceRect inView:sourceView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)showContent
{
    //手动实现面9
    self.visualEffectView.alpha = 76.f/255.f;
}

- (void)addSelfAsChildViewControllerOfViewController:(UIViewController *)viewController
{
    UIViewController *rootViewController = viewController.view.window.rootViewController;
    [self willMoveToParentViewController:rootViewController];
    [rootViewController addChildViewController:self];
    [rootViewController.view addSubview:self.view];
    [self didMoveToParentViewController:rootViewController];
    self.showFromViewController = rootViewController;
//    if (viewController.presentingViewController) {
//        [self willMoveToParentViewController:viewController];
//        [viewController addChildViewController:self];
//        [viewController.view addSubview:self.view];
//        [self didMoveToParentViewController:viewController];
//    }
//    else {
//        UIViewController *rootViewController = viewController.view.window.rootViewController;
//        [self willMoveToParentViewController:rootViewController];
//        [rootViewController addChildViewController:self];
//        [rootViewController.view addSubview:self.view];
//        [self didMoveToParentViewController:rootViewController];
//        self.showFromViewController = rootViewController;
//    }
}

- (void)buildSelfAsChildViewControllerOfViewController:(UIViewController *)viewController
{
    UIViewController *vc = viewController;
    if (viewController.presentedViewController) {
        vc = viewController.presentedViewController;
    }
    [self addSelfAsChildViewControllerOfViewController:vc];
    [vc.view.window addSubview:self.visualEffectView];
    [self buildContent];
}

- (void)showSelfWithAnimated:(BOOL)animated
{
    if (animated) {
        [self layoutBeforeAnimation];
        CGFloat animationDuration = (self.alertType == TTThemedAlertControllerTypeAlert) ? 0.2 : 0.3;
        [UIView animateWithDuration:animationDuration animations:^{
            [self showContent];
            if (self.alertType == TTThemedAlertControllerTypeAlert) {
//                if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.f) {
//                    self.alertView.transform = CGAffineTransformConcat(self.alertView.transform, CGAffineTransformMakeScale(1.05, 1.05));
//                }
//                else {
                self.alertView.transform = CGAffineTransformMakeScale(1.05, 1.05);
//                }
            }
            else {
                CGRect rect = self.actionSheetView.frame;
                rect.origin.y -= rect.size.height;
                self.actionSheetView.frame = rect;
            }
        } completion:^(BOOL finished) {
            if (self.alertType == TTThemedAlertControllerTypeAlert) {
                [UIView animateWithDuration:animationDuration animations:^{
                    if ([TTDeviceHelper OSVersionNumber] >= 8.f) {
                        self.alertView.transform = CGAffineTransformIdentity;
                    }
                    else {
                        [self layoutOniOS7WithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
                    }
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
    else {
        [self showContent];
    }
}

- (void)layoutBeforeAnimation
{
    if (self.alertType == TTThemedAlertControllerTypeActionSheet) {
        CGRect rect = self.actionSheetView.frame;
        rect.origin.y += rect.size.height;
        self.actionSheetView.frame = rect;
    }
    else {
        self.alertView.transform = CGAffineTransformMakeScale(0.f, 0.f);
    }
}

- (void)dismissSelfFromParentViewControllerDidCancel
{
    [self dismissSelfFromParentViewControllerWithComplectionBlock:nil];
}

- (void)dismissSelfFromParentViewControllerWithComplectionBlock:(TTThemedAlertActionBlock)complectionBlock
{
    [UIView animateWithDuration:0.2 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.alertType == TTThemedAlertControllerTypeAlert) {
             self.alertView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        }
        else{
            CGRect rect = self.actionSheetView.frame;
            rect.origin.y += rect.size.height;
            self.actionSheetView.frame = rect;
        }
    }completion:^(BOOL finished){
        [self.visualEffectView removeFromSuperview];
        [self.alertView removeFromSuperview];
        [self.actionSheetView removeFromSuperview];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (self.iPadPopoverController) {
            [self.iPadPopoverController dismissPopoverAnimated:YES];
        }
        
        if (complectionBlock) {
            complectionBlock();
        }
    }];
}

@end
