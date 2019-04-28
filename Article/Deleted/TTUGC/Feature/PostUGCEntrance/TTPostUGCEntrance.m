//
//  TTPostUGCEntrance.m
//  Article
//
//  Created by 王霖 on 16/10/21.
//
//

#import "TTPostUGCEntrance.h"
#import "TTNavigationController.h"
#import "TTRecordImportVideoContainerViewController.h"

#import "TTUGCPermissionService.h"
#import "TTCategoryDefine.h"
#import "TTPostThreadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PGCAccountManager.h"
#import <TTAccountBusiness.h>
#import "TTArticleCategoryManager.h"
#import "TTCustomAnimationNavigationController.h"
#import "TTForumPostThreadCenter.h"

#import "TTImagePicker.h"
#import "TTImagePickerTrackDelegate.h"
#import "JSONAdditions.h"
#import "TTForumPostThreadToPageViewModel.h"
#import "TTArticleTabBarController.h"
#import "TTVideoCategoryManager.h"
#import "UIView+CustomTimingFunction.h"
#import "TTPostUGCEntranceIconDownloadManager.h"
#import "TSVCategoryManager.h"
#import "TTRedpackIntroRotationView.h"
#import "TTTabBarProvider.h"
//#import "TTSFTracker.h"
//todo delete
#import "TTForumPostThreadTask.h"
//#import "TTXiguaLiveManager.h"
#import "TSVPublishShortVideoHelper.h"
#import "PopoverAction.h"

static CGFloat const kAnimateDuration = 0.5;
static CGFloat kEntrancePanelHeight = 195.f;

@interface TTPostUGCEntrance ()<TTImagePickerControllerDelegate>
@property (nonatomic, copy) NSDictionary *tapActionParams;//点击参数
@property (nonatomic, strong) UIWindow * containerWindow;
@property (nonatomic, strong) SSThemedView * maskView;
@property (nonatomic, strong) UIVisualEffectView * blurView;

@property (nonatomic, assign) BOOL isShowWendaEntrance;

@property (nonatomic, strong) SSThemedButton * pureTextEntranceButton;
@property (nonatomic, strong) SSThemedLabel * pureTextTitle;

@property (nonatomic, strong) SSThemedButton * imageEntranceButton;
@property (nonatomic, strong) SSThemedLabel * imageTitle;

@property (nonatomic, strong) SSThemedButton * videoEntranceButton;
@property (nonatomic, strong) SSThemedLabel * videoTitle;

@property (nonatomic, strong) SSThemedButton * xiguaLiveEntranceButton;
@property (nonatomic, strong) SSThemedLabel * xiguaLiveTitle;

@property (nonatomic, strong) SSThemedButton * shortVideoEntranceButton;
@property (nonatomic, strong) TTRedpackIntroRotationView *redPachIntroView;
@property (nonatomic, strong) SSThemedView * shortVideoReddotView;
@property (nonatomic, strong) SSThemedLabel *shortVideoTitle;

@property (nonatomic, strong) SSThemedButton *imageAndTextEntranceButton;
@property (nonatomic, strong) SSThemedLabel *imageAndTextTitle;

@property (nonatomic, strong) SSThemedButton *wendaEntranceButton;
@property (nonatomic, strong) SSThemedLabel *wendaTitle;

@property (nonatomic, strong) SSThemedImageView * closeImageView;
@property (nonatomic, strong) SSThemedButton * closeButton;

@property (nonatomic, strong) NSMutableArray<SSThemedButton *> *currentButtons;
@property (nonatomic, strong) NSMutableArray<SSThemedLabel *> *currentLabels;

@property (nonatomic, strong) ALAssetsLibrary * library;

@property (nonatomic, strong) UITapGestureRecognizer * tap;
@property (nonatomic, strong) UITapGestureRecognizer * cTap;

@property (nonatomic,strong)TTImagePickerTrackDelegate *trackDelegate;

@property (nonatomic, copy) NSString *enterConcernID; //来自的关心主页Id
@property (nonatomic, copy) NSString *entrance; //main、concern、others
@end

static BOOL isShowing;

@implementation TTPostUGCEntrance

+ (void)showMainPostUGCEntrance {
    TTPostUGCEntrance * postUGCEntrance = [[TTPostUGCEntrance alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kEntrancePanelHeight)
                                                                            models:[GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) publishTypeModels]
                                                                   tapActionParams:nil];
    postUGCEntrance.entrance = @"main";
    [postUGCEntrance show];
}

+ (void)showPostUGCEntrance {
    TTPostUGCEntrance * postUGCEntrance = [[TTPostUGCEntrance alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kEntrancePanelHeight)
                                                                            models:nil
                                                                   tapActionParams:nil];
    [postUGCEntrance show];
}

+ (void)showConcernPagePostUGCEntranceWithModels:(NSArray <FRPublishConfigStructModel *> *)models tapActionParams:(NSDictionary *)tapActionParams {
    TTPostUGCEntrance * postUGCEntrance = [[TTPostUGCEntrance alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, kEntrancePanelHeight)
                                                                            models:models
                                                                   tapActionParams:tapActionParams];
    postUGCEntrance.entrance = @"concern";
    postUGCEntrance.enterConcernID = [tapActionParams tt_stringValueForKey:@"cid"];
    [postUGCEntrance show];
}

- (instancetype)initWithFrame:(CGRect)frame models:(NSArray <FRPublishConfigStructModel *> *)models tapActionParams:(NSDictionary *)tapActionParams {
    self = [super initWithFrame:frame];
    if (self) {
        self.entrance = @"others";
        self.isShowWendaEntrance = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) isShowWendaPulishEntrance];
        self.tapActionParams = tapActionParams;
        [self createPostUGCEntranceComponent:models];
        [self registerNotifications];
    }
    return self;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPackIntroUpdated) name:kTTNotificationNameRedpackIntroUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(normalIntroUpdated) name:kTTNotificationNameNormalIntroUpdated object:nil];
}

- (void)redPackIntroUpdated {
    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
        if (!self.redPachIntroView) {
            self.redPachIntroView = [[TTRedpackIntroRotationView alloc] initWithFrame:self.shortVideoEntranceButton.bounds];
        }
        [self.shortVideoEntranceButton addSubview:self.redPachIntroView];
        [self.redPachIntroView startAnimation];
    }
    else {
        [self.redPachIntroView stopAnimation];
        [self.redPachIntroView removeFromSuperview];
    }
}

- (void)normalIntroUpdated {
    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
        //Do nothing
    }
    else {
        if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoMainNormalIntro]) {
            if (!self.shortVideoReddotView) {
                self.shortVideoReddotView = [[SSThemedView alloc] init];
                self.shortVideoReddotView.backgroundColor = [UIColor colorWithHexString:@"#f85959"];
                self.shortVideoReddotView.layer.cornerRadius = 4.0f;
                self.shortVideoReddotView.layer.masksToBounds = YES;
            }
            self.shortVideoReddotView.frame = CGRectMake(44.0f, 9.0f, 8.0f, 8.0f);
            [self.shortVideoEntranceButton addSubview:self.shortVideoReddotView];
        }
        else {
            [self.shortVideoReddotView removeFromSuperview];
        }
    }
}

- (ALAssetsLibrary *)library {
    if (_library == nil) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return _library;
}

