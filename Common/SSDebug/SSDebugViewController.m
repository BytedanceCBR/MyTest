//
//  SSDebugViewController.m
//  Article
//
//  Created by SunJiangting on 15-2-27.
//
//

#import "SSDebugViewController.h"
#import "SSQRCodeScanViewController.h"
#import "SSWebViewController.h"
#import "SSLocationPickerController.h"
#import "TTArticleCategoryManager.h"
#import "MBProgressHUD.h"
#import "SSDebugPingViewController.h"
#import "SSDebugDNSViewController.h"
#import "DebugUmengIndicator.h"
#import "SSDebugUserDefaultsViewController.h"
#import "TTInstallIDWrapperManager.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "TTLocationManager.h"
#import "TTNetworkManager.h"
#import "TTLocationManager.h"
#import "NewsUserSettingManager.h"
#import "FLEXManager.h"
#import "WDDebugViewController.h"
#import "TTMemoryMonitor.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTSandBoxHelper.h"
//#import <TTLiveMainUI/TTLiveMainViewController.h>

#import "TTFetchGuideSettingManager.h"
#import "ArticleMobileSettingViewController.h"
#import "STPersistence.h"
#import "TTURLUtils.h"
#import "WDCommonLogic.h"

#import "ExploreCellHelper.h"
#import "TTStringHelper.h"

#import "TTVideoTip.h"
#import "TTLogServer.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#import "SSADManager.h"

#import <TTAccountBusiness.h>

#import "TTABAuthorizationManager.h"
#import "TTCanvasBundleManager.h"
#import "iConsole.h"


@implementation STTableViewCellItem

- (instancetype) initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end

@implementation STTableViewSectionItem

- (instancetype)initWithSectionTitle:(NSString *)title items:(NSArray *)items {
    return [self initWithSectionHeaderTitle:title footerTitle:nil items:items];
}

- (instancetype)initWithSectionHeaderTitle:(NSString *)title footerTitle:(NSString *)footerTitle items:(NSArray *)items {
    self = [super init];
    if (self) {
        self.headerTitle = title;
        self.footerTitle = footerTitle;
        self.items = items;
    }
    return self;
}

@end

@interface STTableViewCell : SSThemedTableViewCell<UITextFieldDelegate>


@property(nonatomic, strong) UISwitch   *switchView;
@property(nonatomic, strong) STTableViewCellItem   *cellItem;
@property(nonatomic, strong) SSThemedTextField *textFieldView;
@end

@implementation STTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
        self.separatorColorThemeKey = kColorLine7;
        self.switchView = [[UISwitch alloc] init];
        self.accessoryView = self.switchView;
        self.textFieldView = [[SSThemedTextField alloc] init];
        self.textFieldView.borderStyle = UITextBorderStyleRoundedRect;
        self.textFieldView.keyboardType = UIKeyboardTypeAlphabet;
        self.textFieldView.returnKeyType = UIReturnKeyDone;
        self.textFieldView.textColorThemeKey = kColorText1;
        self.textFieldView.delegate = self;
        [self.switchView addTarget:self action:@selector(_switchActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (BOOL)textFieldShouldEndEditing:(SSThemedTextField *)textField{
    
    [self _textFieldActionFired:textField];
    return YES;
}
- (BOOL)textFieldShouldReturn:(SSThemedTextField *)textField {
    [textField resignFirstResponder];//关闭键盘
    return YES;
}

- (void)setCellItem:(STTableViewCellItem *)cellItem {
    self.accessoryView = cellItem.switchStyle ? self.switchView : nil;
    self.selectionStyle = cellItem.switchStyle ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.switchView.on = cellItem.checked;
    if (!self.accessoryView) {
        self.accessoryView = cellItem.textFieldStyle ? self.textFieldView : nil;
        self.textFieldView.text = cellItem.textFieldContent;
        self.textFieldView.tag = cellItem.tag;
        if (cellItem.textFieldStyle) {
            [self.accessoryView setFrame:CGRectMake(0, 10, 50, self.bounds.size.height - 20)];
            [self.accessoryView setBackgroundColor:[UIColor yellowColor]];
        }
        self.selectionStyle = cellItem.textFieldStyle ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    }
    _cellItem = cellItem;
}

- (void)_switchActionFired:(UISwitch *)uiswitch {
    if ([self.cellItem.target respondsToSelector:_cellItem.switchAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.cellItem.target performSelector:_cellItem.switchAction withObject:uiswitch];
#pragma clang diagnostic pop
    }
    self.cellItem.checked = uiswitch.on;
}

- (void)_textFieldActionFired:(SSThemedTextField *)textField{
    if ([self.cellItem.target respondsToSelector:self.cellItem.textFieldAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.cellItem.target performSelector:_cellItem.textFieldAction withObject:textField];
#pragma clang diagnostic pop
    }
}

@end

@implementation UIScrollView (ScrollToBottom)

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    if (contentOffset.y > 0) {
        [self setContentOffset:contentOffset animated:animated];
    }
}

@end


@implementation STDebugTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor greenColor];
        if ([self respondsToSelector:@selector(layoutManager)]) {
            self.layoutManager.allowsNonContiguousLayout = NO;
        }
        self.font = [UIFont systemFontOfSize:14];
        self.editable = NO;
    }
    return self;
}

