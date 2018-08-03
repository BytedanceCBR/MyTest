//
//  SSTitlePopOverView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-8-15.
//
//

#import "SSTitlePopOverView.h"
#import "UIColorAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+Addition.h"

//Button
#define PopOverButtonHeight 40.f
//PopOver
#define PopOverShadowHeight 5.f
#define ButtonContentViewSeparatorLineHeight 1.f
#define PopOverWidth ([UIImage resourceImageNamed:@"menu_bg_up.png"] != nil ? [UIImage resourceImageNamed:@"menu_bg_up.png"].size.width : 160)
#define PopOverForeGroundHeiht ([UIImage resourceImageNamed:@"menu_bg_up.png"] != nil ? [UIImage resourceImageNamed:@"menu_bg_up.png"].size.height : 44)
#define ButtonContentViewHideStatusShowDistance 8.f
#define PopOverInitialHeight PopOverForeGroundHeiht + ButtonContentViewHideStatusShowDistance
#define ButtonContentViewWidth ([UIImage resourceImageNamed:@"popup_menu.png"] != nil ? [UIImage resourceImageNamed:@"popup_menu.png"].size.width : 121)
#define ButtonContentViewHeight  102.f

@interface SSTitlePopOverButton()


@end

@implementation SSTitlePopOverButton

+ (id)initPopOverButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor colorWithHexString:SSUIString(@"uiSSTitlePopOverButtonNormalTitleColor", @"#ff0000")] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:SSUIString(@"uiSSTitlePopOverButtonPressTitleColor", @"00ff00")] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithHexString:SSUIString(@"uiSSTitlePopOverButtonPressTitleColor", @"0000ff")] forState:UIControlStateSelected];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.f]];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleShadowColor:[UIColor colorWithHexString:SSUIString(@"uiSSTtilePopOverButtonShadowColor", @"#00000066")] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(0, SSUIFloat(@"uiSSTitlePopOverButtonShadowOffset", 0.5f));
    button.frame = CGRectMake(0, 0, ButtonContentViewWidth - 20, PopOverButtonHeight);    
    return button;
}


@end

@interface SSTitlePopOverView()

@property(nonatomic, retain, readwrite)NSArray * popOverButtons;
@property(nonatomic, retain, readwrite)UIImageView * foregroundImageView;
@property(nonatomic, retain, readwrite)UIImageView * backgroundImageView;
@property(nonatomic, retain, readwrite)UIImageView * contentImageView;
@property(nonatomic, retain)UIButton * foregroundButton;
@property(nonatomic, retain)UIView * buttonContentView;
@property(nonatomic, retain, readwrite)UILabel * titleLabel;
@property(nonatomic, retain)UIImageView * titleImageView;
@property(nonatomic, retain, readwrite)UIImageView * popArrowView;

/*
    想要吧popover 抽象成独立的控件， 但是， 点击除该控件其他区域， 则控件弹出的view收回。 
    为了这个需求， 此处添加left,center,right button 将直接由keywindow addSubView
    添加left,center,right button， 是为了空出popover控件本身。
    暂无更好的方法。
 */
@property(nonatomic, retain)UIButton * leftHiddenButton;
@property(nonatomic, retain)UIButton * centerHiddenButton;
@property(nonatomic, retain)UIButton * rightHiddenButton;



@property(nonatomic, assign)BOOL isDisplayEntire;

@end

@implementation SSTitlePopOverView
@synthesize titleImages = _titleImages;
@synthesize titleImageView = _titleImageView;
@synthesize titleLabel = _titleLabel;
@synthesize popOverButtons = _popOverButtons;
@synthesize foregroundImageView = _foregroundImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize contentImageView = _contentImageView;
@synthesize foregroundButton = _foregroundButton;
@synthesize buttonContentView = _buttonContentView;
@synthesize isDisplayEntire = _isDisplayEntire;

@synthesize leftHiddenButton = _leftHiddenButton;
@synthesize centerHiddenButton = _centerHiddenButton;
@synthesize rightHiddenButton = _rightHiddenButton;

@synthesize popArrowView = _popArrowView;
@synthesize separators;