- (void)createPostUGCEntranceComponent:(NSArray <FRPublishConfigStructModel *> *)models {
    self.containerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.containerWindow.hidden = YES;
    
    self.maskView = [[SSThemedView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0;
    self.backgroundColors = @[@"cacaca",@"707070"];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tap.numberOfTapsRequired = 1;
    self.tap.numberOfTouchesRequired = 1;
    [self.maskView addGestureRecognizer:self.tap];
    [self.containerWindow addSubview:self.maskView];
    
    [self.containerWindow addSubview:self];

    // 只有 addSubview 之后，safeAreInsets 值会更新
    kEntrancePanelHeight = 195.f + self.tt_safeAreaInsets.bottom;
    self.height = kEntrancePanelHeight;

    self.cTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.cTap.numberOfTapsRequired = 1;
    self.cTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:self.cTap];
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0) {
        self.backgroundColors = @[@"cacaca",@"707070"];
    }else {
        @try {
            UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            }
            self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            self.blurView.frame = self.bounds;
            self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:self.blurView];
        } @catch (NSException *exception) {
            if (self.blurView) {
                [self.blurView removeFromSuperview];
                self.blurView = nil;
            }
            self.backgroundColors = @[@"cacaca",@"707070"];
        }
    }
    
    CGFloat innerPadding = 0;
    CGFloat itemWidth = 0;
    CGSize itemSize =  CGSizeMake(60, 60);
    
    NSInteger itemNum = [models count];
    if (itemNum == 0) {
        if (self.isShowWendaEntrance) {
            itemNum = 4; //文字 图片 视频 问答
        }
        else {
            itemNum = 3; //文字 图片 视频
        }
    }
    
    innerPadding = (CGFloat)(self.width - itemSize.width * itemNum)/(itemNum + 1);
    itemWidth = (CGFloat)(self.width - innerPadding)/(itemNum);
    
    [self.currentButtons removeAllObjects];
    [self.currentLabels removeAllObjects];
    if (models) {
        for (NSUInteger index = 0; index < models.count; ++index) {
            [self layoutButtonsAsParamLogicSize:itemSize width:itemWidth index:index total:models.count model:models[index]];
        }
        
        [self layoutCloseComponents:kEntrancePanelHeight - 62.f];
    } else {
        //默认布局逻辑，只有当下发失败且userDefaults中存有旧下发时走这个
        [self layoutButtonsAsDefaultLogicSize:itemSize width:itemWidth];
    }
   
}

- (void)layoutButtonsAsParamLogicSize:(CGSize)itemSize width:(CGFloat)itemWidth index:(NSInteger)index total:(NSInteger)total model:(FRPublishConfigStructModel *)model {
    CGFloat offset = (CGRectGetWidth([UIScreen mainScreen].bounds) - itemWidth * total) / (total + 1);
    CGFloat originx = (index + 1) * offset + index * itemWidth + itemWidth / 2;
    UIImage *remoteIconImage = [[TTPostUGCEntranceIconDownloadManager sharedManager] getEntranceIconForType:model.type.integerValue withURL:model.icon];
    SSThemedButton *currentButton = nil;
    SSThemedLabel *currentLabel = nil;
    switch (model.type.integerValue) {
        case TTPostUGCEntranceButtonTypeWenda:
            self.wendaEntranceButton.tag = TTPostUGCEntranceButtonTypeWenda;
            self.wendaEntranceButton.size = itemSize;
            self.wendaEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.wendaEntranceButton;
            
            self.wendaTitle.text = model.name;
            [self.wendaTitle sizeToFit];
            self.wendaTitle.centerX = self.wendaEntranceButton.centerX;
            self.wendaTitle.top = self.wendaEntranceButton.bottom + 10.f;
            currentLabel = self.wendaTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.wendaEntranceButton];
                [self addSubview:self.wendaTitle];
            }else {
                [self.blurView.contentView addSubview:self.wendaEntranceButton];
                [self.blurView.contentView addSubview:self.wendaTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeImage:
            self.imageEntranceButton.tag = TTPostUGCEntranceButtonTypeImage;
            self.imageEntranceButton.size = itemSize;
            self.imageEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.imageEntranceButton;
            
            self.imageTitle.text = model.name;
            [self.imageTitle sizeToFit];
            self.imageTitle.centerX = self.imageEntranceButton.centerX;
            self.imageTitle.top = self.imageEntranceButton.bottom + 10.f;
            currentLabel = self.imageTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.imageEntranceButton];
                [self addSubview:self.imageTitle];
            }else {
                [self.blurView.contentView addSubview:self.imageEntranceButton];
                [self.blurView.contentView addSubview:self.imageTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeVideo:
            self.videoEntranceButton.tag = TTPostUGCEntranceButtonTypeVideo;
            self.videoEntranceButton.size = itemSize;
            self.videoEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.videoEntranceButton;
            
            [self.videoEntranceButton addTarget:self
                                         action:@selector(tapEntrance:)
                               forControlEvents:UIControlEventTouchUpInside];
            
            self.videoTitle.text = model.name;
            [self.videoTitle sizeToFit];
            self.videoTitle.centerX = self.videoEntranceButton.centerX;
            self.videoTitle.top = self.videoEntranceButton.bottom + 10.f;
            currentLabel = self.videoTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.videoEntranceButton];
                [self addSubview:self.videoTitle];
            }else {
                [self.blurView.contentView addSubview:self.videoEntranceButton];
                [self.blurView.contentView addSubview:self.videoTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeText:
            self.pureTextEntranceButton.tag = TTPostUGCEntranceButtonTypeText;
            self.pureTextEntranceButton.size = itemSize;
            self.pureTextEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.pureTextEntranceButton;
            
            self.pureTextTitle.text = model.name;
            [self.pureTextTitle sizeToFit];
            self.pureTextTitle.centerX = self.pureTextEntranceButton.centerX;
            self.pureTextTitle.top = self.pureTextEntranceButton.bottom + 10.f;
            currentLabel = self.pureTextTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.pureTextEntranceButton];
                [self addSubview:self.pureTextTitle];
            }else {
                [self.blurView.contentView addSubview:self.pureTextEntranceButton];
                [self.blurView.contentView addSubview:self.pureTextTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeShortVideo:
            self.shortVideoEntranceButton.tag = TTPostUGCEntranceButtonTypeShortVideo;
            self.shortVideoEntranceButton.size = itemSize;
            self.shortVideoEntranceButton.center = CGPointMake(originx, 65);
            [self redPackIntroUpdated];
            [self normalIntroUpdated];
            
            currentButton = self.shortVideoEntranceButton;
            
            self.shortVideoTitle.text = model.name;
            [self.shortVideoTitle sizeToFit];
            self.shortVideoTitle.centerX = self.shortVideoEntranceButton.centerX;
            self.shortVideoTitle.top = self.shortVideoEntranceButton.bottom + 10.f;
            currentLabel = self.shortVideoTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.shortVideoEntranceButton];
                [self addSubview:self.shortVideoTitle];
            }else {
                [self.blurView.contentView addSubview:self.shortVideoEntranceButton];
                [self.blurView.contentView addSubview:self.shortVideoTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeImageAndText:
            self.imageAndTextEntranceButton.tag = TTPostUGCEntranceButtonTypeImageAndText;
            self.imageAndTextEntranceButton.size = itemSize;
            self.imageAndTextEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.imageAndTextEntranceButton;
            
            self.imageAndTextTitle.text = model.name;
            [self.imageAndTextTitle sizeToFit];
            self.imageAndTextTitle.centerX = self.imageAndTextEntranceButton.centerX;
            self.imageAndTextTitle.top = self.imageAndTextEntranceButton.bottom + 10.f;
            currentLabel = self.imageAndTextTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.imageAndTextEntranceButton];
                [self addSubview:self.imageAndTextTitle];
            }else {
                [self.blurView.contentView addSubview:self.imageAndTextEntranceButton];
                [self.blurView.contentView addSubview:self.imageAndTextTitle];
            }
            break;
        case TTPostUGCEntranceButtonTypeXiguaLive:
            self.xiguaLiveEntranceButton.tag = TTPostUGCEntranceButtonTypeXiguaLive;
            self.xiguaLiveEntranceButton.size = itemSize;
            self.xiguaLiveEntranceButton.center = CGPointMake(originx, 65);
            currentButton = self.xiguaLiveEntranceButton;
            
            self.xiguaLiveTitle.text = model.name;
            [self.xiguaLiveTitle sizeToFit];
            self.xiguaLiveTitle.centerX = self.xiguaLiveEntranceButton.centerX;
            self.xiguaLiveTitle.top = self.xiguaLiveEntranceButton.bottom + 10.f;
            currentLabel = self.xiguaLiveTitle;
            if ([TTDeviceHelper OSVersionNumber] < 8.0) {
                [self addSubview:self.xiguaLiveEntranceButton];
                [self addSubview:self.xiguaLiveTitle];
            }else {
                [self.blurView.contentView addSubview:self.xiguaLiveEntranceButton];
                [self.blurView.contentView addSubview:self.xiguaLiveTitle];
            }
            break;
    }
    if (remoteIconImage) {
        [currentButton setImage:remoteIconImage forState:UIControlStateNormal];
    }
    if (currentButton && currentLabel) {
        [self.currentButtons addObject:currentButton];
        [self.currentLabels addObject:currentLabel];
    }
}