- (void)appendText:(NSString *)text {
    if (isEmptyString(text)) {
        return;
    }
    if (isEmptyString(self.text)) {
        self.text = text;
    } else {
        self.text = [NSString stringWithFormat:@"%@\n%@" , self.text, text];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *selectorName = NSStringFromSelector(action);
    return [selectorName hasPrefix:@"copy"] || [selectorName hasPrefix:@"select"];
}

@end

@interface SSDebugViewController () <UITableViewDataSource, UITableViewDelegate> {
    
}

@property(nonatomic, copy)   NSArray        *dataSource;
@property(nonatomic, strong) SSThemedTableView *tableView;

@property(nonatomic, weak)   STTableViewCellItem *itemAB;
@property(nonatomic, weak)   STTableViewCellItem *itemSourceImg;

@property(nonatomic, weak)   STTableViewCellItem *item01;
@property(nonatomic, weak)   STTableViewCellItem *item10;
@property(nonatomic, weak)   STTableViewCellItem *item11;
@property(nonatomic, weak)   STTableViewSectionItem *section1;

@property(nonatomic, weak)   STTableViewCellItem *item41;
@property(nonatomic, weak)   STTableViewCellItem *itemFacebook;
@property(nonatomic, weak)   STTableViewCellItem *itemOwnPlayer;
@property(nonatomic, weak)   STTableViewCellItem *item50;
@property(nonatomic, weak)   STTableViewCellItem *item51;
@property(nonatomic, weak)   STTableViewCellItem *item52;
@property(nonatomic, weak)   STTableViewCellItem *item53;
@property(nonatomic, weak)   STTableViewCellItem *item54;

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureForResignFirstResponder;

@end

@implementation SSDebugViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
        NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:2];
        
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFlex]) {
            STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"UGC新Feed" target:self action:NULL];
            item_00.switchStyle = YES;
            item_00.switchAction = @selector(_abActionFired:);
            item_00.checked = [ExploreCellHelper getFeedUGCTest];
            self.itemAB = item_00;
            
            STTableViewCellItem *item_11 = [[STTableViewCellItem alloc] initWithTitle:@"下方头像露出" target:self action:NULL];
            item_11.switchStyle = YES;
            item_11.switchAction = @selector(_sourceImgActionFired:);
            item_11.checked = [ExploreCellHelper getSourceImgTest];
            self.itemSourceImg = item_11;
            
            //            STTableViewCellItem *item_12 = [[STTableViewCellItem alloc] initWithTitle:@"详情页AB测" target:self action:NULL];
            //            item_12.switchStyle = YES;
            //            item_12.switchAction = @selector(_detailViewABSettingActionFired:);
            //            item_12.checked = [SSCommonLogic detailViewABEnabled];
            
            STTableViewCellItem *item_13 = [[STTableViewCellItem alloc] initWithTitle:@"淘宝广告升级" target:self action:NULL];
            item_13.switchStyle = YES;
            item_13.switchAction = @selector(_taobaosdkActionFired:);
            item_13.checked = [SSCommonLogic shouldUseALBBService];
            
            STTableViewCellItem *item_14 = [[STTableViewCellItem alloc] initWithTitle:@"贴片广告点击AB测" target:self action:NULL];
            item_14.switchStyle = YES;
            item_14.switchAction = @selector(_posterADActionFired:);
            item_14.checked = [SSCommonLogic isPosterADClickEnabled];
            
            
            STTableViewCellItem *item_15 = [[STTableViewCellItem alloc] initWithTitle:@"图集上下滑退出" target:self action:NULL];
            item_15.switchStyle = YES;
            item_15.switchAction = @selector(picturesSlideOutActionFired:);
            item_15.checked = [SSCommonLogic appGallerySlideOutSwitchOn];
            
            STTableViewCellItem *item_16 = [[STTableViewCellItem alloc] initWithTitle:@"日志加密" target:self action:NULL];
            item_16.switchStyle = YES;
            item_16.switchAction = @selector(_encryActionFired:);
            item_16.checked = [SSCommonLogic useEncrypt];
            
            STTableViewCellItem *item_19 = [[STTableViewCellItem alloc] initWithTitle:@"测试Crash" target:self action:@selector(_crashActionFired)];
            
            STTableViewCellItem *item_20 = [[STTableViewCellItem alloc] initWithTitle:@"普通文章cell使用Layout布局" target:self action:NULL];
            item_20.switchStyle = YES;
            item_20.switchAction = @selector(_useLayOutForCellFired:);
            item_20.checked = [SSCommonLogic isLayOutCellEnabled];
            
            STTableViewCellItem *item_22 = [[STTableViewCellItem alloc] initWithTitle:@"使用4G" target:self action:NULL];
            item_22.switchStyle = YES;
            item_22.switchAction = @selector(_switchTo4G:);
            item_22.checked = [SSCommonLogic isNetWorkDebugEnable];
            
            STTableViewCellItem *item_23 = [[STTableViewCellItem alloc] initWithTitle:@"详情页使用SharedWebView" target:self action:NULL];
            item_23.switchStyle = YES;
            item_23.switchAction = @selector(_switchSharedWebView:);
            item_23.checked = [SSCommonLogic detailSharedWebViewEnabled];
            
            STTableViewCellItem *item_24 = [[STTableViewCellItem alloc] initWithTitle:@"下拉刷新交互" target:self action:NULL];
            item_24.switchStyle = YES;
            item_24.switchAction = @selector(_switchToNewPullRefresh:);
            item_24.checked = [SSCommonLogic isNewPullRefreshEnabled];
            
            STTableViewCellItem *item_25 = [[STTableViewCellItem alloc] initWithTitle:@"使用新版转场动画" target:self action:NULL];
            item_25.switchStyle = YES;
            item_25.switchAction = @selector(_switchTransitionAnimation:);
            item_25.checked = [SSCommonLogic transitionAnimationEnable];
            
            STTableViewCellItem *item_26 = [[STTableViewCellItem alloc] initWithTitle:@"开启第四个tab火山" target:self action:NULL];
            item_26.switchStyle = YES;
            item_26.switchAction = @selector(_switchForthTabHtsTab:);
            item_26.checked = [SSCommonLogic isForthTabHTSEnabled];
            
            STTableViewCellItem *item_27 = [[STTableViewCellItem alloc] initWithTitle:@"开启跳转到火山app" target:self action:NULL];
            item_27.switchStyle = YES;
            item_27.switchAction = @selector(_switchLaunchHuoShanAppEnabled:);
            item_27.checked = [SSCommonLogic isLaunchHuoShanAppEnabled];
            
            STTableViewCellItem *item_28 = [[STTableViewCellItem alloc] initWithTitle:@"开屏广告" target:self action:@selector(_fireSpalshAd)];
            
            STTableViewCellItem *item_29 = [[STTableViewCellItem alloc] initWithTitle:@"对火山tab详情页ab测开关 取相反的值" target:self action:@selector(_fireHTSABDict)];
            
            STTableViewCellItem *item_30 = [[STTableViewCellItem alloc] initWithTitle:@"图集开启随手拖动动画" target:self action:NULL];
            item_30.switchStyle = YES;
            item_30.switchAction = @selector(_switchImageTransitionAnimation:);
            item_30.checked = [SSCommonLogic imageTransitionAnimationEnable];
            
            
            STTableViewCellItem *item_31 = [[STTableViewCellItem alloc] initWithTitle:@"视频详情播放上一个" target:self action:NULL];
            item_31.switchStyle = YES;
            item_31.switchAction = @selector(videoDetailPlayLastBtnEnableActionFired:);
            item_31.checked = [SSCommonLogic isVideoDetailPlayLastEnabled];
            
            STTableViewCellItem *item_32 = [[STTableViewCellItem alloc] initWithTitle:@"播放上一个按钮样式" target:self action:NULL];
            item_32.switchStyle = YES;
            item_32.switchAction = @selector(videoDetailPlayLastShowTextActionFired:);
            item_32.checked = [SSCommonLogic isVideoDetailPlayLastShowText];
            
            STTableViewCellItem *item_34 = [[STTableViewCellItem alloc] initWithTitle:@"下载沉浸式RN Bundle" target:self action:NULL];
            item_34.textFieldStyle = YES;
            item_34.textFieldAction = @selector(_downloadCanvasRNBundle:);
           
            STTableViewCellItem *item_35 = [[STTableViewCellItem alloc] initWithTitle:@"重置上传通讯录状态" target:self action:@selector(_resetContactsActionFired)];
            
            STTableViewCellItem *item_36 = [[STTableViewCellItem alloc] initWithTitle:@"打开debug" target:self action:@selector(showConsole)];

            STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"AB测试" items:@[item_00, item_11, item_13, item_14, item_15,item_16, item_19, item_20, item_22, item_23, item_24, item_25, item_26, item_27, item_28, item_29, item_30, item_31, item_32, item_34, item_35, item_36]];

            [dataSource addObject:section0];
        }
        
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFlex]) {
            STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"FLEX" target:self action:@selector(_openFlexActionFired)];
            STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"假数据" target:self action:@selector(_openNetworkStubActionFired)];
            STTableViewCellItem *item_02 = [[STTableViewCellItem alloc] initWithTitle:@"拨打电话测试页" target:self action:@selector(_openCallNativePhoneWebPage)];
            
            STTableViewCellItem *item_03 = [[STTableViewCellItem alloc] initWithTitle:@"内存泄漏及UIKit主线程检测" target:self action:NULL];
            item_03.switchStyle = YES;
            item_03.switchAction = @selector(_leakFinderAndMainThreadGuardActionFired:);
            item_03.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"KTTMLeaksFinderEnableAlertKey"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTUIKitMainThreadGuardKey"];
            
            STTableViewCellItem *item_04 = [[STTableViewCellItem alloc] initWithTitle:@"重置观看视频次数(清除UserDefaults数据)" target:self action:@selector(resetUserWatchVideo)];
            
            STTableViewCellItem *item_05 = [[STTableViewCellItem alloc] initWithTitle:@"达人视频测试入口" target:self action:@selector(_openHTSVideoDetail)];
            
            STTableViewCellItem *item_06 = [[STTableViewCellItem alloc] initWithTitle:@"应用内存使用量监测" target:self action:NULL];
            item_06.switchStyle = YES;
            item_06.switchAction = @selector(_appMemoryMonitorActionFired:);
            item_06.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTAppMemoryMonitorKey"];
            
            STTableViewCellItem *item_07 = [[STTableViewCellItem alloc] initWithTitle:@"截图分享测试" target:self action:@selector(screenshotShare)];
            
            STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"调试工具" items:@[item_00, item_01, item_02, item_03, item_04, item_05, item_06, item_07]];
            [dataSource addObject:section0];
        }
        
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemForum]) {
            STTableViewCellItem *item_00 = [[STTableViewCellItem alloc] initWithTitle:@"话题、关心、问答调试工具" target:self action:@selector(_openForumActionFired)];
            STTableViewCellItem *item_01 = [[STTableViewCellItem alloc] initWithTitle:@"新消息通知测试域名" target:self action:nil];
            item_01.textFieldStyle = YES;
            item_01.textFieldAction = @selector(_openMessageNotificationActionFired:);
            NSString *testHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"message_notification_test_host"];
            item_01.textFieldContent = testHost;
            
            STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"话题、关心、问答调试工具" items:@[item_00, item_01]];
            [dataSource addObject:section0];
        }
        
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemLogging]) {
            STTableViewCellItem *item00 = [[STTableViewCellItem alloc] initWithTitle:@"连接日志服务器" target:self action:@selector(_connectLogServerActionFired)];
            
            STTableViewCellItem *item01 = [[STTableViewCellItem alloc] initWithTitle:@"显示Umeng日志" target:self action:NULL];
            item01.switchStyle = YES;
            item01.switchAction = @selector(_logUmengActionFired:);
            item01.checked = [DebugUmengIndicator displayUmengISOn];
            self.item01 = item01;
            
            STTableViewCellItem *item02 = [[STTableViewCellItem alloc] initWithTitle:@"把Applog请求数据写入文件" target:self action:NULL];
            item02.switchStyle = YES;
            item02.switchAction = @selector(_setShouldSaveApplog:);
            item02.checked = [self _shouldSaveApplog];
            
            STTableViewCellItem *item03 = [[STTableViewCellItem alloc] initWithTitle:@"是否使用重构的Tracker" target:self action:NULL];
            item03.switchStyle = YES;
            item03.switchAction = @selector(_setShouldUseRefactorTracker:);
            item03.checked = [TTTrackerWrapper refactorTrackerEnable];
            
            STTableViewSectionItem *section0 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"统计日志" items:@[item00, item01,item02,item03]];
            [dataSource addObject:section0];
        }
        
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemFakeLocation]) {
            STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"是否手动选择过城市" target:self action:NULL];
            item10.switchStyle = YES;
            item10.checked = [self _shouldAutomaticallyChangeCity];
            item10.switchAction = @selector(_userSelectActionFired:);
            STTableViewCellItem *item11 = [[STTableViewCellItem alloc] initWithTitle:@"模拟用户位置" target:self action:@selector(_fakeUserLocationActionFired)];
            self.item11 = item11;
            STTableViewSectionItem *section1 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"用户位置测试" items:@[item10, item11]];
            [dataSource addObject:section1];
            self.section1 = section1;
            self.item10 = item10;
        }
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemCleanCache]) {
            STTableViewCellItem *item20 = [[STTableViewCellItem alloc] initWithTitle:@"引导视图测试" target:self action:@selector(testGuideSettingActionFired)];
            STTableViewSectionItem *section2 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"引导视图" items:@[item20]];
            [dataSource addObject:section2];
        }
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemIPConfig]) {
            STTableViewCellItem *item30 = [[STTableViewCellItem alloc] initWithTitle:@"Ping测试" target:self action:@selector(_testPingActionFired)];
            STTableViewCellItem *item32 = [[STTableViewCellItem alloc] initWithTitle:@"DNS服务器" target:self action:@selector(_testDNSActionFired)];
            STTableViewSectionItem *section3 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"网络状态测试" items:@[item30, item32]];
            [dataSource addObject:section3];
        }
        if ([SSDebugViewController supportDebugSubitem:SSDebugSubitemUserDefaults]) {
            STTableViewCellItem *item40 = [[STTableViewCellItem alloc] initWithTitle:@"NSUserDefaults" target:self action:@selector(_readUserDefaultsActionFired)];
            STTableViewCellItem *item41 = [[STTableViewCellItem alloc] initWithTitle:@"测试图片专题" target:self action:nil];
            item41.switchStyle = YES;
            item41.switchAction = @selector(_testImageSubjectActionFired:);
            
            STTableViewCellItem *itemfb = [[STTableViewCellItem alloc] initWithTitle:@"测试Facebook浮层" target:self action:nil];
            itemfb.switchStyle = YES;
            itemfb.switchAction = @selector(_testVideoFacebookActionFired:);
            self.itemFacebook = itemfb;
            
            STTableViewCellItem *itemOwnPlayer = [[STTableViewCellItem alloc] initWithTitle:@"打开自研播放器" target:self action:nil];
            itemOwnPlayer.switchStyle = YES;
            itemOwnPlayer.switchAction = @selector(_testVideoOwnPlayerActionFired:);
            self.itemOwnPlayer = itemOwnPlayer;
            
            
            STTableViewSectionItem *section4 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"读取用户设置" items:@[item40, item41 ,itemfb,itemOwnPlayer]];
            [dataSource addObject:section4];
            self.item41 = item41;
        }
        
        if ([TTDeviceHelper OSVersionNumber] > 7.0f) {
            STTableViewCellItem *item60 = [[STTableViewCellItem alloc] initWithTitle:@"使用WKWebView" target:self action:NULL];
            item60.switchStyle = YES;
            item60.checked = [self _shouldAllowWKWebView];
            item60.switchAction = @selector(_wkwebviewSettingActionFired:);
            STTableViewSectionItem *section6 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"WKWebView 开关" items:@[item60]];
            
            [dataSource addObject:section6];
            
        }
        
        if (YES) {
            STTableViewCellItem *item71 = [[STTableViewCellItem alloc] initWithTitle:@"使用Https" target:self action:NULL];
            item71.switchStyle = YES;
            item71.checked = [self _shouldAllowHttps];
            item71.switchAction = @selector(_httpsSettingActionFired:);
            STTableViewSectionItem *section7 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"Https 开关" items:@[item71]];
            
            [dataSource addObject:section7];
        }
        
        if(YES) {
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"使用多清晰度" target:self action:NULL];
            item.switchStyle = YES;
            item.checked = [SSCommonLogic isMultiResolutionEnabled];
            item.switchAction = @selector(_multiResolutionActionFired:);
            
            STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"Feed返回视频URL" target:self action:NULL];
            item1.switchStyle = YES;
            item1.checked = [SSCommonLogic isVideoFeedURLEnabled];
            item1.switchAction = @selector(feedUrlOpen:);
            
            STTableViewCellItem *item3 = [[STTableViewCellItem alloc] initWithTitle:@"视频尺寸可控" target:self action:NULL];
            item3.switchStyle = YES;
            item3.checked = [SSCommonLogic isTTVideoProportionControlEnable];
            item3.switchAction = @selector(videoProportion:);
            
            STTableViewCellItem *item4 = [[STTableViewCellItem alloc] initWithTitle:@"视频cell显示分享按钮" target:self action:NULL];
            item4.switchStyle = YES;
            item4.checked = [SSCommonLogic isVideoCellShowShareEnabled];
            item4.switchAction = @selector(videoCellShowShareButton:);
            
            STTableViewCellItem *item5 = [[STTableViewCellItem alloc] initWithTitle:@"开启新转屏" target:self action:NULL];
            item5.switchStyle = YES;
            item5.checked = [SSCommonLogic isVideoNewRotateEnabled];
            item5.switchAction = @selector(videoNewRotate:);
            
            STTableViewCellItem *item7 = [[STTableViewCellItem alloc] initWithTitle:@"视频列表广告cell dislike" target:self action:NULL];
            item7.switchStyle = YES;
            item7.checked = [SSCommonLogic isVideoAdCellDislikeEnabled];
            item7.switchAction = @selector(videoAdCellDislike:);
            
            STTableViewCellItem *item8 = [[STTableViewCellItem alloc] initWithTitle:@"视频详情页强化作者" target:self action:NULL];
            item8.switchStyle = YES;
            item8.checked = [SSCommonLogic isVideoDetailIntensifyAuthorEnabled];
            item8.switchAction = @selector(videoDetailIntensifyAuthor:);
            
            STTableViewCellItem *item9 = [[STTableViewCellItem alloc] initWithTitle:@"视频自动播放" target:self action:NULL];
            item9.switchStyle = YES;
            item9.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"video_auto_play_test"];
            item9.switchAction = @selector(videoAutoPlay:);
            
            STTableViewCellItem *item10 = [[STTableViewCellItem alloc] initWithTitle:@"新转屏测试提示" target:self action:NULL];
            item10.switchStyle = YES;
            item10.checked = [SSCommonLogic isRotateTipEnabled];
            item10.switchAction = @selector(videoNewRotateTip:);
            STTableViewCellItem *item11 = [[STTableViewCellItem alloc] initWithTitle:@"点播SDK" target:self action:NULL];
            item11.switchStyle = YES;
            item11.checked = [SSCommonLogic isNewPlayerEnabled];
            item11.switchAction = @selector(videoNewPlayer:);

            STTableViewCellItem *item12 = [[STTableViewCellItem alloc] initWithTitle:@"点播SDK提示" target:self action:NULL];
            item12.switchStyle = YES;
            item12.checked = [SSCommonLogic isNewPlayerTipEnabled];
            item12.switchAction = @selector(videoNewPlayerTip:);

            STTableViewSectionItem *section8 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"视频" items:@[item,item1, item3, item4, item5, item7, item8,item9,item10,item11,item12]];
            [dataSource addObject:section8];
        }
        
        if (YES) {
            STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"相关视频样式（0/1/2）" target:self action:nil];
            item1.textFieldStyle = YES;
            item1.textFieldAction = @selector(videoDetailRelatedStyleChange:);
            item1.textFieldContent = [NSString stringWithFormat:@"%ld", [SSCommonLogic videoDetailRelatedStyle]];
            STTableViewSectionItem *relatedVideoSection = [[STTableViewSectionItem alloc] initWithSectionTitle:@"相关视频" items:@[item1]];
            
            [dataSource addObject:relatedVideoSection];
        }
        
        if (YES) {
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"支持水印" target:self action:NULL];
            item.switchStyle = YES;
            item.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"_TTWaterMasterEnabled_"];
            item.switchAction = @selector(_waterMasterActionFired:);
            STTableViewSectionItem *section9 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"视频Cell水印开关" items:@[item]];
            [dataSource addObject:section9];
        }
        
        if (YES) {
            STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"私信长短链接切换策略（0/1/2）" target:self action:nil];
            item1.textFieldStyle = YES;
            item1.textFieldAction = @selector(_imCommunicateStrategy:);
            item1.textFieldContent = [NSString stringWithFormat:@"%ld", [SSCommonLogic imCommunicateStrategy]];
            STTableViewSectionItem *section10 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"私信" items:@[item1]];
            
            [dataSource addObject:section10];
        }

        if (YES) {
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:@"设置为新用户" target:self action:@selector(_newUserSettingActionFired)];
            STTableViewSectionItem *section11 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"新用户" items:@[item]];
            
            [dataSource addObject:section11];
        }
        
        if(YES){
            NSString *title;
            NSString *value;
            NSInteger count = 5;
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
            for (NSInteger i = 1 ; i <= count ; i++){
                title = [SSCommonLogic commonParameterNameWithIndex:i];
                value = [SSCommonLogic commonParameterValueWithIndex:i];
                STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:title target:self action:nil];
                item.textFieldStyle = YES;
                item.tag = i;
                item.textFieldAction = @selector(commonParameterHandle:);
                item.textFieldContent = value;
                [array addObject:item];
            }
            STTableViewSectionItem *section13 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"通用参数配置" items:array];
            [dataSource addObject:section13];
        }
        
        if (YES) {
            STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"贴片广告重播按钮开关" target:self action:NULL];
            item1.switchStyle = YES;
            item1.checked = [SSCommonLogic isVideoADReplayBtnEnabled];
            item1.switchAction = @selector(VideoADReplayBtnEnabledActionFired:);
            STTableViewSectionItem *sectionVideoAD = [[STTableViewSectionItem alloc] initWithSectionTitle:@"QA_video_AD" items:@[item1]];
            
            [dataSource addObject:sectionVideoAD];
        }
        if (YES) {
            STTableViewCellItem *item1 = [[STTableViewCellItem alloc] initWithTitle:@"跳转到详情gid" target:self action:nil];
            item1.textFieldStyle = YES;
            item1.textFieldAction = @selector(_goToDetail:);
            item1.textFieldContent = @"";
            
            STTableViewSectionItem *section13 = [[STTableViewSectionItem alloc] initWithSectionTitle:@"文章相关：" items:@[item1]];
            
            [dataSource addObject:section13];
        }
        //qabegin
        //qacontent
        //qafinish
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.dataSource = dataSource;
    }
    return self;
}

