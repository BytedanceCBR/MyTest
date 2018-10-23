//
//  TTUGCSinaWeiboShareInputViewController.m
//  Article
//
//  Created by 王霖 on 17/2/28.
//
//

#import "TTUGCSinaWeiboShareInputViewController.h"
#import <TTAlphaThemedButton.h>
#import <NetworkUtilities.h>
#import <TTIndicatorView.h>
#import <TTThemedAlertController.h>

#import <TTNetworkManager.h>
#import <TTAccountBusiness.h>
#import <TTThemed/TTThemeManager.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import "FRApiModel.h"

static const NSInteger kMaxInputTextLength = 2000;

@interface TTUGCSinaWeiboShareInputViewController () <UITextViewDelegate>

@property (nonatomic, copy) NSString * uniqueID;
@property (nonatomic, copy) NSString * shareText;
@property (nonatomic, assign) TTUGCShareSourceType shareSourceType;
@property (nonatomic, copy) void(^completion)(NSError *);

@property (nonatomic, strong) SSThemedImageView * bgImageView;
@property (nonatomic, strong) SSThemedTextView * inputTextView;
@property (nonatomic, strong) SSThemedLabel * countLabel;

@end

@implementation TTUGCSinaWeiboShareInputViewController

#pragma mark - Life cycle

- (instancetype)initWithUniqueID:(NSString *)uniqueID
                       shareText:(nullable NSString *)shareText
                 shareSourceType:(TTUGCShareSourceType)shareSourceType
                      completion:(void(^ _Nullable)( NSError * _Nullable error))completion {
    self = [super initWithRouteParamObj:nil];
    if (self) {
        _uniqueID = uniqueID.copy;
        _shareText = shareText.copy;
        _shareSourceType = shareSourceType;
        _completion = [completion copy];
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [self initWithUniqueID:@"" shareText:nil shareSourceType:TTUGCShareSourceTypeConcern completion:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SSThemedLabel * titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.verticalAlignment = ArticleVerticalAlignmentMiddle;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.font = [UIFont systemFontOfSize:17.];
    titleLabel.text = NSLocalizedString(@"分享到新浪微博", nil);
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    TTAlphaThemedButton * cancelButton = [[TTAlphaThemedButton alloc] init];
    cancelButton.titleColorThemeKey = kColorText1;
    [cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton sizeToFit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    TTAlphaThemedButton * sendButton = [[TTAlphaThemedButton alloc] init];
    sendButton.titleColorThemeKey = kColorText1;
    [sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.bgImageView = [[SSThemedImageView alloc] initWithFrame:[self frameForBgImageView]];
    self.bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.bgImageView.image = [[UIImage themedImageNamed:@"inputbox_repost"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self.view addSubview:self.bgImageView];
    
    self.inputTextView = [[SSThemedTextView alloc] initWithFrame:[self frameForInputTextView]];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.inputTextView.backgroundColor = [UIColor clearColor];
    self.inputTextView.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"b1b1b1"]];
    self.inputTextView.font = [UIFont systemFontOfSize:15.f];
    self.inputTextView.scrollsToTop = NO;
    self.inputTextView.delegate = self;
    self.inputTextView.text = self.shareText;
    [self.view addSubview:self.inputTextView];
    
    self.countLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.inputTextView.right - 60.f, self.bgImageView.bottom - 20.f - 2.f, 60.f, 20.f)];
    self.countLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    self.countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.font = [UIFont systemFontOfSize:14.f];
    self.countLabel.text = [NSString stringWithFormat:@" %@ ", @(kMaxInputTextLength)];
    [self refreshCountLabel];
    [self.view addSubview:self.countLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.inputTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGRect)frameForInputTextView {
    CGRect rect = CGRectInset(self.view.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);
    CGFloat height = [TTDeviceHelper is568Screen] ? 172 : 84;
    if ([TTDeviceHelper is568Screen]) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            height = 44.f;
        }else {
            height = 172.f;
        }
    }else {
        height = 84.f;
    }
    rect = CGRectMake(8.f, 64.f + 8.f, CGRectGetWidth(rect) - 16.f, height);
    return rect;
}

- (CGRect)frameForBgImageView {
    CGRect rect = [self frameForInputTextView];
    rect.size.height += 22.f;
    return rect;
}

- (void)refreshCountLabel {
    NSString * content = _inputTextView.text;
    NSInteger count = kMaxInputTextLength - content.length;
    if (count < -9999) {
        count = -9999;
    }
    self.countLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    if (count > 0) {
        self.countLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    }else {
        self.countLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"a40000" nightColorName:@"505050"]];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.bgImageView.image = [[UIImage themedImageNamed:@"inputbox_repost"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    self.inputTextView.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"b1b1b1"]];
    [self refreshCountLabel];
}

#pragma mark - Actions

- (void)cancel:(id)sender {
    [self dismissSelf];
}

- (void)send:(id)sender {
    if (!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接，请稍后再试", nil)
                                 indicatorImage:[UIImage tt_themedImageForKey:@"close_popup_textpage"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    
    if (self.inputTextView.text.length > kMaxInputTextLength) {
        TTThemedAlertController * alert = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"发送内容不可以超过%@个字", nil),@(kMaxInputTextLength)]
                                                                                 message:nil
                                                                           preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil)
                       actionType:TTThemedAlertActionTypeNormal
                      actionBlock:nil];
        [alert showFrom:[TTUIResponderHelper topmostViewController]
               animated:YES];
        return;
    }
    
    FRTtdiscussV1ShareRequestModel *request = [[FRTtdiscussV1ShareRequestModel alloc] init];
    request.forward_to = PLATFORM_SINA_WEIBO;
    request.forward_id = self.uniqueID;
    request.forward_content = self.inputTextView.text;
    switch (self.shareSourceType) {
        case TTUGCShareSourceTypeConcern:
        case TTUGCShareSourceTypeForum:
            request.forward_type = @"forum";
            break;
        case TTUGCShareSourceTypeThread:
            request.forward_type = @"thread";
            break;
        default:
            break;
    }
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (wself.completion) {
            wself.completion(error);
        }
        if (!error) {
            [self dismissSelf];
        }
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self refreshCountLabel];
}

@end