/**
 默认布局逻辑，只有当下发失败且userDefaults中存有旧下发时走这个
 */
- (void)layoutButtonsAsDefaultLogicSize:(CGSize)itemSize width:(CGFloat)itemWidth {
    // Pure text
    self.pureTextEntranceButton.tag = TTPostUGCEntranceButtonTypeText;
    self.pureTextEntranceButton.size = itemSize;
    if (self.isShowWendaEntrance) {
        self.pureTextEntranceButton.center = CGPointMake(self.width/2.f - 3 * itemWidth/2.f, kEntrancePanelHeight - 45/2);
    }
    else {
        self.pureTextEntranceButton.center = CGPointMake(self.width/2.f - itemWidth, kEntrancePanelHeight - 45/2);
    }
    
    self.pureTextTitle.text = NSLocalizedString(@"文字", nil);
    [self.pureTextTitle sizeToFit];
    self.pureTextTitle.centerX = self.pureTextEntranceButton.centerX;
    self.pureTextTitle.top = self.pureTextEntranceButton.bottom + 8.f;
    [self.currentButtons addObject:self.pureTextEntranceButton];
    [self.currentLabels addObject:self.pureTextTitle];
    if (nil == self.blurView) {
        [self addSubview:self.pureTextEntranceButton];
        [self addSubview:self.pureTextTitle];
    }else {
        [self.blurView.contentView addSubview:self.pureTextEntranceButton];
        [self.blurView.contentView addSubview:self.pureTextTitle];
    }
    
    
    //Image
    self.imageEntranceButton.tag = TTPostUGCEntranceButtonTypeImage;
    self.imageEntranceButton.size = itemSize;
    if (self.isShowWendaEntrance) {
        self.imageEntranceButton.center = CGPointMake(self.width/2.f - itemWidth/2.f, kEntrancePanelHeight - 45/2);
    }
    else {
        self.imageEntranceButton.center = CGPointMake(self.width/2.f, kEntrancePanelHeight - 45/2);
    }
    
    self.imageTitle.text = NSLocalizedString(@"图片", nil);
    [self.imageTitle sizeToFit];
    self.imageTitle.centerX = self.imageEntranceButton.centerX;
    self.imageTitle.top = self.imageEntranceButton.bottom + 8.f;
    [self.currentButtons addObject:self.imageEntranceButton];
    [self.currentLabels addObject:self.imageTitle];
    if (nil == self.blurView) {
        [self addSubview:self.imageEntranceButton];
        [self addSubview:self.imageTitle];
    }else {
        [self.blurView.contentView addSubview:self.imageEntranceButton];
        [self.blurView.contentView addSubview:self.imageTitle];
    }
    
    //Video
    self.videoEntranceButton.tag = TTPostUGCEntranceButtonTypeVideo;
    self.videoEntranceButton.size = itemSize;
    if (self.isShowWendaEntrance) {
        self.videoEntranceButton.center = CGPointMake(self.width/2.f + itemWidth/2.f, kEntrancePanelHeight - 45/2);
    }
    else {
        self.videoEntranceButton.center = CGPointMake(self.width/2.f + itemWidth, kEntrancePanelHeight - 45/2);
    }
    
    [self.videoEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    self.videoTitle.text = NSLocalizedString(@"视频", nil);
    [self.videoTitle sizeToFit];
    self.videoTitle.centerX = self.videoEntranceButton.centerX;
    self.videoTitle.top = self.videoEntranceButton.bottom + 8.f;
    [self.currentButtons addObject:self.videoEntranceButton];
    [self.currentLabels addObject:self.videoTitle];
    if (nil == self.blurView) {
        [self addSubview:self.videoEntranceButton];
        [self addSubview:self.videoTitle];
    }else {
        [self.blurView.contentView addSubview:self.videoEntranceButton];
        [self.blurView.contentView addSubview:self.videoTitle];
    }
    
    if (self.isShowWendaEntrance) {
        self.wendaEntranceButton.tag = TTPostUGCEntranceButtonTypeWenda;
        self.wendaEntranceButton.size = itemSize;
        self.wendaEntranceButton.center = CGPointMake(self.width/2.f + 3 * itemWidth/2.f, kEntrancePanelHeight - 45/2);
        
        self.wendaTitle.text = NSLocalizedString(@"提问", nil);
        [self.wendaTitle sizeToFit];
        self.wendaTitle.centerX = self.wendaEntranceButton.centerX;
        self.wendaTitle.top = self.wendaEntranceButton.bottom + 8.f;
        [self.currentButtons addObject:self.wendaEntranceButton];
        [self.currentLabels addObject:self.wendaTitle];
        if (nil == self.blurView) {
            [self addSubview:self.wendaEntranceButton];
            [self addSubview:self.wendaTitle];
        }else {
            [self.blurView.contentView addSubview:self.wendaEntranceButton];
            [self.blurView.contentView addSubview:self.wendaTitle];
        }
    }
    else {
        self.wendaEntranceButton = nil;
        self.wendaTitle = nil;
    }
    
    [self layoutCloseComponents:kEntrancePanelHeight - 54.f];
}

 
- (void)layoutCloseComponents:(CGFloat)originY {
    
    self.closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, kEntrancePanelHeight - 54.f - self.tt_safeAreaInsets.bottom, self.width, 54.f)];
    [self.closeButton addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    if (nil == self.blurView) {
        [self addSubview:self.closeButton];
    }else {
        [self.blurView.contentView addSubview:self.closeButton];
    }
    
    self.closeImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(self.closeButton.width/2 - 22.f, self.closeButton.height/2 - 22.f, 44.f, 44.f)];
    self.closeImageView.imageName = @"feed_publish_close";
    [self.closeButton addSubview:self.closeImageView];
    
    //Theme
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.pureTextEntranceButton.alpha = 1;
        self.imageEntranceButton.alpha = 1;
        self.videoEntranceButton.alpha = 1;
        if (self.wendaEntranceButton) {
            self.wendaEntranceButton.alpha = 1;
        }
        if (self.xiguaLiveEntranceButton.superview) {
            self.xiguaLiveEntranceButton.alpha = 1;
        }
    }else {
        self.pureTextEntranceButton.alpha = 0.5;
        self.imageEntranceButton.alpha = 0.5;
        self.videoEntranceButton.alpha = 0.5;
        if (self.wendaEntranceButton) {
            self.wendaEntranceButton.alpha = 0.5;
        }
        if (self.xiguaLiveEntranceButton.superview) {
            self.xiguaLiveEntranceButton.alpha = 0.5;
        }

    }
    
    //Transform
    self.closeImageView.transform = CGAffineTransformMakeRotation(-M_PI_4/2);
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if (self.blurView) {
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView.effect = blurEffect;
    }
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.pureTextEntranceButton.alpha = 1;
        self.imageEntranceButton.alpha = 1;
        self.videoEntranceButton.alpha = 1;
        self.shortVideoEntranceButton.alpha = 1;
        self.imageAndTextEntranceButton.alpha = 1;
        if (self.wendaEntranceButton) {
            self.wendaEntranceButton.alpha = 1;
        }
    }else {
        self.pureTextEntranceButton.alpha = 0.5;
        self.imageEntranceButton.alpha = 0.5;
        self.videoEntranceButton.alpha = 0.5;
        self.shortVideoEntranceButton.alpha = 0.5;
        self.imageAndTextEntranceButton.alpha = 0.5;
        if (self.wendaEntranceButton) {
            self.wendaEntranceButton.alpha = 0.5;
        }
    }
}