-(void)makeACrash {
    NSArray * array = [NSArray array];
    NSLog(@"array=%@", array[3]);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"高级调试";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(_cancelActionFired:)];
    [self _reloadRightBarItem];
    
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColorThemeKey = kColorBackground4;
    self.tableView.enableTTStyledSeparator = YES;
    self.tableView.separatorColorThemeKey = kColorLine1;
    self.tableView.separatorSecondColorThemeKey = kColorLine1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tapGestureForResignFirstResponder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResignFirstResponder)];
    _tapGestureForResignFirstResponder.numberOfTapsRequired = 1;
    self.tableView.userInteractionEnabled = YES;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[STTableViewCell class] forCellReuseIdentifier:@"Identifier"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    self.itemAB.checked = [ExploreCellHelper getFeedUGCTest];
    self.itemSourceImg.checked = [ExploreCellHelper getSourceImgTest];
    self.item01.checked = [DebugUmengIndicator displayUmengISOn];
    self.item10.checked = [self _shouldAutomaticallyChangeCity];
    TTPlacemarkItem *item = [TTLocationManager sharedManager].placemarks.firstObject;
    if (isEmptyString(item.city) && [TTLocationManager sharedManager].placemarks.count > 1) {
        item = [TTLocationManager sharedManager].placemarks[1];
    }
    if (!isEmptyString(item.city)) {
        self.section1.footerTitle = [NSString stringWithFormat:@"%@", item.address];
        self.item11.detail = item.city;
    } else {
        self.section1.footerTitle = nil;
        self.item11.detail = nil;
    }
    self.item41.checked = [[self class] supportTestImageSubject];
    self.itemFacebook.checked = [[self class] supportTestVideoFacebook];
    self.itemOwnPlayer.checked = [[self class] supportTestVideoOwnPlayer];
    [self.tableView reloadData];
}