- (void)dealloc
{
    self.popArrowView = nil;
    self.titleImages = nil;
    self.titleLabel = nil;
    self.titleImageView = nil;
    
    self.popOverButtons = nil;
    
    self.leftHiddenButton = nil;
    self.centerHiddenButton = nil;
    self.rightHiddenButton = nil;
    
    self.buttonContentView = nil;
    self.foregroundButton = nil;
    self.foregroundImageView = nil;
    self.backgroundImageView = nil;
    self.contentImageView = nil;
    self.separators = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isDisplayEntire = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.foregroundImageView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"menu_bg_up.png"]] autorelease];
        _foregroundImageView.frame = CGRectMake((frame.size.width - _foregroundImageView.frame.size.width) / 2, 0, CGRectGetWidth(_foregroundImageView.frame), CGRectGetHeight(_foregroundImageView.frame));
        [self addSubview:_foregroundImageView];
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"menu_bg_down.png"]];
        self.backgroundImageView = imageView;
        imageView.frame = CGRectMake((self.frame.size.width - imageView.frame.size.width) / 2, CGRectGetMaxY(_foregroundImageView.frame), CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
        [self addSubview:imageView];
        [imageView release];
        
        self.foregroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _foregroundButton.frame = _foregroundImageView.frame;
        [_foregroundButton addTarget:self action:@selector(foregroundButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _foregroundButton.backgroundColor = [UIColor clearColor];
        [self addSubview:_foregroundButton];
        
        self.buttonContentView = [[[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - ButtonContentViewWidth) / 2, CGRectGetMaxY(_foregroundButton.frame) - ButtonContentViewHeight + ButtonContentViewHideStatusShowDistance, ButtonContentViewWidth, ButtonContentViewHeight)] autorelease];
        _buttonContentView.backgroundColor = [UIColor clearColor];
        UIImageView * bgImgView = [[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"popup_menu.png"]];
        self.contentImageView = bgImgView;
        bgImgView.frame = _buttonContentView.bounds;
        bgImgView.frame = CGRectMake(0, 0, CGRectGetWidth(bgImgView.frame), CGRectGetHeight(bgImgView.frame));
        bgImgView.contentStretch = CGRectMake(0.4, 0.4, 0.2, 0.2);
        bgImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_buttonContentView addSubview:bgImgView];
        [self addSubview:_buttonContentView];
        [bgImgView release];
        
        [self bringSubviewToFront:_foregroundImageView];
        [self bringSubviewToFront:_foregroundButton];
        
        self.leftHiddenButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        _leftHiddenButton.backgroundColor = [UIColor clearColor];
        
        self.rightHiddenButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        _rightHiddenButton.backgroundColor = [UIColor clearColor];
        
        self.centerHiddenButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        _centerHiddenButton.backgroundColor = [UIColor clearColor];
        
        [_leftHiddenButton addTarget:self action:@selector(hidenEntireButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_centerHiddenButton addTarget:self action:@selector(hidenEntireButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_rightHiddenButton addTarget:self action:@selector(hidenEntireButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _titleLabel.backgroundColor = [UIColor clearColor];
        BOOL isBold = SSUIBool(@"uiSSTitlePopOverButtonFontIsBold", 1);
        if (isBold) {
            [_titleLabel setFont:[UIFont boldSystemFontOfSize:SSUIFloat(@"uiSSTitlePopOverButtonFontSize", 16.f)]];
        }
        else {
            [_titleLabel setFont:[UIFont systemFontOfSize:SSUIFloat(@"uiSSTitlePopOverButtonFontSize", 16.f)]];
        }
        [_titleLabel setTextColor:[UIColor colorWithHexString:SSUIString(@"SSTitleBarViewTitleLabelColor", @"ffffff")]];
        [_foregroundImageView addSubview:_titleLabel];
        
        self.titleImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        _titleImageView.backgroundColor = [UIColor clearColor];
        [_foregroundImageView addSubview:_titleImageView];
        
        self.popArrowView = [[[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"arrow_pop.png"]] autorelease];
        [_foregroundImageView addSubview:_popArrowView];
    }
    return self;
}

- (id)initWithPopOverButtons:(NSArray *)buttons titleImages:(NSArray *)images
{
    self = [self initWithFrame:CGRectMake(0, 0, PopOverWidth, PopOverInitialHeight)];
    if (self) {
        self.popOverButtons = buttons;
        self.titleImages = images;
        [self addButtonsOnButtonContentview];
        
        if ([images count] > 0) {
            [self settitleImage:[images objectAtIndex:0]];
        }
        else if ([buttons count] > 0) {
            NSString * title = ((UIButton *)[buttons objectAtIndex:0]).titleLabel.text;
            if ([title length] > 0) {
                [self setTitleLabelText:title];
            }
        }
        
    }
    return self;
}

//- (id)initWithPopOverButtons:(NSArray *)buttons titleImages:(NSArray *)images currentInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    self = [self initWithPopOverButtons:buttons titleImages:images];
//    if (self) {
//        self.interfaceOrientation = orientation;
//    }
//    return self;
//}
//
//- (id)initWithPopOverButtons:(NSArray *)buttons currentInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    self = [self initWithPopOverButtons:buttons];
//    if (self) {
//        self.interfaceOrientation = orientation;
//    }
//    return self;
//}



- (id)initWithPopOverButtons:(NSArray *)buttons
{
    self = [self initWithPopOverButtons:buttons titleImages:nil];
    if (self) {
        
    }
    return self;
}

- (void)addButtonsOnButtonContentview
{
    if (!separators) {
        self.separators = [NSMutableArray arrayWithCapacity:[_popOverButtons count]];
    }
    else {
        [separators removeAllObjects];
    }
    
    for (int i = 0 ; i < [_popOverButtons count]; i ++) {
        SSTitlePopOverButton * button = [_popOverButtons objectAtIndex:i];
        button.tag = i;
        CGRect buttonFrame = button.frame;
        buttonFrame.origin.x = (CGRectGetWidth(_buttonContentView.frame) - CGRectGetWidth(buttonFrame) ) / 2;
        buttonFrame.origin.y = i * PopOverButtonHeight;
        button.frame = buttonFrame;
        [_buttonContentView addSubview:button];
        [button addTarget:self action:@selector(selectButtonContentItem:) forControlEvents:UIControlEventTouchUpInside];
        if (i != [_popOverButtons count] -1) {
            UIImageView * separaImageView = [[UIImageView alloc] initWithImage:[UIImage resourceImageNamed:@"line_pop.png"]];
            separaImageView.frame = CGRectMake((CGRectGetWidth(_buttonContentView.frame) - CGRectGetWidth(separaImageView.frame)) / 2, CGRectGetMaxY(buttonFrame), CGRectGetWidth(separaImageView.frame), CGRectGetHeight(separaImageView.frame));
            [_buttonContentView addSubview:separaImageView];
            [self.separators addObject:separaImageView];
            [separaImageView release];
        }
    }
    
    CGRect buttonContentViewFrame = _buttonContentView.frame;
    buttonContentViewFrame.size.height = [_popOverButtons count] * PopOverButtonHeight + ([_popOverButtons count] - 1) * ButtonContentViewSeparatorLineHeight + PopOverShadowHeight;
    _buttonContentView.frame = buttonContentViewFrame;
    
    if (_titleImages == nil) {
        NSString * title = ((UIButton *)[_popOverButtons objectAtIndex:0]).titleLabel.text;
        if ([title length] > 0) {
            [self setTitleLabelText:title];
        }
    }
    
    CGRect contentViewOriginFrame = _buttonContentView.frame;
    contentViewOriginFrame.origin.y = CGRectGetMaxY(_foregroundButton.frame) - CGRectGetHeight(_buttonContentView.frame) + ButtonContentViewHideStatusShowDistance;
    _buttonContentView.frame = contentViewOriginFrame;
}

- (void)selectButtonContentItem:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        NSString * title = ((UIButton *)sender).titleLabel.text;
        if ([title length] > 0) {
            [self setTitleLabelText:title];
            [_titleLabel sizeToFit];
        }
        else if([_titleImages count] > 0){
            int index = 0;
            if (((UIButton *)sender).tag < [_titleImages count]) {
                index = ((UIButton *)sender).tag;
            }
            
            UIImage * image = [_titleImages objectAtIndex:index];
            
            if (image != nil) {
                [self settitleImage:image];
            }
        }
    }    
    [self hidenEntireButtonClick];
}


#pragma mark -- private

- (CGRect)convertHidenButtonRectToKeyWindow:(CGRect)rect
{
    CGRect result = [[SSCommon topViewControllerFor:self].view convertRect:rect toView:[[UIApplication sharedApplication] keyWindow]];
    return result;
}

- (void)reframeHidenButton
{
    float largeScreenSide = MAX(screenSize().width, screenSize().height);
    float shortScreenSide = MIN(screenSize().width, screenSize().height);
    float statusBarHeight = MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
    
//    CGRect popRectOnKeyWindow = [self convertRect:self.bounds toView:[[UIApplication sharedApplication] keyWindow]];
    
    CGRect popRectOnKeyWindow = CGRectMake(self.frame.origin.x, statusBarHeight, self.bounds.size.width, self.bounds.size.height);
    
    if (UIInterfaceOrientationIsPortrait([UIApplication currentUIOrientation])) {
        
        CGRect leftRect = CGRectMake(0, 0, CGRectGetMinX(popRectOnKeyWindow), largeScreenSide - statusBarHeight);
        _leftHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:leftRect];
        
        CGRect centerRect = CGRectMake(CGRectGetMinX(popRectOnKeyWindow), CGRectGetMaxY(popRectOnKeyWindow), CGRectGetWidth(popRectOnKeyWindow), largeScreenSide - CGRectGetMaxY(popRectOnKeyWindow) - statusBarHeight);
        _centerHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:centerRect];
        
        CGRect rightRect = CGRectMake(CGRectGetMaxX(popRectOnKeyWindow), 0, shortScreenSide - CGRectGetMaxX(popRectOnKeyWindow), largeScreenSide - statusBarHeight);
        _rightHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:rightRect];
    }
    else {
        CGRect leftRect = CGRectMake(0, 0, CGRectGetMinX(popRectOnKeyWindow), shortScreenSide - statusBarHeight);
        _leftHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:leftRect];
        
        CGRect centerRect = CGRectMake(CGRectGetMinX(popRectOnKeyWindow), CGRectGetMaxY(popRectOnKeyWindow), CGRectGetWidth(popRectOnKeyWindow), shortScreenSide - CGRectGetMaxY(popRectOnKeyWindow) - statusBarHeight);
        _centerHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:centerRect];
        
        CGRect rightRect = CGRectMake(CGRectGetMaxX(popRectOnKeyWindow), 0, largeScreenSide - CGRectGetMaxX(popRectOnKeyWindow), shortScreenSide - statusBarHeight);
        _rightHiddenButton.frame = [self convertHidenButtonRectToKeyWindow:rightRect];
    }    
}

