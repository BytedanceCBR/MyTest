//
//  FHFastQAViewController.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQAViewController.h"
#import <FHCommonUI/FHRoundShadowView.h>
#import <Masonry/Masonry.h>
#import <FHHouseBase/FHCommonDefines.h>
#import "FHFastQATextView.h"
#import "FHFastQAGuessQuestionView.h"
#import "FHFastQAMobileNumberView.h"
#import <KVOController/KVOController.h>
#import "FHFastQAViewModel.h"
#import <FHHouseBase/FHTracerModel.h>
#import <FHHouseBase/FHURLSettings.h>

#define BANNER_WIDTH 375
#define BANNER_HEIGHT 202
#define CONTAINTER_TOP 136
#define CONTAINER_HOR_MARGIN 15
#define QUESTION_VIEW_HEIGHT 90
#define ITEM_VER_MARGIN      10
#define MOBILE_TO_GESS       30
#define MOBILE_HEIGHT        88
#define SUBMIT_HEIGHT        44

@interface FHFastQAViewController ()

@property(nonatomic , strong) UIScrollView *scrollView;
@property(nonatomic , strong) UIControl *bgView;
@property(nonatomic , strong) UIImageView *bannerImgView;
@property(nonatomic , strong) UIImageView *clockImgView;
@property(nonatomic , strong) UILabel *bannerTitleLabel;
@property(nonatomic , strong) UILabel *bannerInfoLabel;
@property(nonatomic , strong) FHRoundShadowView *containerView;
@property(nonatomic , strong) UILabel *tipLabel;
@property(nonatomic , strong) FHFastQATextView *questionView;
@property(nonatomic , strong) FHFastQAGuessQuestionView *guessView;
@property(nonatomic , strong) FHFastQAMobileNumberView *mobileView;
@property(nonatomic , strong) UIButton *submitButton;
@property(nonatomic , strong) UILabel *aboutLabel;
@property(nonatomic , strong) FHFastQAViewModel *viewModel;
@end

@implementation FHFastQAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupDefaultNavBar:YES];
    self.title = @"幸福问答";
    
    self.tracerModel.categoryName = @"want_ask_question";
    self.tracerModel.enterFrom = @"quick_ask_question";
    self.tracerModel.originFrom = @"everyone_ask_question";
    
    [self setupUI];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsZero];
    self.emptyView.hidden = YES;
    self.viewModel = [[FHFastQAViewModel alloc] init];
    self.viewModel.viewController = self;
    _viewModel.questionView = _questionView;
    _viewModel.guessView = _guessView;
    _viewModel.mobileView = _mobileView;
    
    [self.viewModel requestData];
    
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.containerView keyPath:@"bounds" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        [wself tryUpdateContentSize];
    }];
    
    [self.viewModel addQuckAction];
    [self.viewModel addGoDetailLog];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotifiation:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotifiation:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    [self.viewModel viewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [self.viewModel viewWillDisappear];
}

- (void)retryLoadData
{
    [self.viewModel requestData];
}