- (void)_reloadRightBarItem {
    if ([TTLogServer logEnable]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设备信息" style:UIBarButtonItemStylePlain target:self action:@selector(_sendDeviceActionFired:)];
    }
}

- (void)_sendDeviceActionFired:(id)sender {
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"ArticleDeviceToken"];
    NSString *userId = [TTAccountManager userID];
    NSString *deviceId = [[TTInstallIDWrapperManager sharedManager] deviceID];
    NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithCapacity:2];
    [logs setValue:deviceToken forKey:@"deviceToken"];
    [logs setValue:userId forKey:@"userId"];
    [logs setValue:deviceId forKey:@"deviceId"];
    
    [TTLogServer sendValueToLogServer:logs parameters:@{@"font":@(16)}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_abActionFired:(UISwitch *)uiswitch {
    [ExploreCellHelper setFeedUGCTest:uiswitch.on];
}

- (void)_sourceImgActionFired:(UISwitch *)uiswitch {
    [ExploreCellHelper setSourceImgTest:uiswitch.on];
}

- (void)_userSelectActionFired:(UISwitch *)uiswitch {
    if (!uiswitch.on && [self _shouldAutomaticallyChangeCity]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
        [parameters setValue:[TTAccountManager userID] forKey:@"user_id"];
        [parameters setValue:[[TTInstallIDWrapperManager sharedManager] deviceID] forKey:@"device_id"];
        [[TTNetworkManager shareInstance] requestForJSONWithURL:@"http://ic.snssdk.com/location/rmlbsmhxzkhlinfo/" params:parameters method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
            if (!error) {
                [self _setShouldAutomaticallyChangeCity:uiswitch.on];
            }
        }];
    } else {
        [self _setShouldAutomaticallyChangeCity:uiswitch.on];
    }
    
}

