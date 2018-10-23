//
//  ArticleForwardViewController.m
//  Article
//
//  Created by SunJiangting on 15-1-18.
//
//

#import "ArticleForwardViewController.h"
#import "SSNavigationBar.h"
#import "SSThemed.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "ArticleForwardManager.h"
#import "MBProgressHUD.h"
#import "SSUserModel.h"
#import "ArticleMomentGroupModel.h"
#import "ArticleListNotifyBarView.h"
#import "NetworkUtilities.h"
#import "TTThemeManager.h"
#import "UIColor+TTThemeExtension.h"
#import "UITextView+TTAdditions.h"

#define kMinimumTextViewHeight 100

@interface ArticleForwardViewController ()

@property (nonatomic, strong) SSNavigationBar    *navigationBar;

@property (nonatomic, strong) SSThemedScrollView       *containerView;
@property (nonatomic, strong) SSThemedTextView         *textView;
@property (nonatomic, strong) SSThemedView             *quoteView;

@property (nonatomic, strong) ExploreAvatarView        *avatarView;
@property (nonatomic, strong) SSThemedLabel            *nameLabel;
@property (nonatomic, strong) SSThemedLabel            *descriptionLabel;

@property(nonatomic, retain)ArticleListNotifyBarView   *notifyBarView;    //提示条
@property(nonatomic, copy) NSString                    *umengEventString;

@end

@implementation ArticleForwardViewController

- (void)dealloc {
    [self.textView removeObserver:self forKeyPath:@"contentSize" context:NULL];
    [self.containerView removeObserver:self forKeyPath:@"frame" context:NULL];
}

- (instancetype)initWithMomentModel:(ArticleMomentModel *)momentModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _momentModel = momentModel;
        self.sourceType = ArticleForwardSourceTypeOther;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithMomentModel:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationBar = [[SSNavigationBar alloc] initWithFrame:self.navigationBarFrame];
//    self.navigationBar.title = NSLocalizedString(@"转发", nil);
//    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:self.navigationBar];

    //    self.navigationBar.leftBarView = [SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:@"取消" target:self action:@selector(_dismissActionFired:)];
    //    self.navigationBar.rightBarView = [SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"发送" target:self action:@selector(_sendActionFired:)];

    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"转发", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:@"取消" target:self action:@selector(_dismissActionFired:)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"发送" target:self action:@selector(_sendActionFired:)]];
    
    
    self.containerView = [[SSThemedScrollView alloc] initWithFrame:CGRectZero];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.containerView.panGestureRecognizer addTarget:self action:@selector(_dismissKeyboard)];
    self.containerView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:self.containerView];
    
    [self.containerView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    self.containerView.frame = self.containerViewFrame;
    self.containerView.alwaysBounceVertical = YES;
    
    self.textView = [[SSThemedTextView alloc] initWithFrame:CGRectMake(15, 10, self.view.width - 30, kMinimumTextViewHeight)];
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.font = [UIFont systemFontOfSize:16.];
    self.textView.directionalLockEnabled = YES;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.scrollsToTop = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    
    [self.textView.panGestureRecognizer addTarget:self action:@selector(_dismissKeyboard)];
    self.textView.textColorThemeKey = kColorText1;
    self.textView.placeholderColorThemeKey = kColorText3;
    self.textView.placeHolder = @"说点什么吧";
    [self.containerView addSubview:self.textView];
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    accessoryView.backgroundColor = [UIColor clearColor];
    self.textView.inputAccessoryView = accessoryView;

    self.quoteView = [[SSThemedView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.textView.frame) + 15, CGRectGetWidth(self.view.bounds) - 30, 72)];
    self.quoteView.backgroundColorThemeKey = kColorBackground3;
    [self.containerView addSubview:self.quoteView];
    /// 下面引用的那部分
    {
        self.avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(6, 6, 60, 60)];
        self.avatarView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;;
        self.avatarView.backgroundColor = [UIColor grayColor];
        self.avatarView.verifyView.hidden = YES;
        [self.quoteView addSubview:self.avatarView];
        
        self.nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(72, 6, self.quoteView.width - 78, 20)];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.textColorThemeKey = kColorText1;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.quoteView addSubview:self.nameLabel];
        
        self.descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(self.nameLabel.left, self.nameLabel.bottom + 4, self.nameLabel.width, self.quoteView.height - 10 - self.nameLabel.bottom)];
        self.descriptionLabel.verticalAlignment = ArticleVerticalAlignmentTop;
        self.descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.descriptionLabel.font = [UIFont systemFontOfSize:14.];
        self.descriptionLabel.textColorThemeKey = kColorText2;
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        [self.quoteView addSubview:self.descriptionLabel];
    }
    
    [self _relayLayoutSubviews];
    [self _refreshQuoteUserInformation];
    [self.textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [self.textView becomeFirstResponder]; //PM 需求
    
    
    self.notifyBarView = [[ArticleListNotifyBarView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), self.view.width, [SSCommonLogic articleNotifyBarHeight])];
    [self.view addSubview:_notifyBarView];
    
    wrapperTrackEvent(self.umengEventString, @"enter");
}

- (void)setSourceType:(ArticleForwardSourceType)sourceType {
    switch (sourceType) {
        case ArticleForwardSourceTypeMoment:
            self.umengEventString = @"repost_update";
            break;
        case ArticleForwardSourceTypeProfile:
            self.umengEventString = @"repost_profile";
            break;
        case  ArticleForwardSourceTypeTopic:
            self.umengEventString = @"repost_topic";
            break;
        case ArticleForwardSourceTypeNotify:
            self.umengEventString = @"repost_notify";
            break;
        default:
            self.umengEventString = @"repost_other";
            break;
    }
    _sourceType = sourceType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.containerView) {
        CGSize size = self.containerView.frame.size;
        //始终保证containerView能滚动
        size.height += 1;
        self.containerView.contentSize = size;
    } else {
        [self _relayLayoutSubviews];
    }
}

