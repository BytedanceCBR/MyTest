//
//  SSFeedbackContainerView.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-7.
//
//

#import "SSFeedbackContainerView.h"
#import "SSSegment.h"
#import "SSSegmentControl.h"
#import "SSMyFeedbackView.h"
#import "SSFeedbackFAQView.h"
#import "SSFeedbackPostViewController.h"
#import "SSFeedbackManager.h"
 
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"



#define inputButtonHeight 44.f
#define segmentViewHeight 0
#define segmentNumber 2 //cannot be 0

typedef enum SSFeedbackSegmentType {
    SSFeedbackSegmentTypeLeft,
    SSFeedbackSegmentTypeRight
}SSFeedbackSegmentType;

@interface SSFeedbackInputButton : UIView

@property(nonatomic, retain)UIButton * bgButton;
@property(nonatomic, retain)UILabel * inputTitleLabel;
- (void)refreshUI;

@end

@implementation SSFeedbackInputButton

- (void)dealloc
{
    self.inputTitleLabel = nil;
    self.bgButton = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgButton];
        
        self.inputTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_inputTitleLabel setText:NSLocalizedString(@"期待您的意见反馈", nil)];
        [_inputTitleLabel sizeToFit];
        _inputTitleLabel.backgroundColor = [UIColor clearColor];
        [_inputTitleLabel setFont:[UIFont systemFontOfSize:14.f]];
        [self addSubview:_inputTitleLabel];
        [self refreshUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIEdgeInsets safeAreaInsets = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
    float originY = (self.frame.size.height - _inputTitleLabel.frame.size.height - safeAreaInsets.bottom) / 2.f;
    float originX = padding + 60.f + safeAreaInsets.left;
    _inputTitleLabel.origin = CGPointMake(originX, originY);
    _bgButton.frame = CGRectMake(padding + safeAreaInsets.left, 0, self.width - 2 *padding - safeAreaInsets.left - safeAreaInsets.right, self.height - safeAreaInsets.bottom);
}

- (void)refreshUI
{
    if(([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay)){
        [self setBackgroundColor:[UIColor colorWithRed:247.f/255.f green:247.f/255.f blue:247.f/255.f alpha:1.f]];
    }
    else{
        [self setBackgroundColor:[UIColor colorWithRed:20.f/255.f green:21.f/255.f blue:22.f/255.f alpha:1.f]];
    }
    
    UIImage *backgroundImage = [UIImage themedImageNamed:@"dock_comment.png"];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(0, backgroundImage.size.width / 2.f, 0, backgroundImage.size.width / 2.f);
    backgroundImage = [backgroundImage resizableImageWithCapInsets:capInsets];
    
    UIImage *backgroundHighlightImage = [UIImage themedImageNamed:@"dock_comment.png"];
    capInsets = UIEdgeInsetsMake(0, backgroundHighlightImage.size.width / 2.f, 0, backgroundHighlightImage.size.width / 2.f);
    backgroundHighlightImage = [backgroundHighlightImage resizableImageWithCapInsets:capInsets];
    
    [_bgButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_bgButton setBackgroundImage:backgroundHighlightImage forState:UIControlStateHighlighted];
    [_inputTitleLabel setTextColor:[UIColor tt_themedColorForKey:kColorText3]];
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeInset = self.safeAreaInsets;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        if (ceil(self.height) - ceil(inputButtonHeight) == 0 &&
            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
            CGFloat toolBarHeight = (inputButtonHeight + safeInset.bottom);
            frameInWindow = CGRectMake(frameInWindow.origin.x, screenHeight - toolBarHeight, self.width,toolBarHeight);
            self.frame = [self.superview convertRect:frameInWindow fromView:nil];
        }
    }
}

@end

@interface SSFeedbackSegment : SSSegment
@property(nonatomic)SSFeedbackSegmentType type;
- (void)refreshUI;

@end

@implementation SSFeedbackSegment