- (void)testGuideSettingActionFired
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TTInterestGuideShowInfoKey"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TTPullRefreshGuideShowInfoKey"];
        STPersistence *persistence = [STPersistence persistenceNamed:@"TTGuideViewsCacheKey"];
        [persistence removeAllCachedValues];
        [TTFetchGuideSettingManager startFetchGuideConfigIfNeed];
    });
    UIAlertView * blockAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"接口10s之后请求" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [blockAlert show];
}

- (void)_setShouldSaveApplog:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kShouldSaveApplogKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_shouldSaveApplog {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kShouldSaveApplogKey"];
}

- (void)_setShouldUseRefactorTracker:(UISwitch *)uiswitch {
    [TTTrackerWrapper setRefactorTrackerEnable:uiswitch.isOn];
}

- (void)_logUmengActionFired:(UISwitch *)uiswitch {
    [DebugUmengIndicator setDisplayUmengIsOn:uiswitch.isOn];
    if(uiswitch.isOn) {
        [[DebugUmengIndicator sharedIndicator] startDisplay];
    } else {
        [[DebugUmengIndicator sharedIndicator] stopDisplay];
    }
    [self reloadData];
}

- (void)_openForumActionFired
{
    WDDebugViewController * controller = [WDDebugViewController wendaDebugViewController];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_openMessageNotificationActionFired:(UITextField *)textField
{
    NSString *testHost = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:testHost forKey:@"message_notification_test_host"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_openFlexActionFired
{
    //#ifdef DEBUG
    [[FLEXManager sharedManager] showExplorer];
    //#endif
}

-(void)_switchTo4G:(UISwitch *)uiswitch{
    [SSCommonLogic setIsNetWorkDebugEnable:uiswitch.isOn];
}

- (void)_switchToNewPullRefresh:(UISwitch *)uiswitch {
    [SSCommonLogic setNewPullRefreshEnabled:uiswitch.isOn];
}

- (void)_switchSharedWebView:(UISwitch *)uiswitch {
    [SSCommonLogic setDetailSharedWebViewEnabled:uiswitch.isOn];
}

- (void)_switchTransitionAnimation:(UISwitch *)uiswitch {
    [SSCommonLogic setTransitionAnimationEnable:uiswitch.isOn];
}

- (void)_switchForthTabHtsTab:(UISwitch *)uiswitch {
    [SSCommonLogic setForthTabHTSEnabled:uiswitch.isOn];
}

- (void)_switchLaunchHuoShanAppEnabled:(UISwitch *)uiswitch {
    [SSCommonLogic setLaunchHuoShanAppEnabled:uiswitch.isOn];
}

- (void)_switchImageTransitionAnimation:(UISwitch *)uiswitch {
    [SSCommonLogic setImageTransitionAnimationEnable:uiswitch.isOn];
}

- (void)_resetContactsActionFired {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"TTHasUploadedContactsFlagKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TTABAuthorizationManager setAuthorizationStatusForValue:kTTABAuthorizationStatusNotDetermined];

}

- (void)showConsole {
    [iConsole show];
}

- (void)_downloadCanvasRNBundle:(UITextField *)textField
{
    NSString *bundle_url = textField.text;
    [TTCanvasBundleManager sharedInstance].isDebug = YES;
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCanvasBundleVersionKey"];
    [TTCanvasBundleManager downloadIfNeeded:bundle_url version:@([localVersion integerValue] + 1).stringValue md5:@"anyone"];
    textField.backgroundColor = [UIColor greenColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        textField.backgroundColor = [UIColor yellowColor];
    });
}


- (void)_openNetworkStubActionFired
{
    Class class = NSClassFromString(@"TTNetworkStubSwitchViewController");
    if (class) {
        UIViewController *viewController = [[class alloc] init];
        viewController.title = @"请求本地数据";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)_openCallNativePhoneWebPage
{
    NSDictionary *params = @{@"url":@"http://ad.toutiao.com/tetris/page/6927396748/"};
    NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
    return;
}

- (void)_openHTSVideoDetail
{
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://huoshanvideo?video_id=6354295170023820546"]];
}

- (void)_connectLogServerActionFired {
    
    SSQRCodeScanViewController *viewController = SSQRCodeScanViewController.new;
    viewController.continueWhenScaned = YES;
    if (viewController) {
        viewController.scanCompletionHandler = ^(SSQRCodeScanViewController *vc, NSString *result, NSError *error) {
            NSURL *requestURL = [TTStringHelper URLWithURLString:result];
            if (requestURL.port.intValue > 10000) {
                // 打印Log的服务器               // ip:port/bytedance/log/track  ip:port/bytedance/close/
                if (requestURL.path.length > 0 && [requestURL.path rangeOfString:@"bytedance"].location != NSNotFound) {
                    NSString *title = nil;
                    if ([requestURL.path rangeOfString:@"close"].location != NSNotFound) {
                        // 断开连接
                        requestURL = nil;
                        title = @"已断开测试统计链接";
                    } else {
                        title = @"已连接到测试统计服务器";
                    }
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert showFrom:self animated:YES];
                    
                    if (requestURL) {
                        if ([TTTrackerWrapper refactorTrackerEnable]) {
                            [[TTTracker sharedInstance] setDebugLogServerAddress:result];
                        } else {
                            [TTLogServer setLogServerAddress:result];
                            [TTLogServer startAutoStartLogger];
                        }
                    } else {
                        [TTLogServer clearLogServer];
                    }
                    [vc dismissAnimated:YES];
                    [self _reloadRightBarItem];
                }
            } else {
                if (requestURL) {
                    [vc dismissAnimated:YES];
                    // 增加扫描到网页直接打开的功能
                    NSString *URLString = requestURL.absoluteString;
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"使用WebView打开链接？" message:URLString preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                        SSWebViewController *webViewController = [[SSWebViewController alloc] initWithSupportIPhoneRotate:NO];
                        webViewController.adID = @"97676901";
                        [webViewController requestWithURL:requestURL];
                        if (self.navigationController) {
                            [self.navigationController pushViewController:webViewController animated:YES];
                        } else {
                            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
                            navigationController.navigationBarHidden = YES;
                            [self presentViewController:navigationController animated:YES completion:NULL];
                        }
                    }];
                    [alert showFrom:self animated:YES];
                    
                }
            }
            
        };
        [self presentViewController:viewController animated:YES completion:NULL];
    }
}