- (CGRect)navigationBarFrame {
    return CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), [SSNavigationBar navigationBarHeight]);
}

- (CGRect)containerViewFrame {
    return CGRectMake(0, CGRectGetMaxY(self.navigationBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.navigationBar.frame));;
}

- (void)_relayLayoutSubviews {
    CGFloat height = self.textView.contentSize.height;
    CGRect frame = self.textView.frame;
    height = MAX(height, kMinimumTextViewHeight);
    UIView *keyboardView = self.textView.inputAccessoryView.superview;
    if (keyboardView) {
        CGFloat maxContentHeight = keyboardView.frame.origin.y - CGRectGetMaxY(self.navigationBar.frame) - 15;
        height = MIN(maxContentHeight, height);
    }
    frame.size.height = height;
    self.textView.frame = frame;
    
    self.quoteView.frame = CGRectMake(15, CGRectGetMaxY(self.textView.frame) + 15, CGRectGetWidth(self.view.bounds) - 30, 72);
}

- (void)_dismissActionFired:(id)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    wrapperTrackEvent(self.umengEventString, @"cancel");
    [[ArticleForwardManager sharedManager] cancel];
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (void)_sendActionFired:(id)sender {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    NSString *label = self.textView.text.length > 0 ? @"repost":@"repost_none";
    wrapperTrackEvent(self.umengEventString, label);
    if (!TTNetworkConnected()) {
        [self showNotifyBarMsg:NSLocalizedString(@"网络不给力，请稍后重试", nil)];
        return;
    }
    __weak ArticleForwardViewController *weakSelf = self;
    // 直接添加到新的window上
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.containerView.userInteractionEnabled = NO;
    UIButton *navigationBarButton = (UIButton *)self.navigationBar.rightBarView;
    navigationBarButton.enabled = NO;
    [[ArticleForwardManager sharedManager] forwardMoment:self.momentModel withText:self.textView.text completionHandler:^(NSError *error) {
        weakSelf.containerView.userInteractionEnabled = YES;
        navigationBarButton.enabled = YES;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            HUD.detailsLabelColor = [UIColor tt_themedColorForKey:kColorBackground6];
        } else {
            HUD.detailsLabelColor = [UIColor tt_themedColorForKey:kColorBackground4];
        }
        HUD.mode = MBProgressHUDModeText;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:15.];
        HUD.minSize = CGSizeMake(0, 80);
        if (error) {
            NSString *display = [error.userInfo valueForKey:@"message"];
            if (isEmptyString(display)) {
                display = NSLocalizedString(@"网络不给力，请稍后重试", nil);
            }
            HUD.detailsLabelText = display;
            [HUD hide:YES afterDelay:0.5];
        } else {
            HUD.mode = MBProgressHUDModeText;
            HUD.labelText = NSLocalizedString(@"已转发到我的动态", nil);
            [HUD hide:YES afterDelay:0.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakSelf.navigationController) {
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:NULL];
                } else {
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                }
                
            });
        }

    }];
}

- (void)_dismissKeyboard {
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
}

- (void)_refreshQuoteUserInformation {
    
    BOOL hasOriginItem = [_momentModel.originItem.user.ID longLongValue] != 0;
    
    NSString * nameLabel = _momentModel.user.name;
    if (hasOriginItem) {
        nameLabel = _momentModel.originItem.user.name;
    }
    self.nameLabel.text = nameLabel;
    
    
    NSString * text = nil;
    if (hasOriginItem) {
        text = _momentModel.originItem.content;
        if (isEmptyString(text)) {
            text = _momentModel.originItem.group.title;
        }
    }
    else {
        text = _momentModel.content;
        if (isEmptyString(text)) {
            text = _momentModel.group.title;
        }
    }
    self.descriptionLabel.text = text;
    
    NSString * imgURLStr = nil;
    
    if (hasOriginItem) {
        imgURLStr = _momentModel.originItem.user.avatarURLString;
        if ([_momentModel.originItem.largeImageList count] > 0) {
            TTImageInfosModel * model = [_momentModel.originItem.largeImageList firstObject];
            imgURLStr = [model urlStringAtIndex:0];
        }
    }
    else {
        imgURLStr = _momentModel.user.avatarURLString;
        if ([_momentModel.largeImageList count] > 0) {
            TTImageInfosModel * model = [_momentModel.largeImageList firstObject];
            imgURLStr = [model urlStringAtIndex:0];
        }
    }
    [self.avatarView setImageWithURLString:imgURLStr];
    
    if (hasOriginItem) {
        if (!isEmptyString(_momentModel.user.name) && !isEmptyString(_momentModel.content)) {
            self.textView.text = [NSString stringWithFormat:@"//@%@: %@", _momentModel.user.name, _momentModel.content];
            [self.textView showOrHidePlaceHolderTextView];
            NSRange range;
            range.location = 0;
            range.length = 0;
            _textView.selectedRange = range;
        }
    }
}

- (void)setMomentModel:(ArticleMomentModel *)momentModel {
    _momentModel = momentModel;
    if (self.isViewLoaded) {
        [self _refreshQuoteUserInformation];
    }
}


- (void) showNotifyBarMsg:(NSString *)msg  {
    if (!isEmptyString(msg)) {
        [_notifyBarView showMessage:msg actionButtonTitle:nil delayHide:YES duration:3 bgButtonClickAction:NULL actionButtonClickBlock:NULL didHideBlock:NULL];
    }
}


@end