- (void)resetPopArrowFrame:(CGRect)leftViewFrame
{
    CGRect arrowRect = _popArrowView.frame;
    arrowRect.origin.x = CGRectGetMaxX(leftViewFrame) + 5.f;
    arrowRect.origin.y = CGRectGetMinY(leftViewFrame) + CGRectGetHeight(leftViewFrame) / 2 - CGRectGetHeight(arrowRect) / 2;
    _popArrowView.frame = arrowRect;
}

- (void)settitleImage:(UIImage *)image
{
    [_titleImageView setImage:image];
    [_titleImageView sizeToFit];
    _titleImageView.frame = CGRectMake((CGRectGetWidth(_foregroundImageView.frame) - CGRectGetWidth(_titleImageView.frame)) / 2, CGRectGetHeight(_foregroundImageView.frame) - CGRectGetHeight(_titleImageView.frame) - 3, CGRectGetWidth(_titleImageView.frame), CGRectGetHeight(_titleImageView.frame));
    [self resetPopArrowFrame:_titleImageView.frame];
}

- (void)setTitleLabelText:(NSString *)title
{
    [_titleLabel setText:title];
    [_titleLabel sizeToFit];
    _titleLabel.frame = CGRectMake((CGRectGetWidth(_foregroundImageView.frame) - CGRectGetWidth(_titleLabel.frame)) / 2, CGRectGetHeight(_foregroundImageView.frame) - CGRectGetHeight(_titleLabel.frame) - 5, CGRectGetWidth(_titleLabel.frame), CGRectGetHeight(_titleLabel.frame));
    [self resetPopArrowFrame:_titleLabel.frame];
}