- (void)show {
    isShowing = YES;
    self.containerWindow.hidden = NO;
    
    CGFloat duration = 0.02;
    if (self.wendaEntranceButton && self.wendaTitle) {
        duration = 0.02;
    }
    
    [UIView animateWithDuration:kAnimateDuration/2.f customTimingFunction:CustomTimingFunctionCubicOut animation:^{
        self.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - kEntrancePanelHeight, CGRectGetWidth([UIScreen mainScreen].bounds), kEntrancePanelHeight);
        self.maskView.alpha = 0.3;
    }];
    [UIView animateWithDuration:kAnimateDuration/2
                          delay:kAnimateDuration/2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.closeImageView.transform = CGAffineTransformIdentity;
                     } completion:nil];
    
    CGFloat btnToValue = 65;
    CGFloat titleToValue = 112.25;
    
    CGFloat delay = 0.f;
    for (SSThemedLabel *label in self.currentLabels) {
        [self translateView:label toY:titleToValue delay:delay];
        delay += duration;
    }
    delay = 0.0f;
    for (SSThemedButton *button in self.currentButtons) {
        [self translateView:button toY:btnToValue delay:delay];
        delay += duration;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kTTShowPostUGCEntranceNotification" object:self];
    
    NSMutableDictionary *trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.entrance forKey:@"entrance"];
    [trackDict setValue:self.enterConcernID forKey:@"concern_id"];
    [TTTrackerWrapper eventV3:@"show_publisher" params:trackDict];
}

- (void)translateView:(UIView *)view toY:(CGFloat)y delay:(CGFloat)delay {
    if (@available(iOS 9, *)) {
        CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"position.y"];
        springAnimation.mass = 0.56f;
        springAnimation.damping = 9.5f;
        springAnimation.stiffness = 96.f;
        springAnimation.initialVelocity = 10.f;
        springAnimation.beginTime = CACurrentMediaTime() + delay;
        springAnimation.duration = springAnimation.settlingDuration;

        springAnimation.fromValue = @(kEntrancePanelHeight);
        springAnimation.toValue = @(y);

        view.layer.position = CGPointMake(view.layer.position.x, y);

        [view.layer addAnimation:springAnimation forKey:nil];
    } else {
        [UIView animateWithDuration:kAnimateDuration
                              delay:delay
             usingSpringWithDamping:0.6
              initialSpringVelocity:10
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             view.centerY = y;
                             view.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
    }
}

- (void)hideWithDealloc:(BOOL)dealloc {
    CGFloat duration = 0.05;
    if (self.wendaEntranceButton && self.wendaTitle) {
        duration = 0.03;
    }
    
    isShowing = NO;
    [UIView animateWithDuration:kAnimateDuration/2.f
                     animations:^{
                         self.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds), kEntrancePanelHeight);
                         self.maskView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.containerWindow.hidden = YES;
                         [self.redPachIntroView stopAnimation];
                         if (dealloc) {
                             [self removeFromSuperview];
                         }
                     }];
    [UIView animateWithDuration:kAnimateDuration
                          delay:0.10
         usingSpringWithDamping:0.6
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.pureTextEntranceButton.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                         self.pureTextTitle.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                     }
                     completion:nil];
    [UIView animateWithDuration:kAnimateDuration
                          delay:(0.10 + duration)
         usingSpringWithDamping:0.6
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.imageEntranceButton.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                         self.imageTitle.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                     }
                     completion:nil];
    [UIView animateWithDuration:kAnimateDuration
                          delay:(0.10 + 2 * duration)
         usingSpringWithDamping:0.6
          initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.videoEntranceButton.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                         self.videoTitle.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                     }
                     completion:nil];
    if (self.wendaEntranceButton && self.wendaTitle) {
        [UIView animateWithDuration:kAnimateDuration
                              delay:(0.10 + 3 * duration)
             usingSpringWithDamping:0.6
              initialSpringVelocity:10
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.wendaEntranceButton.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                             self.wendaTitle.transform = CGAffineTransformMakeTranslation(0, kEntrancePanelHeight - 45.f);
                         }
                         completion:nil];
    }
    
}