- (void)_fakeUserLocationActionFired {
    SSLocationPickerController *pickerController = [[SSLocationPickerController alloc] init];
    [self.navigationController pushViewController:pickerController animated:YES];
    UIWindow *window = self.view.window;
    pickerController.completionHandler = ^(SSLocationPickerController *pickerViewController){
        // reverse 城市
        if ([SSLocationPickerController cachedFakeLocationCoordinate].longitude * [SSLocationPickerController cachedFakeLocationCoordinate].latitude > 0) {
            TTIndicatorView *indicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:nil indicatorImage:nil dismissHandler:nil];
            indicator.showDismissButton = NO;
            indicator.autoDismiss = NO;
            [indicator showFromParentView:window];
            [[TTLocationManager sharedManager] regeocodeWithCompletionHandler:^(NSArray *placemarks) {
                [self.tableView reloadData];
                [indicator dismissFromParentView];
                [pickerViewController.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [pickerViewController.navigationController popViewControllerAnimated:YES];
        }
    };
}

- (void)_testPingActionFired {
    SSDebugPingViewController *pingViewController = [[SSDebugPingViewController alloc] init];
    [self.navigationController pushViewController:pingViewController animated:YES];
}

- (void)_testTracerouteActionFired {
}

- (void)_testDNSActionFired {
    SSDebugDNSViewController *viewController = [[SSDebugDNSViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)_readUserDefaultsActionFired {
    SSDebugUserDefaultsViewController *userDefaults = [[SSDebugUserDefaultsViewController alloc] init];
    [self.navigationController pushViewController:userDefaults animated:YES];
}

- (void)_testImageSubjectActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setValue:@(uiswitch.isOn) forKey:@"TTTestImageSubject"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
    
}

- (void)_testVideoOwnPlayerActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setValue:@(uiswitch.isOn) forKey:@"video_own_player"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
}

- (void)_testVideoFacebookActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setValue:@(uiswitch.isOn) forKey:@"TTTestVideoFacebook"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadData];
}

- (void)_setShouldAutomaticallyChangeCity:(BOOL)shouldChange {
    [[NSUserDefaults standardUserDefaults] setBool:shouldChange forKey:@"kArticleCategoryManagerUserSelectedLocalCityKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)_shouldAutomaticallyChangeCity {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kArticleCategoryManagerUserSelectedLocalCityKey"];
}

- (BOOL)_shouldAllowWKWebView
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kWKWebViewSettingSwitchKey"];
}

- (BOOL)_shouldAllowHttps
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kHttpsSettingSwitchKey"];
}

- (NSInteger)_fontSizeForCellTitle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"cellTitleFontSize"];
}

- (NSInteger)_fontSizeForCellSubtitle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"cellSubtitleFontSize"];
}

#pragma mark - WKWebView switch setting