- (void)changeSelfFrame
{
    CGRect popOverFrame = self.frame;
    
    if (_isDisplayEntire) {
        popOverFrame.size.height = PopOverForeGroundHeiht + [SSTitlePopOverView heightOfMaxContentView:[_popOverButtons count]];
    }
    else {
        popOverFrame.size.height = PopOverInitialHeight;
    }
    self.frame = popOverFrame;
}

- (void)hiddenButtonContentAction
{
    [self changeSelfFrame];
    [self removeHiddenButtonFromKeyWindow];
    CGRect contentViewOriginFrame = _buttonContentView.frame;
    contentViewOriginFrame.origin.y = CGRectGetMaxY(_foregroundButton.frame) - CGRectGetHeight(_buttonContentView.frame) + ButtonContentViewHideStatusShowDistance;
    [UIView animateWithDuration:0.25f animations:^{
        _buttonContentView.frame = contentViewOriginFrame;
        _popArrowView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * .0f, 0.0f, 0.0f, 1.0f);
    }];
}

- (void)showEntireAction
{
    [self changeSelfFrame];
    [self addHideButtonToKeyWindow];
    CGRect contentViewOriginFrame = _buttonContentView.frame;
    contentViewOriginFrame.origin.y = CGRectGetMaxY(_foregroundImageView.frame);
    [UIView animateWithDuration:0.25f animations:^{
        _buttonContentView.frame = contentViewOriginFrame;
        _popArrowView.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
    }];
}