-(void)setupUI
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0 , *)){
        insets = [[UIApplication sharedApplication]delegate].window.safeAreaInsets;
    }
    CGRect frame = self.view.bounds;
    if (insets.top > 1) {
        frame.origin.y = (44+insets.top);
    }else{
        frame.origin.y = 64;
    }
    frame.size.height -= frame.origin.y;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [self.view addSubview:_scrollView];
    frame.origin = CGPointZero;
    _bgView = [[UIControl alloc] initWithFrame:frame];
    _bgView.backgroundColor = [UIColor whiteColor];
    [_bgView addTarget:self action:@selector(onTapBgAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_bgView];
    
    _bannerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*BANNER_HEIGHT/BANNER_WIDTH)];
    _bannerImgView.image = SYS_IMG(@"fast_qa_banner.jpg");    
    _clockImgView = [[UIImageView alloc]initWithImage:SYS_IMG(@"fast_qa_clock")];
    _bannerTitleLabel = [[UILabel alloc] init];
    _bannerTitleLabel.textColor = [UIColor themeGray1];
    _bannerTitleLabel.font = [UIFont themeFontSemibold:18];
    _bannerTitleLabel.text = @"买房从提问开始";
    _bannerInfoLabel = [[UILabel alloc] init];
    _bannerInfoLabel.textColor = [UIColor themeGray3];
    _bannerInfoLabel.font = [UIFont themeFontRegular:12];
    _bannerInfoLabel.text = @"百位幸福专家为你解答";
    [_bannerImgView addSubview:_clockImgView];
    [_bannerImgView addSubview:_bannerTitleLabel];
    [_bannerImgView addSubview:_bannerInfoLabel];
    
    
    __weak typeof(self) wself = self;
    _containerView = [[FHRoundShadowView alloc] initWithFrame:self.view.bounds];
    _containerView.cornerRadius = 4;
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.shadowOffset = CGSizeMake(0, 2);
    _containerView.shadowRadius = 6;
    _containerView.shadowColor = [UIColor blackColor];
    _containerView.shadowOpacity = 0.1;
    _containerView.tapBlankBlock = ^{
        [wself onTapBgAction:nil];
    };
    
    [_bgView addSubview:_bannerImgView];
    [_bgView addSubview:_containerView];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.font = [UIFont themeFontRegular:11];
    _tipLabel.textColor = [UIColor themeGray3];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    _tipLabel.text = @"平台承诺：所有问答均来自于真实用户和幸福专家的交流";
    
    CGFloat contentWidth = SCREEN_WIDTH - 2*HOR_MARGIN - 2*CONTAINER_HOR_MARGIN;
    
    _questionView = [[FHFastQATextView alloc]initWithFrame:CGRectMake(0, 0, contentWidth, QUESTION_VIEW_HEIGHT)];
    _questionView.placeholder = @"在这里输入您的问题（非必填）";
    
    _guessView = [[FHFastQAGuessQuestionView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    
    _mobileView = [[FHFastQAMobileNumberView alloc]initWithFrame:CGRectMake(0, 0, contentWidth, MOBILE_HEIGHT)];
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitButton setTitle:@"提交问题" forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _submitButton.titleLabel.font = [UIFont themeFontRegular:16];
    _submitButton.backgroundColor = [UIColor themeRed1];
    _submitButton.layer.cornerRadius = 4;
    _submitButton.layer.masksToBounds = YES;
    [_submitButton addTarget:self action:@selector(onSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _aboutLabel = [[UILabel alloc]init];
    _aboutLabel.font = [UIFont themeFontRegular:10];
    _aboutLabel.textColor = [UIColor themeGray4];
    NSMutableAttributedString* attrText = [[NSMutableAttributedString alloc] initWithString:@"提交即视为同意《个人信息保护声明》"];
    [attrText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(8, @"个人信息保护声明".length)];
    _aboutLabel.attributedText= attrText;
    [_aboutLabel sizeToFit];
    _aboutLabel.textAlignment = NSTextAlignmentCenter;
    UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tipBtnDidClick)];
    self.aboutLabel.userInteractionEnabled = YES;
    [self.aboutLabel addGestureRecognizer:tipTap];
    
    NSArray *views = @[_tipLabel , _questionView,_guessView,_mobileView,_submitButton,_aboutLabel];
    [views enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.containerView addSubview:obj];
    }];
    
    [self initConstraints] ;
    
}

-(void)initConstraints
{
    [self.bannerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.bannerImgView.superview);
        make.height.mas_equalTo(CGRectGetHeight(self.bannerImgView.bounds));
    }];
    
    [_clockImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(18);
        make.size.mas_equalTo(CGSizeMake(47, 46));
    }];
    
    [_bannerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(self.clockImgView.mas_bottom).offset(3);
        make.height.mas_equalTo(25);
    }];
    [_bannerInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.top.mas_equalTo(self.bannerTitleLabel.mas_bottom).offset(3);
    }];
    
    
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.right.mas_equalTo(-HOR_MARGIN);
        make.top.mas_equalTo(CONTAINTER_TOP);
        make.bottom.mas_equalTo(self.aboutLabel.mas_bottom).offset(11);
    }];