- (void)_wkwebviewSettingActionFired:(UISwitch *)uiswitch {
    if (uiswitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kWKWebViewSettingSwitchKey"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kWKWebViewSettingSwitchKey"];
    }
}

//#pragma mark - 详情页AB测 switch setting
//
//- (void)_detailViewABSettingActionFired:(UISwitch *)uiswitch {
//    [SSCommonLogic setDetailViewABEnabled:uiswitch.isOn];
//}

- (void)_taobaosdkActionFired:(UISwitch *)uiswitch{
    [SSCommonLogic setShouldUseALBBService:uiswitch.isOn];
}

- (void)_encryActionFired:(UISwitch *)uiswitch{
    [SSCommonLogic setUseEncrypt:uiswitch.isOn];
}

- (void)_posterADActionFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setPosterADClickEnabled:uiswitch.isOn];
}

- (void)picturesSlideOutActionFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setGallerySlideOutSwitch:@(uiswitch.isOn)];
}

- (void)_useLayOutForCellFired:(UISwitch *)uiswitch
{
    [SSCommonLogic setLayOutCellEnabled:uiswitch.isOn];
}

-(void)_crashActionFired{
    NSArray * array = [NSArray array];
    NSLog(@"array=%@", array[3]);
}

-(void)_fireSpalshAd {
    [[SSADManager class] performSelector:@selector(clearSSADRecentlyEnterBackgroundTime)];
    [[SSADManager class] performSelector:@selector(clearSSADRecentlyShowSplashTime)];
    [[SSADManager shareInstance] applicationDidBecomeActiveShowOnWindow:[UIApplication sharedApplication].keyWindow splashShowType:SSSplashADShowTypeShow];
}

- (void)_fireHTSABDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:[SSCommonLogic htsTabABActionDict]];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_read_comment"] forKey:@"op_read_comment"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_write_comment"] forKey:@"op_write_comment"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_reply_comment"] forKey:@"op_reply_comment"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_digg_video"] forKey:@"op_digg_video"];
    
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_digg_comment"] forKey:@"op_digg_comment"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_click_tips"] forKey:@"op_click_tips"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_follow"] forKey:@"op_follow"];
    [dict setValue:[self changeEnableWirhDict:dict key:@"op_go_profile"] forKey:@"op_go_profile"];
    
    [SSCommonLogic setHTSTabABActionDict:dict];
}

- (NSDictionary *)changeEnableWirhDict:(NSDictionary *)dict key:(NSString *)key
{
    NSDictionary *originalDict = [dict tt_dictionaryValueForKey:key];
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict addEntriesFromDictionary:originalDict];
    [mutDict setValue:@(![mutDict tt_boolValueForKey:@"enable"]) forKey:@"enable"];
    return [mutDict copy];
    
}

#pragma mark - 内存泄漏及UIKit多线程检测
- (void)_leakFinderAndMainThreadGuardActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"KTTMLeaksFinderEnableAlertKey"];
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.isOn forKey:@"kTTUIKitMainThreadGuardKey"];
}

#pragma mark - 应用内存使用量监测
- (void)_appMemoryMonitorActionFired:(UISwitch *)uiswitch {
    [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"kTTAppMemoryMonitorKey"];
    
    if (uiswitch.isOn) {
        [TTMemoryMonitor showMemoryMonitor];
    }
    else {
        [TTMemoryMonitor hideMemoryMonitor];
    }
}

#pragma mark - 截图分享
- (void)screenshotShare{
    [[NSNotificationCenter defaultCenter]postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

#pragma mark - Https switch setting

- (void)_httpsSettingActionFired:(UISwitch *)uiswitch {
    if (uiswitch.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHttpsSettingSwitchKey"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kHttpsSettingSwitchKey"];
    }
}

#pragma mark - 视频多清晰度setting
- (void)_multiResolutionActionFired:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setMultiResolutionEnable:YES];
    } else {
        [SSCommonLogic setMultiResolutionEnable:NO];
    }
}

- (void)feedUrlOpen:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoFeedURLEnabled:YES];
    } else {
        [SSCommonLogic setVideoFeedURLEnabled:NO];
    }
}

- (void)videoProportion:(UISwitch *)uiswich
{
    if (uiswich.isOn) {
        [SSCommonLogic setTTVideoProportionControlEnable:YES];
    } else {
        [SSCommonLogic setTTVideoProportionControlEnable:NO];
    }
}

- (void)videoNewRotateTip:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [SSCommonLogic setVideoNewRotateTipEnabled:YES];
    } else {
        [SSCommonLogic setVideoNewRotateTipEnabled:NO];
    }
}

- (void)videoNewPlayerTip:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [SSCommonLogic setNewPlayerTipEnabled:YES];
    } else {
        [SSCommonLogic setNewPlayerTipEnabled:NO];
    }
}

- (void)videoNewPlayer:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [SSCommonLogic setNewPlayerEnabled:YES];
    } else {
        [SSCommonLogic setNewPlayerEnabled:NO];
    }
}

- (void)videoNewRotate:(UISwitch *)uiswich
{
    if (uiswich.on) {
        [SSCommonLogic setVideoNewRotateEnabled:YES];
    } else {
        [SSCommonLogic setVideoNewRotateEnabled:NO];
    }
}

- (void)videoAdCellDislike:(UISwitch *)uiswitch
{
    [SSCommonLogic setVideoAdCellDislikeEnabled:uiswitch.on];
}

- (void)videoDetailIntensifyAuthor:(UISwitch *)uiswitch
{
    [SSCommonLogic setVideoDetailIntensifyAuthorEnabled:uiswitch.on];
}

- (void)videoAutoPlay:(UISwitch *)uiswitch
{
    return [[NSUserDefaults standardUserDefaults] setBool:uiswitch.on forKey:@"video_auto_play_test"];
}

- (void)videoCellShowShareButton:(UISwitch *)uiswitch
{
    [SSCommonLogic setVideoCellShowShareEnabled:uiswitch.on];
}

- (void)VideoADReplayBtnEnabledActionFired:(UISwitch *)uiswitch
{
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoADReplayBtnEnabled:YES];
    }
    else {
        [SSCommonLogic setVideoADReplayBtnEnabled:NO];
    }
}

- (void)videoDetailPlayLastBtnEnableActionFired:(UISwitch *)uiswitch {
    
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoDetailPlayLastEnabled:YES];
    }
    else {
        [SSCommonLogic setVideoDetailPlayLastEnabled:NO];
    }
}

- (void)videoDetailPlayLastShowTextActionFired:(UISwitch *)uiswitch {
    
    if (uiswitch.isOn) {
        [SSCommonLogic setVideoDetailPlayLastShowText:YES];
    }
    else {
        [SSCommonLogic setVideoDetailPlayLastShowText:NO];
    }
}

- (void)videoDetailRelatedStyleChange:(UITextField *)field{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        [SSCommonLogic setVideoDetailRelatedStyle:[result integerValue]];
    }
}