- (id)initWithFrame:(CGRect)frame type:(SSFeedbackSegmentType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [self refreshUI];
    }
    return self;
}

- (void)setChecked:(BOOL)checked
{
    [super setChecked:checked];
    [self refreshUI];
}

- (void)refreshUI
{
    [super refreshUI];
    
    [self setBackgroundColor:SSGetThemedColorWithKey(kColorBackground4)];
    [self setTitleColor:SSGetThemedColorWithKey(kColorText1) forState:UIControlStateNormal];
}



@end

@interface SSFeedbackContainerView()<SSSegmentControlDelegate>

@property (nonatomic, retain) SSViewBase * currentView;
@property (nonatomic, retain) SSMyFeedbackView * myFeedbackView;
@property (nonatomic, retain) SSFeedbackFAQView * FAQView;
@property (nonatomic, retain) SSFeedbackInputButton * inputButton;

@end

@implementation SSFeedbackContainerView

- (void)dealloc
{
    self.inputButton = nil;
    self.myFeedbackView = nil;
    self.FAQView = nil;
    self.currentView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildListView];
        [self buildInputView];
        [self reloadThemeUI];
    }
    return self;
}

- (void)buildInputView
{
    self.inputButton = [[SSFeedbackInputButton alloc] initWithFrame:[self frameForInputButton]];
    [_inputButton.bgButton addTarget:self action:@selector(inputButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_inputButton];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    [_inputButton refreshUI];
}

- (void)inputButtonClicked
{
    SSFeedbackPostViewController * controller = [[SSFeedbackPostViewController alloc] init];
    UIViewController * topContr = [TTUIResponderHelper topViewControllerFor: self];
    if ([topContr isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)topContr) pushViewController:controller animated:YES];
    }
    else {
        [topContr.navigationController pushViewController:controller animated:YES];
    }
}

- (CGRect)frameForInputButton
{
    UIEdgeInsets safeAreaInsets = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectMake(-padding, CGRectGetMaxY([self frameForListView]), CGRectGetWidth([self frameForListView])+ 2 *padding, inputButtonHeight + safeAreaInsets.bottom);
    }
    else{
        return CGRectMake(0, CGRectGetMaxY([self frameForListView]), CGRectGetWidth([self frameForListView]), inputButtonHeight + safeAreaInsets.bottom);
    }
}

- (void)buildListView
{
    self.myFeedbackView = [[SSMyFeedbackView alloc] initWithFrame:[self frameForListView]];
    self.FAQView = [[SSFeedbackFAQView alloc] initWithFrame:[self frameForListView]];
    self.currentView = _myFeedbackView;
}

- (CGRect)frameForListView
{
    UIEdgeInsets safeAreaInsets = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
    return CGRectMake(safeAreaInsets.left, segmentViewHeight, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.height - segmentViewHeight - inputButtonHeight - safeAreaInsets.bottom);
}

- (void)setCurrentView:(SSViewBase *)currentView
{
    if (_currentView != currentView) {
        if ([self.subviews containsObject:_currentView]) {
            [_currentView willDisappear];
            [_currentView didDisappear];
            [_currentView removeFromSuperview];
        }
        BOOL needInvokeAppear = _currentView != nil;
        _currentView = currentView;
        [self addSubview:_currentView];
        if (needInvokeAppear) {
            [_currentView willAppear];
            [_currentView didAppear];
        }
    }
}

- (void)willAppear
{
    [super willAppear];
    [_currentView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    [_currentView didAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_currentView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_currentView didDisappear];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.myFeedbackView.frame = [self frameForListView];
    self.FAQView.frame = [self frameForListView];
    self.inputButton.frame = [self frameForInputButton];
    
}
#pragma mark -- SSSegmentControlDelegate

- (void)ssSegmentControl:(SSSegmentControl *)ssSegmentControl didSelectAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            self.currentView = _myFeedbackView;
            break;
        case 1:
            self.currentView = _FAQView;
            break;
        default:
            break;
    }
}

@end