- (void)tapEntrance:(SSThemedButton *)entranceButton {
    
    UITabBarController * tabbarController = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    
    NSString *categoryName;
    
    NSMutableDictionary * trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.entrance forKey:@"entrance"];
    //关心主页不发tab_name和category_name
    if (![self.entrance isEqualToString:@"concern"] && [tabbarController isKindOfClass:[UITabBarController class]]) {
        NSString *tabName = [TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex];
        if (!isEmptyString(tabName)) {
            [trackDict setValue:tabName forKey:@"tab_name"];
        }
        if ([tabName isEqualToString:@"stream"]) {
            categoryName = [TTArticleCategoryManager currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"video"]){
            categoryName = [TTVideoCategoryManager currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"hotsoon_video"]) {
            categoryName = [[TSVCategoryManager sharedManager] currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"weitoutiao"]) {
            categoryName = kTTWeitoutiaoCategoryID;
        }else if ([tabName isEqualToString:@"xigua_live"]){
            categoryName = [TTVideoCategoryManager currentSelectedCategoryID];
        }
        if (!isEmptyString(categoryName)) {
            [trackDict setValue:categoryName forKey:@"category_name"];
        }
    }
    switch (entranceButton.tag) {
        case TTPostUGCEntranceButtonTypeImageAndText:
        case TTPostUGCEntranceButtonTypeText:{
            [TTTrackerWrapper eventV3:@"click_publisher_text" params:trackDict];
            NSUInteger postEditStatus = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCShowEtStatus];
            NSString * postHint = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCHint];
            
            NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
            if (isEmptyString(concernID)) {
                concernID = kTTMainConcernID;
            }

            NSDictionary *params = self.tapActionParams;
            if (!params) {
                NSMutableDictionary *baseConditionParams = [NSMutableDictionary dictionary];
                [baseConditionParams setValue:concernID forKey:@"cid"];
                [baseConditionParams setValue:@(postEditStatus) forKey:@"show_et_status"];
                [baseConditionParams setValue:postHint forKey:@"post_content_hint"];
                [baseConditionParams setValue:@(1) forKey:@"refer"];
                [baseConditionParams setValue:@(TTPostUGCEnterFromCategory) forKey:@"post_ugc_enter_from"];
                [baseConditionParams setValue:kTTMainCategoryID forKey:@"category_id"];
                [baseConditionParams setValue:@"feed_publisher" forKey:@"enter_type"];
                params = [baseConditionParams copy];
            }
            TTPostThreadViewController *postThreadVC = [[TTPostThreadViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(params)];
            postThreadVC.enterConcernID = self.enterConcernID;
            postThreadVC.entrance = self.entrance;
            TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:postThreadVC animationStyle:TTCustomAnimationStyleUGCPostEntrance];
            nav.ttDefaultNavBarStyle = @"White";

            [[TTUIResponderHelper topmostViewController] presentViewController:nav animated:YES completion:nil];
            [self hideWithDealloc:YES];
        }
            break;
            
        case TTPostUGCEntranceButtonTypeImage: {
            
            [TTTrackerWrapper eventV3:@"click_publisher_image" params:trackDict];
            [TTImagePickerManager manager].accessIcloud = YES;
            
            TTImagePickerController *picVC = [[TTImagePickerController alloc]initWithDelegate:self];
            picVC.maxImagesCount = 9;
            //忽略photos，不要延迟
            picVC.isRequestPhotosBack = NO;
            [picVC presentOn:[TTUIResponderHelper topmostViewController]];
            
            NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
            NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
            
            if (isEmptyString(concernID)) {
                concernID = kTTMainConcernID;
                categoryID = kTTMainCategoryID;
            }
            
            self.trackDelegate = [[TTImagePickerTrackDelegate alloc] initWithEventName:@"topic_post" TrackDic:@{@"category_id":categoryID,@"concern_id":concernID}];
            [self hideWithDealloc:NO];
        }
            break;

        case TTPostUGCEntranceButtonTypeShortVideo: {
            [TTTrackerWrapper eventV3:@"click_publisher_shortvideo" params:trackDict];
            
            NSString *concernID = [TSVPublishShortVideoHelper publishShortVideoInsertToConcernID];
            NSString *categoryID = [TSVPublishShortVideoHelper publishShortVideoInsertToCategoryID];
            NSString *enterType = [self.tapActionParams stringValueForKey:@"enter_type" defaultValue:@"feed_publisher"];
            
            NSMutableDictionary *extraTrackDict = [NSMutableDictionary dictionary];
            [extraTrackDict setValue:@1 forKey:@"refer"];
            [extraTrackDict setValue:enterType forKey:@"enter_type"];
            if ([self.entrance isEqualToString:@"concern"]) {
                [extraTrackDict setValue:@"shortvideo_concern" forKey:@"shoot_entrance"];
            }
            else {
                [extraTrackDict setValue:@"shortvideo_main" forKey:@"shoot_entrance"];
            }
            [extraTrackDict setValue:[TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex] forKey:@"tab_name"];
            [extraTrackDict setValue:categoryName forKey:@"category_name"];
            [extraTrackDict setValue:concernID forKey:@"concern_id"];
            
            NSString *presetForumName = [self.tapActionParams tt_stringValueForKey:@"title"];
            NSString *presetForumSchema = [self.tapActionParams tt_stringValueForKey:@"schema"];
            NSString *cid = [self.tapActionParams tt_stringValueForKey:@"cid"];
            
            [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setShortVideoNormalMainIntroClicked];
            [TTRecordImportVideoContainerViewController presentRecordImportVideoContainerWithStyle:TTRecordViewStyleShortVideo presetForumName:presetForumName presetForumSchema:presetForumSchema concernID:cid postUGCEnterFrom:TTPostUGCEnterFromCategory extraTrack:extraTrackDict completionBlock:^(BOOL completed, TTRecordedVideo * _Nullable recordedVideo) {
                if (completed) {
                    NSString * homeDirectory = NSHomeDirectory();
                    NSString * outputVideoRelativeUrl = recordedVideo.videoURL.path;
                    if (homeDirectory.length < outputVideoRelativeUrl.length) {
                        outputVideoRelativeUrl = [outputVideoRelativeUrl substringFromIndex:homeDirectory.length];
                    }
                    AVAssetTrack *track = nil;
                    NSArray<AVAssetTrack *> *tracks = [recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo];
                    if ([tracks count] > 0) {
                        track = [[recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                    }
                    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                    [[TTForumPostThreadCenter sharedInstance_tt] postVideoThreadWithTitle:recordedVideo.title
                                                                        withTitleRichSpan:recordedVideo.title_rich_span
                                                                         withMentionUsers:recordedVideo.mentionUser
                                                                      withMentionConcerns:recordedVideo.mentionConcern
                                                                                videoPath:outputVideoRelativeUrl
                                                                            videoDuration:CMTimeGetSeconds(recordedVideo.videoAsset.duration)
                                                                                   height:fabs(dimensions.height)
                                                                                    width:fabs(dimensions.width)
                                                                                videoName:[recordedVideo.videoURL.path lastPathComponent]
                                                                          videoSourceType:recordedVideo.postVideoSource
                                                                               coverImage:recordedVideo.coverImage
                                                                      coverImageTimestamp:recordedVideo.coverImageTimestamp
                                                                         videoCoverSource:recordedVideo.videoCoverSource
                                                                                  musicID:recordedVideo.musicID
                                                                                concernID:concernID
                                                                               categoryID:categoryID
                                                                                    refer:1
                                                                         postUGCEnterFrom:TTPostUGCEnterFromCategory
                                                                               extraTrack:recordedVideo.extraTrackForPublish
                                                                              finishBlock:nil];
                }
            }];
            [self hideWithDealloc:NO];
        }
            break;
        case TTPostUGCEntranceButtonTypeVideo: {
            [TTTrackerWrapper eventV3:@"click_publisher_video" params:trackDict];
            
            __block NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
            __block NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
            NSString *enterType = [self.tapActionParams stringValueForKey:@"enter_type" defaultValue:@"feed_publisher"];

            if (isEmptyString(concernID)) {
                concernID = kTTMainConcernID;
                categoryID = kTTMainCategoryID;
            }
            
            NSMutableDictionary *extraTrackDict = [NSMutableDictionary dictionary];
            [extraTrackDict setValue:@1 forKey:@"refer"];
            [extraTrackDict setValue:enterType forKey:@"enter_type"];
            [extraTrackDict setValue:@"video_main" forKey:@"shoot_entrance"];
            [extraTrackDict setValue:[TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex] forKey:@"tab_name"];
            [extraTrackDict setValue:categoryName forKey:@"category_name"];
            [extraTrackDict setValue:concernID forKey:@"concern_id"];

            [TTRecordImportVideoContainerViewController presentRecordImportVideoContainerWithStyle:TTRecordViewStyleUGCVideo postUGCEnterFrom:TTPostUGCEnterFromCategory extraTrack:extraTrackDict.copy completionBlock:^(BOOL completed, TTRecordedVideo * _Nullable recordedVideo) {
                if (completed) {
                    NSString * homeDirectory = NSHomeDirectory();
                    NSString * outputVideoRelativeUrl = recordedVideo.videoURL.path;
                    if (homeDirectory.length < outputVideoRelativeUrl.length) {
                        outputVideoRelativeUrl = [outputVideoRelativeUrl substringFromIndex:homeDirectory.length];
                    }
                    AVAssetTrack *track = nil;
                    NSArray<AVAssetTrack *> *tracks = [recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo];
                    if ([tracks count] > 0) {
                        track = [[recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                    }
                    CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                    if (recordedVideo.postVideoSource == TTPostVideoSourceShortVideoFromUGCVideo && [[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHTSTabKey]) {
                        concernID = kTTShortVideoConcernID;
                        categoryID = kTTUGCVideoCategoryID;
                    }
                    [[TTForumPostThreadCenter sharedInstance_tt] postVideoThreadWithTitle:recordedVideo.title
                                                                        withTitleRichSpan:recordedVideo.title_rich_span
                                                                         withMentionUsers:recordedVideo.mentionUser
                                                                      withMentionConcerns:recordedVideo.mentionConcern
                                                                                videoPath:outputVideoRelativeUrl
                                                                            videoDuration:CMTimeGetSeconds(recordedVideo.videoAsset.duration)
                                                                                   height:fabs(dimensions.height)
                                                                                    width:fabs(dimensions.width)
                                                                                videoName:[recordedVideo.videoURL.path lastPathComponent]
                                                                          videoSourceType:recordedVideo.postVideoSource
                                                                               coverImage:recordedVideo.coverImage
                                                                      coverImageTimestamp:recordedVideo.coverImageTimestamp
                                                                         videoCoverSource:recordedVideo.videoCoverSource
                                                                                  musicID:recordedVideo.musicID
                                                                                concernID:concernID
                                                                               categoryID:categoryID
                                                                                    refer:1
                                                                         postUGCEnterFrom:TTPostUGCEnterFromCategory
                                                                               extraTrack:recordedVideo.extraTrackForPublish
                                                                              finishBlock:nil];
                }
            }];
            [self hideWithDealloc:YES];
        }
            break;
        case TTPostUGCEntranceButtonTypeWenda: {

            [TTTrackerWrapper eventV3:@"click_publisher_question" params:trackDict];
            NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_question_post"];
            NSString *component = @"?";

            NSMutableDictionary *gdExtJsonDict = [[NSMutableDictionary alloc] init];
            if ([self.tapActionParams tt_dictionaryValueForKey:@"gd_ext_json"]) {
                [gdExtJsonDict setValuesForKeysWithDictionary:[self.tapActionParams tt_dictionaryValueForKey:@"gd_ext_json"]];
            }
            [gdExtJsonDict setValue:@"click_publisher" forKey:@"enter_from"];
            
            if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
                [urlStr appendFormat:@"%@gd_ext_json=%@", component, [gdExtJsonDict tt_JSONRepresentation]];
                component = @"&";
            }
            NSString *schema = [urlStr stringByAppendingString:@"&source=publisher_click_question"];
            [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:schema] userInfo:nil];
            [self hideWithDealloc:YES];
        }
            break;
//        case TTPostUGCEntranceButtonTypeXiguaLive:
//        {
//            [TTTrackerWrapper eventV3:@"live_click" params:nil];
//            NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
//            [extraDic setValue:@"publisher_enter" forKey:@"category_name"];
//            [extraDic setValue:@"click_other" forKey:@"enter_from"];
//            UIViewController *broadcastVC = [[TTXiguaLiveManager sharedManager] boadCastRoomWithExtraInfo:extraDic];
//            [self.navigationController presentViewController:broadcastVC animated:YES completion:nil];
//            [self hideWithDealloc:YES];
//        }
//            break;
    }
}

- (void)tap:(id)sender {
    NSMutableDictionary *trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.entrance forKey:@"entrance"];
    [trackDict setValue:self.enterConcernID forKey:@"concern_id"];
    
    [TTTrackerWrapper eventV3:@"close_publisher" params:trackDict];
    
    [self hideWithDealloc:YES];
}