//qaswitchmanage
#pragma mark - 使用水印开关
- (void)_waterMasterActionFired:(UISwitch *)uiswtich
{
    if (uiswtich.isOn) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"_TTWaterMasterEnabled_"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"_TTWaterMasterEnabled_"];
    }
}

#pragma mark - TTUniversalCommentCell使用缓存布局开关
- (void)cacheTTUniversalCommentCell:(UISwitch *)uiswitch {
    [SSCommonLogic enableTTUniversalCommentCache:uiswitch.isOn];
}

#pragma mark - 私信相关
- (void)_imCommunicateStrategy:(UITextField *)field{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *result = [formatter numberFromString:field.text];
    if (result) {
        [SSCommonLogic setimCommunicateStrategy:[result integerValue]];
    }
    NSLog(@"set imCommunicateStrategy:%@",field.text);
}

- (void)commonParameterHandle:(UITextField *)field
{
    NSString *content = field.text;
    if (isEmptyString(content)){
        return;
    }
    [SSCommonLogic setCommonParameterWithValue:content index:field.tag];
}

#pragma mark - 文章相关
- (void)_goToDetail:(UITextField *)field
{
    if (isEmptyString(field.text)) {
        return;
    }
    NSString *url = [@"sslocal://detail?group_id=" stringByAppendingString:field.text];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
    }];
}

#pragma mark - 模拟新用户开关
- (void)_newUserSettingActionFired{
    [ExploreLogicSetting setIsUpgradeUser:NO];
    //目前模拟新用户的方式只针对新用户刷新引导的需求有效
    [self clearUserCachedData];
}

- (void)clearUserCachedData{
    [[NSUserDefaults standardUserDefaults] setDouble:0 forKey:@"kVideoTipLastShowDateKey"];
    [TTVideoTip setHasShownVideoTip:NO];
    [TTVideoTip setCanShowVideoTip:NO];
}

#pragma mark - 重置观看视频次数
- (void)resetUserWatchVideo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kVideoTipCanShowKey];
    [defaults setDouble:0 forKey:kVideoTipLastShowDateKey];
    [defaults setBool:NO forKey:@"kVideoTipHasShownKey"];
    [defaults synchronize];
}

#pragma mark - textFieldResignFirstResponder
- (void)textFieldResignFirstResponder{
    UIResponder *responder = [self.view findFirstResponder];
    if ([responder isKindOfClass:[SSThemedTextField class]]) {
        [responder resignFirstResponder];
        
    }
}

#pragma mark - keyboard show or hide

- (void)keyboardWillShow:(NSNotification *)notification {
    [self.tableView addGestureRecognizer:_tapGestureForResignFirstResponder];
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGSize  newTableViewContentSize = self.tableView.contentSize;
    newTableViewContentSize.height += keyboardHeight;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setContentSize:newTableViewContentSize];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + keyboardHeight)];
    [UIView commitAnimations];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView removeGestureRecognizer:_tapGestureForResignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearCacheHeightNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingFontSizeChangedAheadNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingFontSizeChangedNotification object:self];
    NSDictionary* userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGSize  oldTableViewContentSize = self.tableView.contentSize;
    oldTableViewContentSize.height -= keyboardHeight;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setContentSize:oldTableViewContentSize];
    [UIView commitAnimations];
}
#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.headerTitle;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.footerTitle;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STTableViewCell *tableViewCell = (STTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    STTableViewSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    STTableViewCellItem *item = sectionItem.items[indexPath.row];
    if ([item isKindOfClass:[STTableViewCellItem class]]) {
        tableViewCell.tableView = (SSThemedTableView *)tableView;
        tableViewCell.cellIndex = indexPath;
        tableViewCell.textLabel.text = item.title;
        tableViewCell.textLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        tableViewCell.textLabel.backgroundColor = [UIColor clearColor];
        tableViewCell.detailTextLabel.text = item.detail;
        tableViewCell.detailTextLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
        tableViewCell.detailTextLabel.backgroundColor = [UIColor clearColor];
        if ([tableViewCell isKindOfClass:[STTableViewCell class]]) {
            tableViewCell.cellItem = item;
        }
    } else {
        tableViewCell.textLabel.text = @"配置出现问题";
    }
    return tableViewCell;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    UILabel * textLabel = ((UITableViewHeaderFooterView * )view).textLabel;
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        textLabel.text = sectionItem.headerTitle;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    UILabel * textLabel = ((UITableViewHeaderFooterView * )view).textLabel;
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        textLabel.text = sectionItem.footerTitle;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    STTableViewCellItem * item = sectionItem.items[indexPath.row];
    if ([item isKindOfClass:[STTableViewCellItem class]] && [item.target respondsToSelector:item.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.target performSelector:item.action];
#pragma clang diagnostic pop
    }
}

- (void)_cancelActionFired:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

+ (BOOL)supportTestImageSubject {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TTTestImageSubject"];
}

+ (BOOL)supportTestVideoFacebook {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"TTTestVideoFacebook"];
}

+ (BOOL)supportTestVideoOwnPlayer {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_own_player"];
}

+ (BOOL)supportWKWebView {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kWKWebViewSettingSwitchKey"];
}

+ (BOOL)supportHttps {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kHttpsSettingSwitchKey"];
}

static SSDebugItems _supportedItems = SSDebugItemController;
+ (BOOL)supportDebugItem:(SSDebugItems)debugItem {
#if INHOUSE
    NSString *channel = [TTSandBoxHelper getCurrentChannel];
    if ([channel isEqualToString:@"local_test"] || [channel isEqualToString:@"dev"]) {
        return _supportedItems & debugItem;
    }
#endif
    return NO;
}

static SSDebugSubitems _suppertedSubitems = SSDebugSubitemAll;
+ (BOOL)supportDebugSubitem:(SSDebugSubitems)debugItem {
#if INHOUSE
    NSString *channel = [TTSandBoxHelper getCurrentChannel];
    if ([[[TTSandBoxHelper bundleIdentifier] lowercaseString] rangeOfString:@"inhouse"].location != NSNotFound || [channel isEqualToString:@"local_test"] || [channel isEqualToString:@"dev"]) {
        return _suppertedSubitems & debugItem;
    }
#endif
    return NO;
}

@end


#if TARGET_OS_SIMULATOR
//#ifdef DEBUG
#import <FLEX/FLEXManager.h>
#import "ExploreCellHelper.h"

#import "TTStringHelper.h"
@implementation SSDebugViewController (DebugThemedChanged)

+(void) load
{
    void (^notiBlock)(void) = ^{
        
        TTThemeMode mode = [[TTThemeManager sharedInstance_tt] currentThemeMode];
        mode = (mode == TTThemeModeDay) ? TTThemeModeNight : TTThemeModeDay;
        [[TTThemeManager sharedInstance_tt] switchThemeModeto:mode];
    };
    
    [[FLEXManager sharedManager] registerSimulatorShortcutWithKey:@"t" modifiers:0 action:notiBlock description:@"Post Themed Change Notification"];
    
}

@end
//#endif
#endif