#define MAKE_HOR()  make.left.mas_equalTo(CONTAINER_HOR_MARGIN); \
                    make.right.mas_equalTo(-CONTAINER_HOR_MARGIN);
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        MAKE_HOR();
        make.top.mas_equalTo(ITEM_VER_MARGIN);
        make.height.mas_equalTo(16);
    }];
    
    [self.questionView mas_makeConstraints:^(MASConstraintMaker *make) {
        MAKE_HOR();
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(ITEM_VER_MARGIN);
        make.height.mas_equalTo(QUESTION_VIEW_HEIGHT);
    }];
    
    [self.guessView mas_makeConstraints:^(MASConstraintMaker *make) {
        MAKE_HOR();
        make.top.mas_equalTo(self.questionView.mas_bottom).offset(ITEM_VER_MARGIN);
        make.height.mas_equalTo(0);
    }];
    
    [self.mobileView mas_makeConstraints:^(MASConstraintMaker *make) {
        MAKE_HOR();
        make.top.mas_equalTo(self.guessView.mas_bottom).offset(30);
        make.height.mas_equalTo(88);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        MAKE_HOR();
        make.top.mas_equalTo(self.mobileView.mas_bottom).offset(ITEM_VER_MARGIN);
        make.height.mas_equalTo(SUBMIT_HEIGHT);
    }];
    
    [self.aboutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.aboutLabel.superview);
        make.width.mas_equalTo(self.aboutLabel.bounds.size.width);
        make.top.mas_equalTo(self.submitButton.mas_bottom).offset(3);
        make.height.mas_equalTo(16);
    }];
    
}

-(void)tryUpdateContentSize
{    
    CGRect frame = self.containerView.frame;
    frame.origin.y = CONTAINTER_TOP;
    if (CGRectGetMaxY(frame) > self.scrollView.frame.size.height) {
        CGSize size = self.scrollView.contentSize;
        size = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(frame));
        self.scrollView.contentSize = size;
        self.bgView.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

-(void)onSubmitAction:(id)sender
{
    [self.view endEditing:YES];
    [_viewModel submitQuestation];
}

-(void)onTapBgAction:(id)sender
{
    [self.bgView endEditing:YES];
}

- (void)tipBtnDidClick
{
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)trackEndedByAppWillEnterBackground
{
    [self.viewModel endTrack];
    [self.viewModel addStayPageLog];
    [self.viewModel resetStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    [self.viewModel resetStayTime];
    [self.viewModel startTrack];
}

-(void)scrollToFitShowKeyboard
{
    
}
-(void)scrollToFitHideKeyboard
{
    CGRect frame = self.bgView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.frame = frame;
    }];
}

#pragma mark - keyboard
-(void)keyboardWillShowNotifiation:(NSNotification *)notification
{
    if (![self.mobileView.phoneTextField isFirstResponder]) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardScreenFrame = [self.view convertRect:keyboardScreenFrame toView:self.bgView];
    if (CGRectGetHeight(keyboardScreenFrame) == 0) {
        //sougou 
        return;
    }
    
    CGRect submitFrame = [self.containerView convertRect:self.submitButton.frame toView:self.bgView];
    submitFrame.origin.y += self.scrollView.frame.origin.y;
    
//    NSLog(@"keyboard info is: %@ convert frame is: %@  submit frame is: %@",userInfo,NSStringFromCGRect(keyboardScreenFrame),NSStringFromCGRect(submitFrame));
//    NSLog(@"bgview is: %@",self.bgView);
//
    CGFloat delta = CGRectGetMaxY(submitFrame) - CGRectGetMinY(keyboardScreenFrame);
    if (delta < 0) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.bgView.frame;
    
    
    frame.origin.y = -(delta);
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.bgView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)keyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardScreenFrame = [self.view convertRect:keyboardScreenFrame fromView:self.containerView];
    
    if (self.bgView.frame.origin.y >= 0 ) {//[self.viewController scrollToFitHideKeyboard];
        return;
    }
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.bgView.frame;
    
    frame.origin = CGPointZero;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.bgView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