#pragma mark - TTImagePickerControllerDelegate

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray<TTAssetModel *> *)assets
{
    self.trackDelegate = nil;
    NSMutableDictionary *baseConditionParams = [NSMutableDictionary dictionary];
    [baseConditionParams setValue:[assets copy] forKey:@"assets"];
    [self showPostView:baseConditionParams];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishTakePhoto:(UIImage *)photo selectedAssets:(NSArray<TTAssetModel *> *)assets withInfo:(NSDictionary *)info
{
    self.trackDelegate = nil;
    NSMutableDictionary *baseConditionParams = [NSMutableDictionary dictionary];
    if (photo) {
        [baseConditionParams setValue:assets forKey:@"assets"];
        [baseConditionParams setValue:@[photo] forKey:@"images"];
    }
    [self showPostView:baseConditionParams];
}

// 选择器取消选择的回调
- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker
{
    self.trackDelegate = nil;
}

- (void)showPostView:(nonnull NSMutableDictionary *)baseConditionParams
{
    if (!self.tapActionParams) {
        NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];

        if (isEmptyString(concernID)) {
            concernID = kTTMainConcernID;
        }

        NSUInteger postEditStatus = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCShowEtStatus];
        NSString *postHint = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCHint];
        [baseConditionParams setValue:concernID forKey:@"cid"];
        [baseConditionParams setValue:@(postEditStatus) forKey:@"show_et_status"];
        [baseConditionParams setValue:postHint forKey:@"post_content_hint"];
        [baseConditionParams setValue:@(1) forKey:@"refer"];
        [baseConditionParams setValue:@(TTPostUGCEnterFromCategory) forKey:@"post_ugc_enter_from"];
        [baseConditionParams setValue:kTTMainCategoryID forKey:@"category_id"];
        [baseConditionParams setValue:@"feed_publisher" forKey:@"enter_type"];
    } else {
        [baseConditionParams addEntriesFromDictionary:self.tapActionParams];
    }

    [baseConditionParams setValue:self.library forKey:@"library"];

    TTPostThreadViewController *postThreadVC = [[TTPostThreadViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict([baseConditionParams copy])];
    postThreadVC.enterConcernID = self.enterConcernID;
    postThreadVC.entrance = self.entrance;
    TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:postThreadVC animationStyle:TTCustomAnimationStyleUGCPostEntrance];
    nav.ttDefaultNavBarStyle = @"White";

    [[TTUIResponderHelper topmostViewController] presentViewController:nav
                                                               animated:YES
                                                             completion:^{
                                                             }];
    [self removeFromSuperview];
}

+ (BOOL)isShowing
{
    return isShowing;
}

- (void)dealloc
{
    [TTImagePickerManager manager].accessIcloud = NO;

}

#pragma mark - GET

- (SSThemedButton *)pureTextEntranceButton {
    if (!_pureTextEntranceButton) {
        _pureTextEntranceButton = [[SSThemedButton alloc] init];
        [_pureTextEntranceButton setImage:[UIImage imageNamed:@"weitoutiao_allshare"] forState:UIControlStateNormal];
        [_pureTextEntranceButton addTarget:self
                                    action:@selector(tapEntrance:)
                          forControlEvents:UIControlEventTouchUpInside];
    }
    return _pureTextEntranceButton;
}