#pragma mark -- button click

- (void)hidenEntireButtonClick
{
    _isDisplayEntire = NO;
    [self hiddenButtonContentAction];
}


- (void)changeContentViewStatus
{
    _isDisplayEntire = !_isDisplayEntire;
    
    if (_isDisplayEntire) {

        [self showEntireAction];
        
    }
    else {
        [self hiddenButtonContentAction];
    }
}

- (void)foregroundButtonClick
{
    [self changeContentViewStatus];
}

#pragma mark -- hide button


- (void)addHideButtonToKeyWindow
{
//    CGRect popRectOnKeyWindow = [self convertRect:self.bounds toView:[[UIApplication sharedApplication] keyWindow]];
//
//    _leftHiddenButton.frame = CGRectMake(0, 0, CGRectGetMinX(popRectOnKeyWindow), screenSize().height);
//    _centerHiddenButton.frame = CGRectMake(CGRectGetMinX(popRectOnKeyWindow), CGRectGetMaxY(popRectOnKeyWindow), CGRectGetWidth(popRectOnKeyWindow), screenSize().height - CGRectGetMaxY(popRectOnKeyWindow));
//    _rightHiddenButton.frame = CGRectMake(CGRectGetMaxX(popRectOnKeyWindow), 0, screenSize().width - CGRectGetMaxX(popRectOnKeyWindow), screenSize().height);
    
    [self reframeHidenButton];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_leftHiddenButton];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_centerHiddenButton];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_rightHiddenButton];
    
    
}

- (void)removeHiddenButtonFromKeyWindow
{
    [_leftHiddenButton removeFromSuperview];
    [_centerHiddenButton removeFromSuperview];
    [_rightHiddenButton removeFromSuperview];
}


#pragma mark -- util

+ (CGFloat)heightOfMaxContentView:(NSInteger)buttonCount
{
    float height = 0;
    height += buttonCount * PopOverButtonHeight;
    height += (buttonCount - 1) * ButtonContentViewSeparatorLineHeight;
    return height;
}

#pragma mark -- life cycle

- (void)layoutSubviews
{
    [self reframeHidenButton];
}

- (void)willAppear
{
    [super willAppear];
    
}

- (void)didAppear
{
    [super didAppear];
    
}

- (void)willDisappear
{
    [super willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
}
@end