- (SSThemedLabel *)pureTextTitle {
    if (!_pureTextTitle) {
        _pureTextTitle = [[SSThemedLabel alloc] init];
        _pureTextTitle.font = [UIFont systemFontOfSize:12.f];
        _pureTextTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _pureTextTitle;
}

- (SSThemedButton *)imageEntranceButton {
    if (!_imageEntranceButton) {
        _imageEntranceButton = [[SSThemedButton alloc] init];
        [_imageEntranceButton setImage:[UIImage imageNamed:@"image_allshare"] forState:UIControlStateNormal];
        
        [_imageEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageEntranceButton;
}

- (SSThemedLabel *)imageTitle {
    if (!_imageTitle) {
        _imageTitle = [[SSThemedLabel alloc] init];
        _imageTitle.font = [UIFont systemFontOfSize:12.f];
        _imageTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _imageTitle;
}

- (SSThemedButton *)videoEntranceButton {
    if (!_videoEntranceButton) {
        _videoEntranceButton = [[SSThemedButton alloc] init];
        [_videoEntranceButton setImage:[UIImage imageNamed:@"video_allshare"] forState:UIControlStateNormal];
        
        [_videoEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoEntranceButton;
}

- (SSThemedLabel *)videoTitle {
    if (!_videoTitle) {
        _videoTitle = [[SSThemedLabel alloc] init];
        _videoTitle.font = [UIFont systemFontOfSize:12.f];
        _videoTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _videoTitle;
}

- (SSThemedButton *)xiguaLiveEntranceButton {
    if (!_xiguaLiveEntranceButton) {
        _xiguaLiveEntranceButton = [[SSThemedButton alloc] init];
        [_xiguaLiveEntranceButton setImage:[UIImage imageNamed:@"video_allshare"] forState:UIControlStateNormal];
        
        [_xiguaLiveEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _xiguaLiveEntranceButton;
}

- (SSThemedLabel *)xiguaLiveTitle {
    if (!_xiguaLiveTitle) {
        _xiguaLiveTitle = [[SSThemedLabel alloc] init];
        _xiguaLiveTitle.font = [UIFont systemFontOfSize:12.f];
        _xiguaLiveTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _xiguaLiveTitle;
}


- (SSThemedButton *)shortVideoEntranceButton {
    if (!_shortVideoEntranceButton) {
        _shortVideoEntranceButton = [[SSThemedButton alloc] init];
        [_shortVideoEntranceButton setImage:[UIImage imageNamed:@"short_video_allshare"] forState:UIControlStateNormal];
        [_shortVideoEntranceButton addTarget:self
                                      action:@selector(tapEntrance:)
                            forControlEvents:UIControlEventTouchUpInside];
    }
    return _shortVideoEntranceButton;
}

- (SSThemedLabel *)shortVideoTitle {
    if (!_shortVideoTitle) {
        _shortVideoTitle = [[SSThemedLabel alloc] init];
        _shortVideoTitle.font = [UIFont systemFontOfSize:12.f];
        _shortVideoTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _shortVideoTitle;
}

- (SSThemedButton *)wendaEntranceButton {
    if (!_wendaEntranceButton) {
        _wendaEntranceButton = [[SSThemedButton alloc] init];
        [_wendaEntranceButton setImage:[UIImage imageNamed:@"ask_allshare"] forState:UIControlStateNormal];
        
        [_wendaEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _wendaEntranceButton;
}

- (SSThemedLabel *)wendaTitle {
    if (!_wendaTitle) {
        _wendaTitle = [[SSThemedLabel alloc] init];
        _wendaTitle.font = [UIFont systemFontOfSize:12.f];
        _wendaTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _wendaTitle;
}

- (SSThemedButton *)imageAndTextEntranceButton {
    if (!_imageAndTextEntranceButton) {
        _imageAndTextEntranceButton = [[SSThemedButton alloc] init];
        [_imageAndTextEntranceButton setImage:[UIImage imageNamed:@"text_image_allshare"] forState:UIControlStateNormal];;
        
        [_imageAndTextEntranceButton addTarget:self
                                 action:@selector(tapEntrance:)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageAndTextEntranceButton;
}

- (SSThemedLabel *)imageAndTextTitle {
    if (!_imageAndTextTitle) {
        _imageAndTextTitle = [[SSThemedLabel alloc] init];
        _imageAndTextTitle.font = [UIFont systemFontOfSize:12.f];
        _imageAndTextTitle.textColors = @[@"222222",@"cacaca"];
    }
    return _imageAndTextTitle;
}

- (NSMutableArray <SSThemedButton *>*)currentButtons {
    if (!_currentButtons) {
        _currentButtons = [[NSMutableArray alloc] init];
    }
    return _currentButtons;
}

- (NSMutableArray <SSThemedLabel *>*)currentLabels {
    if (!_currentLabels) {
        _currentLabels = [[NSMutableArray alloc] init];
    }
    return _currentLabels;
}

- (NSArray<PopoverAction *> *)topBarPublishActions {
    self.entrance = @"main";
    NSArray<FRPublishConfigStructModel *> *models = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) publishTypeModels];

    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:4];
    NSString *categoryName = [self getCurCategoryName];
    NSDictionary *trackDict = [self getTrackDict];
    UITabBarController * tabbarController = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;

    if (models) {
        for (NSUInteger index = 0; index < models.count; ++index) {
            PopoverAction *action;
            FRPublishConfigStructModel *model = models[index];
            UIImage *remoteIconImage = [[TTPostUGCEntranceIconDownloadManager sharedManager] getEntranceIconForType:model.type.integerValue withURL:model.top_icon];

            switch (model.type.integerValue) {
                case TTPostUGCEntranceButtonTypeWenda:{
                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"icon_ask_titlebar"] title:model.name ?: @"提问" handler:^(PopoverAction *action) {
                        [TTTrackerWrapper eventV3:@"click_publisher_question" params:trackDict];
                        NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_question_post"];
                        NSString *component = @"?";

                        NSMutableDictionary *gdExtJsonDict = [[NSMutableDictionary alloc] init];
                        if ([self.tapActionParams tt_dictionaryValueForKey:@"gd_ext_json"]) {
                            [gdExtJsonDict setValuesForKeysWithDictionary:[self.tapActionParams tt_dictionaryValueForKey:@"gd_ext_json"]];
                        }
                        [gdExtJsonDict setValue:@"click_publisher" forKey:@"enter_from"];

                        if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
                            [urlStr appendFormat:@"%@gd_ext_json=%@", component, [gdExtJsonDict tt_JSONRepresentation]];
                            component = @"&";
                        }
                        NSString *schema = [urlStr stringByAppendingString:@"&source=publisher_click_question"];
                        [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:schema] userInfo:nil];
                    }];
                }
                    break;
                case TTPostUGCEntranceButtonTypeImage:{
                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"image_allshare"] title:model.name ?: @"图片" handler:^(PopoverAction *action) {
                        [TTTrackerWrapper eventV3:@"click_publisher_image" params:trackDict];
                        [TTImagePickerManager manager].accessIcloud = YES;

                        TTImagePickerController *picVC = [[TTImagePickerController alloc]initWithDelegate:self];
                        picVC.maxImagesCount = 9;
                        //忽略photos，不要延迟
                        picVC.isRequestPhotosBack = NO;
                        [picVC presentOn:[TTUIResponderHelper topmostViewController]];

                        NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
                        NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];

                        if (isEmptyString(concernID)) {
                            concernID = kTTMainConcernID;
                            categoryID = kTTMainCategoryID;
                        }

                        self.trackDelegate = [[TTImagePickerTrackDelegate alloc] initWithEventName:@"topic_post" TrackDic:@{@"category_id":categoryID,@"concern_id":concernID}];
                    }];
                }
                    break;
                case TTPostUGCEntranceButtonTypeVideo:{
                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"icon_video_titlebar"] title:model.name ?: @"视频" handler:^(PopoverAction *action) {
                        [TTTrackerWrapper eventV3:@"click_publisher_video" params:trackDict];

                        NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
                        NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
                        NSString *enterType = [self.tapActionParams stringValueForKey:@"enter_type" defaultValue:@"feed_publisher"];

                        if (isEmptyString(concernID)) {
                            concernID = kTTMainConcernID;
                            categoryID = kTTMainCategoryID;
                        }

                        NSMutableDictionary *extraTrackDict = [NSMutableDictionary dictionary];
                        [extraTrackDict setValue:@1 forKey:@"refer"];
                        [extraTrackDict setValue:enterType forKey:@"enter_type"];
                        [extraTrackDict setValue:@"video_main" forKey:@"shoot_entrance"];
                        [extraTrackDict setValue:[TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex] forKey:@"tab_name"];
                        [extraTrackDict setValue:categoryName forKey:@"category_name"];
                        [extraTrackDict setValue:concernID forKey:@"concern_id"];

                        [TTRecordImportVideoContainerViewController presentRecordImportVideoContainerWithStyle:TTRecordViewStyleUGCVideo postUGCEnterFrom:TTPostUGCEnterFromCategory extraTrack:extraTrackDict.copy completionBlock:^(BOOL completed, TTRecordedVideo * _Nullable recordedVideo) {
                            if (completed) {
                                NSString * homeDirectory = NSHomeDirectory();
                                NSString * outputVideoRelativeUrl = recordedVideo.videoURL.path;
                                if (homeDirectory.length < outputVideoRelativeUrl.length) {
                                    outputVideoRelativeUrl = [outputVideoRelativeUrl substringFromIndex:homeDirectory.length];
                                }
                                AVAssetTrack *track = nil;
                                NSArray<AVAssetTrack *> *tracks = [recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo];
                                if ([tracks count] > 0) {
                                    track = [[recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                                }
                                CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                                [[TTForumPostThreadCenter sharedInstance_tt] postVideoThreadWithTitle:recordedVideo.title
                                                                                    withTitleRichSpan:recordedVideo.title_rich_span
                                                                                     withMentionUsers:recordedVideo.mentionUser
                                                                                  withMentionConcerns:recordedVideo.mentionConcern
                                                                                            videoPath:outputVideoRelativeUrl
                                                                                        videoDuration:CMTimeGetSeconds(recordedVideo.videoAsset.duration)
                                                                                               height:fabs(dimensions.height)
                                                                                                width:fabs(dimensions.width)
                                                                                            videoName:[recordedVideo.videoURL.path lastPathComponent]
                                                                                      videoSourceType:recordedVideo.postVideoSource
                                                                                           coverImage:recordedVideo.coverImage
                                                                                  coverImageTimestamp:recordedVideo.coverImageTimestamp
                                                                                     videoCoverSource:recordedVideo.videoCoverSource
                                                                                              musicID:recordedVideo.musicID
                                                                                            concernID:concernID
                                                                                           categoryID:categoryID
                                                                                                refer:1
                                                                                     postUGCEnterFrom:TTPostUGCEnterFromCategory
                                                                                           extraTrack:recordedVideo.extraTrackForPublish
                                                                                          finishBlock:nil];
                            }
                        }];
                    }];
                }
                    break;
                case TTPostUGCEntranceButtonTypeText:{
                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"icon_photo&article_titlebar"] title:model.name ?: @"文字" handler:^(PopoverAction *action) {
                        [self triggerTextAndImageCallback];
                    }];
                }
                    break;
                case TTPostUGCEntranceButtonTypeShortVideo:{
                    UIImage *iconImage = remoteIconImage ?: [UIImage imageNamed:@"icon_shortvideo_titlebar"];
                    NSString *text = model.name ?: @"拍小视频";
                    NSArray *colors = nil;
                    UIImage *titleBgImage = nil;
                    UIFont *titleFont = nil;
                    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) shouldShowSpringShortVideoRedPackGuide]) {
                        iconImage = [UIImage imageNamed:@"icon_spring_red_packet"];
                        titleBgImage = [UIImage imageNamed:@"short_video_redpack_bg"];
                        titleFont = [UIFont boldSystemFontOfSize:14.f];
                        text = @"拜年小视频";
                        colors = @[@"f85959",@"935656"];
                    } else if([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro]) {
                        iconImage = [UIImage imageNamed:@"icon_spring_red_packet"];
                        colors = @[@"f85959",@"935656"];
                    }
                    BOOL showRedDot = ![GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoRedpackIntro] && [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) needShowShortVideoMainNormalIntro];
                    action = [PopoverAction actionWithImage:iconImage title:text titleFont:titleFont titleImage:titleBgImage colors:colors showRedDot:showRedDot handler:^(PopoverAction *action) {
                        [self triggerShortVideoCallback];
                    }];
                }
                    break;
                case TTPostUGCEntranceButtonTypeImageAndText:{
                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"icon_photo&article_titlebar"] title:model.name ?: @"发图文" handler:^(PopoverAction *action) {
                        [self triggerTextAndImageCallback];
                    }];
                }
                    break;
//                case TTPostUGCEntranceButtonTypeXiguaLive:{
//                    action = [PopoverAction actionWithImage:remoteIconImage ?: [UIImage imageNamed:@"xiguaLive&article_titlebar"] title:model.name ?: @"直播" handler:^(PopoverAction *action) {
//                        [TTTrackerWrapper eventV3:@"live_click" params:nil];
//                        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
//                        [extraDic setValue:@"publisher_enter" forKey:@"category_name"];
//                        [extraDic setValue:@"click_other" forKey:@"enter_from"];
//                        UIViewController *broadcastVC = [[TTXiguaLiveManager sharedManager] boadCastRoomWithExtraInfo:extraDic];
//                        [self.navigationController presentViewController:broadcastVC animated:YES completion:nil];
//                    }];
//                }
//                    break;
                default:
                    break;
            }
            if (action) {
                [actions addObject:action];
            }
        }
    }

    return [actions copy];
}

- (NSDictionary *)getTrackDict {
    UITabBarController * tabbarController = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    NSString *categoryName = [self getCurCategoryName];

    NSMutableDictionary * trackDict = [NSMutableDictionary new];
    [trackDict setValue:self.entrance forKey:@"entrance"];
    //关心主页不发tab_name和category_name
    if (![self.entrance isEqualToString:@"concern"] && [tabbarController isKindOfClass:[UITabBarController class]]) {
        NSString *tabName = [TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex];

        if (!isEmptyString(tabName)) {
            [trackDict setValue:tabName forKey:@"tab_name"];
        }

        if (!isEmptyString(categoryName)) {
            [trackDict setValue:categoryName forKey:@"category_name"];
        }
    }

    return [trackDict copy];
}

- (NSString *)getCurCategoryName {
    UITabBarController * tabbarController = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    NSString *categoryName;

    //关心主页不发tab_name和category_name
    if (![self.entrance isEqualToString:@"concern"] && [tabbarController isKindOfClass:[UITabBarController class]]) {
        NSString *tabName = [TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex];
        if ([tabName isEqualToString:@"stream"]) {
            categoryName = [TTArticleCategoryManager currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"video"]){
            categoryName = [TTVideoCategoryManager currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"hotsoon_video"]) {
            categoryName = [[TSVCategoryManager sharedManager] currentSelectedCategoryID];
        }
        else if ([tabName isEqualToString:@"weitoutiao"]) {
            categoryName = kTTWeitoutiaoCategoryID;
        }else if ([tabName isEqualToString:@"xigua_live"]){
            categoryName = [TTVideoCategoryManager currentSelectedCategoryID];
        }
    }

    return categoryName;
}

- (void)triggerShortVideoCallback {
    [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) setShortVideoNormalMainIntroClicked];

    if ([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) shouldShowSpringShortVideoRedPackGuide]) {
        [self openSpringShortVideoTemplatePage];
    } else {
        NSString *categoryName = [self getCurCategoryName];
        NSDictionary *trackDict = [self getTrackDict];
        BOOL isInShortVideoTab = [[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHTSTabKey];
        UITabBarController * tabbarController = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;

        [TTTrackerWrapper eventV3:@"click_publisher_shortvideo" params:trackDict];

        NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
        NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
        NSString *enterType = [self.tapActionParams stringValueForKey:@"enter_type" defaultValue:@"feed_publisher"];
        if (isInShortVideoTab) {
            concernID = kTTShortVideoConcernID;
            categoryID = kTTUGCVideoCategoryID;
        }
        if (isEmptyString(concernID)) {
            concernID = kTTMainConcernID;
            categoryID = kTTMainCategoryID;
        }

        NSMutableDictionary *extraTrackDict = [NSMutableDictionary dictionary];
        [extraTrackDict setValue:@1 forKey:@"refer"];
        [extraTrackDict setValue:enterType forKey:@"enter_type"];
        [extraTrackDict setValue:@"shortvideo_main" forKey:@"shoot_entrance"];
        [extraTrackDict setValue:[TTArticleTabBarController tabStayStringForIndex:tabbarController.selectedIndex] forKey:@"tab_name"];
        [extraTrackDict setValue:categoryName forKey:@"category_name"];
        [extraTrackDict setValue:concernID forKey:@"concern_id"];

        [TTRecordImportVideoContainerViewController presentRecordImportVideoContainerWithStyle:TTRecordViewStyleShortVideo postUGCEnterFrom:TTPostUGCEnterFromCategory extraTrack:extraTrackDict completionBlock:^(BOOL completed, TTRecordedVideo * _Nullable recordedVideo) {
            if (completed) {
                NSString * homeDirectory = NSHomeDirectory();
                NSString * outputVideoRelativeUrl = recordedVideo.videoURL.path;
                if (homeDirectory.length < outputVideoRelativeUrl.length) {
                    outputVideoRelativeUrl = [outputVideoRelativeUrl substringFromIndex:homeDirectory.length];
                }
                AVAssetTrack *track = nil;
                NSArray<AVAssetTrack *> *tracks = [recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo];
                if ([tracks count] > 0) {
                    track = [[recordedVideo.videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                }
                CGSize dimensions = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                [[TTForumPostThreadCenter sharedInstance_tt] postVideoThreadWithTitle:recordedVideo.title
                                                                    withTitleRichSpan:recordedVideo.title_rich_span
                                                                     withMentionUsers:recordedVideo.mentionUser
                                                                  withMentionConcerns:recordedVideo.mentionConcern
                                                                            videoPath:outputVideoRelativeUrl
                                                                        videoDuration:CMTimeGetSeconds(recordedVideo.videoAsset.duration)
                                                                               height:fabs(dimensions.height)
                                                                                width:fabs(dimensions.width)
                                                                            videoName:[recordedVideo.videoURL.path lastPathComponent]
                                                                      videoSourceType:recordedVideo.postVideoSource
                                                                           coverImage:recordedVideo.coverImage
                                                                  coverImageTimestamp:recordedVideo.coverImageTimestamp
                                                                     videoCoverSource:recordedVideo.videoCoverSource
                                                                              musicID:recordedVideo.musicID
                                                                            concernID:concernID
                                                                           categoryID:categoryID
                                                                                refer:1
                                                                     postUGCEnterFrom:TTPostUGCEnterFromCategory
                                                                           extraTrack:recordedVideo.extraTrackForPublish
                                                                          finishBlock:nil];
            }
        }];
    }
}

- (void)triggerTextAndImageCallback {
    NSDictionary *trackDict = [self getTrackDict];

    [TTTrackerWrapper eventV3:@"click_publisher_text" params:trackDict];
    NSUInteger postEditStatus = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCShowEtStatus];
    NSString * postHint = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCHint];

    NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
    if (isEmptyString(concernID)) {
        concernID = kTTMainConcernID;
    }

    NSDictionary *params = self.tapActionParams;
    if (!params) {
        NSMutableDictionary *baseConditionParams = [NSMutableDictionary dictionary];
        [baseConditionParams setValue:concernID forKey:@"cid"];
        [baseConditionParams setValue:@(postEditStatus) forKey:@"show_et_status"];
        [baseConditionParams setValue:postHint forKey:@"post_content_hint"];
        [baseConditionParams setValue:@(1) forKey:@"refer"];
        [baseConditionParams setValue:@(TTPostUGCEnterFromCategory) forKey:@"post_ugc_enter_from"];
        [baseConditionParams setValue:kTTMainCategoryID forKey:@"category_id"];
        [baseConditionParams setValue:@"feed_publisher" forKey:@"enter_type"];
        params = [baseConditionParams copy];
    }
    TTPostThreadViewController *postThreadVC = [[TTPostThreadViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(params)];
    postThreadVC.enterConcernID = self.enterConcernID;
    postThreadVC.entrance = self.entrance;
    TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:postThreadVC animationStyle:TTCustomAnimationStyleUGCPostEntrance];
    nav.ttDefaultNavBarStyle = @"White";

    [[TTUIResponderHelper topmostViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)openSpringShortVideoTemplatePage {
//    [TTSFTracker event:@"shoot" eventType:TTSpringActivityEventTypeShortVideo params:nil];

    [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) didEnterSpringShortVideoRedPackEntrance];

    NSURL *url = [NSURL URLWithString:@"sslocal://sf_video_style"];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPresentViewController:url userInfo:nil];
    }
}

@end
