//
//  HMDSRWTESTEnvironment.m
//  Heimdallr_Example
//
//  Created by HuaQ on 2019/4/23.
//  Copyright © 2019 HuaQ All rights reserved.
//

// -----------------------------



#pragma mark - 配置 Settings

//#define Launch_simbol       // 需要 Heimdallr 引导图标
//
//#define Heimdallr_inspect   // 强制启动 Heimdallr 事件监控



// -----------------------------

#include <stdatomic.h>
#include <math.h>
#include <mach/task.h>
#include <mach/mach_init.h>
#include <mach/mach_port.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <float.h>
#include <sys/time.h>
#include <pthread.h>
#include <limits.h>
#include <signal.h>
#import <UIKit/UIKit.h>
#include <sys/time.h>
#import "HMDSRWTESTEnvironment.h"
//#import <TTBaseLib/UIAlertController+TTAdditions.h>

#import "UIAlertController+TTAdditions.h"

#if __has_include("CADynamicCall.h")
#import "CADynamicCall.h"
#elif __has_include("HMDDynamicCall.h")
#import "HMDDynamicCall.h"
#else
#error DynamicCall is needed
#endif

#ifndef MICROSEC_PER_SEC
#define MICROSEC_PER_SEC 1000000ul
#endif

#ifndef MILLISEC_PER_SEC
#define MILLISEC_PER_SEC 1000ul
#endif

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000ull
#endif

#ifndef DEBUG_ELSE
#ifdef DEBUG
#define DEBUG_ELSE else __builtin_trap();
#else
#define DEBUG_ELSE
#endif
#endif

#ifndef DEBUG_POINT
#ifdef DEBUG
#define DEBUG_POINT __builtin_trap();
#else
#define DEBUG_POINT
#endif
#endif

#ifndef DEBUG_ASSERT
#ifdef DEBUG
#define DEBUG_ASSERT(x) if(!(x)) DEBUG_POINT
#else
#define DEBUG_ASSERT(x)
#endif
#endif

#define HMDSRW_FPS_TEST_AVERAGE_LENTH 5
#define HMDSRW_HTTP_DISPLAY_WIDTH 128

#define OFFSET_OBJECT(object, offset) ((void *)(((char *)(__bridge void *)(object)) + (offset)))

#define DynamicUpdatedWithoutActionSubfix "(动态)"
#define SelfUpdateContentSubfix "(更新)"

#ifndef CA_Stringlization
#define CA_Stringlization(x) CA_Stringlization_Internal(x)
#define CA_Stringlization_Internal(x) #x
#endif

#ifndef CA_STICK
#define CA_STICK(x, y) CA_STICK_Internal(x, y)
#define CA_STICK_Internal(x, y) x##y
#endif

#define SECTION_ERROR   0
#define SECTION_STRING  1
#define SECTION_NUMBER  2
#define SECTION_CONTROL 3

#define HMDSRW_HeimdallrView_fixed_width 40
#define HMDSRW_HeimdallrView_inside 3

#define HMDSRW_TEST_COULD_LOCATE_ESSENTIAL 0.8
#define HMDSRW_TEST_ENSSENTIAL_CHILD_VC_PERCENTAGE 0.8
#define HMDSRW_TEST_ENSSENTIAL_CHILD_NOT_TORLERANCE_OTHER_PERCENTAGE 0.35

#define CONSOLE_UPADTE_DELAY 5.0
#define CONSOLE_COLOR_BACKGROUND [UIColor colorForHex:@"f0f0f4"]
#define CONSOLE_COLOR_DATABASE ([UIColor colorForHex:@"b3b3b3"])
#define CONSOLE_COLOR_MODULE_DETECT ([UIColor colorForHex:@"C1194E"])
#define CONSOLE_COLOR_MODULE_LIFE ([UIColor colorForHex:@"4c8dae"])
#define CONSOLE_COLOR_DEFAULT [UIColor colorForHex:@"1685a9"]
#define CONSOLE_COLOR_UPLOAD_REPORTER [UIColor colorForHex:@"6b6882"]
#define CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD [UIColor colorForHex:@"21a675"]
#define CONSOLE_COLOR_UPLOAD_MODULE_CLEANUP [UIColor colorForHex:@"c89b40"]
#define CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL [UIColor colorForHex:@"92d3cf"]
#define CONSOLE_COLOR_UIACTION [UIColor colorForHex:@"7E884F"]
#define CONSOLE_COLOR_NETWORK [UIColor colorForHex:@"75878a"]

#define CA_mockClassTreeForClassMethod(class, sel, impBlock)                   \
({                                                                             \
    Class aClass = objc_getClass(CA_Stringlization(class));                    \
    SEL real_sel = sel_registerName(CA_Stringlization(sel));                   \
    SEL moke_sel = sel_registerName(CA_Stringlization(CA_STICK(MOKE_, sel)));  \
    ca_mockClassTreeForClassMethod(aClass, real_sel, moke_sel, (impBlock));    \
})

#define CA_mockClassTreeForInstanceMethod(class, sel, impBlock)                \
({                                                                             \
    Class aClass = objc_getClass(CA_Stringlization(class));                    \
    SEL real_sel = sel_registerName(CA_Stringlization(sel));                   \
    SEL moke_sel = sel_registerName(CA_Stringlization(CA_STICK(MOKE_, sel)));  \
    ca_mockClassTreeForInstanceMethod(aClass, real_sel, moke_sel, (impBlock)); \
})

#define CA_mockClassLeavesForClassMethod(class, sel, impBlock)                 \
({                                                                             \
    Class aClass = objc_getClass(CA_Stringlization(class));                    \
    SEL real_sel = sel_registerName(CA_Stringlization(sel));                   \
    SEL moke_sel = sel_registerName(CA_Stringlization(CA_STICK(MOKE_, sel)));  \
    ca_mockClassLeavesForClassMethod(aClass, real_sel, moke_sel, (impBlock));  \
})

#define CA_mockClassLeavesForInstanceMethod(class, sel, impBlock)               \
({                                                                              \
    Class aClass = objc_getClass(CA_Stringlization(class));                     \
    SEL real_sel = sel_registerName(CA_Stringlization(sel));                    \
    SEL moke_sel = sel_registerName(CA_Stringlization(CA_STICK(MOKE_, sel)));   \
    ca_mockClassLeavesForInstanceMethod(aClass, real_sel, moke_sel, (impBlock));\
})

#define SECTION(section)                                                       \
({                                                                             \
    int result = SECTION_ERROR;                                                \
    if(_stringSettings.count > 0 && _numberSettings.count > 0) {               \
        if(section == 0) result = SECTION_STRING;                              \
        else if(section == 1) result = SECTION_NUMBER;                         \
        else if(section == 2) result = SECTION_CONTROL;                        \
    }                                                                          \
    else if(_stringSettings.count != 0) {                                      \
        if(section == 0) result = SECTION_STRING;                              \
        else if(section == 1) result = SECTION_CONTROL;                        \
    }                                                                          \
    else if(_numberSettings.count != 0) {                                      \
        if(section == 0) result = SECTION_NUMBER;                              \
        else if(section == 1) result = SECTION_CONTROL;                        \
    }                                                                          \
    result;                                                                    \
})

@class HMDSRWSetting;

typedef enum : NSUInteger {
    UIViewCoverageRelationshipError = - 1,
    UIViewCoverageRelationshipAbove = 0,
    UIViewCoverageRelationshipEqual = 1,
    UIViewCoverageRelationshipBelow = 2,
} UIViewCoverageRelationship;

typedef enum : NSUInteger {
    HMDSRWSettingTypeString,
    HMDSRWSettingTypeNumber
} HMDSRWSettingType;

typedef void (^HMDSRWTESTEnvironmentAction)(void);

typedef void (^HMDSRWExpectedSettingAction)(HMDSRWSetting *setting);

static BOOL shouldShowInformation = YES;
static BOOL hasSwizzledTTMacroManager = NO;
static BOOL hasSwizzledSimpleBackgroundTask = NO;
static BOOL hasSwizzledHMDHeimdallrConfig = NO;
static BOOL isCurrentDEBUG = NO;
static BOOL hasPermittedFreeRotation = NO;
static CADisplayLink *FPS_Control_DisplayLink;
static CADisplayLink *FPS_Test_DisplayLink;
static NSUInteger current_FPS = 60;
static NSUInteger current_FPS_level = 60;
static NSMutableArray<NSValue *> *currentAllocation;
static BOOL hasForceOpenAllModules = NO;
static BOOL needUpdateValueWhenTimerCallback = NO;
static BOOL onceDiskCellHasBeenTouched = NO;
static CFTimeInterval averageArray[HMDSRW_FPS_TEST_AVERAGE_LENTH];
static NSString * const kHMDSRWTestEnvironmentLanchStuckKey = @"HMDSRWTestEnvironmentLanchStuckKey";
static NSString * const kHMDSRW_HOOK_Heimdallr = @"HMDSRW_HOOK_Heimdallr";
static NSString * const kHMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey = @"HMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey";
static NSUInteger logMultiplex = 1;
static BOOL protector_enable_logMultiplex = NO;
static BOOL exceptionReportOnceTocken = NO;
static BOOL testENV_onceToken = NO;
static BOOL enable_callBack = NO;
static BOOL hasDisplayed_vc_finder = NO;
static UIWindow *vc_finder_window = nil;
static UITextView *vc_finder_textview = nil;
static NSString *vc_finder_didAppear = nil;
static NSUInteger total_find_vc_amount = 0;
static CFTimeInterval current_find_time = 0;
static CFTimeInterval total_find_vc_time = 0;
static BOOL hasHookedHeimdallr_thisTime = NO;
static BOOL hasLaunchedSimbol_thiTime = NO;
static BOOL hasOnceOpenFPS = NO;
static BOOL HMDSRW_floatingVC_didApear_onceToken = NO;

static NSString * const kHMD_WatchDog_exposedData_isLaunchCrashKey = @"HMD_WatchDog_exposedData_isLaunchCrash";
static NSString * const kHMD_WatchDog_exposedData_isBackgroundKey = @"HMD_WatchDog_exposedData_isBackground";
static NSString * const kHMD_WatchDog_exposedData_connectTypeNameKey = @"HMD_WatchDog_exposedData_connectTypeName";
static NSString * const kHMD_WatchDog_exposedData_backtraceKey = @"HMD_WatchDog_exposedData_backtrace";
static NSString * const kHMD_WatchDog_exposedData_internalSessionIDKey = @"HMD_WatchDog_exposedData_internalSessionID";
static NSString * const kHMD_WatchDog_exposedData_timeoutDurationKey = @"HMD_WatchDog_exposedData_timeoutDuration";
static NSString * const kHMD_WatchDog_exposedData_memoryUsageKey = @"HMD_WatchDog_exposedData_memoryUsage";
static NSString * const kHMD_WatchDog_exposedData_freeMemoryUsageKey = @"HMD_WatchDog_exposedData_freeMemoryUsage";
static NSString * const kHMD_WatchDog_exposedData_freeDiskUsageKey = @"HMD_WatchDog_exposedData_freeDiskUsage";
static NSString * const kHMD_WatchDog_exposedData_lastSceneKey = @"HMD_WatchDog_exposedData_lastScene";
static NSString * const kHMD_WatchDog_exposedData_sessionIDKey = @"HMD_WatchDog_exposedData_sessionID";
static NSString * const kHMD_WatchDog_exposedData_timeStampKey = @"HMD_WatchDog_exposedData_timeStamp";
static NSString * const kHMD_WatchDog_exposedData_inAppTimeKey = @"HMD_WatchDog_exposedData_inAppTime";

static _Nullable Method ca_classHasInstanceMethod(Class _Nullable aClass,
                                                  SEL _Nonnull selector);

static _Nullable Method ca_classHasClassMethod(Class _Nullable aClass,
                                               SEL _Nonnull selector);

static void ca_swizzle_instance_method(Class _Nullable aClass,
                                       SEL _Nonnull selector1,
                                       SEL _Nonnull selector2);

static void ca_swizzle_class_method(Class _Nullable aClass,
                                    SEL _Nonnull selector1,
                                    SEL _Nonnull selector2);

static void ca_insert_and_swizzle_instance_method
(Class _Nullable originalClass, SEL _Nonnull originalSelector,
 Class _Nullable   targetClass, SEL _Nonnull   targetSelector);

static Class _Nonnull * _Nullable objc_getSubclasses(Class _Nullable aClass,
                                                     size_t * _Nonnull num);

static Class _Nonnull * _Nullable objc_getAllSubclasses(Class _Nullable aClass,
                                                        size_t * _Nonnull num);


static void ca_mockClassTreeForInstanceMethod(Class _Nullable aClass,
                                              SEL _Nonnull originSEL,
                                              SEL _Nonnull mockSEL,
                                              id _Nonnull impBlock);

static void ca_mockClassTreeForClassMethod(Class _Nullable aClass,
                                           SEL _Nonnull originSEL,
                                           SEL _Nonnull mockSEL,
                                           id _Nonnull impBlock);

static _Nullable Method ca_classSearchInstanceMethodUntilClass(Class _Nullable aClass,
                                                               SEL _Nonnull selector,
                                                               Class _Nullable untilClassExcluded);

static _Nullable Method ca_classSearchClassMethodUntilClass(Class _Nullable aClass,
                                                            SEL _Nonnull selector,
                                                            Class _Nullable untilClassExcluded);

static void ca_mockClassLeavesForInstanceMethod(Class _Nullable aClass,
                                                SEL _Nonnull originSEL,
                                                SEL _Nonnull mockSEL,
                                                id _Nonnull impBlock);

static void ca_mockClassLeavesForClassMethod(Class _Nullable aClass,
                                             SEL _Nonnull originSEL,
                                             SEL _Nonnull mockSEL,
                                             id _Nonnull impBlock);

static __kindof UIViewController * _Nonnull CA_topMostPresentedVC(void);

static __kindof UIViewController * _Nonnull CA_locateEssentialChildVC(__kindof UIViewController * _Nonnull parentVC);

static CGRect CGRectContainRect(CGRect outside, CGRect inside);

static CGRect CGRectCombine(CGRect one, CGRect another);

static UIViewCoverageRelationship UIViewGetCoverageRelationship(__kindof UIView *view1, __kindof UIView *view2);

static __kindof UIViewController * _Nonnull CA_testVCFinder(__kindof UIViewController *rootVC);

static CFTimeInterval CAXNUSystemCall_timeSince1970(void);

@interface KVO_DEALLOC_TEST : UIView
- (instancetype)initWithTest:(KVO_DEALLOC_TEST *)aTest;
@end
@interface KVO_SELF_DEALLOC_TEST : UIView
- (instancetype)initWithTest:(KVO_SELF_DEALLOC_TEST *)aTest;
@end
@interface NSThread (HMD_BLOCK_THREAD)
+ (void)HMD_detachNewThreadWithBlock:(void (^)(void))block;
@end

@interface UIViewController (HMD_SRW_TEST)
- (void)MOKE_viewDidAppear:(BOOL)animated;
@end

@interface HMDSRWTEST_POPUP_DISPLAY: UIViewController
- (instancetype)initWithOneClickAction:(HMDSRWTESTEnvironmentAction)oneClickAction
                          doubleAction:(HMDSRWTESTEnvironmentAction)doubleAction
                       longPressAction:(HMDSRWTESTEnvironmentAction)longPressAction;
@end

@interface HMDSRWSettingViewController: UITableViewController

- (instancetype)initWithSettings:(NSArray<HMDSRWSetting *> *)settings;

@end

@interface HMDSRWSetting : NSObject

@property(nonatomic, readonly) HMDSRWSettingType type;

@property(nonatomic, readonly, nonnull) NSString *name;

@property(nonatomic, readwrite) NSNumber *number;

@property(nonatomic, readwrite) NSString *string;

- (instancetype)initWithType:(HMDSRWSettingType)type name:(NSString *)name action:(HMDSRWExpectedSettingAction)action;

- (void)invokeAction;

@end

@interface UIView (Coordination)

@property(nonatomic) CGPoint origin;

@property(nonatomic) CGSize size;

@property(nonatomic) CGFloat width;

@property(nonatomic) CGFloat height;

- (NSArray<NSLayoutConstraint *> *)constraintEqualToView:(UIView *)view;

- (NSArray<NSLayoutConstraint *> *)constraintAtTopEqualWidthFixedHight:(UIView *)scrollView internalSpace:(CGFloat)internalSpace;

- (NSArray<NSLayoutConstraint *> *)constraintBelowViewFixedHight:(UIView *)formerView internalSpace:(CGFloat)internalSpace;

- (void)setSize:(CGSize)size center:(CGPoint)center;

@end

@interface HMDSRWSettingCell : UITableViewCell

@end

@interface HMDSRWSettingInputViewController : UITableViewController

- (instancetype)initWithSetting:(HMDSRWSetting *)setting;

@end

@interface HMDSRWTEST_POPUP_DISPLAY_VIEW : UIView

@end

@interface HMDSRWTEST_KVO_POX : NSObject

@property(class, readonly, atomic) __kindof HMDSRWTEST_KVO_POX *shared;

@end

@interface HMDSRW_ConsoleViewController: UITableViewController

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *standardConsole;

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *databaseConsole;

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *moduleConsole;

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *uploadConsole;

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *UIActionConsole;

@property(class, readonly, nonnull) HMDSRW_ConsoleViewController *networkConsole;

+ (void)log:(NSString *)info;

+ (void)log:(NSString *)info color:(UIColor *)color;

+ (void)flush;

- (void)log:(NSString *)info;

- (void)log:(NSString *)info color:(UIColor *)color;

- (void)flush;

@end

@interface UIColor (Designer)

+ (instancetype)colorForHex:(NSString *)hex;

@end

@interface HMDSRW_floatingWindow : UIWindow

@property(class, readonly, nonnull) HMDSRW_floatingWindow *standard;

@end

@interface HMDSRW_floatingVC : UIViewController

@property(class, readonly, nonnull) HMDSRW_floatingVC *standard;

@property(readonly) BOOL presented;

@end

@interface HMDSRW_HeimdallrView : UIView

@property(class, readonly, nonnull) HMDSRW_HeimdallrView *standard;

@end

@interface HMDSRW_NOT_TOUCH_WINDOW : UIWindow

@end

@interface HMDSRWTESTEnvironment ()

@end

@implementation HMDSRWTESTEnvironment {
    NSDictionary<NSString *, HMDSRWTESTEnvironmentAction> *_testActionDictionary;
    NSArray<NSString *> *_sessionNameArray;
    NSArray<NSArray<NSString *> *> *_cellNamesInSessionsArray;
    UINavigationItem * _navigationItem;
    NSTimer *_timer;
    NSDictionary<NSString *, NSIndexPath *> *_dynamicCells;
    BOOL _hasCheckedDynamicCells;
    NSDictionary<NSString *, NSIndexPath *> *_selfUpdateCells;
    BOOL _hasCheckedSelfUpdateCells;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    style = UITableViewStyleGrouped;
    return [super initWithStyle:style];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsMultipleSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"standardCell"];
}

- (void)dealloc {
    if(_timer) [_timer invalidate];
}

#pragma mark - Display callback

+ (void)showInformationTitle:(NSString * _Nullable)title message:(NSString * _Nullable)message {
    if(shouldShowInformation) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray<NSString *> *testSessionName = [self testSessionName];
    return testSessionName.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray<NSArray<NSString *> *> *cellNamesInSessions = [self cellNamesInSessions];
    if(section < cellNamesInSessions.count)
        return cellNamesInSessions[section].count;
    DEBUG_ELSE
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"standardCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sessionIndex = indexPath.section;
    NSUInteger rowIndex = indexPath.row;
    NSArray<NSString *> *testSessionName = [self testSessionName];
    NSArray<NSArray<NSString *> *> *cellNamesInSessions = [self cellNamesInSessions];
    if(sessionIndex < testSessionName.count && rowIndex < cellNamesInSessions[sessionIndex].count) {
        NSString *cellName = cellNamesInSessions[sessionIndex][rowIndex];
        if([cellName containsString:[NSString stringWithUTF8String:DynamicUpdatedWithoutActionSubfix]]) {
            NSString *dynamicCellName = [self queryDynamicCellNameForRawName:cellName];
            cell.textLabel.text = dynamicCellName;
        }
        else if([cellName containsString:[NSString stringWithUTF8String:SelfUpdateContentSubfix]]) {
            NSString *selfUpdateCellName = [self querySelfUpdateNameForRawName:cellName];
            cell.textLabel.text = selfUpdateCellName;
        }
        else cell.textLabel.text = cellName;
        cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    DEBUG_ELSE
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray<NSString *> *testSessionName = [self testSessionName];
    if(section < testSessionName.count) {
        return testSessionName[section];
    }
    DEBUG_ELSE
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSArray<NSString *> *testSessionName = [self testSessionName];
    if(section < testSessionName.count) {
        return [NSString stringWithFormat:@"End of %@", testSessionName[section]];
    }
    DEBUG_ELSE
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger sessionIndex = indexPath.section;
    NSUInteger rowIndex = indexPath.row;
    NSArray<NSArray<NSString *> *> *cellNamesInSessions = [self cellNamesInSessions];
    NSDictionary<NSString *, HMDSRWTESTEnvironmentAction> *testActions = [self testActions];
    NSString *cellName;
    HMDSRWTESTEnvironmentAction action;
    if(sessionIndex < cellNamesInSessions.count &&
       rowIndex < cellNamesInSessions[sessionIndex].count &&
       (cellName = cellNamesInSessions[sessionIndex][rowIndex]) != nil) {
        if(![cellName containsString:[NSString stringWithUTF8String:DynamicUpdatedWithoutActionSubfix]]) {
            if((action = [testActions objectForKey:cellName]) != nil)
                action();
            DEBUG_ELSE
        }
    }
    DEBUG_ELSE
}

#pragma mark - Dynamic Cell loading

- (NSString *)queryDynamicCellNameForRawName:(NSString *)rawName {
    NSString *result = nil;
    if([rawName isEqualToString:@"CPU" DynamicUpdatedWithoutActionSubfix]) {
        id monitor = DC_CL(HMDCPUMonitor, sharedMonitor);
        id record = DC_OB(monitor, refresh);
        NSNumber *usage = DC_OB(record, appUsage);
        double cpu = [usage doubleValue];
        if(isnan(cpu)) cpu = 0.0;
        result = [NSString stringWithFormat:@"CPU: %.1f%%", cpu * 100];
    }
    else if([rawName isEqualToString:@"MEMORY" DynamicUpdatedWithoutActionSubfix]) {
        id monitor = DC_CL(HMDMemoryMonitor, sharedMonitor);
        id record = DC_OB(monitor, refresh);
        NSNumber *usage = DC_OB(record, appUsedMemory);
        double memory = [usage doubleValue];
        double mb_momory = memory / (1024 * 1024);
        result = [NSString stringWithFormat:@"内存: %.2f MB", mb_momory];
    }
    else if([rawName isEqualToString:@"FPS" DynamicUpdatedWithoutActionSubfix]) {
        if(FPS_Test_DisplayLink == nil) {
            result = @"FPS 尚未开始测定";
        }
        else result = [NSString stringWithFormat:@"FPS: %lu", lround(current_FPS)];
    }
    DEBUG_ASSERT(result != nil);
    return result;
}

- (NSString *)querySelfUpdateNameForRawName:(NSString *)rawName {
    NSString *result;
    if([rawName isEqualToString:@"DISK" SelfUpdateContentSubfix]) {
        id diskUsage =
        DC_OB(DC_CL(HMDDiskUsage, alloc), initWithOutdatedDays:abnormalFolderSize:abnormalFolderFileNumber:ignoreRelativePathes:checkSparseFile:sparseFileLeastDifferPercentage:sparseFileLeastDifferSize:visitors:, 10.0, 1234l, 4321l, @[], NO, 0.2, 666l, @[]);
        NSNumber *appSpace = DC_OB(diskUsage, appSpace);
        long long bytes = appSpace.longLongValue;
        if(bytes < 1024)
            result = [NSString stringWithFormat:@"APP磁盘占用: %lld B", bytes];
        else if(bytes < 1024 * 1024)
            result = [NSString stringWithFormat:@"APP磁盘占用: %.1f KB", bytes / 1024.0];
        else if(bytes < 1024 * 1024 * 1024)
            result = [NSString stringWithFormat:@"APP磁盘占用: %.1f MB", bytes / (1024.0 * 1024.0)];
        else result = [NSString stringWithFormat:@"APP磁盘占用: %.1f GB", bytes / (1024.0 * 1024.0)];
        if(!onceDiskCellHasBeenTouched) result = [result stringByAppendingString:@" (点击更新)"];
        else result = [result stringByAppendingString:@" (已刷新)"];
    }
    else if ([rawName isEqualToString:@"开关 结果显示" SelfUpdateContentSubfix]) {
        if(shouldShowInformation) result = @"关闭 结果显示";
        else result = @"开启 结果显示";
    }
    else if ([rawName isEqualToString:@"记录数量 x N" SelfUpdateContentSubfix]) {
        result = [NSString stringWithFormat:@"记录数量 x %lu", (unsigned long)logMultiplex];
    }
    else if ([rawName isEqualToString:@"开关 DEBUG [TTMacroManager]" SelfUpdateContentSubfix]) {
        BOOL isDebug;
        if(!hasSwizzledTTMacroManager) {
            NSNumber *query = DC_ET(DC_CL(TTMacroManager, isDebug), NSNumber);
            isDebug = query.boolValue;
        }
        else isDebug = isCurrentDEBUG;
        if(isDebug) result = @"关闭 DEBUG [TTMacroManager]";
        else result = @"开启 DEBUG [TTMacroManager]";
    }
    else if ([rawName isEqualToString:@"TOGGLE 当前视图跟踪窗口" SelfUpdateContentSubfix]) {
        if(hasDisplayed_vc_finder) result = @"隐藏 当前视图跟踪窗口";
        else result = @"显示 当前视图跟踪窗口";
    }
    else if([rawName isEqualToString:@"开关 动态信息刷新" SelfUpdateContentSubfix]) {
        if(needUpdateValueWhenTimerCallback) result = @"关闭 动态信息刷新";
        else result = @"开启 动态信息刷新";
    }
    else if([rawName isEqualToString:@"FPS 掉帧测试" SelfUpdateContentSubfix]) {
        if(!hasOnceOpenFPS) result = @"FPS 掉帧测试";
        else if(current_FPS_level >= 60) result = @"FPS 已恢复";
        else result = [NSString stringWithFormat:@"FPS %lu", (unsigned long)current_FPS_level];
    }
    DEBUG_ASSERT(result != nil);
    if(result == nil) result = @"self-update CELL ERROR";
    return result;
}

- (void)updateSelfUpdateCellForName:(NSString *)cellName {
    NSAssert(cellName != nil, @"- [HMDSRWTESTENvironment updateSelfUpdateCellForName:] cellName nil");
    if(!_hasCheckedSelfUpdateCells) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        NSArray<NSArray<NSString *> *> *cellNamesInSessions = [self cellNamesInSessions];
        NSUInteger sessionCount = cellNamesInSessions.count;
        for(NSUInteger sessionIndex = 0; sessionIndex < sessionCount; sessionIndex++) {
            NSArray<NSString *> *cellNames = cellNamesInSessions[sessionIndex];
            NSUInteger rowCount = cellNames.count;
            for(NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
                NSString *rowName = cellNames[rowIndex];
                if([rowName containsString:[NSString stringWithUTF8String:SelfUpdateContentSubfix]]) {
                    [temp setObject:[NSIndexPath indexPathForRow:rowIndex inSection:sessionIndex] forKey:rowName];
                }
            }
        }
        _selfUpdateCells = [temp copy];
        _hasCheckedSelfUpdateCells = YES;
    }
    NSIndexPath *path;
    if((path = [_selfUpdateCells objectForKey:cellName]) != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.textLabel.text = [self querySelfUpdateNameForRawName:cellName];
    }
    DEBUG_ELSE
}

- (void)updateDynamicCell {
    if(!_hasCheckedDynamicCells) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        NSArray<NSArray<NSString *> *> *cellNamesInSessions = [self cellNamesInSessions];
        NSUInteger sessionCount = cellNamesInSessions.count;
        for(NSUInteger sessionIndex = 0; sessionIndex < sessionCount; sessionIndex++) {
            NSArray<NSString *> *cellNames = cellNamesInSessions[sessionIndex];
            NSUInteger rowCount = cellNames.count;
            for(NSUInteger rowIndex = 0; rowIndex < rowCount; rowIndex++) {
                NSString *rowName = cellNames[rowIndex];
                if([rowName containsString:[NSString stringWithUTF8String:DynamicUpdatedWithoutActionSubfix]]) {
                    [temp setObject:[NSIndexPath indexPathForRow:rowIndex inSection:sessionIndex] forKey:rowName];
                }
            }
        }
        _dynamicCells = [temp copy];
        _hasCheckedDynamicCells = YES;
    }
    if(needUpdateValueWhenTimerCallback) {
        [_dynamicCells enumerateKeysAndObjectsUsingBlock: ^ (NSString * _Nonnull key, NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
            cell.textLabel.text = [self queryDynamicCellNameForRawName:key];
        }];
    }
}

#pragma mark - Test actions

- (NSArray<NSString *> *)testSessionName {
    if(_sessionNameArray == nil) {
        return @[@"管理操作",
                 @"模拟 Module 记录",
                 @"模拟上传",
                 @"模拟清理",
                 @"模拟生命周期",
                 @"获取当前状态",
                 @"崩溃测试",
                 @"主线程卡顿测试",
                 @"内存分配测试",
                 @"安全气垫测试",
                 @"搭建测试环境",
                 @"动态信息",
                 @"动态窗口",
                 @"控制台"];
    }
    return _sessionNameArray;
}

- (NSArray<NSArray<NSString *> *> *)cellNamesInSessions {
    if(_cellNamesInSessionsArray == nil) {
        return @[@[@"开关 结果显示" SelfUpdateContentSubfix,
                   @"允许 自由旋转",
                   @"关闭 测试环境",
#ifndef Launch_simbol
                   @"开关 Heimdallr 图标",
#endif
#ifndef Heimdallr_inspect
                   @"开关 Heimdallr 行为监控",
#endif
                   ],
                 @[@"当前 开启模块 [race]",
                   @"当前 模块检测结果",
                   @"记录数量 x N" SelfUpdateContentSubfix,
                   @"记录 ANR [handleTimeout]",
                   @"记录 Battery [refresh]",
                   @"记录 CPU",
                   @"记录 Dart [record]",
                   @"记录 Game [record]",
                   @"记录 Crash [怎么实现嘛]",
                   @"记录 Disk [enterBG]",
                   @"记录 FPS [refresh_async]",
                   @"记录 Frame Drop [notification]",
                   @"记录 HTTP [不好实现]",
                   @"记录 Memory [refresh]",
                   @"记录 NetTraffic [recordForScene:]",
                   @"记录 OOM Crash [没有实现]",
                   @"记录 OOM [没有实现]",
                   @"记录 Smart Net Traffic [recordData]",
                   @"记录 Start [没有实现]",
                   @"记录 UI [trackEvent]",
                   @"记录 User Exception [track]",
                   @"记录 Watch Dog",
                   @"记录 TTMonitor [tracker/matrics]"],
                 @[@"当前 数据库记录",
                   @"启动 DebugReal 上传",
                   @"启动 Exception 上传",
                   @"启动 Performance 上传",
                   @"启动 Crash 上传",
                   @"禁用 所有上传"],
                 @[@"启动 Inspector 数据库清理",
                   @"启动 Heimdallr Cleanup"],
                 @[@"发布 willEnterForground",
                   @"发布 didEnterBackground",
                   @"发布 willResignActive",
                   @"发布 didBecomeActive",
                   @"发布 didFinishLaunch",
                   @"发布 willTerminate",
                   @"模拟 强制关闭 [慎重]",
                   @"模拟 关机"],
                 @[@"当前 ApplicationSession",
                   @"禁止 后台任务结束",
                   @"当前 后台任务 [race]",
                   @"使用 随机数据更新 InjectInfo",
                   @"设置 InjectInfo",
                   @"当前 InjectInfo 用户数据",
                   @"当前 InjectInfo 上报配置"],
                 @[@"测试 SIGABRT (signal)",
                   @"测试 SIGTERM (signal)",
                   @"测试 SIGINT  (signal)",
                   @"测试 SIGILL  (signal)",
                   @"测试 EXC_BAD_ACCESS (mach)",
                   @"测试 SIGBUS (fatal signal)",
                   @"测试 C++ 异常",
                   @"测试 NSException"],
                 @[@"测试 主线程卡顿 5s 后 强杀APP",
                   @"测试 主线程卡顿 8s",
                   @"测试 主线程卡死 20s 后 强杀APP",
                   @"开关 主线程启动卡顿 5s",
                   @"FPS 掉帧测试" SelfUpdateContentSubfix],
                 @[@"恢复 内存分配",
                   @"测试 分配 20M",
                   @"测试 分配 100M",
                   @"测试 分配 500M"],
                 @[@"安全气垫模块开关 记录类型倍增逻辑",
                   @"测试 unrecognized selector",
                   @"测试 NSString 异常访问",
                   @"测试 NSArray 异常访问",
                   @"测试 NSDictionary 异常访问",
                   @"测试 NSMutableString 异常访问",
                   @"测试 NSMutableArray 异常访问",
                   @"测试 NSMutableDictionary 异常访问",
                   @"测试 NSAttributedString 异常访问",
                   @"测试 NSMutableAttributedString 异常访问",
                   @"测试 KVO 异常使用",
                   @"当前 KVO 监控信息",
                   @"当前 KVO 异常信息",
                   @"测试 KVC 异常使用"],
                 @[@"搭建测试环境",
                   @"允许 所有类型记录 [log enabled]",
                   @"开关 DEBUG [TTMacroManager]" SelfUpdateContentSubfix,
                   @"强制 开启所有 模块",
                   @"重制 exceptionReporter 上报时间间隔",
                   @"开关 模块检测回调"],
                 @[@"开关 动态信息刷新" SelfUpdateContentSubfix,
                   @"CPU" DynamicUpdatedWithoutActionSubfix,
                   @"MEMORY" DynamicUpdatedWithoutActionSubfix,
                   @"FPS" DynamicUpdatedWithoutActionSubfix,
                   @"DISK" SelfUpdateContentSubfix],
                 @[@"TOGGLE 当前视图跟踪窗口" SelfUpdateContentSubfix,
                   @"测试 视图跟踪效率",
                   @"当前 视图跟踪时间消耗"],
                 @[@"主控制台",
                   @"数据库控制台",
                   @"模块控制台",
                   @"上传控制台",
                   @"UI Action 控制台",
                   @"Network 控制台"]];
    }
    return _cellNamesInSessionsArray;
}

- (NSDictionary<NSString *, HMDSRWTESTEnvironmentAction> *)testActions {
    if(_testActionDictionary == nil) {
        __weak typeof(self) weakSelf = self;
        _testActionDictionary =
        @{
          @"开关 结果显示"SelfUpdateContentSubfix: ^ {
              shouldShowInformation = !shouldShowInformation;
              [weakSelf updateSelfUpdateCellForName:@"开关 结果显示" SelfUpdateContentSubfix];
          },
          @"允许 自由旋转": ^ {
              if(!hasPermittedFreeRotation) {
                  Class aClass = object_getClass(UIApplication.sharedApplication.delegate);
                  SEL aSEL = sel_registerName("application:supportedInterfaceOrientationsForWindow:");
                  if(aClass != nil && aSEL != NULL) {
                      Method method;
                      if((method = ca_classHasInstanceMethod(aClass, aSEL)) != NULL) {
                          SEL mockSEL = sel_registerName("MOCK_application:supportedInterfaceOrientationsForWindow:");
                          ca_mockClassTreeForInstanceMethod(aClass, aSEL, mockSEL, ^ UIInterfaceOrientationMask(id thisSelf, UIApplication *app, UIWindow *window) {
                              return UIInterfaceOrientationMaskAll;
                          });
                      }
                      else {
                          Protocol *protocol;
                          if((protocol = objc_getProtocol("UIApplicationDelegate")) != NULL) {
                              struct objc_method_description
                              description = protocol_getMethodDescription(protocol, aSEL, NO, YES);
                              if(description.types != NULL) {
                                  IMP imp = imp_implementationWithBlock(^ UIInterfaceOrientationMask(id thisSelf, UIApplication *app, UIWindow *window) {
                                      return UIInterfaceOrientationMaskAll;
                                  });
                                  class_addMethod(aClass, aSEL, imp, description.types);
                                  id<UIApplicationDelegate> currentDelegate = UIApplication.sharedApplication.delegate;
                                  UIApplication.sharedApplication.delegate = currentDelegate;
                              }
                              DEBUG_ELSE
                          }
                          DEBUG_ELSE
                      }
                      Class vcClass = objc_getClass("UIViewController");
                      SEL autoSEL = sel_registerName("shouldAutorotate");
                      SEL supportSEL = sel_registerName("supportedInterfaceOrientations");
                      SEL mokeAutoSEL = sel_registerName("MOKE_shouldAutorotate");
                      SEL mokeSupportSEL = sel_registerName("MOKE_supportedInterfaceOrientations");
                      if(vcClass != nil && autoSEL != NULL && supportSEL != NULL && mokeAutoSEL != NULL && mokeSupportSEL != NULL) {
                          ca_mockClassTreeForInstanceMethod(vcClass, autoSEL, mokeAutoSEL, ^ BOOL (id thisSelf) {
                              return YES;
                          });
                          ca_mockClassTreeForInstanceMethod(vcClass, supportSEL, mokeSupportSEL, ^ UIInterfaceOrientationMask (id thisSelf) {
                              return UIInterfaceOrientationMaskAll;
                          });
                          [UIViewController attemptRotationToDeviceOrientation];
                      }
                      DEBUG_ELSE
                  }
                  DEBUG_ELSE
                  hasPermittedFreeRotation = YES;
              }
          },
          @"关闭 测试环境": ^ {
              if(weakSelf.presentingViewController != nil) {
                  [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
              }
              else if(weakSelf.parentViewController != nil) {
                  if([weakSelf.parentViewController isKindOfClass:UINavigationController.class]) {
                      UINavigationController *vc = (__kindof UINavigationController *)weakSelf.parentViewController;
                      NSArray<__kindof UIViewController *> *viewControllers = vc.viewControllers;
                      if(viewControllers != nil && [viewControllers containsObject:weakSelf] && viewControllers[0] != weakSelf) {
                          NSUInteger index = [viewControllers indexOfObject:weakSelf];
                          __kindof UIViewController *toVC = viewControllers[index - 1];
                          [vc popToViewController:toVC animated:YES];
                      }
                  }
              }
          },
#ifndef Heimdallr_inspect
          @"开关 Heimdallr 行为监控": ^ {
              if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRW_HOOK_Heimdallr]) {
                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHMDSRW_HOOK_Heimdallr];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  if(hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"已关闭 行为监控" message:@"下次启动才可停止"];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"已关闭 行为监控" message:@"下次启动依然不会开启"];
              }
              else {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHMDSRW_HOOK_Heimdallr];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  if(hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"已开启 行为监控" message:@"下次启动还会继续"];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"已开启 行为监控" message:@"下次启动才可开启"];
              }
          },
#endif
#ifdef Launch_simbol
          @"开关 Heimdallr 图标": ^ {
              if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey]) {
                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  if(hasLaunchedSimbol_thiTime) [HMDSRWTESTEnvironment showInformationTitle:@"已关闭 图标" message:@"下次启动才可停止"];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"已关闭 图标" message:@"下次启动依然不会开启"];
              }
              else {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  if(hasLaunchedSimbol_thiTime) [HMDSRWTESTEnvironment showInformationTitle:@"已开启 图标" message:@"下次启动还会继续"];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"已开启 图标" message:@"下次启动才可开启"];
              }
          },
#endif
          @"当前 开启模块 [race]": ^ {
              id heimdallr = DC_CL(Heimdallr, shared);
              NSMutableDictionary<NSString *, id> *remoteModules = DC_OB(heimdallr, remoteModules);
              NSDictionary<NSString *, id> *copied = [remoteModules copy];
              NSMutableString *str = [NSMutableString string];
              NSUInteger count = copied.count;
              [copied enumerateKeysAndObjectsUsingBlock: ^ (NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                  NSNumber *isRunning = DC_ET(DC_OB(obj, isRunning), NSNumber);
                  if(isRunning.boolValue) [str appendFormat:@"%@\n", key];
              }];
              if(count == 0) [str appendString:@"NOTHING launched"];
              [HMDSRWTESTEnvironment showInformationTitle:@"当前开启模块" message:str];
          },
          @"当前 模块检测结果": ^ {
              NSMutableString *str = [NSMutableString string];
              BOOL onceWritten = NO;
              BOOL hasNotFinished = NO;
              NSArray<Class> *moduleConfigClassArray = DC_CL(HMDModuleConfig, allRemoteModuleClasses);
              for(Class eachClass in moduleConfigClassArray) {
                  id config = DC_OB(eachClass, alloc);
                  config = DC_OB(config, initWithDictionary:, @{});
                  id module = DC_OB(config, getModule);
                  Protocol *protocol;
                  if((protocol = objc_getProtocol("HMDExcludeModule")) != NULL) {
                      for(Class aClass = object_getClass(module); aClass; aClass = class_getSuperclass(aClass)) {
                          if(class_conformsToProtocol(aClass, protocol)) {
                              onceWritten = YES;
                              id excludedModule = DC_OB(object_getClass(module), excludedModule);
                              NSNumber *finishDetection = DC_OB(excludedModule, isFinishDetection);
                              NSNumber *detected = DC_OB(excludedModule, isDetected);
                              BOOL isFinishDetection = finishDetection.boolValue;
                              BOOL isDetected = detected.boolValue;
                              if(!isFinishDetection) {
                                  [str appendFormat:@"%s 未完成检测\n", class_getName(object_getClass(module))];
                                  hasNotFinished = YES;
                              }
                              else if(isDetected)
                                  [str appendFormat:@"%s 检测成功\n", class_getName(object_getClass(module))];
                              else
                                  [str appendFormat:@"%s 检测失败\n", class_getName(object_getClass(module))];
                              break;
                          }
                      }
                  }
              }
              if(!onceWritten) [str appendString:@"没有模块遵守 HMDExcludeModule 协议"];
              else if(hasNotFinished) [str appendString:@"[模块未完成检测 可能压根没开启]\n"
                                                         "建议搭建测试环境"];
              [HMDSRWTESTEnvironment showInformationTitle:@"模块检测结果" message:str];
          },
          @"记录数量 x N" SelfUpdateContentSubfix: ^ {
              if(logMultiplex <= 1) logMultiplex = 10;
              else if(logMultiplex <= 10) logMultiplex = 100;
              else if(logMultiplex <= 100) logMultiplex = 1000;
              else if(logMultiplex <= 1000) logMultiplex = 10000;
              else logMultiplex = 1;
              [weakSelf updateSelfUpdateCellForName:@"记录数量 x N" SelfUpdateContentSubfix];
          },
          @"记录 ANR [handleTimeout]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDANRTracker, sharedTracker), handleTimeOutWithStack:blockDuration:, @"TEST_STACK", (NSTimeInterval)1.0);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 ANR" message:@"已完成"];
          },
          @"记录 Battery [refresh]": ^ {
              static dispatch_once_t onceToken;
              dispatch_once(&onceToken, ^ {
                  SEL sel = sel_registerName("batteryState");
                  SEL moke_sel = sel_registerName("MOKE_batteryState");
                  ca_mockClassTreeForInstanceMethod(UIDevice.class, sel, moke_sel, ^ UIDeviceBatteryState(void) {
                      return UIDeviceBatteryStateUnplugged;
                  });
              });
              DC_OB(DC_CL(HMDBatteryMonitor, sharedMonitor), setIsRunning:, YES);
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDBatteryMonitor, sharedMonitor), refresh);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Battery" message:@"已完成"];
          },
          @"记录 CPU": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDCPUMonitor, sharedMonitor), refresh);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 CPU" message:@"已完成"];
          },
          @"记录 Dart [record]": ^ {
              DC_OB(DC_CL(HMDDartTracker, sharedTracker), recordDartErrorWithTraceStack:, @"fake_stack");
          },
          @"记录 Game [record]": ^ {
              DC_OB(DC_CL(HMDGameTracker, sharedTracker), recordGameErrorWithTraceStack:name:reason:, @"fake_stack", @"fake_name", @"fake_reason");
          },
          @"记录 Crash [怎么实现嘛]": ^ {
              [HMDSRWTESTEnvironment showInformationTitle:@"没有实现" message:@"Crash 记录怎么实现嘛"];
          },
          @"记录 Disk [enterBG]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDDiskMonitor, sharedMonitor), didEnterBackground:, nil);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Disk" message:@"已完成"];
          },
          @"记录 FPS [refresh_async]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDFPSMonitor, sharedMonitor), refresh_async);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 FPS" message:@"已完成"];
          },
          @"记录 Frame Drop [notification]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDFrameDropMonitor, sharedMonitor), applicationDidReceiveFrameNotification:frameDuration:, nil, 0.0);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Frame Drop" message:@"已完成"];
          },
          @"记录 HTTP [不好实现]": ^ {
              [HMDSRWTESTEnvironment showInformationTitle:@"没有实现" message:@"HTTP 记录不好实现"];
          },
          @"记录 Memory [refresh]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDMemoryMonitor, sharedMonitor), refresh);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Memory" message:@"已完成"];
          },
          @"记录 NetTraffic [recordForScene:]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDNetTrafficMonitor, sharedMonitor), recordForSpecificScene:, nil);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 NetTraffic" message:@"已完成"];
          },
          @"记录 OOM Crash [没有实现]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  id record = DC_CL(HMDOOMCrashRecord, new);
                  DC_OB(DC_CL(HMDOOMCrashTracker, sharedTracker), didCollectOneRecord:trackerBlock:, record, nil);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 OOM Crash" message:@"已完成"];
          },
          @"记录 OOM [没有实现]": ^ {
              [HMDSRWTESTEnvironment showInformationTitle:@"没有实现" message:@"OOM 记录没有实现"];
          },
          @"记录 Smart Net Traffic [recordData]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDSmartNetTrafficMonitor, sharedMonitor), recordData);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Smart Net Traffic" message:@"已完成"];
          },
          @"记录 Start [没有实现]": ^ {
              [HMDSRWTESTEnvironment showInformationTitle:@"没有实现" message:@"Start 记录没有实现"];
          },
          @"记录 UI [trackEvent]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDUITrackerManager, sharedManager), hmdTrackWithName:event:parameters:, @"TEST_NAME", @"TEST_EVENT", nil);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 UI" message:@"已完成"];
          },
          @"记录 User Exception [track]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDUserExceptionTracker, sharedTracker), trackCurrentThreadLogExceptionType:skippedDepth:customParams:filters:callback:, @"TEST_TYPE", (NSUInteger)0ul, nil, nil, nil);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 User Exception" message:@"已完成"];
          },
          @"记录 Watch Dog": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDWatchDogTracker, sharedTracker), watchDogDidDetectEventWithData:, @{@"HMD_WatchDog_exposedData_timeStamp":@([[NSDate date] timeIntervalSince1970] - 30.0)});
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 Watch Dog" message:@"已完成"];
          },
          @"记录 TTMonitor [tracker/matrics]": ^ {
              dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                  DC_OB(DC_CL(HMDTTMonitor, defaultManager), trackAppLogWithTag:label:, @"TEST_TG", @"TEST_LABEL");
                  DC_OB(DC_CL(HMDTTMonitor, defaultManager), event:label:duration:needAggregate:, @"TEST_TG", @"TEST_LABEL", (float)0.0f, YES);
                  DC_OB(DC_CL(HMDTTMonitor, defaultManager), event:label:needAggregate:, @"TEST_TG", @"TEST_LABEL", YES);
              });
              [HMDSRWTESTEnvironment showInformationTitle:@"记录 TTMonitor" message:@"已完成"];
          },
          @"当前 数据库记录": ^ {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                  BOOL onceAdded = NO;
                  NSMutableString *str = [NSMutableString string];
                  NSArray<NSString *> *tableNames;
                  NSDictionary<NSString *, NSNumber *> *countDictionary;
                  NSDictionary<NSString *, NSNumber *> *cleanupWeightDictionary;
                  
                  NSArray<NSString *> * __autoreleasing tableNames_autoreleasing;
                  NSDictionary<NSString *, NSNumber *> * __autoreleasing countDictionary_autoreleasing;
                  NSDictionary<NSString *, NSNumber *> * __autoreleasing cleanupWeightDictionary_autoreleasing;
                  
                  NSNumber *result = DC_ET(DC_OB(DC_ET(DC_CL(HMDInspector, shared), HMDInspector), currentDatabaseTable:count:cleanupWeight:, &tableNames_autoreleasing, &countDictionary_autoreleasing, &cleanupWeightDictionary_autoreleasing), NSNumber);
                  
                  tableNames = tableNames_autoreleasing;
                  countDictionary = countDictionary_autoreleasing;
                  cleanupWeightDictionary = cleanupWeightDictionary_autoreleasing;
                  
                  if([result boolValue])
                      for(NSString *eachTableName in tableNames) {
                          NSNumber *count = countDictionary[eachTableName];
                          if(!onceAdded) {
                              [str appendFormat:@"%@: %@", eachTableName, count];
                              onceAdded = YES;
                          }
                          else [str appendFormat:@"\n%@: %@", eachTableName, count];
                      }
                  
                  if(!onceAdded) [str appendString:@"空的"];
                  
                  NSNumber *value =
                  DC_ET(DC_OB(DC_OB(DC_CL(Heimdallr, shared), database), dbFileSize), NSNumber);
                  [str appendFormat:@"\n数据库大小: %.1f MB", value.doubleValue / (1024 * 1024)];
                  
                  NSNumber *expectedSize = DC_CL(HMDInspector, expectedDatabaseSize);
                  [str appendFormat:@"\n数据库期望大小: %lu MB", (unsigned long)expectedSize.unsignedIntegerValue];
                  
                  NSNumber *devastedSize = DC_CL(HMDInspector, resolveDevastedSizeByExpectedSize:, (NSUInteger)expectedSize.unsignedIntegerValue);
                  [str appendFormat:@"\n数据库损坏式清理触发阈值: %lu MB", (unsigned long)devastedSize.unsignedIntegerValue];
                  
                  dispatch_async(dispatch_get_main_queue(), ^ {
                      [HMDSRWTESTEnvironment showInformationTitle:@"数据库" message:str];
                  });
              });
          },
          @"启动 DebugReal 上传": ^ {
              DC_CL(Heimdallr, uploadDebugRealDataWithStartTime:endTime:wifiOnly:,
                                 [[NSDate distantPast] timeIntervalSince1970],
                                 [[NSDate distantFuture] timeIntervalSince1970], NO);
          },
          @"启动 Exception 上传": ^ {
              id reporter = DC_CL(HMDExceptionReporter, sharedInstance);
              DC_OB(reporter, reportExceptionDataAsync);
              DC_OB(reporter, reportUserExceptionDataAsync);
              if(!hasSwizzledTTMacroManager) {
                  NSNumber *isDebug = DC_CL(TTMacroManager, isDebug);
                  if(isDebug.boolValue)
                      [HMDSRWTESTEnvironment showInformationTitle:@"上传警告"
                                                          message:@"当前尚未关闭 TTMacroManager DEBUG 开关\n"
                                                                   "默认逻辑会禁止上传"];
              }
              else if(isCurrentDEBUG) {
                  [HMDSRWTESTEnvironment showInformationTitle:@"上传警告"
                                                      message:@"当前已开启 TTMacroManager DEBUG 开关\n"
                                                               "默认逻辑会禁止上传"];
              }
          },
          @"启动 Performance 上传": ^ {
              id heimdallr = DC_CL(Heimdallr, shared);
              id performanceReporter = DC_OB(heimdallr, reporter);
              DC_OB(performanceReporter, reportPerformanceDataAsyncWithBlock:, nil);
          },
          @"启动 Crash 上传": ^ {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                  DC_OB(DC_OB(DC_CL(HMDCrashTracker, sharedTracker), crashlogUploader), uploadCrashLogIfNeeded);
              });
          },
          @"禁用 所有上传": ^ {
              static BOOL once = NO;
              if(!once) {
                  Class aClass = objc_getClass("HMDExceptionReporter");
                  SEL sel = sel_registerName("reportExceptionDataAsync");
                  SEL moke_sel = sel_registerName("MOKE_reportExceptionDataAsync");
                  if(aClass != nil) {
                      ca_mockClassTreeForInstanceMethod(aClass, sel, moke_sel, ^ void (id thisSelf) {
                          //
                      });
                      
                      sel = sel_registerName("reportUserExceptionDataAsync");
                      moke_sel = sel_registerName("MOKE_reportUserExceptionDataAsync");
                      ca_mockClassTreeForInstanceMethod(aClass, sel, moke_sel, ^ void (id thisSelf) {
                          //
                      });
                      
                      aClass = objc_getClass("Heimdallr");
                      sel = sel_registerName("uploadDebugRealDataWithStartTime:endTime:wifiOnly:");
                      moke_sel = sel_registerName("MOKE_uploadDebugRealDataWithStartTime:endTime:wifiOnly:");
                      ca_mockClassTreeForClassMethod(aClass, sel, moke_sel, ^ void (id thisSelf,
                                                                                    NSTimeInterval fetchStartTime,
                                                                                    NSTimeInterval fetchEndTime) {
                          //
                      });
                      
                      aClass = objc_getClass("HMDPerformanceReporter");
                      sel = sel_registerName("reportPerformanceDataAsyncWithBlock:");
                      moke_sel = sel_registerName("MOKE_reportPerformanceDataAsyncWithBlock:");
                      ca_mockClassTreeForInstanceMethod(aClass, sel, moke_sel, ^ void (id thisSelf, id block) {
                          //
                      });
                      
                      aClass = objc_getClass("HMDCrashlogUploader");
                      sel = sel_registerName("uploadCrashLogIfNeeded");
                      moke_sel = sel_registerName("MOKE_uploadCrashLogIfNeeded");
                      ca_mockClassTreeForInstanceMethod(aClass, sel, moke_sel, ^ void (id thisSelf) {
                          //
                      });
                  }
                  
                  once = YES;
                  [HMDSRWTESTEnvironment showInformationTitle:@"禁用 所有上传" message:@"已完成了呢"];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"禁用 所有上传" message:@"不可恢复呀"];
          },
          @"启动 Inspector 数据库清理": ^ {
              DC_OB(DC_CL(HMDInspector, shared), handleDatabaseInspectation);
          },
          @"启动 Heimdallr Cleanup": ^ {
              id heimdallr = DC_CL(Heimdallr, shared);
              id config;
              if((config = DC_OB(heimdallr, config)) != nil) {
                  id cleanupConfig;
                  if((cleanupConfig = DC_OB(config, cleanupConfig)) != nil) {
                      id condition = DC_OB(DC_CL(HMDStoreCondition, alloc), init);
                      DC_OB(condition, setKey:, @"timestamp");
                      DC_OB(condition, setThreshold:, (double)[[NSDate distantFuture] timeIntervalSince1970]);
                      DC_OB(condition, setJudgeType:, (NSInteger)1);
                      DC_OB(cleanupConfig, setAndConditions:, @[condition]);
                      DC_OB(cleanupConfig, setOutdatedTimestamp:, (NSTimeInterval)[[NSDate distantPast] timeIntervalSince1970]);
                      DC_OB(cleanupConfig, setMaxSessionCount:, (NSUInteger)0);
                      
                      DC_OB(heimdallr, cleanup);
                  }
                  else [HMDSRWTESTEnvironment showInformationTitle:@"无法清理" message:@"Heimdallr config.cleanupConfig 未设置"];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"无法清理" message:@"Heimdallr config 未设置"];
          },
          @"发布 willEnterForground": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"发布 didEnterBackground": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"发布 willResignActive": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"发布 didBecomeActive": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"发布 didFinishLaunch": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"发布 willTerminate": ^ {
              [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification
                                                                  object:[UIApplication sharedApplication]];
          },
          @"模拟 强制关闭 [慎重]": ^ {
              pthread_kill(pthread_self(), SIGKILL);
          },
          @"模拟 关机": ^ {
              CFTimeInterval targetTime = CFAbsoluteTimeGetCurrent() + 10;
              [NSThread HMD_detachNewThreadWithBlock: ^ {
                  CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
                  CFTimeInterval shutdownTime = targetTime - currentTime;
                  if(shutdownTime < 0) shutdownTime = 0;
                  double sec;
                  double frac = modf(shutdownTime, &sec);
                  struct timespec ts;
                  ts.tv_sec = sec;
                  ts.tv_nsec = frac * NSEC_PER_SEC;
                  nanosleep(&ts, NULL);
                  pthread_kill(pthread_self(), SIGKILL);
              }];
              [NSThread HMD_detachNewThreadWithBlock: ^ {
                  CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
                  CFTimeInterval notificationTime = targetTime - 0.5 - currentTime;
                  if(notificationTime < 0) notificationTime = 0;
                  double sec;
                  double frac = modf(notificationTime, &sec);
                  struct timespec ts;
                  ts.tv_sec = sec;
                  ts.tv_nsec = frac * NSEC_PER_SEC;
                  nanosleep(&ts, NULL);
                  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification
                                                                      object:[UIApplication sharedApplication]];
              }];
              [HMDSRWTESTEnvironment showInformationTitle:@"模拟关机"
                                                  message:@"9.5秒后 发布 willTerminate\n"
                                                           " 10秒后 强杀 APP"];
          },
          @"当前 ApplicationSession": ^ {
              id session = DC_CL(HMDSessionTracker, currentSession);
              NSNumber *localID = DC_OB(session, localID);
              NSString *sessionID = DC_OB(session, sessionID);
              NSNumber *timeInSession = DC_OB(session, timeInSession);
              NSNumber *duration = DC_OB(session, duration);
              NSNumber *memoryUsage = DC_OB(session, memoryUsage);
              NSNumber *freeMemory = DC_OB(session, freeMemory);
              NSNumber *freeDisk = DC_OB(session, freeDisk);
              NSNumber *timestamp = DC_OB(session, timestamp);
              NSNumber *backgroundStatus = DC_OB(session, isBackgroundStatus);
              NSDictionary<NSString*, id> *customParams = DC_OB(session, customParams);
              NSString *eternalSessionID = DC_OB(session, eternalSessionID);
              NSDictionary<NSString*, id> *filters = DC_OB(session, filters);
              NSMutableString *str = [NSMutableString string];
              [str appendFormat:@"localID: %@\n", localID];
              [str appendFormat:@"sessionID: %@\n", sessionID];
              [str appendFormat:@"timeInSession: %@\n", timeInSession];
              [str appendFormat:@"duration: %@\n", duration];
              [str appendFormat:@"memoryUsage: %@\n", memoryUsage];
              [str appendFormat:@"freeMemory: %@\n", freeMemory];
              [str appendFormat:@"freeDisk: %@\n", freeDisk];
              [str appendFormat:@"timestamp: %@\n", timestamp];
              [str appendFormat:@"backgroundStatus: %@\n", backgroundStatus.boolValue?@"YES":@"NO"];
              NSString *customParamsString;
              if(customParams == nil) customParamsString = @"nil";
              else if(customParams.count == 0) customParamsString = @"空字典";
              else customParamsString = [NSString stringWithFormat:@"\n%@", customParams.description];
              [str appendFormat:@"customParams:%@\n", customParamsString];
              [str appendFormat:@"eternalSessionID: %@\n", eternalSessionID];
              NSString *filtersString;
              if(filters == nil) filtersString = @"nil";
              else if(filters.count == 0) filtersString = @"空字典";
              else filtersString = [NSString stringWithFormat:@"\n%@", filters.description];
              [str appendFormat:@"filters:%@", filtersString];
              [HMDSRWTESTEnvironment showInformationTitle:@"当前 ApplicationSession" message:str];
          },
          @"禁止 后台任务结束": ^ {
              if(!hasSwizzledSimpleBackgroundTask) {
                  Class aClass = objc_getClass("HMDSimpleBackgroundTask");
                  SEL aSEL = sel_registerName("completeBackgroundTask");
                  SEL mokeSEL = sel_registerName("SRW_TEST_MOKE_completeBackgroundTask");
                  if(aClass != nil && aSEL != NULL) {
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL, mokeSEL, ^ (id thisSelf) {
                      });
                  }
                  hasSwizzledSimpleBackgroundTask = YES;
              }
          },
          @"当前 后台任务 [race]": ^ {
              NSMutableArray *allBGTasks = DC_CL(HMDSimpleBackgroundTask, currentBackgroundTask);
              NSArray *copied = [allBGTasks copy];
              NSMutableString *str = [NSMutableString string];
              NSUInteger count = copied.count;
              for(NSUInteger index = 0; index < count; index++) {
                  id currentTask = copied[index];
                  NSString *name = DC_OB(currentTask, valueForKey:, @"name");
                  [str appendFormat:@"任务名称: %@", name];
                  if(index + 1 < count) [str appendString:@"\n"];
              }
              if(count == 0) [str appendString:
                              @"当前没有后台任务\n"
                              "PostScript:\n"
                              "先禁止后台任务结束\n"
                              "再模拟发布 didEnterBackground\n"
                              "试一试"];
              [HMDSRWTESTEnvironment showInformationTitle:@"当前后台任务" message:str];
          },
          @"使用 随机数据更新 InjectInfo": ^ {
              id info = DC_CL(HMDInjectedInfo, defaultInfo);
              srand((unsigned int)time(NULL));
              NSNumber *appID = [NSNumber numberWithInt:rand()];
              NSString *appIDString = [@"appID_" stringByAppendingString:appID.description];
              DC_OB(info, setAppID:, appIDString);
              NSNumber *appName = [NSNumber numberWithInt:rand()];
              NSString *appNameString = [@"appName_" stringByAppendingString:appName.description];
              DC_OB(info, setAppName:, appNameString);
              NSNumber *channel = [NSNumber numberWithInt:rand()];
              NSString *channelString = [@"channel_" stringByAppendingString:channel.description];
              DC_OB(info, setChannel:, channelString);
              NSString *deviceIDString = [[NSUUID UUID] UUIDString];
              DC_OB(info, setDeviceID:, deviceIDString);
              NSString *installIDString = [[NSUUID UUID] UUIDString];
              DC_OB(info, setInstallID:, installIDString);
              NSNumber *userID = [NSNumber numberWithInt:rand()];
              NSString *userIDString = [@"userID_" stringByAppendingString:userID.description];
              DC_OB(info, setUserID:, userIDString);
              NSNumber *userName = [NSNumber numberWithInt:rand()];
              NSString *userNameString = [@"userName_" stringByAppendingString:userName.description];
              DC_OB(info, setUserName:, userNameString);
              NSNumber *email = [NSNumber numberWithInt:rand()];
              NSString *emailString = [@"email_" stringByAppendingString:email.description];
              [emailString stringByAppendingString:@"@bytedance.com"];
              DC_OB(info, setEmail:, emailString);
              NSString *sessionIDString = [[NSUUID UUID] UUIDString];
              DC_OB(info, setSessionID:, sessionIDString);
              NSNumber *crashUploadHost = [NSNumber numberWithInt:rand()];
              NSString *crashUploadHostString = [@"crashUploadHost_" stringByAppendingString:crashUploadHost.description];
              DC_OB(info, setCrashUploadHost:, crashUploadHostString);
              NSNumber *exceptionUploadHost = [NSNumber numberWithInt:rand()];
              NSString *exceptionUploadHostString = [@"exceptionUploadHost_" stringByAppendingString:exceptionUploadHost.description];
              DC_OB(info, setExceptionUploadHost:, exceptionUploadHostString);
              NSNumber *userExceptionUploadHost = [NSNumber numberWithInt:rand()];
              NSString *userExceptionUploadHostString = [@"userExceptionUploadHost_" stringByAppendingString:userExceptionUploadHost.description];
              DC_OB(info, setUserExceptionUploadHost:, userExceptionUploadHostString);
              NSNumber *performanceUploadHost = [NSNumber numberWithInt:rand()];
              NSString *performanceUploadHostString = [@"performanceUploadHost_" stringByAppendingString:performanceUploadHost.description];
              DC_OB(info, setPerformanceUploadHost:, performanceUploadHostString);
              NSNumber *fileUploadHost = [NSNumber numberWithInt:rand()];
              NSString *fileUploadHostString = [@"fileUploadHost_" stringByAppendingString:fileUploadHost.description];
              DC_OB(info, setFileUploadHost:, fileUploadHostString);
              DC_OB(info, setConfigHostArray:, @[[NSNumber numberWithInt:rand()].description,
                                                               [NSNumber numberWithInt:rand()].description,
                                                               [NSNumber numberWithInt:rand()].description,
                                                               [NSNumber numberWithInt:rand()].description]);
              NSDictionary *customContext = DC_OB(info, customContext);
              NSArray<NSString *> *allKeys1 = customContext.allKeys;
              for(NSString *eachKey in allKeys1)
                  DC_OB(info, removeCustomContextKey:, eachKey);
              NSNumber *num1 = [NSNumber numberWithInt:rand()];
              NSNumber *num2 = [NSNumber numberWithInt:rand()];
              NSNumber *num3 = [NSNumber numberWithInt:rand()];
              DC_OB(info, setCustomContextValue:forKey:, num1, num1.description);
              DC_OB(info, setCustomContextValue:forKey:, num2, num2.description);
              DC_OB(info, setCustomContextValue:forKey:, num3, num3.description);
              NSDictionary *filters = DC_OB(info, filters);
              NSArray<NSString *> *allKeys2 = filters.allKeys;
              for(NSString *eachKey in allKeys2)
                  DC_OB(info, removeCustomFilterKey:, eachKey);
              NSNumber *num4 = [NSNumber numberWithInt:rand()];
              NSNumber *num5 = [NSNumber numberWithInt:rand()];
              NSNumber *num6 = [NSNumber numberWithInt:rand()];
              DC_OB(info, setCustomFilterValue:forKey:, num4, num4.description);
              DC_OB(info, setCustomFilterValue:forKey:, num5, num5.description);
              DC_OB(info, setCustomFilterValue:forKey:, num6, num6.description);
          },
          @"设置 InjectInfo": ^ {
              if(objc_getClass("BDAutoTrackInstallManager") != nil) {
                  HMDSRWSetting *appID = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"appID" action: ^ (HMDSRWSetting *setting) {
                      id manager = DC_ET(DC_CL(BDAutoTrackInstallManager, sharedInstance), BDAutoTrackInstallManager);
                      id config = DC_ET(DC_OB(manager, config), BDAutoTrackConfig);
                      if(config != nil) {
                          DC_OB(config, setAppID:, setting.string);
                          DC_OB(manager, setConfig:, config);
                      }
                  }];
                  HMDSRWSetting *appName = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"appName" action: ^ (HMDSRWSetting *setting) {
                      id manager = DC_ET(DC_CL(BDAutoTrackInstallManager, sharedInstance), BDAutoTrackInstallManager);
                      id config = DC_ET(DC_OB(manager, config), BDAutoTrackConfig);
                      if(config != nil) {
                          DC_OB(config, setAppName:, setting.string);
                          DC_OB(manager, setConfig:, config);
                      }
                  }];
                  HMDSRWSettingViewController *settingsVC = [[HMDSRWSettingViewController alloc] initWithSettings:@[appID, appName]];
                  [weakSelf showViewController:settingsVC sender:weakSelf];
              }
              else if(objc_getClass("HMDInjectedInfo") != nil) {
                  HMDSRWSetting *appName = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"appName" action: ^ (HMDSRWSetting *setting) {
                      id info = DC_CL(HMDInjectedInfo, defaultInfo);
                      DC_OB(info, setAppName:, setting.string);
                  }];
                  HMDSRWSetting *appID = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"appID" action: ^ (HMDSRWSetting *setting) {
                      id info = DC_CL(HMDInjectedInfo, defaultInfo);
                      DC_OB(info, setAppID:, setting.string);
                  }];
                  HMDSRWSetting *userID = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"userID" action: ^ (HMDSRWSetting *setting) {
                      id info = DC_CL(HMDInjectedInfo, defaultInfo);
                      DC_OB(info, setUserID:, setting.string);
                  }];
                  HMDSRWSetting *deviceID = [[HMDSRWSetting alloc] initWithType:HMDSRWSettingTypeString name:@"deviceID" action: ^ (HMDSRWSetting *setting) {
                      id info = DC_CL(HMDInjectedInfo, defaultInfo);
                      DC_OB(info, setDeviceID:, setting.string);
                  }];
                  HMDSRWSettingViewController *settingsVC = [[HMDSRWSettingViewController alloc] initWithSettings:@[appName, appID, userID, deviceID]];
                  [weakSelf showViewController:settingsVC sender:weakSelf];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"当前环境非 Heimdallr 兼容"];
          },
          @"当前 InjectInfo 用户数据": ^ {
              if(objc_getClass("BDAutoTrackInstallManager") != nil) {
                  id manager = DC_ET(DC_CL(BDAutoTrackInstallManager, sharedInstance), BDAutoTrackInstallManager);
                  id config = DC_ET(DC_OB(manager, config), BDAutoTrackConfig);
                  if(config != nil) {
                      NSString *appID = DC_ET(DC_OB(config, appID), NSString);
                      NSString *appName = DC_ET(DC_OB(config, appName), NSString);
                      NSMutableString *str = [NSMutableString string];
                      [str appendFormat:@"appID: %@\n", appID];
                      [str appendFormat:@"appName: %@\n", appName];
                      [HMDSRWTESTEnvironment showInformationTitle:@"当前 InjectInfo 用户数据" message:str];
                  }
              }
              else if(objc_getClass("HMDInjectedInfo") != nil) {
                  id injectInfo = DC_CL(HMDInjectedInfo, defaultInfo);
                  NSString *appID = DC_OB(injectInfo, appID);/**应用标示，如头条主端是13 */
                  NSString *appName = DC_OB(injectInfo, appName);/**应用名称，如头条主端是news_article */
                  NSString *channel = DC_OB(injectInfo, channel);/**应用渠道，正式包用App Store，内测版用local_test*/
                  NSString *deviceID = DC_OB(injectInfo, deviceID);/**从TTInstallService库中获取到的设备标示 */
                  NSString *installID = DC_OB(injectInfo, installID);/**从TTInstallService库中获取到的安装标示 */
                  NSString *userID = DC_OB(injectInfo, userID);/**用户ID */
                  NSString *userName = DC_OB(injectInfo, userName);/**用户名 */
                  NSString *email = DC_OB(injectInfo, email);/**用户邮箱 */
                  NSString *sessionID = DC_OB(injectInfo, sessionID);/**返回TTTracker中的sessionID */
                  NSDictionary<NSString*, id> *commonParams = DC_OB(injectInfo, commonParams);/**App全局的通用参数 静态*/
                  NSString *business = DC_OB(injectInfo, business);/** 业务方名称，退出业务时记得赋空，只适合用在非常独立的大模块，如小程序*/
                  NSDictionary *customContext = DC_OB(injectInfo, customContext);/**自定义环境信息，崩溃时可在后台查看辅助分析问题，只做展示而不是筛选使用*/
                  NSDictionary *filters = DC_OB(injectInfo, filters);
                  NSMutableString *str = [NSMutableString string];
                  [str appendFormat:@"appID: %@\n", appID];
                  [str appendFormat:@"appName: %@\n", appName];
                  [str appendFormat:@"channel: %@\n", channel];
                  [str appendFormat:@"deviceID: %@\n", deviceID];
                  [str appendFormat:@"installID: %@\n", installID];
                  [str appendFormat:@"userID: %@\n", userID];
                  [str appendFormat:@"userName: %@\n", userName];
                  [str appendFormat:@"email: %@\n", email];
                  [str appendFormat:@"sessionID: %@\n", sessionID];
                  NSString *commonParamsString;
                  if(commonParams == nil) commonParamsString = @"nil";
                  else if(commonParams.count == 0) commonParamsString = @"空字典";
                  else commonParamsString = [NSString stringWithFormat:@"\n%@", commonParams.description];
                  [str appendFormat:@"commonParams: %@\n", commonParamsString];
                  [str appendFormat:@"business: %@\n", business];
                  NSString *customContextString;
                  if(customContext == nil) customContextString = @"nil";
                  else if(customContext.count == 0) customContextString = @"空字典";
                  else customContextString = [NSString stringWithFormat:@"\n%@", customContext.description];
                  [str appendFormat:@"customContext: %@\n", customContextString];
                  NSString *filtersString;
                  if(filters == nil) filtersString = @"nil";
                  else if(filters.count == 0) filtersString = @"空字典";
                  else filtersString = [NSString stringWithFormat:@"\n%@", filters.description];
                  [str appendFormat:@"filters: %@", filtersString];
                  [HMDSRWTESTEnvironment showInformationTitle:@"当前 InjectInfo 用户数据" message:str];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"当前环境非 Heimdallr 兼容"];
          },
          @"当前 InjectInfo 上报配置": ^ {
              id injectInfo = DC_CL(HMDInjectedInfo, defaultInfo);
              NSString *crashUploadHost = DC_OB(injectInfo, crashUploadHost);/** Crash 上报域名，默认为 lg.snssdk.com */
              NSString *exceptionUploadHost = DC_OB(injectInfo, exceptionUploadHost);/** ANR 等异常事件上报域名，默认为 abn.snssdk.com */
              NSString *userExceptionUploadHost = DC_OB(injectInfo, userExceptionUploadHost);
              NSString *performanceUploadHost = DC_OB(injectInfo, performanceUploadHost);/** CPU 等性能数据上报域名，默认为 mon.snssdk.com */
              NSString *fileUploadHost = DC_OB(injectInfo, fileUploadHost);/** 文件上传域名，默认为 mon.snssdk.com */
              NSArray *configHostArray = DC_OB(injectInfo, configHostArray);/** 配置拉取和重试域名，默认为 mon.snssdk.com，mon.toutiaocloud.com */
              NSMutableString *str = [NSMutableString string];
              [str appendFormat:@"crashUploadHost: %@\n", crashUploadHost];
              [str appendFormat:@"exceptionUploadHost: %@\n", exceptionUploadHost];
              [str appendFormat:@"userExceptionUploadHost: %@\n", userExceptionUploadHost];
              [str appendFormat:@"performanceUploadHost: %@\n", performanceUploadHost];
              [str appendFormat:@"fileUploadHost: %@\n", fileUploadHost];
              NSString *configHostArrayString;
              if(configHostArray == nil) configHostArrayString = @"nil";
              else if(configHostArray.count == 0) configHostArrayString = @"空数组";
              else configHostArrayString = [NSString stringWithFormat:@"\n%@", configHostArray.description];
              [str appendFormat:@"configHostArray: %@", configHostArrayString];
              [HMDSRWTESTEnvironment showInformationTitle:@"当前 InjectInfo 上报配置" message:str];
          },
          @"测试 SIGABRT (signal)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  raise(SIGABRT);
              });
          },
          @"测试 SIGTERM (signal)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  raise(SIGTERM);
              });
          },
          @"测试 SIGINT  (signal)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  raise(SIGINT);
              });
          },
          @"测试 SIGILL  (signal)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  raise(SIGILL);
              });
          },
          @"测试 EXC_BAD_ACCESS (mach)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  int *pointer = (int *)0xFF;
                  *pointer = 6;
              });
          },
          @"测试 SIGBUS (fatal signal)": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  task_set_exception_ports(mach_task_self(),
                                           EXC_MASK_BAD_ACCESS,
                                           MACH_PORT_NULL,
                                           EXCEPTION_DEFAULT, 0);
                  void *a = calloc(1, sizeof(void *));
                  ((void(*)())a)();
              });
          },
          @"测试 C++ 异常": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  id testVC = DC_CL(HMDCrashCatchTestTableViewController, new);
                  DC_OB(testVC, tableView:didSelectRowAtIndexPath:, nil, [NSIndexPath indexPathForRow:3 inSection:0]);
              });
          },
          @"测试 NSException": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  [[NSException exceptionWithName:@"TEST_EXCEPTION" reason:nil userInfo:nil] raise];
              });
          },
          @"测试 主线程卡顿 5s 后 强杀APP": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  sleep(5);
                  pthread_kill(pthread_self(), SIGKILL);
              });
          },
          @"测试 主线程卡顿 8s": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  sleep(8);
                  [HMDSRWTESTEnvironment showInformationTitle:@"卡顿报告" message:@"卡顿 8s 已结束"];
              });
          },
          @"测试 主线程卡死 20s 后 强杀APP": ^ {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
                  sleep(20);
                  pthread_kill(pthread_self(), SIGKILL);
              });
          },
          @"开关 主线程启动卡顿 5s": ^ {
              BOOL setted = [[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRWTestEnvironmentLanchStuckKey];
              if(setted) {
                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHMDSRWTestEnvironmentLanchStuckKey];
                  [HMDSRWTESTEnvironment showInformationTitle:@"主线程启动卡顿" message:@"已经关闭了呢"];
              }
              else {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHMDSRWTestEnvironmentLanchStuckKey];
                  [HMDSRWTESTEnvironment showInformationTitle:@"主线程启动卡顿" message:@"已经开启了呀"];
              }
          },
          @"FPS 掉帧测试" SelfUpdateContentSubfix : ^ {
              if(FPS_Control_DisplayLink == nil) {
                  FPS_Control_DisplayLink = [CADisplayLink displayLinkWithTarget:HMDSRWTESTEnvironment.class selector:@selector(FPS_control_displayLinkCallback:)];
                  [FPS_Control_DisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
              }
              if(current_FPS_level >= 60) current_FPS_level = 30;
              else if(current_FPS_level >= 30) current_FPS_level = 20;
              else if(current_FPS_level >= 20) current_FPS_level = 5;
              else { current_FPS_level = 60; FPS_Control_DisplayLink.paused = NO;}
              hasOnceOpenFPS = YES;
              [weakSelf updateSelfUpdateCellForName:@"FPS 掉帧测试" SelfUpdateContentSubfix];
          },
          @"恢复 内存分配": ^ {
              if(currentAllocation != nil) {
                  for(NSValue *eachValue in currentAllocation) {
                      void *pointer = [eachValue pointerValue];
                      free(pointer);
                  }
                  [currentAllocation removeAllObjects];
              }
          },
          @"测试 分配 20M": ^ {
              if(currentAllocation == nil)
                  currentAllocation = [NSMutableArray array];
              void *pointer;
              if((pointer = malloc(20 * 1024 * 1024)) != NULL) {
                  memset(pointer, UCHAR_MAX, 20 * 1024 * 1024);
                  NSValue *value = [NSValue valueWithPointer:pointer];
                  [currentAllocation addObject:value];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"内存分配" message:@"系统拒绝分配 20M 内存"];
          },
          @"测试 分配 100M": ^ {
              if(currentAllocation == nil)
                  currentAllocation = [NSMutableArray array];
              void *pointer;
              if((pointer = malloc(100 * 1024 * 1024)) != NULL) {
                  memset(pointer, UCHAR_MAX, 100 * 1024 * 1024);
                  NSValue *value = [NSValue valueWithPointer:pointer];
                  [currentAllocation addObject:value];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"内存分配" message:@"系统拒绝分配 100M 内存"];
          },
          @"测试 分配 500M": ^ {
              if(currentAllocation == nil)
                  currentAllocation = [NSMutableArray array];
              void *pointer;
              if((pointer = malloc(500 * 1024 * 1024)) != NULL) {
                  memset(pointer, UCHAR_MAX, 500 * 1024 * 1024);
                  NSValue *value = [NSValue valueWithPointer:pointer];
                  [currentAllocation addObject:value];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"内存分配" message:@"系统拒绝分配 500M 内存"];
          },
          @"安全气垫模块开关 记录类型倍增逻辑": ^ {
              if((protector_enable_logMultiplex = !protector_enable_logMultiplex))
                  [HMDSRWTESTEnvironment showInformationTitle:@"记录倍增" message:@"已开启\n"
                                                                                 "[警告⚠️] 可能会非常卡"];
              else
                  [HMDSRWTESTEnvironment showInformationTitle:@"记录倍增" message:@"已关闭"];
          },
          @"测试 unrecognized selector": ^ {
              if(protector_enable_logMultiplex) {
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                      NSObject *object = [NSObject new];
                      SEL aSEL = sel_registerName("TEST_INVALID_SELECTOR");
                      void *bridged_object = (__bridge void *)object;
                      
                      @try {
                          ((void (*)(void *, SEL))objc_msgSend)(bridged_object, aSEL);
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"USEL 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"USEL 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
              }
              else {
                  BOOL detectException = false;
                  
                  NSObject *object = [NSObject new];
                  SEL aSEL = sel_registerName("TEST_INVALID_SELECTOR");
                  void *bridged_object = (__bridge void *)object;
                  
                  @try {
                      ((void (*)(void *, SEL))objc_msgSend)(bridged_object, aSEL);
                  } @catch (NSException *exception) {
                      detectException = true;
                      [HMDSRWTESTEnvironment showInformationTitle:@"USEL 安全气垫检查" message:exception.description];
                  }
                  
                  if(!detectException)
                      [HMDSRWTESTEnvironment showInformationTitle:@"USEL 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
              }
          },
          @"测试 NSString 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t index) {
                      NSString *testString = [[NSUUID UUID] UUIDString];
                      NSUInteger length = testString.length;
                      srand((unsigned int)time(NULL));
                      void *testStringCast = (__bridge void *)testString;
                      SEL aSEL = sel_registerName("characterAtIndex:");
                      
                      NSUInteger testIndex = length;
                      @try {
                          ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      } @catch (NSException *exception) {errorTimes++; }
                      
                      testString = [[NSUUID UUID] UUIDString];
                      length = testString.length;
                      testIndex = length + 1;
                      aSEL = sel_registerName("substringFromIndex:");
                      testStringCast = (__bridge void *)testString;
                      @try {
                          ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      } @catch (NSException *exception) { errorTimes++;}
                      
                      testString = [[NSUUID UUID] UUIDString];
                      length = testString.length;
                      testIndex = length + 1;
                      aSEL = sel_registerName("substringToIndex:");
                      testStringCast = (__bridge void *)testString;
                      @try {
                          ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      } @catch (NSException *exception) {errorTimes++; }
                      
                      testString = [[NSUUID UUID] UUIDString];
                      length = testString.length;
                      testIndex = rand() % (length + 1);
                      NSRange testRange = NSMakeRange(testIndex, length + 1 - testIndex);
                      testStringCast = (__bridge void *)testString;
                      aSEL = sel_registerName("stringByReplacingCharactersInRange:withString:");
                      @try {
                          ((void *(*)(void *, SEL, NSRange, NSString *))objc_msgSend)(testStringCast, aSEL, testRange, @"ABC");
                      } @catch (NSException *exception) {errorTimes++; }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSString 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSString 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  
                  /* - NSString characterAtIndex: */
                  NSString *testString = [[NSUUID UUID] UUIDString];
                  NSUInteger length = testString.length;
                  srand((unsigned int)time(NULL));
                  void *testStringCast = (__bridge void *)testString;
                  SEL aSEL = sel_registerName("characterAtIndex:");
                  
                  NSUInteger testIndex = length;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      [str appendFormat:
                       @"- [NSString characterAtIndex:%lu]\n"
                       "length %lu, return value:%s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       (result == nil)?"nil":object_getClassName((__bridge id)result)];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSString characterAtIndex:%lu] length %lu\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       exception.name, exception.reason];
                  }
                  
                  testString = [[NSUUID UUID] UUIDString];
                  length = testString.length;
                  testIndex = length + 1;
                  aSEL = sel_registerName("substringFromIndex:");
                  testStringCast = (__bridge void *)testString;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      [str appendFormat:
                       @"- [NSString substringFromIndex:%lu]\n"
                       "length %lu, return value:%s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       (result == nil)?"nil":object_getClassName((__bridge id)result)];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSString substringFromIndex:%lu] length %lu\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       exception.name, exception.reason];
                  }
                  
                  testString = [[NSUUID UUID] UUIDString];
                  length = testString.length;
                  testIndex = length + 1;
                  aSEL = sel_registerName("substringToIndex:");
                  testStringCast = (__bridge void *)testString;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)(testStringCast, aSEL, testIndex);
                      [str appendFormat:
                       @"- [NSString substringToIndex:%lu]\n"
                       "length %lu, return value:%s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       (result == nil)?"nil":object_getClassName((__bridge id)result)];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSString substringToIndex:%lu] length %lu\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)testIndex, (unsigned long)length,
                       exception.name, exception.reason];
                  }
                  
                  testString = [[NSUUID UUID] UUIDString];
                  length = testString.length;
                  testIndex = rand() % (length + 1);
                  NSRange testRange = NSMakeRange(testIndex, length + 1 - testIndex);
                  testStringCast = (__bridge void *)testString;
                  aSEL = sel_registerName("stringByReplacingCharactersInRange:withString:");
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSRange, NSString *))objc_msgSend)(testStringCast, aSEL, testRange, @"ABC");
                      [str appendFormat:
                       @"- [NSString stringByReplacingCharactersInRange:%@ withString:]\n"
                       "length %lu, return value:%s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       [NSValue valueWithRange:testRange], (unsigned long)length,
                       (result == nil)?"nil":object_getClassName((__bridge id)result)];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSString stringByReplacingCharactersInRange:%@ withString:] length %lu\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       [NSValue valueWithRange:testRange], (unsigned long)length,
                       exception.name, exception.reason];
                  }
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSString 安全气垫检查" message:str];
              }
          },
          @"测试 NSArray 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      srand((unsigned int)time(NULL));
                      NSUInteger count = rand() % 41 + 1;
                      void **objectsArray = __builtin_alloca(count * sizeof(void *));
                      memset(objectsArray, '\0', count * sizeof(void *));
                      for(NSUInteger index = 0; index < count - 1; index++)
                          objectsArray[index] = (__bridge_retained void *)[[NSUUID UUID] UUIDString];
                      Class arrayClass = objc_getClass("NSArray");
                      void *castClass = (__bridge void *)arrayClass;
                      SEL aSEL = sel_registerName("arrayWithObjects:count:");
                      @try {
                          ((void *(*)(void *, SEL, void * const *, NSUInteger))objc_msgSend)
                          (castClass, aSEL, objectsArray, count);
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      id empty_cast;
                      for(NSUInteger index = 0; index < count - 1; index++)
                          empty_cast =(__bridge_transfer id)objectsArray[index];
                      
                      count = rand() % 41 + 1;
                      NSMutableArray *testArray = [NSMutableArray array];
                      for(NSUInteger index = 0; index < count; index++)
                          [testArray addObject:[[NSUUID UUID] UUIDString]];
                      testArray = [testArray copy];
                      void *castArray = (__bridge void *)testArray;
                      aSEL = sel_registerName("objectsAtIndexes:");
                      NSUInteger index = rand() % (count + 1);
                      NSUInteger length = (count + 1) - index;
                      NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, length)];
                      void *castIndexSet = (__bridge void *)set;
                      @try {
                          ((void *(*)(void *, SEL, void *))objc_msgSend)
                          (castArray, aSEL, castIndexSet);
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      count = rand() % 41 + 1;
                      testArray = [NSMutableArray array];
                      for(NSUInteger index = 0; index < count; index++)
                          [testArray addObject:[[NSUUID UUID] UUIDString]];
                      testArray = [testArray copy];
                      castArray = (__bridge void *)testArray;
                      aSEL = sel_registerName("objectAtIndex:");
                      index = count;
                      @try {
                          ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)
                          (castArray, aSEL, index);
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      count = rand() % 41 + 1;
                      testArray = [NSMutableArray array];
                      for(NSUInteger index = 0; index < count; index++)
                          [testArray addObject:[[NSUUID UUID] UUIDString]];
                      testArray = [testArray copy];
                      castArray = (__bridge void *)testArray;
                      aSEL = sel_registerName("objectAtIndexedSubscript:");
                      index = count;
                      @try {
                          ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)
                          (castArray, aSEL, index);
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSArray 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                                                                   "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSArray 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  srand((unsigned int)time(NULL));
                  NSMutableString *str = [NSMutableString string];
                  NSUInteger count = rand() % 41 + 1;
                  void **objectsArray = __builtin_alloca(count * sizeof(void *));
                  memset(objectsArray, '\0', count * sizeof(void *));
                  for(NSUInteger index = 0; index < count - 1; index++)
                      objectsArray[index] = (__bridge_retained void *)[[NSUUID UUID] UUIDString];
                  Class arrayClass = objc_getClass("NSArray");
                  void *castClass = (__bridge void *)arrayClass;
                  SEL aSEL = sel_registerName("arrayWithObjects:count:");
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, void * const *, NSUInteger))objc_msgSend)
                      (castClass, aSEL, objectsArray, count);
                      [str appendFormat:
                       @"+ [NSArray arrayWithObjects:count:%lu]\n"
                       "objectsArray[%lu] == nil\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)count, (unsigned long)(count - 1),
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"+ [NSArray arrayWithObjects:count:%lu]\n"
                       "objectsArray[%lu] == nil\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)count, (unsigned long)(count - 1),
                       exception.name, exception.reason];
                  }
                  
                  id empty_cast;
                  for(NSUInteger index = 0; index < count - 1; index++)
                      empty_cast =(__bridge_transfer id)objectsArray[index];
                  
                  count = rand() % 41 + 1;
                  NSMutableArray *testArray = [NSMutableArray array];
                  for(NSUInteger index = 0; index < count; index++)
                      [testArray addObject:[[NSUUID UUID] UUIDString]];
                  testArray = [testArray copy];
                  void *castArray = (__bridge void *)testArray;
                  aSEL = sel_registerName("objectsAtIndexes:");
                  NSUInteger index = rand() % (count + 1);
                  NSUInteger length = (count + 1) - index;
                  NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, length)];
                  void *castIndexSet = (__bridge void *)set;
                  const char *setDescription = set.description.UTF8String;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, void *))objc_msgSend)
                      (castArray, aSEL, castIndexSet);
                      [str appendFormat:
                       @"- [NSArray objectsAtIndexes:%s]\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       setDescription,
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSArray objectsAtIndexes:%s]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       setDescription,
                       exception.name, exception.reason];
                  }
                  
                  count = rand() % 41 + 1;
                  testArray = [NSMutableArray array];
                  for(NSUInteger index = 0; index < count; index++)
                      [testArray addObject:[[NSUUID UUID] UUIDString]];
                  testArray = [testArray copy];
                  castArray = (__bridge void *)testArray;
                  aSEL = sel_registerName("objectAtIndex:");
                  index = count;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)
                      (castArray, aSEL, index);
                      [str appendFormat:
                       @"- [NSArray objectAtIndex:%lu]\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)index,
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSArray objectAtIndex:%lu]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)index,
                       exception.name, exception.reason];
                  }
                  
                  count = rand() % 41 + 1;
                  testArray = [NSMutableArray array];
                  for(NSUInteger index = 0; index < count; index++)
                      [testArray addObject:[[NSUUID UUID] UUIDString]];
                  testArray = [testArray copy];
                  castArray = (__bridge void *)testArray;
                  aSEL = sel_registerName("objectAtIndexedSubscript:");
                  index = count;
                  @try {
                      void *result =
                      ((void *(*)(void *, SEL, NSUInteger))objc_msgSend)
                      (castArray, aSEL, index);
                      [str appendFormat:
                       @"- [NSArray objectAtIndexedSubscript:%lu]\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)index,
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSArray objectAtIndexedSubscript:%lu]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)index,
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSArray 安全气垫检查" message:str];
              }
          },
          @"测试 NSDictionary 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      srand((unsigned int)time(NULL));
                      NSString *objectArray[42];
                      NSString *keyArray[42];
                      NSUInteger randIndex = rand() % 42;
                      for(NSUInteger index = 0; index < 42; index++) {
                          if(index != randIndex) objectArray[index] = [[NSUUID UUID] UUIDString];
                          keyArray[index] = [[NSUUID UUID] UUIDString];
                      }
                      
                      @try {
                          [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray count:42];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      NSArray *array1 = @[@"A", @"B", @"C"];
                      NSArray *array2 = @[@"A", @"B", @"C", @"D"];
                      @try {
                          [NSDictionary dictionaryWithObjects:array1 forKeys:array2];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSDictionary 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSDictionary 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  srand((unsigned int)time(NULL));
                  NSMutableString *str = [NSMutableString string];
                  NSString *objectArray[42];
                  NSString *keyArray[42];
                  NSUInteger randIndex = rand() % 42;
                  for(NSUInteger index = 0; index < 42; index++) {
                      if(index != randIndex) objectArray[index] = [[NSUUID UUID] UUIDString];
                      keyArray[index] = [[NSUUID UUID] UUIDString];
                  }
                  
                  @try {
                      void *result = (__bridge void *)[NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray count:42];
                      [str appendFormat:
                       @"- [NSDictionary dictionaryWithObjects:forKeys:count:%lu]\n"
                       "objectArray[%lu] == nil\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)42,
                       (unsigned long)randIndex,
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSDictionary dictionaryWithObjects:forKeys:count:%lu]\n"
                       "objectArray[%lu] == nil\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       (unsigned long)42,
                       (unsigned long)randIndex,
                       exception.name, exception.reason];
                  }
                  
                  NSArray *array1 = @[@"A", @"B", @"C"];
                  NSArray *array2 = @[@"A", @"B", @"C", @"D"];
                  @try {
                      void *result = (__bridge void *)[NSDictionary dictionaryWithObjects:array1 forKeys:array2];
                      [str appendFormat:
                       @"- [NSDictionary dictionaryWithObjects:[array count %lu] forKeys:[array count %lu]]\n"
                       "returns %s\n"
                       "无异常抛出 这是什么黑魔法\n",
                       (unsigned long)array1.count, (unsigned long)array2.count,
                       result == nil?"nil":class_getName(objc_getClass(result))];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSDictionary dictionaryWithObjects:forKeys:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSDictionary 安全气垫检查" message:str];
              }
          },
          @"测试 NSMutableString 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      
                      srand((unsigned int)time(NULL));
                      NSMutableString *testString = [[[NSUUID UUID] UUIDString] mutableCopy];
                      NSUInteger length = testString.length;
                      NSUInteger index = rand() % (length + 1);
                      @try {
                          [testString replaceCharactersInRange:NSMakeRange(index, (length + 1) - index) withString:@"ABC"];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [testString insertString:@"ABC" atIndex:length + 1];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      index = rand() % (length + 1);
                      @try {
                          [testString deleteCharactersInRange:NSMakeRange(index, (length + 1) - index)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableString 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableString 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  
                  srand((unsigned int)time(NULL));
                  NSMutableString *testString = [[[NSUUID UUID] UUIDString] mutableCopy];
                  NSUInteger length = testString.length;
                  NSUInteger index = rand() % (length + 1);
                  @try {
                      [testString replaceCharactersInRange:NSMakeRange(index, (length + 1) - index) withString:@"ABC"];
                      [str appendFormat:
                       @"- [NSMutableString replaceCharactersInRange:withString:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableString replaceCharactersInRange:withString:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [testString insertString:@"ABC" atIndex:length + 1];
                      [str appendFormat:
                       @"- [NSMutableString insertString:atIndex:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableString insertString:atIndex:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  index = rand() % (length + 1);
                  @try {
                      [testString deleteCharactersInRange:NSMakeRange(index, (length + 1) - index)];
                      [str appendFormat:
                       @"- [NSMutableString deleteCharactersInRange:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableString deleteCharactersInRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableString 安全检查" message:str];
              }
          },
          @"测试 NSMutableArray 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      srand((unsigned int)time(NULL));
                      
                      NSMutableArray *array = [@[@"A", @"B", @"C"] mutableCopy];
                      @try {
                          [array removeObjectAtIndex:3];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      NSUInteger count = array.count;
                      NSUInteger index = rand() % (count + 1);
                      @try {
                          [array removeObjectsInRange:NSMakeRange(index, (count + 1) - index)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, (count + 1) - index)];
                      @try {
                          [array removeObjectsAtIndexes:set];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [array insertObject:set atIndex:count + 1];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                      [indexSet addIndex:1];
                      [indexSet addIndex:2];
                      [indexSet addIndex:100];
                      NSArray *objectsArray = @[@"A", @"B", @"C"];
                      
                      @try {
                          [array insertObjects:objectsArray atIndexes:indexSet];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [array replaceObjectAtIndex:count withObject:@"YYY"];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [array replaceObjectsAtIndexes:indexSet withObjects:objectsArray];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [array replaceObjectsInRange:NSMakeRange(index, (count + 1) - index) withObjectsFromArray:@[]];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [array replaceObjectsInRange:NSMakeRange(index, (count + 1) - index) withObjectsFromArray:@[] range:NSMakeRange(0, 666)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableArray 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableArray 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  srand((unsigned int)time(NULL));
                  
                  NSMutableArray *array = [@[@"A", @"B", @"C"] mutableCopy];
                  @try {
                      [array removeObjectAtIndex:3];
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectAtIndex:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectAtIndex:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  NSUInteger count = array.count;
                  NSUInteger index = rand() % (count + 1);
                  @try {
                      [array removeObjectsInRange:NSMakeRange(index, (count + 1) - index)];
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectsInRange:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectsInRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, (count + 1) - index)];
                  @try {
                      [array removeObjectsAtIndexes:set];
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectsAtIndexes:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray removeObjectsAtIndexes:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [array insertObject:set atIndex:count + 1];
                      [str appendFormat:
                       @"- [NSMutableArray insertObject:atIndex:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray insertObject:atIndex:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                  [indexSet addIndex:1];
                  [indexSet addIndex:2];
                  [indexSet addIndex:100];
                  NSArray *objectsArray = @[@"A", @"B", @"C"];
                  
                  @try {
                      [array insertObjects:objectsArray atIndexes:indexSet];
                      [str appendFormat:
                       @"- [NSMutableArray insertObjects:atIndexes:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray insertObjects:atIndexes:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [array replaceObjectAtIndex:count withObject:@"YYY"];
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectAtIndex:atIndexes:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectAtIndex:atIndexes:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [array replaceObjectsAtIndexes:indexSet withObjects:objectsArray];
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsAtIndexes:withObjects:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsAtIndexes:withObjects:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [array replaceObjectsInRange:NSMakeRange(index, (count + 1) - index) withObjectsFromArray:@[]];
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsInRange:withObjectsFromArray:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsInRange:withObjectsFromArray:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [array replaceObjectsInRange:NSMakeRange(index, (count + 1) - index) withObjectsFromArray:@[] range:NSMakeRange(0, 666)];
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsInRange:withObjectsFromArray:range:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableArray replaceObjectsInRange:withObjectsFromArray:range:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableArray 安全检查" message:str];
              }
          },
          @"测试 NSMutableDictionary 异常访问" : ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                      [dictionary setObject:@"YYY" forKey:@"YYY-KEY"];
                      [dictionary setObject:@"HUAQ" forKey:@"HUAQ-KEY"];
                      
                      id nilObject = nil;
                      @try {
                          [dictionary setObject:nilObject forKey:@"NIL-KEY"];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      
                      @try {
                          [dictionary setValue:@"nil" forKey:nilObject];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [dictionary removeObjectForKey:nil];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableDictionary 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableDictionary 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                  [dictionary setObject:@"YYY" forKey:@"YYY-KEY"];
                  [dictionary setObject:@"HUAQ" forKey:@"HUAQ-KEY"];
                  
                  id nilObject = nil;
                  @try {
                      [dictionary setObject:nilObject forKey:@"NIL-KEY"];
                      [str appendFormat:
                       @"- [NSMutableDictionary setObject:forKey:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableDictionary setObject:forKey:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  
                  @try {
                      [dictionary setValue:@"nil" forKey:nilObject];
                      [str appendFormat:
                       @"- [NSMutableDictionary setValue:forKey:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableDictionary setValue:forKey:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [dictionary removeObjectForKey:nil];
                      [str appendFormat:
                       @"- [NSMutableDictionary setValue:forKey:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableDictionary removeObjectForKey:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableDictionary 检查" message:str];
              }
          },
          @"测试 NSAttributedString 异常访问" : ^ {
              
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      NSAttributedString *test = [[NSAttributedString alloc] initWithString:@"HuaQ"];
                      @try {
                          [test attributedSubstringFromRange:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(5, 0) options:0 usingBlock: ^ (id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                              // ANY HOW
                          }];
                          [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(5, 0) options:0 usingBlock:nil];
                          
                          [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(5, 0) options:666 usingBlock: ^ (id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                              // ANY HOW
                          }];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [test enumerateAttributesInRange:NSMakeRange(5, 0) options:0 usingBlock: ^ (NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                              // ANY
                          }];
                          [test enumerateAttributesInRange:NSMakeRange(0, 1) options:0 usingBlock:nil];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [test dataFromRange:NSMakeRange(5, 0) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} error:nil];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [test fileWrapperFromRange:NSMakeRange(5, 0) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} error:nil];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      
                      @try {
                          [test containsAttachmentsInRange:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSAttributedString 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSAttributedString 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
                  
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  NSAttributedString *test = [[NSAttributedString alloc] initWithString:@"HuaQ"];
                  @try {
                      [test attributedSubstringFromRange:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSAttributedString attributedSubstringFromRange:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString attributedSubstringFromRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(5, 0) options:0 usingBlock: ^ (id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                          // ANY HOW
                      }];
                      [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, 1) options:0 usingBlock:nil];
                      
                      [test enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(5, 0) options:666 usingBlock: ^ (id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                          // ANY HOW
                      }];
                      [str appendFormat:
                       @"- [NSAttributedString enumerateAttribute:inRange:options:usingBlock:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString enumerateAttribute:inRange:options:usingBlock:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [test enumerateAttributesInRange:NSMakeRange(5, 0) options:0 usingBlock: ^ (NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                          // ANY
                      }];
                      [test enumerateAttributesInRange:NSMakeRange(0, 1) options:0 usingBlock:nil];
                      [str appendFormat:
                       @"- [NSAttributedString enumerateAttributesInRange:options:usingBlock:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString enumerateAttributesInRange:options:usingBlock:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [test dataFromRange:NSMakeRange(5, 0) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} error:nil];
                      [str appendFormat:
                       @"- [NSAttributedString dataFromRange:documentAttributes:error:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString dataFromRange:documentAttributes:error:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [test fileWrapperFromRange:NSMakeRange(5, 0) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} error:nil];
                      [str appendFormat:
                       @"- [NSAttributedString fileWrapperFromRange:documentAttributes:error:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString fileWrapperFromRange:documentAttributes:error:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  @try {
                      [test containsAttachmentsInRange:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSAttributedString containsAttachmentsInRange:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSAttributedString containsAttachmentsInRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSAttributedString 检查" message:str];
              }
          },
          @"测试 NSMutableAttributedString 异常访问": ^ {
              if(protector_enable_logMultiplex) {
                  
                  __block atomic_uint errorTimes = 0;
                  
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      NSMutableAttributedString *test = [[NSMutableAttributedString alloc] initWithString:@"HuaQ"];
                      
                      @try {
                          [test replaceCharactersInRange:NSMakeRange(5, 0) withString:@"ABC"];
                          [test replaceCharactersInRange:NSMakeRange(0, 1) withString:nil];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test deleteCharactersInRange:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test setAttributes:@{@"ABC":@"EFG"} range:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test addAttribute:@"HuaQ" value:@"YYY" range:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test removeAttribute:@"HuaQ" range:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test insertAttributedString:[NSAttributedString new] atIndex:5];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test replaceCharactersInRange:NSMakeRange(5, 0) withAttributedString:[NSAttributedString new]];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                      @try {
                          [test fixAttributesInRange:NSMakeRange(5, 0)];
                      } @catch (NSException *exception) {
                          errorTimes++;
                      }
                  });
                  
                  if(errorTimes == 0)
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableAttributedString 安全气垫检查"
                                                          message:@"没有任何异常抛出\n"
                       "这是什么黑魔法"];
                  else
                      [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableAttributedString 安全气垫检查"
                                                          message:[NSString stringWithFormat:@"ERROR TIMES:%lu", (unsigned long)errorTimes]];
              }
              else {
                  NSMutableString *str = [NSMutableString string];
                  NSMutableAttributedString *test = [[NSMutableAttributedString alloc] initWithString:@"HuaQ"];
                  
                  @try {
                      [test replaceCharactersInRange:NSMakeRange(5, 0) withString:@"ABC"];
                      [test replaceCharactersInRange:NSMakeRange(0, 1) withString:nil];
                      [str appendFormat:
                       @"- [NSMutableAttributedString replaceCharactersInRange:withString:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString replaceCharactersInRange:withString:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test deleteCharactersInRange:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSMutableAttributedString deleteCharactersInRange:]\n"
                        "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString deleteCharactersInRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test setAttributes:@{@"ABC":@"EFG"} range:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSMutableAttributedString setAttributes:range:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString setAttributes:range:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test addAttribute:@"HuaQ" value:@"YYY" range:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSMutableAttributedString addAttribute:value:range:]\n"
                        "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString addAttribute:value:range:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test removeAttribute:@"HuaQ" range:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSMutableAttributedString removeAttribute:range:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString removeAttribute:range:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test insertAttributedString:[NSAttributedString new] atIndex:5];
                      [str appendFormat:
                       @"- [NSMutableAttributedString insertAttributedString:atIndex:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString insertAttributedString:atIndex:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test replaceCharactersInRange:NSMakeRange(5, 0) withAttributedString:[NSAttributedString new]];
                      [str appendFormat:
                       @"- [NSMutableAttributedString replaceCharactersInRange:withAttributedString:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString replaceCharactersInRange:withAttributedString:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  @try {
                      [test fixAttributesInRange:NSMakeRange(5, 0)];
                      [str appendFormat:
                       @"- [NSMutableAttributedString fixAttributesInRange:]\n"
                       "无异常抛出 这是什么黑魔法\n"];
                  } @catch (NSException *exception) {
                      [str appendFormat:
                       @"- [NSMutableAttributedString fixAttributesInRange:]\n"
                       "异常: %@\n"
                       "原因: %@\n",
                       exception.name, exception.reason];
                  }
                  
                  [HMDSRWTESTEnvironment showInformationTitle:@"NSMutableAttributedString 检查" message:str];
              }
          },
          @"测试 KVO 异常使用": ^ {
              if(protector_enable_logMultiplex) {
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      KVO_DEALLOC_TEST *aTest = [KVO_DEALLOC_TEST new];
                      @autoreleasepool {
                          KVO_DEALLOC_TEST *toTest = [[KVO_DEALLOC_TEST alloc] initWithTest:aTest];
                          toTest = nil;
                      }
                      
                      KVO_SELF_DEALLOC_TEST *c = [KVO_SELF_DEALLOC_TEST new];
                      @autoreleasepool {
                          KVO_SELF_DEALLOC_TEST *d = [[KVO_SELF_DEALLOC_TEST alloc] initWithTest:c];
                          d = nil;
                      }
                      
                      KVO_DEALLOC_TEST *a = [KVO_DEALLOC_TEST new];
                      @autoreleasepool {
                          KVO_DEALLOC_TEST *b = [KVO_DEALLOC_TEST new];
                          [a addObserver:b forKeyPath:@"backgroundColor" options:0 context:0];
                      }
                      a.backgroundColor = UIColor.redColor;
                      
                      KVO_DEALLOC_TEST *e = [KVO_DEALLOC_TEST new];
                      KVO_DEALLOC_TEST *f = [KVO_DEALLOC_TEST new];
                      [e addObserver:f forKeyPath:@"backgroundColor" options:0 context:0];
                      [e addObserver:f forKeyPath:@"backgroundColor" options:0 context:0];
                      [e addObserver:f forKeyPath:nil options:0 context:0];
                      [e removeObserver:f forKeyPath:nil];
                      [e removeObserver:nil forKeyPath:@"backgroundColor"];
                      [e removeObserver:nil forKeyPath:@"backgroundColor" context:NULL];
                      
                      UIView *g = [UIView new];
                      [f removeObserver:e forKeyPath:@"backgroundColor"];
                      
                  });
              }
              else {
                  KVO_DEALLOC_TEST *aTest = [KVO_DEALLOC_TEST new];
                  @autoreleasepool {
                      KVO_DEALLOC_TEST *toTest = [[KVO_DEALLOC_TEST alloc] initWithTest:aTest];
                      toTest = nil;
                  }
                  
                  KVO_SELF_DEALLOC_TEST *c = [KVO_SELF_DEALLOC_TEST new];
                  @autoreleasepool {
                      KVO_SELF_DEALLOC_TEST *d = [[KVO_SELF_DEALLOC_TEST alloc] initWithTest:c];
                      d = nil;
                  }
                  
                  KVO_DEALLOC_TEST *a = [KVO_DEALLOC_TEST new];
                  @autoreleasepool {
                      KVO_DEALLOC_TEST *b = [KVO_DEALLOC_TEST new];
                      [a addObserver:b forKeyPath:@"backgroundColor" options:0 context:0];
                  }
                  a.backgroundColor = UIColor.redColor;
                  
                  KVO_DEALLOC_TEST *e = [KVO_DEALLOC_TEST new];
                  KVO_DEALLOC_TEST *f = [KVO_DEALLOC_TEST new];
                  [e addObserver:f forKeyPath:@"backgroundColor" options:0 context:0];
                  [e addObserver:f forKeyPath:@"backgroundColor" options:0 context:0];
                  [e addObserver:f forKeyPath:nil options:0 context:0];
                  [e removeObserver:f forKeyPath:nil];
                  [e removeObserver:nil forKeyPath:@"backgroundColor"];
                  [e removeObserver:nil forKeyPath:@"backgroundColor" context:NULL];
                  
                  UIView *g = [UIView new];
                  [f removeObserver:e forKeyPath:@"backgroundColor"];
              }
              
              [HMDSRWTESTEnvironment showInformationTitle:@"KVO 异常使用" message:@"没有崩溃 安全可靠"];
          },
          @"当前 KVO 监控信息": ^ {
              NSString *str = DC_ET(DC_OB(DC_CL(HMDKeyValueObservingCenter, defaultCenter), rawDebugInformation), NSString);
              if((objc_getClass("HMDKeyValueObservingCenter")) != nil && str == nil) {
                  id center;
                  if((center = DC_CL(HMDKeyValueObservingCenter, defaultCenter)) != nil) {
                      Ivar ivar = class_getInstanceVariable(object_getClass(center), "mutex_");
                      ptrdiff_t offset = ivar_getOffset(ivar);
                      pthread_mutex_t *mutex_ref = OFFSET_OBJECT(center, offset);
                      ivar = class_getInstanceVariable(object_getClass(center), "pairArray_");
                      offset = ivar_getOffset(ivar);
                      void *pairArray_store = *((void **)OFFSET_OBJECT(center, offset));
                      NSMutableString *temp = [NSMutableString string];
                      if(pthread_mutex_lock(mutex_ref)) DEBUG_POINT;
                      NSMutableArray *pairArray_ = (__bridge NSMutableArray *)pairArray_store;
                      [pairArray_ enumerateObjectsUsingBlock: ^ (id _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
                          [temp appendFormat:@"Pair %3lu %@\n", (unsigned long)idx, pair];
                      }];
                      if(pthread_mutex_unlock(mutex_ref)) DEBUG_POINT;
                      str = temp;
                  }
              }
              [HMDSRWTESTEnvironment showInformationTitle:@"KVO 监控记录" message:str];
          },
          @"当前 KVO 异常信息": ^ {
              NSString *str = DC_ET(DC_OB(DC_CL(HMDKeyValueObservingCenter, defaultCenter), rawDebugDevatedInformation), NSString);
              if((objc_getClass("HMDKeyValueObservingCenter")) != nil && str == nil) {
                  id center;
                  if((center = DC_CL(HMDKeyValueObservingCenter, defaultCenter)) != nil) {
                      Ivar ivar = class_getInstanceVariable(object_getClass(center), "mutex_");
                      ptrdiff_t offset = ivar_getOffset(ivar);
                      pthread_mutex_t *mutex_ref = OFFSET_OBJECT(center, offset);
                      ivar = class_getInstanceVariable(object_getClass(center), "pairArray_");
                      offset = ivar_getOffset(ivar);
                      void *pairArray_store = *((void **)OFFSET_OBJECT(center, offset));
                      NSMutableString *temp = [NSMutableString string];
                      if(pthread_mutex_lock(mutex_ref)) DEBUG_POINT;
                      NSMutableArray *pairArray_ = (__bridge NSMutableArray *)pairArray_store;
                      [pairArray_ enumerateObjectsUsingBlock: ^ (id _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
                          if(DC_OB(pair, observer) == nil || DC_OB(pair, observee) == nil) {
                              [temp appendFormat:@"Pair %3lu %@\n", (unsigned long)idx, pair];
                          }
                      }];
                      if(pthread_mutex_unlock(mutex_ref)) DEBUG_POINT;
                      str = temp;
                  }
              }
              [HMDSRWTESTEnvironment showInformationTitle:@"KVO 异常信息" message:str];
          },
          @"测试 KVC 异常使用": ^ {
              if(protector_enable_logMultiplex) {
                  dispatch_apply(logMultiplex, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ (size_t notUsed) {
                      UIView *a = [[UIView alloc] init];
                      [a setValue:@"" forKey:@"backgroundColor"];
                      [a setValue:@"" forKey:@"NOT_EXIST_KEY"];
                  });
              }
              else {
                  UIView *a = [[UIView alloc] init];
                  [a setValue:@"" forKey:@"backgroundColor"];
                  [a setValue:@"" forKey:@"NOT_EXIST_KEY"];
              }
              [HMDSRWTESTEnvironment showInformationTitle:@"KVC 测试" message:@"没有崩溃 安全可靠"];
          },
          @"搭建测试环境": ^ {
              BOOL previous_shouldShowInformation = shouldShowInformation;
              shouldShowInformation = NO;
              
              if(!testENV_onceToken) {
                  if(objc_getClass("HMDANRMonitor") != nil) {
                      ca_mockClassTreeForInstanceMethod(objc_getClass("HMDANRMonitor"), sel_registerName("shouldHandleANRThisTime"), sel_registerName("MOKE_shouldHandleANRThisTime"), ^ BOOL (void) {
                          return YES;
                      });
                  }
                  testENV_onceToken = YES;
              }
              if(!hasSwizzledHMDHeimdallrConfig) [weakSelf testActions][@"允许 所有类型记录 [log enabled]"]();
              if(!hasSwizzledTTMacroManager) {
                  Class aClass = objc_getClass("TTMacroManager");
                  SEL aSEL = sel_registerName("isDebug");
                  SEL mockSEL = sel_registerName("SRW_TEST_MOKE_isDebug");
                  if(aClass != nil && aSEL != NULL && mockSEL != NULL && [aClass respondsToSelector:aSEL])
                      ca_mockClassTreeForClassMethod(aClass, aSEL, mockSEL, ^ BOOL (Class aClass) {
                          return isCurrentDEBUG;
                      });
                  DEBUG_ELSE
                  hasSwizzledTTMacroManager = YES;
              }
              isCurrentDEBUG = NO;
              if(!hasForceOpenAllModules) [weakSelf testActions][@"强制 开启所有 模块"]();
              if(!exceptionReportOnceTocken) [weakSelf testActions][@"重制 exceptionReporter 上报时间间隔"]();
              
              [weakSelf testActions][@"启动 Crash 上传"]();
              
              if(hasHookedHeimdallr_thisTime) enable_callBack = YES;
              
              shouldShowInformation = previous_shouldShowInformation;
              
              if(![[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRW_HOOK_Heimdallr]) {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHMDSRW_HOOK_Heimdallr];
                  [[NSUserDefaults standardUserDefaults] synchronize];
              }
          },
          @"允许 所有类型记录 [log enabled]": ^ {
              if(!hasSwizzledHMDHeimdallrConfig) {
                  Class aClass = objc_getClass("HMDHeimdallrConfig");
                  SEL aSEL1 = sel_registerName("isURLInBlackList:");
                  SEL aSEL2 = sel_registerName("isURLInWhiteList:");
                  SEL aSEL3 = sel_registerName("logTypeEnabled:");
                  SEL aSEL4 = sel_registerName("metricTypeEnabled:");
                  SEL aSEL5 = sel_registerName("serviceTypeEnabled:");
                  
                  SEL mokeSEL1 = sel_registerName("MOKE_isURLInBlackList:");
                  SEL mokeSEL2 = sel_registerName("MOKE_isURLInWhiteList:");
                  SEL mokeSEL3 = sel_registerName("MOKE_logTypeEnabled:");
                  SEL mokeSEL4 = sel_registerName("MOKE_metricTypeEnabled:");
                  SEL mokeSEL5 = sel_registerName("MOKE_serviceTypeEnabled:");
                  
                  if(aClass != nil &&
                     aSEL1 != NULL &&
                     aSEL2 != NULL &&
                     aSEL3 != NULL &&
                     aSEL4 != NULL &&
                     aSEL5 != NULL &&
                     mokeSEL1 != NULL &&
                     mokeSEL2 != NULL &&
                     mokeSEL3 != NULL &&
                     mokeSEL4 != NULL &&
                     mokeSEL5 != NULL) {
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL1, mokeSEL1, ^ BOOL (id thisSelf, NSString *unused) {
                          return NO;
                      });
                      
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL2, mokeSEL2, ^ BOOL (id thisSelf, NSString *unused) {
                          return YES;
                      });
                      
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL3, mokeSEL3, ^ BOOL (id thisSelf, NSString *unused) {
                          return YES;
                      });
                      
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL4, mokeSEL4, ^ BOOL (id thisSelf, NSString *unused) {
                          return YES;
                      });
                      
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL5, mokeSEL5, ^ BOOL (id thisSelf, NSString *unused) {
                          return YES;
                      });
                  }
                  DEBUG_ELSE
                  hasSwizzledHMDHeimdallrConfig = YES;
                  [HMDSRWTESTEnvironment showInformationTitle:@"允许 所有类型记录 [log enabled]"
                                                      message:@"已完成"];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"重复操作"
                                                       message:@"允许 所有类型记录 只能执行一次"];
              
          },
          @"开关 DEBUG [TTMacroManager]" SelfUpdateContentSubfix: ^ {
              if(!hasSwizzledTTMacroManager) {
                  Class aClass = objc_getClass("TTMacroManager");
                  SEL aSEL = sel_registerName("isDebug");
                  SEL mockSEL = sel_registerName("SRW_TEST_MOKE_isDebug");
                  if(aClass != nil && aSEL != NULL && mockSEL != NULL && [aClass respondsToSelector:aSEL])
                      ca_mockClassTreeForClassMethod(aClass, aSEL, mockSEL, ^ BOOL (Class aClass) {
                          return isCurrentDEBUG;
                      });
                  DEBUG_ELSE
                  hasSwizzledTTMacroManager = YES;
              }
              isCurrentDEBUG = !isCurrentDEBUG;
          },
          @"强制 开启所有 模块": ^ {
              if(!hasForceOpenAllModules) {
                  Class aClass = objc_getClass("Heimdallr");
                  SEL aSEL = sel_registerName("stopModule:");
                  SEL mokeSEL = sel_registerName("MOKE_stopModule:");
                  if(aClass != nil) {
                      ca_mockClassTreeForInstanceMethod(aClass, aSEL, mokeSEL, ^ void (id thisSelf, id notused) {
                      });
                  }
                  
                  NSArray<Class> *moduleConfigClassArray = DC_CL(HMDModuleConfig, allRemoteModuleClasses);
                  id heimdallr = DC_CL(Heimdallr, shared);
                  NSDictionary *dic = DC_OB(heimdallr, remoteModules);
                  NSArray *currentlyOpenedModules = dic.allValues;
                  for(Class eachClass in moduleConfigClassArray) {
                      id config = DC_OB(eachClass, alloc);
                      config = DC_OB(config, initWithDictionary:, @{});
                      id module = DC_OB(config, getModule);
                      if(![currentlyOpenedModules containsObject:module]) {
                          DC_OB(module, updateConfig:, config);
                          DC_OB(heimdallr, setupModule:, module);
                      }
                  }
                  
                  for(id eachModule in currentlyOpenedModules) {
                      NSNumber *isRunning = DC_OB(eachModule, isRunning);
                      if(!isRunning.boolValue)
                          DC_OB(eachModule, start);
                  }
                  hasForceOpenAllModules = YES;
                  [HMDSRWTESTEnvironment showInformationTitle:@"强制 开启所有 模块"
                                                      message:@"已完成"];
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"重复操作"
                                                       message:@"强制开启只能执行一次"];
          },
          @"重制 exceptionReporter 上报时间间隔": ^ {
              if(!exceptionReportOnceTocken) {
                  NSDictionary *dictionary = @{
                                               @"result": @{
                                                       @"is_crash":@(0),
                                                       @"message":@"success"
                                                       }
                                               };
                  DC_OB(DC_CL(HMDExceptionReporter, sharedInstance), checkIfDegradedwithResponse:, dictionary);
                  
                  if(objc_getClass("HMDExceptionReporter") != nil) {
                      ca_mockClassTreeForInstanceMethod(objc_getClass("HMDExceptionReporter"), sel_registerName("checkIfDegradedwithResponse:"), sel_registerName("MOKE_checkIfDegradedwithResponse:"), ^ void (id thisSelf, id notUsed) {
                          // EMPTY
                      });
                  }
                  exceptionReportOnceTocken = YES;
              }
              else [HMDSRWTESTEnvironment showInformationTitle:@"重制 exceptionReporter 上报时间间隔"
                                                       message:@"只能执行一次"];
          },
          @"开关 模块检测回调": ^ {
              if(!hasHookedHeimdallr_thisTime) {
                  if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRW_HOOK_Heimdallr])
                      [HMDSRWTESTEnvironment showInformationTitle:@"模块检测回调" message:@"需要重启才可启用"];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"模块检测回调" message:@"需要开启 Heimdallr 行为监控"];}
              else { if((enable_callBack = !enable_callBack)) [HMDSRWTESTEnvironment showInformationTitle:@"已开启模块回调" message:nil];
                  else [HMDSRWTESTEnvironment showInformationTitle:@"已关闭模块回调" message:nil]; }
          },
          @"开关 动态信息刷新" SelfUpdateContentSubfix : ^ {
              if(FPS_Test_DisplayLink == nil) {
                  FPS_Test_DisplayLink = [CADisplayLink displayLinkWithTarget:HMDSRWTESTEnvironment.class selector:@selector(FPS_test_displayLinkCallback:)];
                  [FPS_Test_DisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                  CFTimeInterval current = CFAbsoluteTimeGetCurrent() - 1;
                  for(NSUInteger index = 1; index < HMDSRW_FPS_TEST_AVERAGE_LENTH; index++)
                      averageArray[index] = current;
              }
              if(_timer == nil) {
                  if(@available(iOS 10.0, *)) {
                      _timer =
                      [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block: ^ (NSTimer * _Nonnull timer) {
                          [weakSelf updateDynamicCell];
                      }];
                  }
                  else {
                      static dispatch_once_t onceToken;
                      dispatch_once(&onceToken, ^ {
                          [HMDSRWTESTEnvironment showInformationTitle:@"尚未支持"
                                                              message:@"iOS 10.0 以前尚未支持刷新\n"
                                                                       "点击可以手动刷新\n"
                                                                       "(该消息只显示一次)"];
                      });
                      [weakSelf updateDynamicCell];
                  }
              }
              needUpdateValueWhenTimerCallback = !needUpdateValueWhenTimerCallback;
              [weakSelf updateSelfUpdateCellForName:@"开关 动态信息刷新" SelfUpdateContentSubfix];
          },
          @"DISK" SelfUpdateContentSubfix: ^ {
              onceDiskCellHasBeenTouched = YES;
              [weakSelf updateSelfUpdateCellForName:@"DISK" SelfUpdateContentSubfix];
          },
          @"TOGGLE 当前视图跟踪窗口" SelfUpdateContentSubfix : ^ {
              if(hasDisplayed_vc_finder) [HMDSRWTESTEnvironment hidden_vc_finder];
              else [HMDSRWTESTEnvironment display_vc_finder];
              [weakSelf updateSelfUpdateCellForName:@"TOGGLE 当前视图跟踪窗口" SelfUpdateContentSubfix];
          },
          @"测试 视图跟踪效率": ^ {
              UIWindow *aWindow2 = [UIWindow new];
              aWindow2.windowLevel = UIWindowLevelNormal;
              UIViewController *rootVC2 = [UIViewController new];
              aWindow2.rootViewController = rootVC2;
              aWindow2.hidden = NO;
              UIViewController *current = rootVC2;
              for(NSUInteger index = 0; index < 100; index++) {
                  UIViewController *child = [UIViewController new];
                  dispatch_async(dispatch_get_main_queue(), ^ {
                      [current addChildViewController:child];
                      [current.view addSubview:child.view];
                      [child didMoveToParentViewController:current];
                  });
                  current = child;
              }
              dispatch_async(dispatch_get_main_queue(), ^ {
                  CFTimeInterval child_begin = CAXNUSystemCall_timeSince1970();
                  CA_testVCFinder(rootVC2);
                  CFTimeInterval child_end = CAXNUSystemCall_timeSince1970();
                  
                  NSString *str = [NSString stringWithFormat:@"深度百层查找: %f ms", (child_end - child_begin) * MILLISEC_PER_SEC];
                  [HMDSRWTESTEnvironment showInformationTitle:@"测试结果" message:str];
              });
              dispatch_async(dispatch_get_main_queue(), ^ {
                  aWindow2.hidden = YES;
              });
          },
          @"当前 视图跟踪时间消耗": ^ {
              if(total_find_vc_amount == 0)
                  [HMDSRWTESTEnvironment showInformationTitle:@"沐黝查找" message:@"还没有查找过"];
              else {
                  NSString *str = [NSString stringWithFormat:@"当前统计次数: %lu\n当前耗时: %fms\n当前平均时耗: %fms",
                                   (unsigned long)total_find_vc_amount,
                                   current_find_time * MILLISEC_PER_SEC,
                                   total_find_vc_time / total_find_vc_amount * MILLISEC_PER_SEC];
                  [HMDSRWTESTEnvironment showInformationTitle:@"视图跟踪时间消耗" message:str];
              }
          },
          @"主控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.standardConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          },
          @"数据库控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.databaseConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          },
          @"模块控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.moduleConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          },
          @"上传控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.uploadConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          },
          @"UI Action 控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.UIActionConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          },
          @"Network 控制台": ^ {
              [weakSelf showViewController:HMDSRW_ConsoleViewController.networkConsole sender:weakSelf];
              if(!hasHookedHeimdallr_thisTime) [HMDSRWTESTEnvironment showInformationTitle:@"警告" message:@"尚未启动 Heimdallr 监控"];
          }};
    }
    return _testActionDictionary;
}

#pragma mark - Navigation Item

- (UINavigationItem *)navigationItem {
    if(_navigationItem == nil) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:@"标准测试环境"];
        if (@available(iOS 11.0, *)) {
            _navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        }
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"回到测试环境"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
        _navigationItem.backBarButtonItem = backBarButtonItem;
        _navigationItem.leftItemsSupplementBackButton = YES;
        if (@available(iOS 11.0, *)) {
            _navigationItem.hidesSearchBarWhenScrolling = YES;
        }
    }
    return _navigationItem;
}

#pragma mark - Adjust Appearance

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.parentViewController != nil) {
        if([self.parentViewController isKindOfClass:UINavigationController.class]) {
            CGFloat textGray = 0.2;
            CGFloat buttonGray = 0.4;
            UINavigationController *nv = (UINavigationController *)self.parentViewController;
            UINavigationBar *bar = nv.navigationBar;
            if (@available(iOS 11.0, *)) {
                bar.prefersLargeTitles = YES;
                bar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:textGray green:textGray blue:textGray alpha:1.0]};
                bar.tintColor = [UIColor colorWithRed:buttonGray green:buttonGray blue:buttonGray alpha:1.0];
            }
            bar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:textGray green:textGray blue:textGray alpha:1.0]};
        }
    }
}

#pragma mark - FPS

+ (void)FPS_control_displayLinkCallback:(CADisplayLink *)sender {
    CFTimeInterval stuckTime = 1.0 / current_FPS_level;
    double sec;
    double frac = modf(stuckTime, &sec);
    struct timespec ts;
    ts.tv_sec = sec;
    ts.tv_nsec = frac * NSEC_PER_SEC;
    nanosleep(&ts, NULL);
}

+ (void)FPS_test_displayLinkCallback:(CADisplayLink *)sender {
#if HMDSRW_FPS_TEST_AVERAGE_LENTH < 2
#error NO LESS THAN 2
#endif
    CFTimeInterval current = CFAbsoluteTimeGetCurrent();
    memmove(averageArray + 1, averageArray, (HMDSRW_FPS_TEST_AVERAGE_LENTH - 1) * sizeof(CFTimeInterval));
    averageArray[0] = current;
    current_FPS = (HMDSRW_FPS_TEST_AVERAGE_LENTH - 1) / (current - averageArray[HMDSRW_FPS_TEST_AVERAGE_LENTH - 1]);
}

#pragma mark - Load Launch

+ (void)load {
    [HMDSRWTESTEnvironment launchStuck];
#ifdef Launch_simbol
    [HMDSRWTESTEnvironment launchHeimdallrSimbol];
#else
    [HMDSRWTESTEnvironment mayLaunchHeimdallrSimbol];
#endif
#ifndef Heimdallr_inspect
    if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRW_HOOK_Heimdallr]) {
#endif
        hasHookedHeimdallr_thisTime = YES;
        [HMDSRWTESTEnvironment hookANRMonitor];
        [HMDSRWTESTEnvironment initializeKVOPairDescription];
        [HMDSRWTESTEnvironment hookDatabase];
        [HMDSRWTESTEnvironment hookOOMCrash];
        [HMDSRWTESTEnvironment hookWatchdog];
        [HMDSRWTESTEnvironment hookHeimdallrModule];
        [HMDSRWTESTEnvironment hookPerformanceReport];
        [HMDSRWTESTEnvironment hookUIAction];
        [HMDSRWTESTEnvironment hookExceptionReporter];
        [HMDSRWTESTEnvironment hookHTTPTracker];
        [HMDSRWTESTEnvironment hookProtect];
        [HMDSRWTESTEnvironment hookCrash];
#ifndef Heimdallr_inspect
    }
#endif
}

+ (void)launchHeimdallrSimbol {
    hasLaunchedSimbol_thiTime = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
        HMDSRW_floatingWindow.standard.hidden = NO;
    });
}

+ (void)mayLaunchHeimdallrSimbol {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRWTestEnvironmentMayLaunchHeimdallrSimbolKey]) {
        hasLaunchedSimbol_thiTime = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            HMDSRW_floatingWindow.standard.hidden = NO;
        });
    }
}

+ (void)launchStuck {
    if([[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRWTestEnvironmentLanchStuckKey]) {
        sleep(5);
    }
}

+ (void)hookANRMonitor {
    SEL sel = sel_registerName("startWithAnrBlock:");
    SEL moke_sel = sel_registerName("MOKE_startWithAnrBlock:");
    
    typedef void (^anr_block_t)(BOOL isANR, NSTimeInterval blockDuration, NSString *stack);
    
    if(objc_getClass("HMDANRMonitor") != nil) {
        ca_mockClassTreeForInstanceMethod(objc_getClass("HMDANRMonitor"), sel, moke_sel, ^ void (id thisSelf, anr_block_t block) {
            anr_block_t mockBlock = ^ (BOOL isANR, NSTimeInterval blockDuration, NSString *stack) {
                [HMDSRW_ConsoleViewController.moduleConsole log:[NSString stringWithFormat:@"[ANR] blocked %f ms\n", blockDuration] color:CONSOLE_COLOR_MODULE_DETECT];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    if(enable_callBack) {
                        [HMDSRWTESTEnvironment showInformationTitle:@"ANR 报告" message:[NSString stringWithFormat:@"BlockDuration: %f 毫秒", blockDuration]];
                    }
                });
                block(isANR, blockDuration, stack);
            };
            DC_OB(thisSelf, MOKE_startWithAnrBlock:, mockBlock);
        });
    }
}

+ (void)initializeKVOPairDescription {
    Class aClass = objc_getClass("HMDKeyValueObservingPair");
    SEL aSEL = sel_registerName("description");
    if(aClass != nil && !ca_classHasInstanceMethod(aClass, aSEL)) {
        IMP imp = imp_implementationWithBlock(^ NSString * (id thisSelf) {
            Class thisClass = object_getClass(thisSelf);
            Ivar ivar = class_getInstanceVariable(thisClass, "observee_");
            id observee_ = object_getIvar(thisSelf, ivar);
            ivar = class_getInstanceVariable(thisClass, "observeeClass_");
            Class observeeClass_ = object_getIvar(thisSelf, ivar);
            ivar = class_getInstanceVariable(thisClass, "observer_");
            id observer_ = object_getIvar(thisSelf, ivar);
            ivar = class_getInstanceVariable(thisClass, "observerClass_");
            Class observerClass_ = object_getIvar(thisSelf, ivar);
            ivar = class_getInstanceVariable(thisClass, "keypath_");
            NSString *keypath_ = object_getIvar(thisSelf, ivar);
            ivar = class_getInstanceVariable(thisClass, "option_");
            ptrdiff_t offset = ivar_getOffset(ivar);
            NSKeyValueObservingOptions option_ = *((NSKeyValueObservingOptions *)OFFSET_OBJECT(thisSelf, offset));
            ivar = class_getInstanceVariable(thisClass, "context_");
            offset = ivar_getOffset(ivar);
            void *context_ = *((void **)OFFSET_OBJECT(thisSelf, offset));
            ivar = class_getInstanceVariable(thisClass, "actived_");
            offset = ivar_getOffset(ivar);
            BOOL actived_ = *((BOOL *)OFFSET_OBJECT(thisSelf, offset));
            return [NSString stringWithFormat:
                    @"<HMDKeyValueObservingPair %p>\n"
                    "\tobservee:%@\n"
                    "\tobserver:%@\n"
                    "\tkeypath:%@\n"
                    "\toption:%lu\n"
                    "\tcontext:%p\n"
                    "\tactive:%s",
                    self, observee_?:[NSString stringWithFormat:@"<对象已释放曾经是 %@>", NSStringFromClass(observeeClass_)], observer_?:[NSString stringWithFormat:@"<对象已释放曾经是 %@>", NSStringFromClass(observerClass_)], keypath_,
                    (unsigned long)option_, context_, actived_?"YES":"NO"];
        });
        class_addMethod(aClass, aSEL, imp, "@@:");
    }
}

+ (void)hookDatabase {
    
    id block1 = ^ BOOL (id thisSelf, NSString *tableName, __unsafe_unretained Class cls) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_createTable:withClass:, tableName, cls), NSNumber);
        DEBUG_ASSERT(value != nil && tableName != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] createTable:%@ %@\n", tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, createTable:withClass:, block1);
    
    id block2 = ^ BOOL (id thisSelf, id object, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_insertObject:into:, object, tableName), NSNumber);
        DEBUG_ASSERT(value != nil && tableName != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] insertObject:%p into:%@ %@\n", object, tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, insertObject:into:, block2);
    
    id block3 = ^ BOOL (id thisSelf, NSArray<id> *objects, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_insertObjects:into:, objects, tableName), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] insertObjects:%p into:%@ %@\n", objects, tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, insertObjects:into:, block3);
    
    id block4 = ^ id (id thisSelf, NSString *tableName, Class class, id andConditions, id orConditions) {
        id value = DC_OB(thisSelf, MOKE_getOneObjectWithTableName:class:andConditions:orConditions:, tableName, class, andConditions, orConditions);
        NSString *str = [NSString stringWithFormat:@"[Database] getOneObjectWithTableName:%@ class:%@ andConditions:orConditions:%@\n", tableName, NSStringFromClass(class), value == nil?@" return nil":@""];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, getOneObjectWithTableName:class:andConditions:orConditions:, block4);
    
    id block5 = ^ NSArray *(id thisSelf, NSString *tableName, Class class) {
        NSArray *value = DC_ET(DC_OB(thisSelf, MOKE_getAllObjectsWithTableName:class:, tableName, class), NSArray);
//        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] getAllObjectsWithTableName:%@ class:%@ return count %lu\n", tableName, NSStringFromClass(class), (unsigned long)value.count];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, getAllObjectsWithTableName:class:, block5);
    
    id block6 = ^ NSArray *(id thisSelf, NSString *tableName, Class class, id andConditions, id orConditions, NSString *orderingProperty, NSInteger orderingType) {
        NSArray *value = DC_ET(DC_OB(thisSelf, MOKE_getObjectsWithTableName:class:andConditions:orConditions:orderingProperty:orderingType:, tableName, class, andConditions, orConditions, orderingProperty, orderingType), NSArray);
//        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] getOneObjectWithTableName:%@ class:%@ andConditions:orConditions:orderingProperty:%@ orderingType:%lu return count %lu\n", tableName, NSStringFromClass(class), orderingProperty, (unsigned long)orderingType, (unsigned long)value.count];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, getObjectsWithTableName:class:andConditions:orConditions:orderingProperty:orderingType:, block6);
    
    id block7 = ^ NSArray *(id thisSelf, NSString *tableName, Class class, id andConditions, id orConditions, NSInteger limitCount) {
        NSArray *value = DC_ET(DC_OB(thisSelf, MOKE_getObjectsWithTableName:class:andConditions:orConditions:limit:, tableName, class, andConditions, orConditions, limitCount), NSArray);
        NSString *str = [NSString stringWithFormat:@"[Database] getOneObjectWithTableName:%@ class:%@ andConditions:orConditions:limit:%lu return count %lu\n", tableName, NSStringFromClass(class), (unsigned long)limitCount, (unsigned long)value.count];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, getObjectsWithTableName:class:andConditions:orConditions:limit:, block7);
    
    id block8 = ^ BOOL (id thisSelf, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_deleteAllObjectsFromTable:, tableName), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] deleteAllObjectsFromTable:%@ %@\n", tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, deleteAllObjectsFromTable:, block8);
    
    id block9 = ^ BOOL (id thisSelf, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_dropTable:, tableName), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] dropTable:%@ %@\n", tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, dropTable:, block9);
    
    id block10 = ^ BOOL (id thisSelf, NSString *tableName, id andConditions, id orConditions) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_deleteObjectsFromTable:andConditions:orConditions:, tableName, andConditions, orConditions), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] deleteObjectsFromTable:%@ andConditions:orConditions: %@\n", tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, deleteObjectsFromTable:andConditions:orConditions:, block10);
    
    id block11 = ^ BOOL (id thisSelf, NSString *tableName, id andConditions, id orConditions, NSInteger limitCount) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_deleteObjectsFromTable:andConditions:orConditions:limit:, tableName, andConditions, orConditions, limitCount), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] deleteObjectsFromTable:%@ andConditions:orConditions:limitCount:%lu %@\n", tableName, (unsigned long)limitCount, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, deleteObjectsFromTable:andConditions:orConditions:limit:, block11);
    
    id block12 = ^ BOOL (id thisSelf, NSString *tableName, long long maxSize) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_deleteObjectsFromTable:limitToMaxSize:, tableName, maxSize), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] deleteObjectsFromTable:%@ limitToMaxSize:%lld %@\n", tableName, (long long)maxSize, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, deleteObjectsFromTable:limitToMaxSize:, block12);
    
    id block13 = ^ BOOL (id thisSelf, NSString *tableName, NSString *property, id propertyValue, id object, NSArray *andConditions, NSArray *orConditions) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_updateRowsInTable:onProperty:propertyValue:withObject:andConditions:orConditions:, tableName, property, propertyValue, object, andConditions, orConditions), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] updateRowsInTable:%@ onProperty:%@ propertyValue:withObject:andConditions:orConditions: %@\n", tableName, property, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, updateRowsInTable:onProperty:propertyValue:withObject:andConditions:orConditions:, block13);
    
    id block14 = ^ BOOL (id thisSelf, NSString *tableName, NSString *property, id propertyValue, id object, NSArray *andConditions, NSArray *orConditions, NSInteger limitCount) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_updateRowsInTable:onProperty:propertyValue:withObject:andConditions:orConditions:limit:, tableName, property, propertyValue, object, andConditions, orConditions, limitCount), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] updateRowsInTable:%@ onProperty:%@ propertyValue:withObject:andConditions:orConditions:limit:%lu %@\n", tableName, property, (unsigned long)limitCount, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, updateRowsInTable:onProperty:propertyValue:withObject:andConditions:orConditions:limit:, block14);
    
    id block15 = ^ BOOL (id thisSelf, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_isTableExistsForName:, tableName), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] isTableExistsForName:%@ %@\n", tableName, value.boolValue?@"success":@"failed"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.boolValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, isTableExistsForName:, block15);
    
    id block16 = ^ long long (id thisSelf, NSString *tableName) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_recordCountForTable:, tableName), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] recordCountForTable:%@ %@\n", tableName, value];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.longLongValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, recordCountForTable:, block16);
    
    id block17 = ^ unsigned long long (id thisSelf) {
        NSNumber *value = DC_ET(DC_OB(thisSelf, MOKE_dbFileSize), NSNumber);
        DEBUG_ASSERT(value != nil);
        NSString *str = [NSString stringWithFormat:@"[Database] dbFileSize %@\n", value];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
        return value.unsignedLongLongValue;
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, dbFileSize, block17);
    
    id block18 = ^ (id thisSelf) {
        id mustNil = DC_OB(thisSelf, MOKE_vacuumIfNeeded);
        DEBUG_ASSERT(mustNil == nil);
        NSString *str = [NSString stringWithFormat:@"[Database] vacuumIfNeeded\n"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, vacuumIfNeeded, block18);
    
    id block19 = ^ (id thisSelf) {
        id mustNil = DC_OB(thisSelf, MOKE_immediatelyActiveVacuum);
        DEBUG_ASSERT(mustNil == nil);
        NSString *str = [NSString stringWithFormat:@"[Database] immediatelyActiveVacuum\n"];
        [HMDSRW_ConsoleViewController.databaseConsole log:str color:CONSOLE_COLOR_DATABASE];
    };
    
    CA_mockClassTreeForInstanceMethod(HMDStoreFMDB, immediatelyActiveVacuum, block19);
}

+ (void)hookOOMCrash {
    typedef enum SRW_HMDApplicationRelaunchReason {
        SRW_HMDApplicationRelaunchReasonApplicationUpdate,
        SRW_HMDApplicationRelaunchReasonSystemUpdate,
        SRW_HMDApplicationRelaunchReasonTerminate,
        SRW_HMDApplicationRelaunchReasonBackgroundExit,
        SRW_HMDApplicationRelaunchReasonExit,
        SRW_HMDApplicationRelaunchReasonDebug,
        SRW_HMDApplicationRelaunchReasonDetectorStopped,
        SRW_HMDApplicationRelaunchReasonFOOM,
        SRW_HMDApplicationRelaunchReasonNodata
    } SRW_HMDApplicationRelaunchReason;
    
    id block1 = ^ (id thisSelf, id record, NSString * thatTimeInternalSession) {
        DC_OB(thisSelf, MOKE_OOMCrashDidFindPossibleOOMCrashWithRecord:intervalSession:, record, thatTimeInternalSession);
        NSString *str = [NSString stringWithFormat:@"[OOMCrash] collect one possible record exclusive begin\n"
                                                    "internalSession:%@\n\n", thatTimeInternalSession];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    CA_mockClassTreeForInstanceMethod(HMDOOMCrashTracker, OOMCrashDidFindPossibleOOMCrashWithRecord:intervalSession:, block1);
    
    id block2 = ^ (id thisSelf) {
        DC_OB(thisSelf, MOKE_excludedCompleteWithoutOOMCrash);
        NSString *str = [NSString stringWithFormat:@"[OOMCrash] exclusive complete [其他模块检测成功]\n"];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    CA_mockClassTreeForInstanceMethod(HMDOOMCrashTracker, excludedCompleteWithoutOOMCrash, block2);
    
    id block3 = ^ (id thisSelf) {
        DC_OB(thisSelf, MOKE_excludedCompleteAndDetectOOMCrash);
        NSString *str = [NSString stringWithFormat:@"[OOMCrash] application relaunch reason: OOM Crash [检测成功]\n"];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    CA_mockClassTreeForInstanceMethod(HMDOOMCrashTracker, excludedCompleteAndDetectOOMCrash, block3);
    
    id block4 = ^ (id thisSelf, SRW_HMDApplicationRelaunchReason reason) {
        DC_OB(thisSelf, MOKE_crashDetectorDidNotDetectOOMCrashWithRelaunchReason:, reason);
        NSString *reasonString;
        switch (reason) {
            case SRW_HMDApplicationRelaunchReasonApplicationUpdate:
                reasonString = @"应用更新";
                break;
            case SRW_HMDApplicationRelaunchReasonSystemUpdate:
                reasonString = @"系统更新";
                break;
            case SRW_HMDApplicationRelaunchReasonTerminate:
                reasonString = @"用户主动结束";
                break;
            case SRW_HMDApplicationRelaunchReasonExit:
                reasonString = @"应用主动退出";
                break;
            case SRW_HMDApplicationRelaunchReasonBackgroundExit:
                reasonString = @"应用后台退出";
                break;
            case SRW_HMDApplicationRelaunchReasonDebug:
                reasonString = @"应用被调试";
                break;
            case SRW_HMDApplicationRelaunchReasonDetectorStopped:
                reasonString = @"检测模块被关闭";
                break;
            case SRW_HMDApplicationRelaunchReasonNodata:
                reasonString = @"暂无数据";
                break;
            case SRW_HMDApplicationRelaunchReasonFOOM:
                reasonString = @"前台OOM";
                break;
            default:
                NSAssert(NO, @"【严重错误】请保留现场环境，及时联系 Heimdallr 开发者 \n"
                         " [FATAL EOOR] Please preserve current environment"
                         " and contact Heimdallr developer ASAP");
                reasonString = @"状态无法解析";
                break;
        }
        NSString *str = [NSString stringWithFormat:@"[OOMCrash] application relaunch reason: %@\n", reasonString];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    if([objc_getClass("HMDOOMCrashTracker") instancesRespondToSelector:sel_registerName("crashDetectorDidNotDetectOOMCrashWithRelaunchReason:")])
        CA_mockClassTreeForInstanceMethod(HMDOOMCrashTracker, crashDetectorDidNotDetectOOMCrashWithRelaunchReason:, block4);
}

+ (void)hookWatchdog {
    id block1 = ^ (id thisSelf, NSDictionary *dictionary) {
        id mustNil = DC_OB(thisSelf, MOKE_watchDogDidDetectSystemKillWithData:, dictionary);
        DEBUG_ASSERT(mustNil == nil);
        NSString *internalSessionID = DC_ET(dictionary[kHMD_WatchDog_exposedData_internalSessionIDKey], NSString);
        NSString *sessionID = DC_ET(dictionary[kHMD_WatchDog_exposedData_sessionIDKey], NSString);
        NSString *lastScene = DC_ET(dictionary[kHMD_WatchDog_exposedData_lastSceneKey], NSString);
        NSNumber *timeoutDuration = DC_ET(dictionary[kHMD_WatchDog_exposedData_timeoutDurationKey], NSNumber);
        NSNumber *memoryUsage = DC_ET(dictionary[kHMD_WatchDog_exposedData_memoryUsageKey], NSNumber);
        NSNumber *freeDiskUsage = DC_ET(dictionary[kHMD_WatchDog_exposedData_freeDiskUsageKey], NSNumber);
        NSNumber *timeStamp = DC_ET(dictionary[kHMD_WatchDog_exposedData_timeStampKey], NSNumber);
        NSNumber *inAppTime = DC_ET(dictionary[kHMD_WatchDog_exposedData_inAppTimeKey], NSNumber);
        NSString *backtraceString = DC_ET(dictionary[kHMD_WatchDog_exposedData_backtraceKey], NSString);
        NSString *connectionTypeName = DC_ET(dictionary[kHMD_WatchDog_exposedData_connectTypeNameKey], NSString);
        NSNumber *isBackground = DC_ET(dictionary[kHMD_WatchDog_exposedData_isBackgroundKey], NSNumber);
        NSNumber *isLaunchCrash = DC_ET(dictionary[kHMD_WatchDog_exposedData_isLaunchCrashKey], NSNumber);
        DEBUG_ASSERT(internalSessionID != nil);
        DEBUG_ASSERT(sessionID != nil);
        DEBUG_ASSERT(lastScene != nil);
        DEBUG_ASSERT(timeoutDuration != nil);
        DEBUG_ASSERT(memoryUsage != nil);
        DEBUG_ASSERT(freeDiskUsage != nil);
        DEBUG_ASSERT(timeStamp != nil);
        DEBUG_ASSERT(inAppTime != nil);
        DEBUG_ASSERT(backtraceString != nil);
        DEBUG_ASSERT(connectionTypeName != nil);
        DEBUG_ASSERT(isBackground != nil);
        DEBUG_ASSERT(isLaunchCrash != nil);
        NSMutableString *str = [NSMutableString stringWithFormat:@"[Watchdog] application relaunch reason: system kill [系统强杀] timeout %f sec\n", timeoutDuration.doubleValue];
        [str appendFormat:@" internalSessionID: %@\n", internalSessionID];
        [str appendFormat:@"         sessionID: %@\n", sessionID];
        [str appendFormat:@"         lastScene: %@\n", lastScene];
        [str appendFormat:@"       memoryUsage: %@\n", memoryUsage];
        [str appendFormat:@"     freeDiskUsage: %@\n", freeDiskUsage];
        [str appendFormat:@"         timeStamp: %@\n", timeStamp];
        [str appendFormat:@"         inAppTime: %@\n", inAppTime];
        [str appendFormat:@"connectionTypeName: %@\n", connectionTypeName];
        [str appendFormat:@"         lastScene: %@\n", lastScene];
        [str appendFormat:@"      isBackground: %@\n", isBackground];
        [str appendFormat:@"     isLaunchCrash: %@\n", isLaunchCrash];
        [str appendFormat:@"      stack length: %lu\n\n", (unsigned long)backtraceString.length];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    
    if(objc_getClass("HMDWatchDogTracker") != nil && ca_classHasInstanceMethod(objc_getClass("HMDWatchDogTracker"), sel_registerName("watchDogDidDetectSystemKillWithData:")))
        CA_mockClassTreeForInstanceMethod(HMDWatchDogTracker, watchDogDidDetectSystemKillWithData:, block1);
    
    id block2 = ^ (id thisSelf) {
        id mustNil = DC_OB(thisSelf, MOKE_watchDogDidNotHappenLastTime);
        DEBUG_ASSERT(mustNil == nil);
        [HMDSRW_ConsoleViewController.moduleConsole log:@"[Watchdog] did not happen last time\n" color:CONSOLE_COLOR_MODULE_DETECT];
    };
    
    if(objc_getClass("HMDWatchDogTracker") != nil && ca_classHasInstanceMethod(objc_getClass("HMDWatchDogTracker"), sel_registerName("watchDogDidNotHappenLastTime")))
        CA_mockClassTreeForInstanceMethod(HMDWatchDogTracker, watchDogDidNotHappenLastTime, block2);
    
    id block3 = ^ (id thisSelf, NSDictionary *dictionary) {
        id mustNil = DC_OB(thisSelf, MOKE_watchDogDidDetectUserForceQuitWithData:, dictionary);
        DEBUG_ASSERT(mustNil == nil);
        NSString *lastScene =       DC_ET(dictionary[kHMD_WatchDog_exposedData_lastSceneKey], NSString);
        NSNumber *timeoutDuration = DC_ET(dictionary[kHMD_WatchDog_exposedData_timeoutDurationKey], NSNumber);
        NSNumber *memoryUsage =     DC_ET(dictionary[kHMD_WatchDog_exposedData_memoryUsageKey], NSNumber);
        NSNumber *freeDiskUsage =   DC_ET(dictionary[kHMD_WatchDog_exposedData_freeMemoryUsageKey], NSNumber);
        NSNumber *timeStamp =       DC_ET(dictionary[kHMD_WatchDog_exposedData_timeStampKey], NSNumber);
        NSNumber *inAppTime =       DC_ET(dictionary[kHMD_WatchDog_exposedData_inAppTimeKey], NSNumber);
        NSNumber *freeMemoryUsage = DC_ET(dictionary[kHMD_WatchDog_exposedData_freeDiskUsageKey], NSNumber);
        DEBUG_ASSERT(lastScene != nil);
        DEBUG_ASSERT(timeoutDuration != nil);
        DEBUG_ASSERT(memoryUsage != nil);
        DEBUG_ASSERT(freeDiskUsage != nil);
        DEBUG_ASSERT(inAppTime != nil);
        DEBUG_ASSERT(freeMemoryUsage != nil);
        NSMutableString *str = [NSMutableString stringWithFormat:@"[Watchdog] application relaunch reason: user's force quit [用户强退] threshold %f sec\n", timeoutDuration.doubleValue];
        [str appendFormat:@"      lastScene: %@\n", lastScene];
        [str appendFormat:@"    memoryUsage: %@\n", memoryUsage];
        [str appendFormat:@"  freeDiskUsage: %@\n", freeDiskUsage];
        [str appendFormat:@"      timeStamp: %@\n", timeStamp];
        [str appendFormat:@"      inAppTime: %@\n", inAppTime];
        [str appendFormat:@"freeMemoryUsage: %@\n\n", freeMemoryUsage];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
    };
    if(objc_getClass("HMDWatchDogTracker") != nil && ca_classHasInstanceMethod(objc_getClass("HMDWatchDogTracker"), sel_registerName("watchDogDidDetectSystemKillWithData:")))
        CA_mockClassTreeForInstanceMethod(HMDWatchDogTracker, watchDogDidDetectUserForceQuitWithData:, block3);
}

+ (void)hookHeimdallrModule {
    id block1 = ^ (id thisSelf) {
        DC_OB(thisSelf, MOKE_start);
        NSNumber *running = DC_ET(DC_OB(thisSelf, isRunning), NSNumber);
        DEBUG_ASSERT(running != nil);
        NSString *str = [NSString stringWithFormat:@"[%@] launch %@\n", NSStringFromClass(DC_OB(thisSelf, class)), running.boolValue?@"complete":@"failed !"];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_LIFE];
    };
    CA_mockClassLeavesForInstanceMethod(HeimdallrModule, start, block1);
    
    id block2 = ^ (id thisSelf) {
        DC_OB(thisSelf, MOKE_stop);
        NSNumber *running = DC_ET(DC_OB(thisSelf, isRunning), NSNumber);
        DEBUG_ASSERT(running != nil);
        NSString *str = [NSString stringWithFormat:@"[%@] stop %@\n", NSStringFromClass(DC_OB(thisSelf, class)), (!running.boolValue)?@"complete":@"failed !"];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_LIFE];
    };
    CA_mockClassLeavesForInstanceMethod(HeimdallrModule, stop, block2);
    
    id block3 = ^ (id thisSelf, id config) {
        id mustNil = DC_OB(thisSelf, MOKE_updateConfig:, config);
        DEBUG_ASSERT(mustNil == nil);
        NSString *str = [NSString stringWithFormat:@"[%@] updated config\n", NSStringFromClass(DC_OB(thisSelf, class))];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_LIFE];
    };
    CA_mockClassLeavesForInstanceMethod(HeimdallrModule, updateConfig:, block3);
    
    id block4 = ^ (id thisSelf, id config) {
        id mustNil = DC_OB(thisSelf, MOKE_cleanupWithConfig:, config);
        DEBUG_ASSERT(mustNil == nil);
        NSString *str = [NSString stringWithFormat:@"[%@] cleanup\n", NSStringFromClass(DC_OB(thisSelf, class))];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_LIFE];
    };
    CA_mockClassLeavesForInstanceMethod(HeimdallrModule, cleanupWithConfig:, block4);
}

+ (void)hookExceptionReporter {
    static pthread_mutex_t local_mtx = PTHREAD_MUTEX_INITIALIZER;
    static NSMutableArray *hookedPerformaceModule;
    id block1 = ^ (id thisSelf, id module) {
        Class moduleClass = object_getClass(module);
        pthread_mutex_lock(&local_mtx);
        if(hookedPerformaceModule == nil) hookedPerformaceModule = [NSMutableArray array];
        if(![hookedPerformaceModule containsObject:moduleClass]) {
            
            if(class_respondsToSelector(moduleClass, sel_registerName("pendingNormalExceptionData")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_pendingNormalExceptionData"))) {
                id block = ^ NSArray *(id thisSelf) {
                    NSArray *array = DC_ET(DC_OB(thisSelf, MOKE_pendingNormalExceptionData), NSArray);
                    NSString *str = [NSString stringWithFormat:@"[%@] Exception %lu\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)array.count];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(array.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    return array;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("pendingNormalExceptionData"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("pendingNormalExceptionData"), sel_registerName("MOKE_pendingNormalExceptionData"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("pendingNormalUserExceptionData")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_pendingNormalUserExceptionData"))) {
                id block = ^ NSArray *(id thisSelf) {
                    NSArray *array = DC_ET(DC_OB(thisSelf, MOKE_pendingNormalUserExceptionData), NSArray);
                    NSString *str = [NSString stringWithFormat:@"[%@] Exception [USER] %lu\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)array.count];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(array.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    return array;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("pendingNormalUserExceptionData"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("pendingNormalUserExceptionData"), sel_registerName("MOKE_pendingNormalUserExceptionData"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("pendingDebugRealExceptionDataWithConfig:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_pendingDebugRealExceptionDataWithConfig:"))) {
                id block = ^ NSArray * (id thisSelf, id debugRealConfig) {
                    NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
                    NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
                    NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
                    NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
                    
                    DEBUG_ASSERT(value_fetchStartTime != nil);
                    DEBUG_ASSERT(value_fetchEndTime != nil);
                    DEBUG_ASSERT(value_isNeedWifi != nil);
                    DEBUG_ASSERT(value_limitCnt != nil);
                    
                    NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
                    NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
                    BOOL isNeedWifi = value_isNeedWifi.boolValue;
                    NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
                    
                    NSArray * result = DC_OB(thisSelf, MOKE_pendingDebugRealExceptionDataWithConfig:, debugRealConfig);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] DebugReal Upload %lu%@ limited:%lu\n[%@ - %@]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)result.count, isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(result.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    
                    return result;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("pendingDebugRealExceptionDataWithConfig:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("pendingDebugRealExceptionDataWithConfig:"), sel_registerName("MOKE_pendingDebugRealExceptionDataWithConfig:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("pendingDebugRealUserExceptionDataWithConfig:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_pendingDebugRealUserExceptionDataWithConfig:"))) {
                id block = ^ NSArray * (id thisSelf, id debugRealConfig) {
                    NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
                    NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
                    NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
                    NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
                    
                    DEBUG_ASSERT(value_fetchStartTime != nil);
                    DEBUG_ASSERT(value_fetchEndTime != nil);
                    DEBUG_ASSERT(value_isNeedWifi != nil);
                    DEBUG_ASSERT(value_limitCnt != nil);
                    
                    NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
                    NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
                    BOOL isNeedWifi = value_isNeedWifi.boolValue;
                    NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
                    
                    NSArray * result = DC_OB(thisSelf, MOKE_pendingDebugRealUserExceptionDataWithConfig:, debugRealConfig);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] DebugReal [USER] Upload %lu%@ limited:%lu\n[%@ - %@]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)result.count, isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(result.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    
                    return result;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("pendingDebugRealUserExceptionDataWithConfig:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("pendingDebugRealUserExceptionDataWithConfig:"), sel_registerName("MOKE_pendingDebugRealUserExceptionDataWithConfig:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("cleanupExceptionDataWithConfig:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_cleanupExceptionDataWithConfig:"))) {
                id block = ^ (id thisSelf, id debugRealConfig) {
                    NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
                    NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
                    NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
                    NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
                    
                    DEBUG_ASSERT(value_fetchStartTime != nil);
                    DEBUG_ASSERT(value_fetchEndTime != nil);
                    DEBUG_ASSERT(value_isNeedWifi != nil);
                    DEBUG_ASSERT(value_limitCnt != nil);
                    
                    NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
                    NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
                    BOOL isNeedWifi = value_isNeedWifi.boolValue;
                    NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
                    
                    DC_OB(thisSelf, MOKE_cleanupExceptionDataWithConfig:, debugRealConfig);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] DebugReal Cleanup%@ limited:%lu\n[%@ - %@]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:CONSOLE_COLOR_UPLOAD_MODULE_CLEANUP];
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("cleanupExceptionDataWithConfig:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("cleanupExceptionDataWithConfig:"), sel_registerName("MOKE_cleanupExceptionDataWithConfig:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("exceptionReporterDidReceiveResponse:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("exceptionReporterDidReceiveResponse:"))) {
                id block = ^ (id thisSelf, BOOL isSuccess) {
                    
                    DC_OB(thisSelf, MOKE_exceptionReporterDidReceiveResponse:, isSuccess);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] Exception Cleanup [report:%s]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), isSuccess?"SCCUESS":"FAILED!"];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:CONSOLE_COLOR_UPLOAD_MODULE_CLEANUP];
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("exceptionReporterDidReceiveResponse:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("exceptionReporterDidReceiveResponse:"), sel_registerName("MOKE_exceptionReporterDidReceiveResponse:"), block);
            }
            
            [hookedPerformaceModule addObject:moduleClass];
        }
        pthread_mutex_unlock(&local_mtx);
        
        DC_OB(thisSelf, MOKE_addReportModule:, module);
    };
    CA_mockClassTreeForInstanceMethod(HMDExceptionReporter, addReportModule:, block1);
}

+ (void)hookPerformanceReport {
    static pthread_mutex_t local_mtx = PTHREAD_MUTEX_INITIALIZER;
    static NSMutableArray *hookedPerformaceModule;
    id block1 = ^ (id thisSelf, id module) {
        Class moduleClass = object_getClass(module);
        pthread_mutex_lock(&local_mtx);
        if(hookedPerformaceModule == nil) hookedPerformaceModule = [NSMutableArray array];
        
        if(![hookedPerformaceModule containsObject:moduleClass]) {
            
            if(class_respondsToSelector(moduleClass, sel_registerName("metricCountPerformanceData")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_metricCountPerformanceData"))) {
                id block = ^ NSArray *(id thisSelf) {
                    NSArray *array = DC_ET(DC_OB(thisSelf, MOKE_metricCountPerformanceData), NSArray);
                    NSString *str = [NSString stringWithFormat:@"[%@] metricCount %lu\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)array.count];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(array.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    return array;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("metricCountPerformanceData"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("metricCountPerformanceData"), sel_registerName("MOKE_metricCountPerformanceData"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("metricTimerPerformanceData")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_metricTimerPerformanceData"))) {
                id block = ^ NSArray *(id thisSelf) {
                    NSArray *array = DC_ET(DC_OB(thisSelf, MOKE_metricTimerPerformanceData), NSArray);
                    NSString *str = [NSString stringWithFormat:@"[%@] metricTimer %lu\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)array.count];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(array.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    return array;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("metricTimerPerformanceData"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("metricTimerPerformanceData"), sel_registerName("MOKE_metricTimerPerformanceData"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("performanceDataWithCountLimit:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_performanceDataWithCountLimit:"))) {
                id block = ^ NSArray *(id thisSelf, NSInteger limitCount) {
                    NSArray *array = DC_ET(DC_OB(thisSelf, MOKE_performanceDataWithCountLimit:, limitCount), NSArray);
                    NSString *str = [NSString stringWithFormat:@"[%@] Performance %lu limited %lu\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)array.count, (unsigned long)limitCount];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(array.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    return array;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("performanceDataWithCountLimit:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("performanceDataWithCountLimit:"), sel_registerName("MOKE_performanceDataWithCountLimit:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("performanceDataDidReportSuccess:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_performanceDataDidReportSuccess:"))) {
                id block = ^ (id thisSelf, BOOL isSuccess) {
                    DC_OB(thisSelf, MOKE_performanceDataDidReportSuccess:, isSuccess);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] Performance Callback %@\n\n", NSStringFromClass(DC_OB(thisSelf, class)), isSuccess?@"success":@"failed"];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:CONSOLE_COLOR_UPLOAD_MODULE_CLEANUP];
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("performanceDataDidReportSuccess:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("performanceDataDidReportSuccess:"), sel_registerName("MOKE_performanceDataDidReportSuccess:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("cleanupPerformanceDataWithConfig:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_cleanupPerformanceDataWithConfig:"))) {
                id block = ^ (id thisSelf, id debugRealConfig) {
                    NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
                    NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
                    NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
                    NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
                    
                    DEBUG_ASSERT(value_fetchStartTime != nil);
                    DEBUG_ASSERT(value_fetchEndTime != nil);
                    DEBUG_ASSERT(value_isNeedWifi != nil);
                    DEBUG_ASSERT(value_limitCnt != nil);
                    
                    NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
                    NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
                    BOOL isNeedWifi = value_isNeedWifi.boolValue;
                    NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
                    
                    DC_OB(thisSelf, MOKE_cleanupPerformanceDataWithConfig:, debugRealConfig);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] DebugReal Cleanup%@ limited:%lu\n[%@ - %@]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:CONSOLE_COLOR_UPLOAD_MODULE_CLEANUP];
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("cleanupPerformanceDataWithConfig:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("cleanupPerformanceDataWithConfig:"), sel_registerName("MOKE_cleanupPerformanceDataWithConfig:"), block);
            }
            
            if(class_respondsToSelector(moduleClass, sel_registerName("debugRealPerformanceDataWithConfig:")) &&
               !class_respondsToSelector(moduleClass, sel_registerName("MOKE_debugRealPerformanceDataWithConfig:"))) {
                id block = ^ NSArray *(id thisSelf, id debugRealConfig) {
                    NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
                    NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
                    NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
                    NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
                    
                    DEBUG_ASSERT(value_fetchStartTime != nil);
                    DEBUG_ASSERT(value_fetchEndTime != nil);
                    DEBUG_ASSERT(value_isNeedWifi != nil);
                    DEBUG_ASSERT(value_limitCnt != nil);
                    
                    NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
                    NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
                    BOOL isNeedWifi = value_isNeedWifi.boolValue;
                    NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
                    
                    NSArray * result = DC_OB(thisSelf, MOKE_debugRealPerformanceDataWithConfig:, debugRealConfig);
                    
                    NSString *str = [NSString stringWithFormat:@"[%@] DebugReal Upload %lu%@ limited:%lu\n[%@ - %@]\n\n", NSStringFromClass(DC_OB(thisSelf, class)), (unsigned long)result.count, isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
                    [HMDSRW_ConsoleViewController.uploadConsole log:str color:(result.count > 0) ? CONSOLE_COLOR_UPLOAD_MODULE_UPLOAD : CONSOLE_COLOR_UPLOAD_MODULE_NOT_ESSENTIAL];
                    
                    return result;
                };
                Class tempClass = class_getSuperclass(moduleClass);
                while(tempClass != nil) {
                    if(ca_classHasInstanceMethod(tempClass, sel_registerName("cleanupPerformanceDataWithConfig:"))) moduleClass = tempClass;
                    tempClass = class_getSuperclass(tempClass);
                };
                ca_mockClassTreeForInstanceMethod(moduleClass, sel_registerName("debugRealPerformanceDataWithConfig:"), sel_registerName("MOKE_debugRealPerformanceDataWithConfig:"), block);
            }
            
            [hookedPerformaceModule addObject:moduleClass];
        }
        pthread_mutex_unlock(&local_mtx);
        DC_OB(thisSelf, MOKE_addReportModule:, module);
    };
    CA_mockClassTreeForInstanceMethod(HMDPerformanceReporter, addReportModule:, block1);
    
    id block2 = ^ (id thisSelf, id debugRealConfig) {
        NSNumber *value_fetchStartTime = DC_ET(DC_OB(debugRealConfig, fetchStartTime), NSNumber);
        NSNumber *value_fetchEndTime = DC_ET(DC_OB(debugRealConfig, fetchEndTime), NSNumber);
        NSNumber *value_isNeedWifi = DC_ET(DC_OB(debugRealConfig, isNeedWifi), NSNumber);
        NSNumber *value_limitCnt = DC_ET(DC_OB(debugRealConfig, limitCnt), NSNumber);
        
        DEBUG_ASSERT(value_fetchStartTime != nil);
        DEBUG_ASSERT(value_fetchEndTime != nil);
        DEBUG_ASSERT(value_isNeedWifi != nil);
        DEBUG_ASSERT(value_limitCnt != nil);
        
        NSTimeInterval fetchStartTime = value_fetchStartTime.doubleValue;
        NSTimeInterval fetchEndTime = value_fetchEndTime.doubleValue;
        BOOL isNeedWifi = value_isNeedWifi.boolValue;
        NSUInteger limitCnt = value_limitCnt.unsignedIntegerValue;
        
        DC_OB(thisSelf, MOKE_reportDebugRealPerformanceDataWithConfig:, debugRealConfig);
        NSString *str = [NSString stringWithFormat:@"[Performance] DebugReal%@ limited:%lu\n[%@ - %@]\n\n", isNeedWifi?@" [WIFI]":@"", (unsigned long)limitCnt, [NSDate dateWithTimeIntervalSince1970:fetchStartTime], [NSDate dateWithTimeIntervalSince1970:fetchEndTime]];
        [HMDSRW_ConsoleViewController.uploadConsole log:str color:CONSOLE_COLOR_UPLOAD_REPORTER];
    };
    CA_mockClassTreeForInstanceMethod(HMDPerformanceReporter, reportDebugRealPerformanceDataWithConfig:, block2);
}

+ (void)hookUIAction {
    id block1 = ^ (id thisSelf, NSString *name, NSString *event, NSDictionary *parameters) {
        DC_OB(thisSelf, MOKE_hmdTrackWithName:event:parameters:, name, event, parameters);
        NSString *extraInfo = (parameters == nil || parameters.count == 0) ? @"":[NSString stringWithFormat:@"\nextra:%@", parameters];
        NSString *str = [NSString stringWithFormat:@"[UIAction] %@ [%@]%@\n\n", name, event, extraInfo];
        [HMDSRW_ConsoleViewController.UIActionConsole log:str color:CONSOLE_COLOR_UIACTION];
    };
    CA_mockClassTreeForInstanceMethod(HMDUITrackerManager, hmdTrackWithName:event:parameters:, block1);
    
    id block2 = ^ (id thisSelf, id context, NSString *event, NSDictionary *parameters) {
        DC_OB(thisSelf, MOKE_hmdTrackableContext:eventWithName:parameters:, context, event, parameters);
        NSString *name = DC_ET(DC_OB(context, trackName), NSString);
        NSString *extraInfo = (parameters == nil || parameters.count == 0) ? @"":[NSString stringWithFormat:@"\nextra:%@", parameters];
        NSString *str = [NSString stringWithFormat:@"[UIAction] %@ [%@]%@\n\n", name, event, extraInfo];
        [HMDSRW_ConsoleViewController.UIActionConsole log:str color:CONSOLE_COLOR_UIACTION];
    };
    CA_mockClassTreeForInstanceMethod(HMDUITrackerManager, hmdTrackableContext:eventWithName:parameters:, block2);
}

+ (void)hookHTTPTracker {
    Class httpTrackerClass;
    Class superClass;
    if((httpTrackerClass = objc_getClass("HMDHTTPRequestTracker")) != nil &&
       (superClass = class_getSuperclass(httpTrackerClass)) != nil) {
        id block = ^ (id thisSelf, id record) {
            NSString *logType = DC_ET(DC_OB(record, logType), NSString);
            NSString *connetType = DC_ET(DC_OB(record, connetType), NSString);
            NSString *method = DC_ET(DC_OB(record, method), NSString);
            NSString *host = DC_ET(DC_OB(record, host), NSString);
            NSString *absoluteURL = DC_ET(DC_OB(record, absoluteURL), NSString);
            NSNumber *startTime = DC_ET(DC_OB(record, startTime), NSNumber);
            NSNumber *endtime = DC_ET(DC_OB(record, endtime), NSNumber);
            NSNumber *duration = DC_ET(DC_OB(record, duration), NSNumber);
            NSNumber *upStreamBytes = DC_ET(DC_OB(record, upStreamBytes), NSNumber);
            NSNumber *downStreamBytes = DC_ET(DC_OB(record, downStreamBytes), NSNumber);
            NSNumber *statusCode = DC_ET(DC_OB(record, statusCode), NSNumber);
            NSNumber *inWhiteList = DC_ET(DC_OB(record, inWhiteList), NSNumber);
            NSString *MIMEType = DC_ET(DC_OB(record, MIMEType), NSString);
            NSNumber *errCode = DC_ET(DC_OB(record, errCode), NSNumber);
            NSString *errDesc = DC_ET(DC_OB(record, errDesc), NSString);
            NSString *requestHeader = DC_ET(DC_OB(record, requestHeader), NSString);
            NSString *requestBody = DC_ET(DC_OB(record, requestBody), NSString);
            NSString *responseHeader = DC_ET(DC_OB(record, responseHeader), NSString);
            NSString *responseBody = DC_ET(DC_OB(record, responseBody), NSString);
            NSNumber *proxyTime = DC_ET(DC_OB(record, proxyTime), NSNumber);
            NSNumber *dnsTime = DC_ET(DC_OB(record, dnsTime), NSNumber);
            NSNumber *connectTime = DC_ET(DC_OB(record, connectTime), NSNumber);
            NSNumber *sslTime = DC_ET(DC_OB(record, sslTime), NSNumber);
            NSNumber *sendTime = DC_ET(DC_OB(record, sendTime), NSNumber);
            NSNumber *waitTime = DC_ET(DC_OB(record, waitTime), NSNumber);
            NSNumber *receiveTime = DC_ET(DC_OB(record, receiveTime), NSNumber);
            NSNumber *isSocketReused = DC_ET(DC_OB(record, isSocketReused), NSNumber);
            NSNumber *isCached = DC_ET(DC_OB(record, isCached), NSNumber);
            NSNumber *isFromProxy = DC_ET(DC_OB(record, isFromProxy), NSNumber);
            NSString *remoteIP = DC_ET(DC_OB(record, remoteIP), NSString);
            NSNumber *remotePort = DC_ET(DC_OB(record, remotePort), NSNumber);
            NSString *protocolName = DC_ET(DC_OB(record, protocolName), NSString);
            NSString *traceId = DC_ET(DC_OB(record, traceId), NSString);
            NSString *requestLog = DC_ET(DC_OB(record, requestLog), NSString);
            NSString *clientType = DC_ET(DC_OB(record, clientType), NSString);
            NSString *scene = DC_ET(DC_OB(record, scene), NSString);
            NSString *format = DC_ET(DC_OB(record, format), NSString);
            NSNumber *isForeground = DC_ET(DC_OB(record, isForeground), NSNumber);
            NSNumber *isOverThreshold = DC_ET(DC_OB(record, isOverThreshold), NSNumber);
            NSNumber *sid = DC_ET(DC_OB(record, sid), NSNumber);
            NSMutableString *str = [NSMutableString string];
            [str appendString:@"-----------------------------------------\n"];
            [str appendFormat:@"%@ %@ %@ %@\n", method, host, remotePort, protocolName];
            if(absoluteURL.length > HMDSRW_HTTP_DISPLAY_WIDTH) {
                absoluteURL = [absoluteURL stringByReplacingCharactersInRange:NSMakeRange(HMDSRW_HTTP_DISPLAY_WIDTH, absoluteURL.length - HMDSRW_HTTP_DISPLAY_WIDTH) withString:@""];
                absoluteURL = [absoluteURL stringByAppendingString:@"..."];
            }
            [str appendFormat:@"[URL] %@\n", absoluteURL];
            [str appendFormat:@"%@ %@\n", statusCode, MIMEType];
            [str appendFormat:@"[%@] upload:%@ download:%@\n\n", connetType, upStreamBytes, downStreamBytes];
            [HMDSRW_ConsoleViewController.networkConsole log:str color:CONSOLE_COLOR_NETWORK];
            
            ((void(*)(struct objc_super *, SEL, id))objc_msgSendSuper)
            (&(struct objc_super) {.receiver = thisSelf, .super_class = superClass},
             sel_registerName("didCollectOneRecord:"), record);
        };
        IMP imp = imp_implementationWithBlock(block);
        class_addMethod(httpTrackerClass, sel_registerName("didCollectOneRecord:"), imp, "v@:@");
    }
}

+ (void)hookProtect {
    typedef NS_ENUM(NSInteger, HMDProtectionType) {
        HMDProtectionTypeNone = 0,
        HMDProtectionTypeUnrecognizedSelector = 1<<0,
        HMDProtectionTypeContainers = 1<<1,
        HMDProtectionTypeNotification = 1<<2,
        HMDProtectionTypeKVO = 1<<3,
        HMDProtectionTypeKVC = 1<<4,
        HMDProtectionTypeAll = HMDProtectionTypeUnrecognizedSelector|HMDProtectionTypeContainers|
                               HMDProtectionTypeNotification|HMDProtectionTypeKVO|HMDProtectionTypeKVC
    };
    id block = ^ (id thisSelf, HMDProtectionType type, id capture) {
        NSString *type_str;
        switch (type) {
            case HMDProtectionTypeNone: type_str = @"none"; break;
            case HMDProtectionTypeUnrecognizedSelector: type_str = @"NONE"; break;
            case HMDProtectionTypeContainers: type_str = @"Container"; break;
            case HMDProtectionTypeNotification: type_str = @"Notification"; break;
            case HMDProtectionTypeKVO: type_str = @"KVO"; break;
            case HMDProtectionTypeKVC: type_str = @"KVC"; break;
            case HMDProtectionTypeAll: type_str = @"ANY"; break;
            default: type_str = @"UNKOWN"; break;
        }
        NSString *exception = DC_ET(DC_OB(capture, exception), NSString);
        NSString *reason = DC_ET(DC_OB(capture, reason), NSString);
        NSString *str = [NSString stringWithFormat:@"[%@] %@\n%@\n\n", type_str, exception, reason];
        [HMDSRW_ConsoleViewController.moduleConsole log:str color:CONSOLE_COLOR_MODULE_DETECT];
        id mustNil = DC_OB(thisSelf, MOKE_recordAnExceptionType:capture:, type, capture);
        DEBUG_ASSERT(mustNil == nil);
    };
    if(objc_getClass("HMDExceptionTracker") != nil)
        CA_mockClassTreeForInstanceMethod(HMDExceptionTracker, recordAnExceptionType:capture:, block);
}

+ (void)hookCrash {
    id block = ^ (id thisSelf, BOOL hasCrash) {
        static atomic_flag onceToken = ATOMIC_FLAG_INIT;
        if(!atomic_flag_test_and_set_explicit(&onceToken, memory_order_relaxed)) {
            if(hasCrash) [HMDSRW_ConsoleViewController.moduleConsole log:@"[Crash] application relaunch reason: crash [应用崩溃]\n"
                                                                   color:CONSOLE_COLOR_MODULE_DETECT];
            else [HMDSRW_ConsoleViewController.moduleConsole log:@"[Crash] did not happen last time\n"
                                                           color:CONSOLE_COLOR_MODULE_DETECT];
        }
        DC_OB(thisSelf, MOKE_didFinishDetectCrashRecords:, hasCrash);
    };
    CA_mockClassTreeForInstanceMethod(HMDCrashTracker, didFinishDetectCrashRecords:, block);
}

#pragma mark - Additional Windows

+ (void)display_vc_finder {
    if(!hasDisplayed_vc_finder) {
        if(vc_finder_window == nil) {   // ONCE TOKEN
            CGRect statusBar = UIApplication.sharedApplication.statusBarFrame;
            vc_finder_window = [[UIWindow alloc] initWithFrame:CGRectMake(0, statusBar.size.height, UIScreen.mainScreen.bounds.size.width, 30)];
            vc_finder_textview = [[UITextView alloc] init];
            UIViewController *vc =
            [[HMDSRWTEST_POPUP_DISPLAY alloc] initWithOneClickAction: ^ { DC_OB(DC_CL(HMDVCFinder, finder), triggerUpdate); }
                                                        doubleAction: ^ { [HMDSRWTESTEnvironment  hidden_vc_finder]; }
                                                     longPressAction: ^ { [HMDSRWTESTEnvironment showInformationTitle:@"视图跟踪器"
                                                                                                            message:@"version 0.7.5\n"
                                                                                                                     "单击刷新 双击关闭\n"
                                                                                                                     "by HuaQ"];}];
            vc.view.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 30);
            [vc.view addSubview:vc_finder_textview];
            vc_finder_textview.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 30);
            vc_finder_window.rootViewController = vc;
            vc_finder_textview.backgroundColor = [UIColor colorForHex:@"F0F6F7"];
            vc_finder_textview.textColor = [UIColor colorForHex:@"369ca0"];
            vc_finder_textview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            vc_finder_textview.editable = NO;
            vc_finder_textview.selectable = NO;
            vc_finder_textview.textContainerInset = UIEdgeInsetsZero;
            vc_finder_textview.textContainer.lineFragmentPadding = 0.0;
            vc_finder_textview.textContainer.maximumNumberOfLines = 0;
            vc_finder_textview.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
            ca_swizzle_instance_method(UIViewController.class, @selector(viewDidAppear:), @selector(MOKE_viewDidAppear:));
            vc_finder_window.windowLevel = UIWindowLevelStatusBar + 1;
            id manager = DC_CL(HMDUITrackerManager, sharedManager);
            [manager addObserver:HMDSRWTEST_KVO_POX.shared forKeyPath:@"scene" options:0 context:NULL];
        }
        vc_finder_window.hidden = NO;
        hasDisplayed_vc_finder = YES;
        ;
    }
}

+ (void)hidden_vc_finder {
    if(hasDisplayed_vc_finder) {
        vc_finder_window.hidden = YES;
        hasDisplayed_vc_finder = NO;
    }
}

+ (void)refresh_vc_finder {
    if(hasDisplayed_vc_finder) {
        [HMDSRWTESTEnvironment importancyVC];   // ONLY to test VC Find Time
        NSString *temp = DC_ET(DC_OB(DC_CL(HMDUITrackerManager, sharedManager), scene), NSString);
        NSString *str = [NSString stringWithFormat:@"老版逻辑: %@\n新版逻辑: %@", vc_finder_didAppear, temp];
        vc_finder_textview.text = str;
    }
}

+ (UIViewController *)importancyVC {
    CFTimeInterval beginTime = CAXNUSystemCall_timeSince1970();
    __kindof UIViewController *result = CA_locateEssentialChildVC(CA_topMostPresentedVC());
    CFTimeInterval endTime = CAXNUSystemCall_timeSince1970();
    total_find_vc_amount++;
    current_find_time = endTime - beginTime;
    total_find_vc_time += current_find_time;
    return result;
}

#pragma mark - KVO

@end

static void ca_mockClassLeavesForClassMethod(Class _Nullable aClass,
                                             SEL _Nonnull originSEL,
                                             SEL _Nonnull mockSEL,
                                             id _Nonnull impBlock) {
    Method rootOriginMethod;
    if(aClass == nil || originSEL == NULL ||
       mockSEL == NULL || impBlock == nil ||
       !(rootOriginMethod = ca_classHasClassMethod(aClass, originSEL))) {
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    
    const char *encodeType = method_getTypeEncoding(rootOriginMethod);
    IMP imp; Class *allSubclasses; size_t count;
    if((imp = imp_implementationWithBlock(impBlock)) != NULL) {
        
        BOOL mockSelfFlag = YES;
        
        /* mock for subclasses */
        if((allSubclasses = objc_getAllSubclasses(aClass, &count)) != NULL) {
            for(size_t index = 0; index < count; index++) {
                Method eachSubOriginMethod = ca_classHasClassMethod(allSubclasses[index], originSEL);
                if(eachSubOriginMethod != NULL) {
                    mockSelfFlag = NO;
                    size_t insideCount;
                    Class *insideSubclasses;
                    BOOL notFlag = NO;
                    if((insideSubclasses = objc_getAllSubclasses(allSubclasses[index], &insideCount)) != NULL) {
                        for(size_t index = 0; index < insideCount; index++)
                            if(ca_classHasClassMethod(insideSubclasses[index], originSEL) != NULL) {
                                notFlag = YES;
                                break;
                            }
                        free(insideSubclasses);
                    }
                    if(!notFlag && class_addMethod(object_getClass(allSubclasses[index]), mockSEL, imp, encodeType)) {
                        Method eachSubMockedMethod;
                        if((eachSubMockedMethod = ca_classHasClassMethod(allSubclasses[index], mockSEL)) != NULL)
                            method_exchangeImplementations(eachSubMockedMethod, eachSubOriginMethod);
                    }
                }
            }
            free(allSubclasses);
        }
        
        /* mock for thisClass */
        if(mockSelfFlag && class_addMethod(object_getClass(aClass), mockSEL, imp, encodeType)) {
            Method rootMockedMethod;
            if((rootMockedMethod = ca_classHasClassMethod(aClass, mockSEL)) != NULL)
                method_exchangeImplementations(rootMockedMethod, rootOriginMethod);
        }
    }
}

static void ca_mockClassLeavesForInstanceMethod(Class _Nullable aClass,
                                                SEL _Nonnull originSEL,
                                                SEL _Nonnull mockSEL,
                                                id _Nonnull impBlock) {
    Method rootOriginMethod;
    if(aClass == nil || originSEL == NULL ||
       mockSEL == NULL || impBlock == nil ||
       !(rootOriginMethod = ca_classHasInstanceMethod(aClass, originSEL))) {
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    
    const char *encodeType = method_getTypeEncoding(rootOriginMethod);
    IMP imp; Class *allSubclasses; size_t count;
    if((imp = imp_implementationWithBlock(impBlock)) != NULL) {
        
        BOOL mockSelfFlag = YES;
        
        /* mock for subclasses */
        if((allSubclasses = objc_getAllSubclasses(aClass, &count)) != NULL) {
            for(size_t index = 0; index < count; index++) {
                Method eachSubOriginMethod = ca_classHasInstanceMethod(allSubclasses[index], originSEL);
                if(eachSubOriginMethod != NULL) {
                    mockSelfFlag = NO;
                    size_t insideCount;
                    Class *insideSubclasses;
                    BOOL notFlag = NO;
                    if((insideSubclasses = objc_getAllSubclasses(allSubclasses[index], &insideCount)) != NULL) {
                        for(size_t index = 0; index < insideCount; index++)
                            if(ca_classHasInstanceMethod(insideSubclasses[index], originSEL) != NULL) {
                                notFlag = YES;
                                break;
                            }
                        free(insideSubclasses);
                    }
                    if(!notFlag && class_addMethod(allSubclasses[index], mockSEL, imp, encodeType)) {
                        Method eachSubMockedMethod;
                        if((eachSubMockedMethod = ca_classHasInstanceMethod(allSubclasses[index], mockSEL)) != NULL)
                            method_exchangeImplementations(eachSubMockedMethod, eachSubOriginMethod);
                    }
                }
            }
            free(allSubclasses);
        }
        
        /* mock for thisClass */
        if(mockSelfFlag && class_addMethod(aClass, mockSEL, imp, encodeType)) {
            Method rootMockedMethod;
            if((rootMockedMethod = ca_classHasInstanceMethod(aClass, mockSEL)) != NULL)
                method_exchangeImplementations(rootMockedMethod, rootOriginMethod);
        }
    }
}

static void ca_swizzle_instance_method(Class _Nullable aClass,
                                       SEL _Nonnull selector1,
                                       SEL _Nonnull selector2)
{
    NSCParameterAssert(!(selector1 == NULL || selector2 == NULL));
    if(aClass == nil || selector1 == NULL || selector2 == NULL) return;
    
    Method method1 = ca_classHasInstanceMethod(aClass, selector1);
    Method method2 = ca_classHasInstanceMethod(aClass, selector2);
    
    if(method1 == NULL || method2 == NULL) {
        fprintf(stderr, "ca_swizzle_instance_method method does not exist");
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    method_exchangeImplementations(method1, method2);
}

static void ca_swizzle_class_method(Class _Nullable aClass,
                                    SEL _Nonnull selector1,
                                    SEL _Nonnull selector2)
{
    NSCParameterAssert(!(selector1 == NULL || selector2 == NULL));
    if(aClass == nil || selector1 == NULL || selector2 == NULL) return;
    
    Method method1 = ca_classHasClassMethod(aClass, selector1);
    Method method2 = ca_classHasClassMethod(aClass, selector2);
    
    if(method1 == NULL || method2 == NULL) {
        fprintf(stderr, "ca_swizzle_class_method method does not exist");
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    method_exchangeImplementations(method1, method2);
}

static void ca_insert_and_swizzle_instance_method
(Class _Nullable originalClass, SEL _Nonnull originalSelector,  // 添加到
 Class _Nullable   targetClass, SEL _Nonnull   targetSelector) { // 提供者
    
    NSCParameterAssert(!(originalSelector == NULL || targetSelector == NULL));
    
    if(originalClass == nil || originalSelector == NULL ||
       targetClass == nil || targetSelector == NULL) return;
    
    Method originalMethod =
    class_getInstanceMethod(originalClass, originalSelector);
    
    if(originalMethod == NULL) {
        fprintf(stderr, "ca_insert_and_swizzle_instance_method "
                "originalMethod not exist in originalClass "
                "(including super)");
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    
    Method preSwizzledMethod =
    ca_classHasInstanceMethod(originalClass, targetSelector);
    
    if(preSwizzledMethod != NULL) {
        method_exchangeImplementations(originalMethod, preSwizzledMethod);
        return;
    }
    
    // 这个方法存在即可
    Method targetMethod = class_getInstanceMethod(targetClass, targetSelector);
    if(targetMethod != NULL) {
        class_addMethod(originalClass,
                        targetSelector,
                        method_getImplementation(targetMethod),
                        method_getTypeEncoding(targetMethod));
        
        Method swizzleMethod = class_getInstanceMethod(originalClass,
                                                       targetSelector);
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

#pragma mark - supporting function

static _Nullable Method ca_classHasInstanceMethod(Class _Nullable aClass,
                                                  SEL _Nonnull selector) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        unsigned int length;
        Method *methodList = class_copyMethodList(aClass, &length);
        const char *selectorName = sel_getName(selector);
        for (unsigned int index = 0; index < length; index++) {
            const char *currentName =
            sel_getName(method_getName(methodList[index]));
            if(strcmp(currentName, selectorName) == 0) {
                free(methodList);
                return class_getInstanceMethod(aClass, selector);
            }
        }
        free(methodList);
    }
    return NULL;
}

static _Nullable Method ca_classHasClassMethod(Class _Nullable aClass,
                                               SEL _Nonnull selector) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        Class metaClass = object_getClass(aClass);
        
        unsigned int length;
        Method *methodList = class_copyMethodList(metaClass, &length);
        const char *selectorName = sel_getName(selector);
        for(unsigned int index = 0; index < length; index++) {
            const char *currentName =
            sel_getName(method_getName(methodList[index]));
            if(strcmp(currentName, selectorName) == 0) {
                free(methodList);
                return class_getClassMethod(aClass, selector);
            }
        }
        free(methodList);
    }
    return NULL;
}

static Class _Nonnull * _Nullable objc_getSubclasses(Class _Nullable aClass,
                                                     size_t * _Nonnull num) {
    if(aClass == nil || num == NULL) return NULL;
    
    unsigned int allClassAmount; Class *classList;
    if((classList = objc_copyClassList(&allClassAmount)) != NULL) {
        
        size_t count = 0;
        for(int index = 0; index < allClassAmount; index++)
            if(class_getSuperclass(classList[index]) == aClass) count++;
        
        if(count == 0) {
            free(classList); *num = 0;
            return NULL;
        }
        
        Class *result;
        if((result = (__unsafe_unretained Class *)
            malloc(sizeof(Class) * count)) != NULL) {
            
            int currentIndex = 0;
            for(int index = 0; index < allClassAmount; index++)
                if(class_getSuperclass(classList[index]) == aClass)
                    result[currentIndex++] = classList[index];
            
            free(classList);
            *num = count;
            return result;
        }
        free(classList);
    }
    *num = 0;           // whether NULL decided before
    return NULL;
}

static Class _Nonnull * _Nullable objc_getAllSubclasses(Class _Nullable aClass,
                                                        size_t * _Nonnull num) {
    if(aClass == nil || num == NULL) return NULL;
    
    unsigned int allClassAmount; Class *classList;
    if((classList = objc_copyClassList(&allClassAmount)) != NULL) {
        
        size_t count = 0;
        for(int index = 0; index < allClassAmount; index++) {
            Class superClass = class_getSuperclass(classList[index]);
            while(superClass && superClass != aClass)
                superClass = class_getSuperclass(superClass);
            if(superClass) count++;
        }
        
        if(count == 0) {
            free(classList); *num = 0;
            return NULL;
        }
        
        Class *result;
        if((result = (__unsafe_unretained Class *)
            malloc(sizeof(Class) * count)) != NULL) {
            
            int currentIndex = 0;
            for(int index = 0; index < allClassAmount; index++) {
                Class superClass = class_getSuperclass(classList[index]);
                while(superClass && superClass != aClass)
                    superClass = class_getSuperclass(superClass);
                if(superClass) result[currentIndex++] = classList[index];
            }
            
            free(classList);
            *num = count;
            return result;
        }
        free(classList);
    }
    *num = 0;       // whether NULL decided before
    return NULL;
}

static void ca_mockClassTreeForInstanceMethod(Class _Nullable aClass,
                                              SEL _Nonnull originSEL,
                                              SEL _Nonnull mockSEL,
                                              id _Nonnull impBlock) {
    Method rootOriginMethod;
    if(aClass == nil || originSEL == NULL ||
       mockSEL == NULL || impBlock == nil ||
       !(rootOriginMethod = ca_classHasInstanceMethod(aClass, originSEL))) {
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    
    const char *encodeType = method_getTypeEncoding(rootOriginMethod);
    IMP imp; Class *allSubclasses; size_t count;
    if((imp = imp_implementationWithBlock(impBlock)) != NULL) {
        
        /* mock for subclasses */
        if((allSubclasses = objc_getAllSubclasses(aClass, &count)) != NULL) {
            for(size_t index = 0; index < count; index++) {
                Method eachSubOriginMethod;
                
                if((eachSubOriginMethod = ca_classHasInstanceMethod
                    (allSubclasses[index], originSEL)) != NULL &&
                   class_addMethod(allSubclasses[index],
                                   mockSEL,
                                   imp,
                                   encodeType)) {
                       Method eachSubMockedMethod;
                       
                       if((eachSubMockedMethod =
                           ca_classHasInstanceMethod(allSubclasses[index],
                                                     mockSEL)) != NULL)
                           method_exchangeImplementations(eachSubMockedMethod,
                                                          eachSubOriginMethod);
                   }
            }
            free(allSubclasses);
        }
        
        /* mock for thisClass */
        if(class_addMethod(aClass, mockSEL, imp, encodeType)) {
            Method rootMockedMethod;
            if((rootMockedMethod =
                ca_classHasInstanceMethod(aClass, mockSEL)) != NULL)
                method_exchangeImplementations(rootMockedMethod,
                                               rootOriginMethod);
        }
    }
}

static void ca_mockClassTreeForClassMethod(Class _Nullable aClass,
                                           SEL _Nonnull originSEL,
                                           SEL _Nonnull mockSEL,
                                           id _Nonnull impBlock) {
    Method rootOriginMethod;
    if(aClass == nil || originSEL == NULL ||
       mockSEL == NULL || impBlock == nil ||
       !(rootOriginMethod = ca_classHasClassMethod(aClass, originSEL))) {
#ifdef DEBUG
        __builtin_trap();
#endif
        return;
    }
    
    const char *encodeType = method_getTypeEncoding(rootOriginMethod);
    IMP imp; Class *allSubclasses; size_t count;
    if((imp = imp_implementationWithBlock(impBlock)) != NULL) {
        
        /* mock for subclasses */
        if((allSubclasses = objc_getAllSubclasses(aClass, &count)) != NULL) {
            for(size_t index = 0; index < count; index++) {
                Method eachSubOriginMethod;
                
                if((eachSubOriginMethod = ca_classHasClassMethod
                    (allSubclasses[index], originSEL)) != NULL &&
                   class_addMethod(object_getClass(allSubclasses[index]),
                                   mockSEL,
                                   imp,
                                   encodeType)) {
                       Method eachSubMockedMethod;
                       
                       if((eachSubMockedMethod =
                           ca_classHasClassMethod(allSubclasses[index],
                                                  mockSEL)) != NULL)
                           method_exchangeImplementations(eachSubMockedMethod,
                                                          eachSubOriginMethod);
                   }
            }
            free(allSubclasses);
        }
        
        /* mock for thisClass */
        if(class_addMethod(object_getClass(aClass), mockSEL, imp, encodeType)) {
            Method rootMockedMethod;
            if((rootMockedMethod =
                ca_classHasClassMethod(aClass, mockSEL)) != NULL)
                method_exchangeImplementations(rootMockedMethod,
                                               rootOriginMethod);
        }
    }
}

static _Nullable Method ca_classSearchInstanceMethodUntilClass(Class _Nullable aClass,
                                                               SEL _Nonnull selector,
                                                               Class _Nullable untilClassExcluded) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        Class currentClass = aClass;
        while(currentClass != NULL && currentClass != untilClassExcluded) {
            Method currentMethod = ca_classHasInstanceMethod(currentClass, selector);
            if(currentMethod) return currentMethod;
            else currentClass = class_getSuperclass(currentClass);
        }
    }
    return NULL;
}

static _Nullable Method ca_classSearchClassMethodUntilClass(Class _Nullable aClass,
                                                            SEL _Nonnull selector,
                                                            Class _Nullable untilClassExcluded) {
    NSCParameterAssert(selector != NULL && !class_isMetaClass(aClass));
    if(aClass != nil && selector != NULL && !class_isMetaClass(aClass)) {
        Class currentClass = aClass;
        while(currentClass != NULL && currentClass != untilClassExcluded) {
            Method currentMethod = ca_classHasClassMethod(currentClass, selector);
            if(currentMethod) return currentMethod;
            else currentClass = class_getSuperclass(currentClass);
        }
    }
    return NULL;
}

@implementation NSThread (HMD_BLOCK_THREAD)

+ (void)HMD_detachNewThreadWithBlock:(void (^)(void))block {
    [NSThread detachNewThreadSelector:@selector(HMD_handleNewThreadDetachWithBlock:) toTarget:[NSThread class] withObject:block];
}

+ (void)HMD_handleNewThreadDetachWithBlock:(void (^)(void))block {
    block();
}

@end

@implementation KVO_DEALLOC_TEST {
    KVO_DEALLOC_TEST *_observee;
}
- (instancetype)initWithTest:(KVO_DEALLOC_TEST *)aTest {
    if(self = [super initWithFrame:CGRectZero]) {
        [_observee = aTest addObserver:self forKeyPath:@"backgroundColor" options:0 context:0];
    }
    return self;
}
- (void)dealloc {
    if(_observee) [_observee removeObserver:self forKeyPath:@"backgroundColor"];
}
@end

@implementation KVO_SELF_DEALLOC_TEST {
    KVO_SELF_DEALLOC_TEST *_observer;
}
- (instancetype)initWithTest:(KVO_SELF_DEALLOC_TEST *)aTest {
    if(self = [super initWithFrame:CGRectZero]) {
        [self addObserver:aTest forKeyPath:@"backgroundColor" options:0 context:0];
    }
    return self;
}
- (void)dealloc {
    if(_observer)
        [self removeObserver:_observer forKeyPath:@"backgroundColor"];
}
@end

@implementation UIViewController (HMD_SRW_TEST)

- (void)MOKE_viewDidAppear:(BOOL)animated {
    vc_finder_didAppear = NSStringFromClass(self.class);
    [HMDSRWTESTEnvironment refresh_vc_finder];
    [self MOKE_viewDidAppear:animated];
}

@end

@implementation HMDSRWTEST_POPUP_DISPLAY_VIEW
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled
        || self.isHidden
        || self.alpha <= 0.01)
        return nil;
    if ([self pointInside:point withEvent:event]) return self;
    return nil;
}
@end
@implementation HMDSRWTEST_POPUP_DISPLAY {
    CFTimeInterval _timestamp;
    HMDSRWTESTEnvironmentAction _Nullable _oneClickAction;
    HMDSRWTESTEnvironmentAction _Nullable _doubleAction;
    HMDSRWTESTEnvironmentAction _Nullable _longPressAction;
}
- (instancetype)initWithOneClickAction:(HMDSRWTESTEnvironmentAction)oneClickAction
                          doubleAction:(HMDSRWTESTEnvironmentAction)doubleAction
                       longPressAction:(HMDSRWTESTEnvironmentAction)longPressAction {
    if(self = [super init]) {
        _oneClickAction = oneClickAction;
        _doubleAction = doubleAction;
        _longPressAction = longPressAction;
    }
    return self;
}
- (void)loadView {
    self.view = [[HMDSRWTEST_POPUP_DISPLAY_VIEW alloc] init];
    UITapGestureRecognizer *oneClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneClick)];
    [self.view addGestureRecognizer:oneClick];
    UITapGestureRecognizer *doubleGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDouble)];
    doubleGR.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleGR];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 1.5;
    [self.view addGestureRecognizer:longPress];
}
- (void)handleOneClick {
    if(_oneClickAction) _oneClickAction();
}
- (void)handleDouble {
    if(_doubleAction) _doubleAction();
}
- (void)handleLongPress:(UIGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan) {
        if(_longPressAction) _longPressAction();
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end

static __kindof UIViewController * _Nonnull CA_testVCFinder(__kindof UIViewController *rootVC) {
    __kindof UIViewController *vc = rootVC;
    __kindof UIViewController *temp;
    do {
        if((temp = vc.presentedViewController) != nil) {
            UIModalPresentationStyle style = vc.presentationController.presentationStyle;
            if(style == UIModalPresentationFullScreen ||
               style == UIModalPresentationOverFullScreen ||
               style == UIModalPresentationCurrentContext ||
               style == UIModalPresentationOverCurrentContext ||
               (style == UIModalPresentationCustom &&
                (temp.presentedViewController != nil ||
                 (!temp.view.hidden &&
                  temp.view.alpha >= 0.01)))) {
                     vc = temp; continue;
                 }
        }
        if((temp = vc.childViewControllerForStatusBarHidden) != nil) {
            __kindof UIView *view = temp.viewIfLoaded;
            if(view != nil && !view.hidden && view.alpha >= 0.01) vc = temp;
            else temp = nil;
        }
    }while(temp != nil);
    return CA_locateEssentialChildVC(vc);
}

static __kindof UIViewController * _Nonnull CA_topMostPresentedVC(void) {
    NSCAssert(NSThread.isMainThread, @"CA_topMostPresentedVC not in main thread");
    UIApplication *application = UIApplication.sharedApplication;
    id<UIApplicationDelegate> delegate = application.delegate;
    __kindof UIViewController *vc;
    if([delegate respondsToSelector:@selector(window)]) vc = delegate.window.rootViewController;
    if(vc == nil) vc = application.keyWindow.rootViewController;
    __kindof UIViewController *temp;
    static BOOL isQueriedStatusBarAppearance = NO;
    static BOOL viewControllerBased_statusBar = YES;
    if(!isQueriedStatusBarAppearance) {
        id maybeNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
        if([maybeNumber isKindOfClass:NSNumber.class]) {
            viewControllerBased_statusBar = ((NSNumber *)maybeNumber).boolValue;
        }
    }
    do {
        if((temp = vc.presentedViewController) != nil) {
            UIModalPresentationStyle style = vc.presentationController.presentationStyle;
            if(style == UIModalPresentationFullScreen ||
               style == UIModalPresentationOverFullScreen ||
               style == UIModalPresentationCurrentContext ||
               style == UIModalPresentationOverCurrentContext ||
               (style == UIModalPresentationCustom &&
                (temp.presentedViewController != nil ||
                 (!temp.view.hidden &&
                  temp.view.alpha >= 0.01)))) {
                     vc = temp; continue;
                 }
        }
        if((temp = vc.childViewControllerForStatusBarHidden) != nil) {
            if([vc isKindOfClass:UINavigationController.class] || [vc isKindOfClass:UITabBarController.class] ||
               viewControllerBased_statusBar) {
                __kindof UIView *view = temp.view;
                if(view != nil && !view.hidden && view.alpha >= 0.01) vc = temp;
                else temp = nil;
            }
            else temp = nil;
        }
    }while(temp != nil);
    return vc;
}

static __kindof UIViewController * _Nonnull CA_locateEssentialChildVC(__kindof UIViewController * _Nonnull parentVC) {
    __kindof UIView *this_view = parentVC.view;
    CGRect bounds = this_view.bounds;
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat parentSize = bounds.size.width * bounds.size.height;
    CGFloat screenSize = screenBounds.size.width * screenBounds.size.height;
    
    if(parentSize >= screenSize * HMDSRW_TEST_COULD_LOCATE_ESSENTIAL) {
        NSArray *array = parentVC.childViewControllers;
        if(array.count == 1) {
            __kindof UIViewController *childVC = array[0];
            __kindof UIView *child_view = childVC.view;
            if(!child_view.hidden && child_view.alpha >= 0.01 && [child_view isDescendantOfView:this_view]) {
                CGRect child_frame = [this_view convertRect:child_view.bounds fromView:child_view];
                CGRect contained = CGRectContainRect(bounds, child_frame);
                CGFloat containedSize = contained.size.width * contained.size.height;
                if(containedSize >= parentSize * HMDSRW_TEST_ENSSENTIAL_CHILD_VC_PERCENTAGE) {
                    return CA_locateEssentialChildVC(childVC);
                }
            }
        }
        else if(array.count >= 2) {
            NSMutableArray<__kindof UIViewController *> *possibleViewControllers = [NSMutableArray arrayWithCapacity:array.count];
            NSEnumerator *enumerator = array.objectEnumerator;
            __kindof UIViewController *eachViewController;
            while ((eachViewController = enumerator.nextObject) != nil) {
                __kindof UIView *front_child_view = eachViewController.view;
                if(!front_child_view.hidden && front_child_view.alpha >= 0.01 && [front_child_view isDescendantOfView:this_view])
                    [possibleViewControllers addObject:eachViewController];
            }
            if(possibleViewControllers.count > 0) {
                __block BOOL errorFlag = NO;
                [possibleViewControllers sortUsingComparator: ^NSComparisonResult(__kindof UIViewController *vc1, __kindof UIViewController *vc2) {
                    UIViewCoverageRelationship relationship = UIViewGetCoverageRelationship(vc1.view, vc2.view);
                    if(relationship == UIViewCoverageRelationshipAbove) return NSOrderedAscending;
                    else if(relationship == UIViewCoverageRelationshipBelow) return NSOrderedDescending;
                    errorFlag = YES;
                    return NSOrderedSame;
                }];
                if(!errorFlag) {
                    __block UIViewController *targetViewController = nil;
                    [possibleViewControllers enumerateObjectsUsingBlock: ^ (__kindof UIViewController * _Nonnull eachViewController, NSUInteger idx, BOOL * _Nonnull stop) {
                        __kindof UIView *front_child_view = eachViewController.view;
                        CGRect child_frame = [this_view convertRect:front_child_view.bounds fromView:front_child_view];
                        CGRect contained = CGRectContainRect(bounds, child_frame);
                        CGFloat containedSize = contained.size.width * contained.size.height;
                        if(containedSize >= parentSize * HMDSRW_TEST_ENSSENTIAL_CHILD_VC_PERCENTAGE) {
                            targetViewController = eachViewController;
                            *stop = YES;
                        }
                        else if(containedSize >= parentSize * HMDSRW_TEST_ENSSENTIAL_CHILD_NOT_TORLERANCE_OTHER_PERCENTAGE) *stop = YES;
                    }];
                    if(targetViewController) return CA_locateEssentialChildVC(targetViewController);
                }
                DEBUG_ELSE
            }
        }
    }
    return parentVC;
}

static CGRect CGRectContainRect(CGRect outside, CGRect inside)
{
    CGFloat left = inside.origin.x,
    right = inside.origin.x + inside.size.width,
    top = inside.origin.y,
    bottom = inside.origin.y + inside.size.height;
    CGFloat leftMax = outside.origin.x,
    rightMax = outside.origin.x + outside.size.width,
    topMax = outside.origin.y,
    bottomMax = outside.origin.y + outside.size.height;
    
    if(left <= rightMax && right >= leftMax && top <= bottomMax && bottom >= topMax)
    {
        if(left < leftMax) left = leftMax;
        if(right > rightMax) right = rightMax;
        if(top < topMax) top = topMax;
        if(bottom > bottomMax) bottom = bottomMax;
        CGPoint origin = CGPointMake(left, top);
        CGSize size = CGSizeMake(right - left, bottom - top);
        return (CGRect) {origin, size};
    }
    return CGRectZero;
}

static CGRect CGRectCombine(CGRect one, CGRect another) {
    CGRect result;
    result.origin.x = fmin(one.origin.x, another.origin.x);
    result.origin.y = fmin(one.origin.y, another.origin.y);
    result.size.width = fmax(one.size.width + one.origin.x - result.origin.x, another.size.width + another.origin.x - result.origin.x);
    result.size.height = fmax(one.size.height + one.origin.y - result.origin.y, another.size.height + another.origin.y - result.origin.y);
    return result;
}

static UIViewCoverageRelationship UIViewGetCoverageRelationship(__kindof UIView *view1, __kindof UIView *view2) {
    if(view1 == view2) return UIViewCoverageRelationshipEqual;
    if([view2 isDescendantOfView:view1]) return UIViewCoverageRelationshipBelow;
    __kindof UIView *intermediateView = view1;
    __kindof UIView *currentView = view1.superview;
    while(currentView != nil) {
        if([view2 isDescendantOfView:currentView]) {
            if(view2 == currentView) return UIViewCoverageRelationshipAbove;
            __block NSUInteger view1_index = NSUIntegerMax;
            __block NSUInteger view2_index = NSUIntegerMax;
            NSArray<__kindof UIView *> *subviews = currentView.subviews;
            [subviews enumerateObjectsUsingBlock: ^ (__kindof UIView * _Nonnull eachSubview, NSUInteger idx, BOOL * _Nonnull stop) {
                if(eachSubview == intermediateView) view1_index = idx;
                else if([view2 isDescendantOfView:eachSubview]) view2_index = idx;
                if(view1_index != NSUIntegerMax && view2_index != NSUIntegerMax) *stop = YES;
            }];
            if(view1_index == NSUIntegerMax || view2_index == NSUIntegerMax || view1_index == view2_index) {
                DEBUG_POINT
                return UIViewCoverageRelationshipError;
            }
            if(view1_index < view2_index) return UIViewCoverageRelationshipBelow;
            else return UIViewCoverageRelationshipAbove;
        }
        intermediateView = currentView;
        currentView = currentView.superview;
    }
    return UIViewCoverageRelationshipError;
}

#pragma mark - HMDSRWSetting

@implementation HMDSRWSetting {
    HMDSRWSettingType _type;
    HMDSRWExpectedSettingAction _action;
    NSString *_name;
}

@synthesize type = _type, name = _name;

- (instancetype)initWithType:(HMDSRWSettingType)type
                        name:(NSString *)name
                      action:(HMDSRWExpectedSettingAction)action {
    if((type == HMDSRWSettingTypeString || type == HMDSRWSettingTypeNumber) && action != nil && name != nil) {
        if(self = [super init]) {
            _type = type;
            _action = action;
            _name = name;
        }
        return self;
    }
    DEBUG_ELSE
    return nil;
}

- (void)invokeAction {
    if(_action != nil) _action(self);
    DEBUG_ELSE
}

@end

#pragma mark - HMDSRWSettingViewController

@implementation HMDSRWSettingViewController {
    UINavigationItem * _navigationItem;
    NSMutableArray<HMDSRWSetting *> * _stringSettings;
    NSMutableArray<HMDSRWSetting *> * _numberSettings;
}

- (instancetype)initWithSettings:(NSArray<HMDSRWSetting *> *)settings {
    if([settings isKindOfClass:NSArray.class]) {
        __block BOOL errorFlag = NO;
        [settings enumerateObjectsUsingBlock: ^ (id _Nonnull maybeSetting, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![maybeSetting isKindOfClass:HMDSRWSetting.class]) {
                errorFlag = YES; *stop = YES;
            }
        }];
        if(!errorFlag) {
            if(self = [super initWithStyle:UITableViewStyleGrouped]) {
                NSMutableArray *string = [NSMutableArray array];
                NSMutableArray *number = [NSMutableArray array];
                [settings enumerateObjectsUsingBlock: ^ (HMDSRWSetting *_Nonnull eachSetting, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(eachSetting.type == HMDSRWSettingTypeString)
                        [string addObject:eachSetting];
                    else if(eachSetting.type == HMDSRWSettingTypeNumber)
                        [number addObject:eachSetting];
                    DEBUG_ELSE
                }];
                _stringSettings = string;
                _numberSettings = number;
            }
            return self;
        }
        DEBUG_ELSE
    }
    DEBUG_ELSE
    return nil;
}

#pragma mark ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsMultipleSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"standardCell"];
}

- (BOOL)definesPresentationContext {
    return YES;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCurrentContext;
}

- (UINavigationItem *)navigationItem {
    if(_navigationItem == nil) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:@"设置界面"];
        if (@available(iOS 11.0, *)) {
            _navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        }
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"回到设置界面"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
        _navigationItem.backBarButtonItem = backBarButtonItem;
        _navigationItem.leftItemsSupplementBackButton = YES;
        if (@available(iOS 11.0, *)) {
            _navigationItem.hidesSearchBarWhenScrolling = YES;
        }
    }
    return _navigationItem;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger stringCount = _stringSettings.count;
    NSUInteger numberCount = _numberSettings.count;
    if(stringCount > 0 && numberCount > 0) return 3;
    else if(stringCount == 0 && numberCount == 0) return 1;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(SECTION(section) == SECTION_STRING) return _stringSettings.count;
    else if(SECTION(section) == SECTION_NUMBER) return _numberSettings.count;
    else if(SECTION(section) == SECTION_CONTROL) return 1;
    DEBUG_ELSE
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"standardCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(SECTION(section) == SECTION_STRING) {
        NSUInteger storeCount = _stringSettings.count;
        if(row < storeCount) {
            cell.textLabel.text = _stringSettings[row].name;
        }
        DEBUG_ELSE
    }
    else if(SECTION(section) == SECTION_NUMBER) {
        NSUInteger storeCount = _numberSettings.count;
        if(row < storeCount) {
            cell.textLabel.text = _numberSettings[row].name;
        }
        DEBUG_ELSE
    }
    else if(SECTION(section) == SECTION_CONTROL) {
        if(row == 0) {
            cell.textLabel.text = @"退出界面";
        }
        DEBUG_ELSE
    }
    DEBUG_ELSE
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(SECTION(section) == SECTION_STRING) {
        return @"STRING";
    }
    else if(SECTION(section) == SECTION_NUMBER) {
        return @"NUMBER";
    }
    else if(SECTION(section) == SECTION_CONTROL) {
        return @"CONTROL";
    }
    DEBUG_ELSE
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(SECTION(section) == SECTION_STRING) {
        return @"End of STRING";
    }
    else if(SECTION(section) == SECTION_NUMBER) {
        return @"End of NUMBER";
    }
    else if(SECTION(section) == SECTION_CONTROL) {
        return @"End of CONTROL";
    }
    DEBUG_ELSE
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(SECTION(section) == SECTION_STRING) {
        NSUInteger storeCount = _stringSettings.count;
        if(row < storeCount) {
            HMDSRWSettingInputViewController *vc = [[HMDSRWSettingInputViewController alloc] initWithSetting:_stringSettings[row]];
            [self showViewController:vc sender:self];
        }
        DEBUG_ELSE
    }
    else if(SECTION(section) == SECTION_NUMBER) {
        NSUInteger storeCount = _numberSettings.count;
        if(row < storeCount) {
            HMDSRWSettingInputViewController *vc = [[HMDSRWSettingInputViewController alloc] initWithSetting:_numberSettings[row]];
            [self showViewController:vc sender:self];
        }
        DEBUG_ELSE
    }
    else if(SECTION(section) == SECTION_CONTROL) {
        if(row == 0) {
            [self tryToExit];
        }
        DEBUG_ELSE
    }
}

- (void)tryToExit {
    if(self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if(self.parentViewController != nil) {
        if([self.parentViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *vc = (__kindof UINavigationController *)self.parentViewController;
            NSArray<__kindof UIViewController *> *viewControllers = vc.viewControllers;
            if(viewControllers != nil && [viewControllers containsObject:self] && viewControllers[0] != self) {
                NSUInteger index = [viewControllers indexOfObject:self];
                __kindof UIViewController *toVC = viewControllers[index - 1];
                [vc popToViewController:toVC animated:YES];
            }
        }
    }
}

@end

#pragma mark - HMDSRWSettingCell

@interface HMDSRWSettingCell () <UITextFieldDelegate>
@property(nonatomic, readwrite) UITextField *textField;
@end

@implementation HMDSRWSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UITextField *textField = [[UITextField alloc] initWithFrame:self.contentView.frame];
        [self.contentView addSubview:textField];
        textField.delegate = self;
        [textField constraintEqualToView:self.contentView];
        self.textField = textField;
    }
    return self;
}

@end

#pragma mark - HMDSRWSettingInputViewController

@implementation HMDSRWSettingInputViewController {
    UINavigationItem *_navigationItem;
    HMDSRWSetting * _setting;
}

- (instancetype)initWithSetting:(HMDSRWSetting *)setting {
    if([setting isKindOfClass:HMDSRWSetting.class]) {
        if(self = [super initWithStyle:UITableViewStyleGrouped]) {
            _setting = setting;
        }
        return self;
    }
    return nil;
}

#pragma mark ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsMultipleSelection = NO;
    [self.tableView registerClass:[HMDSRWSettingCell class] forCellReuseIdentifier:@"settingCell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"commonCell"];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCallback:)];
    gr.numberOfTapsRequired = 1;
    gr.numberOfTouchesRequired = 1;
    gr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gr];
}

- (BOOL)definesPresentationContext {
    return YES;
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCurrentContext;
}

- (UINavigationItem *)navigationItem {
    if(_navigationItem == nil) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:@"输入界面"];
        if (@available(iOS 11.0, *)) {
            _navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        }
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"回到输入界面"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
        _navigationItem.backBarButtonItem = backBarButtonItem;
        _navigationItem.leftItemsSupplementBackButton = YES;
        if (@available(iOS 11.0, *)) {
            _navigationItem.hidesSearchBarWhenScrolling = YES;
        }
    }
    return _navigationItem;
}

#pragma mark GR callback

- (void)tapCallback:(UITapGestureRecognizer *)gr {
    if(gr.state == UIGestureRecognizerStateRecognized) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if([cell isKindOfClass:HMDSRWSettingCell.class]) {
            CGPoint touch = [gr locationInView:cell];
            if(![cell pointInside:touch withEvent:nil]) {
                HMDSRWSettingCell *setting_cell = (__kindof HMDSRWSettingCell *)cell;
                UITextField *textFiled = setting_cell.textField;
                [textFiled resignFirstResponder];
            }
        }
    }
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return 1;
    else if(section == 1) return 2;
    DEBUG_ELSE
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    UITableViewCell *cell;
    if(section == 0) cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    else if(section == 1) cell = [tableView dequeueReusableCellWithIdentifier:@"commonCell" forIndexPath:indexPath];
    else {
        DEBUG_POINT
        cell = [tableView dequeueReusableCellWithIdentifier:@"commonCell" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0) {
        if([cell isKindOfClass:HMDSRWSettingCell.class]) {
            HMDSRWSettingCell *setting_cell = (__kindof HMDSRWSettingCell *)cell;
            if(_setting.type == HMDSRWSettingTypeString) {
                setting_cell.textField.placeholder = @"一定要是字符串呢";
            }
            else if(_setting.type == HMDSRWSettingTypeNumber) {
                setting_cell.textField.placeholder = @"需要数字喔";
            }
            DEBUG_ELSE
        }
        DEBUG_ELSE
    }
    else if(section == 1) {
        if(row == 0) cell.textLabel.text = @"确认修改";
        else if(row == 1) cell.textLabel.text = @"关闭界面";
        DEBUG_ELSE
    }
    DEBUG_ELSE
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"输入界面";
    else if(section == 1) return @"操作界面";
    DEBUG_ELSE
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) return @"End of 输入界面";
    else if(section == 1) return @"End of 操作界面";
    DEBUG_ELSE
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0 && row == 0) return NO;
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0 && row == 0) return nil;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0) {
        DEBUG_POINT
    }
    else if(section == 1) {
        if(row == 0) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if([cell isKindOfClass:HMDSRWSettingCell.class]) {
                HMDSRWSettingCell *setting_cell = (__kindof HMDSRWSettingCell *)cell;
                UITextField *textFiled = setting_cell.textField;
                [textFiled resignFirstResponder];
                NSString *string = textFiled.text;
                if(_setting.type == HMDSRWSettingTypeNumber) {
                    const char *rawString = string.UTF8String;
                    double number;
                    if(sscanf(rawString, "%lf", &number) == 1) {
                        NSNumber *store = [NSNumber numberWithDouble:number];
                        _setting.number = store;
                        [_setting invokeAction];
                    }
                    else [HMDSRWTESTEnvironment showInformationTitle:@"类型检查" message:@"这不是数字吧"];
                }
                else if(_setting.type == HMDSRWSettingTypeString) {
                    _setting.string = string;
                    [_setting invokeAction];
                }
                DEBUG_ELSE
            }
            DEBUG_ELSE
        }
        else if(row == 1) [self tryToExit];
        DEBUG_ELSE
    }
    DEBUG_ELSE
}

- (void)tryToExit {
    if(self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if(self.parentViewController != nil) {
        if([self.parentViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *vc = (__kindof UINavigationController *)self.parentViewController;
            NSArray<__kindof UIViewController *> *viewControllers = vc.viewControllers;
            if(viewControllers != nil && [viewControllers containsObject:self] && viewControllers[0] != self) {
                NSUInteger index = [viewControllers indexOfObject:self];
                __kindof UIViewController *toVC = viewControllers[index - 1];
                [vc popToViewController:toVC animated:YES];
            }
        }
    }
}


@end

#pragma mark - UIView + Coordination

@implementation UIView (Coordination)

@dynamic origin, size, width, height;

- (void)setSize:(CGSize)size center:(CGPoint)center
{
    CGRect frame = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (NSArray<NSLayoutConstraint *> *)constraintEqualToView:(UIView *)view
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

- (NSArray<NSLayoutConstraint *> *)constraintAtTopEqualWidthFixedHight:(UIView *)scrollView internalSpace:(CGFloat)internalSpace
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:internalSpace];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:scrollView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:self.bounds.size.height];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

- (NSArray<NSLayoutConstraint *> *)constraintBelowViewFixedHight:(UIView *)formerView internalSpace:(CGFloat)internalSpace
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:internalSpace];
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:formerView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0];
    NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0
                                                           constant:self.bounds.size.height];
    NSArray *constraintArr = @[c1, c2, c3, c4];
    [NSLayoutConstraint activateConstraints:constraintArr];
    return constraintArr;
}

@end

@implementation HMDSRWTEST_KVO_POX : NSObject

+ (instancetype)shared {
    static __kindof HMDSRWTEST_KVO_POX *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        shared = [[HMDSRWTEST_KVO_POX alloc] init];
    });
    return shared;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"scene"]) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [HMDSRWTESTEnvironment refresh_vc_finder];
        });
    }
}

@end

static CFTimeInterval CAXNUSystemCall_timeSince1970(void) {
    struct timeval tv;
    if(!gettimeofday(&tv, NULL)) {
        return tv.tv_sec + ( (CFTimeInterval)tv.tv_usec / MICROSEC_PER_SEC);
    }
    return - 1.0;
}

#pragma mark - HMDSRW_ConsoleViewController

@implementation HMDSRW_ConsoleViewController {
    UINavigationItem *_navigationItem;
    UITextView *_textView;
    BOOL _isStandard;
    NSMutableAttributedString *_waitingPending;
    pthread_mutex_t _mtx;
    atomic_bool _refreshFlag;
    BOOL _viewAppeared;
}

+ (instancetype)networkConsole {
    static HMDSRW_ConsoleViewController *networkConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        networkConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
        networkConsole->_isStandard = YES;
    });
    return networkConsole;
}

+ (instancetype)standardConsole {
    static HMDSRW_ConsoleViewController *standardConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        standardConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
        standardConsole->_isStandard = YES;
    });
    return standardConsole;
}

+ (instancetype)databaseConsole {
    static HMDSRW_ConsoleViewController *databaseConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        databaseConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
    });
    return databaseConsole;
}

+ (instancetype)moduleConsole {
    static HMDSRW_ConsoleViewController *moduleConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        moduleConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
    });
    return moduleConsole;
}

+ (instancetype)uploadConsole {
    static HMDSRW_ConsoleViewController *uploadConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        uploadConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
    });
    return uploadConsole;
}

+ (instancetype)UIActionConsole {
    static HMDSRW_ConsoleViewController *UIActionConsole;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        UIActionConsole = [[HMDSRW_ConsoleViewController alloc] initWithDefault];
    });
    return UIActionConsole;
}

#pragma mark Initialization

- (instancetype)init {
    return HMDSRW_ConsoleViewController.standardConsole;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return HMDSRW_ConsoleViewController.standardConsole;
}

- (instancetype)initWithDefault {
    if(self = [super initWithStyle:UITableViewStyleGrouped]) {
        _waitingPending = [[NSMutableAttributedString alloc] init];
        _isStandard = NO;
        _viewAppeared = NO;
        pthread_mutex_init(&_mtx, NULL);
        atomic_store_explicit(&_refreshFlag, false, memory_order_release);
    }
    return self;
}

- (UITextView *)generateTextViewIfNotExist_mainThreadOnly {
    if(_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = CONSOLE_COLOR_BACKGROUND;
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.selectable = YES;
    }
    return _textView;
}

#pragma mark Log information

+ (void)log:(NSString *)info {
    [HMDSRW_ConsoleViewController.standardConsole log:info];
}

+ (void)log:(NSString *)info color:(UIColor *)color {
    [HMDSRW_ConsoleViewController.standardConsole log:info color:color];
}

+ (void)flush {
    [HMDSRW_ConsoleViewController.standardConsole flush];
}

- (void)log:(NSString *)info {
    if(!_isStandard) [HMDSRW_ConsoleViewController.standardConsole log:info];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:info attributes:@{ NSForegroundColorAttributeName:CONSOLE_COLOR_DEFAULT }];
    NSMutableAttributedString *waitingPending = _waitingPending;
    pthread_mutex_lock(&_mtx);
    [waitingPending appendAttributedString:str];
    pthread_mutex_unlock(&_mtx);
    bool expected = false;
    if(atomic_compare_exchange_strong_explicit(&_refreshFlag, &expected, true, memory_order_acq_rel, memory_order_acquire)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CONSOLE_UPADTE_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            if(_viewAppeared) {
                UITextView *textView = [self generateTextViewIfNotExist_mainThreadOnly];
                pthread_mutex_lock(&_mtx);
                [textView.textStorage appendAttributedString:waitingPending];
                [waitingPending deleteCharactersInRange:NSMakeRange(0, waitingPending.length)];
                pthread_mutex_unlock(&_mtx);
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
            atomic_store_explicit(&_refreshFlag, false, memory_order_release);
        });
    }
}

- (void)log:(NSString *)info color:(UIColor *)color {
    if(!_isStandard) [HMDSRW_ConsoleViewController.standardConsole log:info color:color];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:info attributes:@{ NSForegroundColorAttributeName:color?:UIColor.whiteColor }];
    NSMutableAttributedString *waitingPending = _waitingPending;
    pthread_mutex_lock(&_mtx);
    [waitingPending appendAttributedString:str];
    pthread_mutex_unlock(&_mtx);
    bool expected = false;
    if(atomic_compare_exchange_strong_explicit(&_refreshFlag, &expected, true, memory_order_acq_rel, memory_order_acquire)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CONSOLE_UPADTE_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            if(_viewAppeared) {
                UITextView *textView = [self generateTextViewIfNotExist_mainThreadOnly];
                pthread_mutex_lock(&_mtx);
                [textView.textStorage appendAttributedString:waitingPending];
                [waitingPending deleteCharactersInRange:NSMakeRange(0, waitingPending.length)];
                pthread_mutex_unlock(&_mtx);
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
            }
            atomic_store_explicit(&_refreshFlag, false, memory_order_release);
        });
    }
}

- (void)flush {
    NSMutableAttributedString *waitingPending = _waitingPending;
    pthread_mutex_lock(&_mtx);
    [waitingPending deleteCharactersInRange:NSMakeRange(0, waitingPending.length)];
    pthread_mutex_unlock(&_mtx);
    dispatch_async(dispatch_get_main_queue(), ^ {
        UITextView *textView = [self generateTextViewIfNotExist_mainThreadOnly];
        [textView.textStorage deleteCharactersInRange:NSMakeRange(0, textView.textStorage.length)];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewAppeared = YES;
    UITextView *textView = [self generateTextViewIfNotExist_mainThreadOnly];
    pthread_mutex_lock(&_mtx);
    [textView.textStorage appendAttributedString:_waitingPending];
    [_waitingPending deleteCharactersInRange:NSMakeRange(0, _waitingPending.length)];
    pthread_mutex_unlock(&_mtx);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _viewAppeared = NO;
}

#pragma mark TableView Data Source

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsMultipleSelection = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"commonCell"];
    
}

- (UINavigationItem *)navigationItem {
    if(_navigationItem == nil) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:@"CONSOLE"];
        if (@available(iOS 11.0, *)) {
            _navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        }
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"BACK CONSOLE"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
        
        UIBarButtonItem *rightBarButtonItem_top = [[UIBarButtonItem alloc] initWithTitle:@"UP"
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(scrollToTop)];
        
        UIBarButtonItem *rightBarButtonItem_bottom = [[UIBarButtonItem alloc] initWithTitle:@"DOWN"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(scrollToBottom)];
        
        _navigationItem.rightBarButtonItems = @[rightBarButtonItem_bottom, rightBarButtonItem_top];
        _navigationItem.backBarButtonItem = backBarButtonItem;
        _navigationItem.leftItemsSupplementBackButton = YES;
        if (@available(iOS 11.0, *)) {
            _navigationItem.hidesSearchBarWhenScrolling = YES;
        }
    }
    return _navigationItem;
}

- (void)scrollToTop {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)scrollToBottom {
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return 2;
    else if(section == 1) return 1;
    DEBUG_ELSE
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:@"commonCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0) {
        if(row == 0) cell.textLabel.text = @"想要关闭界面";
        else if(row == 1) cell.textLabel.text = @"清空控制台";
        DEBUG_ELSE
    }
    else if(section == 1) {
        UITextView *textView = [self generateTextViewIfNotExist_mainThreadOnly];
        [cell.contentView addSubview:textView];
        [textView constraintEqualToView:cell.contentView];
    }
    DEBUG_ELSE
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"CONTROL";
    else if(section == 1) return @"CONSOLE";
    DEBUG_ELSE
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 0) return @"End of CONTROL";
    else if(section == 1) return @"End of CONSOLE";
    DEBUG_ELSE
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    if(section == 1) return NO;
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    if(section == 1) return nil;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    if(section == 1) return UITableViewAutomaticDimension;
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    if(section == 1) return UITableViewAutomaticDimension;
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0) {
        if(row == 0) [self tryToExit];
        else if(row == 1) [self flush];
        DEBUG_ELSE
    }
    DEBUG_ELSE
}

- (void)tryToExit {
    if(self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if(self.parentViewController != nil) {
        if([self.parentViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *vc = (__kindof UINavigationController *)self.parentViewController;
            NSArray<__kindof UIViewController *> *viewControllers = vc.viewControllers;
            if(viewControllers != nil && [viewControllers containsObject:self] && viewControllers[0] != self) {
                NSUInteger index = [viewControllers indexOfObject:self];
                __kindof UIViewController *toVC = viewControllers[index - 1];
                [vc popToViewController:toVC animated:YES];
            }
        }
    }
}

@end

#pragma mark - UIColor (Designer)

@implementation UIColor (Designer)

+(instancetype)colorForHex:(NSString *)hex {
    const char *raw = hex.UTF8String;
    const char *current = raw;
    if(*current == '#') current++;
    size_t length = strlen(current);
    if(length == 6) {
        unsigned int red, green, blue;
        if(sscanf(current, "%2x%2x%2x", &red, &green, &blue) == 3) {
            // possible blue only one char
            return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        }
        DEBUG_ELSE
    }
    DEBUG_ELSE
    return UIColor.whiteColor;
}

@end

#pragma mark - HMDSRW_HeimdallrView

@implementation HMDSRW_HeimdallrView

#pragma mark fixed width

+ (instancetype)standard {
    static HMDSRW_HeimdallrView *standard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        standard = [[HMDSRW_HeimdallrView alloc] initWithFrame:CGRectMake(0, 0, HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width)];
    });
    return standard;
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width);
    if(self = [super initWithFrame:frame]) {
        self.opaque = NO;
    }
    return self;
}

- (instancetype)init {
    CGRect frame = CGRectMake(0, 0, HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width);
    if(self = [super initWithFrame:frame]) {
        self.opaque = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        [super setBounds:CGRectMake(0, 0, HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width)];
        self.opaque = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size = CGSizeMake(HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width);
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    bounds.size = CGSizeMake(HMDSRW_HeimdallrView_fixed_width, HMDSRW_HeimdallrView_fixed_width);
    [super setFrame:bounds];
}

- (void)drawRect:(CGRect)rect {
    [UIColor.whiteColor setFill];
    [UIColor.blackColor setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, HMDSRW_HeimdallrView_inside, HMDSRW_HeimdallrView_inside)];
    path.lineWidth = 2.0;
    [path fill];
    [path stroke];
    UIFont *font = [UIFont systemFontOfSize:HMDSRW_HeimdallrView_fixed_width - 2 * HMDSRW_HeimdallrView_inside - 2];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    style.alignment = NSTextAlignmentCenter;
    style.paragraphSpacingBefore = HMDSRW_HeimdallrView_inside;
    NSDictionary *attribute = @{NSForegroundColorAttributeName:UIColor.blackColor,
                                NSFontAttributeName:font,
                                NSParagraphStyleAttributeName:style};
    CGSize size = [@"H" sizeWithAttributes:attribute];
    CGRect textRect = CGRectMake(CGRectGetMidX(rect) - size.width / 2,
                                 CGRectGetMidY(rect) - size.height / 2,
                                 size.width, size.height);
    
    [@"H" drawInRect:textRect withAttributes:attribute];
}

@end

#pragma mark - HMDSRW_floatingVC

@implementation HMDSRW_floatingVC {
    CGPoint _viewBeginCenter;
    BOOL _presented;
}

@synthesize presented = _presented;

+ (instancetype)standard {
    static HMDSRW_floatingVC *standard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        standard = [[HMDSRW_floatingVC alloc] initWithDefault];
    });
    return standard;
}

- (instancetype)initWithDefault {
    if(self = [super init]) {
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCallback:)];
        panGR.maximumNumberOfTouches = 1;
        panGR.minimumNumberOfTouches = 1;
        [self.view addGestureRecognizer:panGR];
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCallBack:)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapGR];
        UILongPressGestureRecognizer *longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longCallback:)];
        longGR.numberOfTouchesRequired = 1;
        longGR.minimumPressDuration = 1.0;
        [self.view addGestureRecognizer:longGR];
        [self.view addSubview:HMDSRW_HeimdallrView.standard];
        
    }
    return self;
}

- (void)panCallback:(UIPanGestureRecognizer *)panGR {
    if(panGR.state == UIGestureRecognizerStateBegan) {
        _viewBeginCenter = HMDSRW_HeimdallrView.standard.center;
        CGPoint tranlation = [panGR translationInView:self.view];
        CGPoint reflect = CGPointMake(_viewBeginCenter.x + tranlation.x, _viewBeginCenter.y + tranlation.y);
        [panGR setTranslation:reflect inView:self.view];
        HMDSRW_HeimdallrView.standard.center = reflect;
    }
    else if(panGR.state == UIGestureRecognizerStateChanged || panGR.state == UIGestureRecognizerStateEnded) {
        HMDSRW_HeimdallrView.standard.center = [panGR translationInView:self.view];
    }
    else if(panGR.state == UIGestureRecognizerStateCancelled) {
        HMDSRW_HeimdallrView.standard.center = _viewBeginCenter;
    }
    DEBUG_ELSE
}

- (void)longCallback:(UILongPressGestureRecognizer *)longGR {
    if(longGR.state == UIGestureRecognizerStateEnded) {
        [self.view.window.rootViewController showViewController:[HMDSRWTESTEnvironment new] sender:self];
        _presented = YES;
    }
}

- (void)tapCallBack:(UITapGestureRecognizer *)tapGR {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Heimdallr 快捷功能"
                                                                   message:@"Let's say HuaQ"
                                                            preferredStyle:UIAlertControllerStyleActionSheet sourceView:self.view];
    
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"搭建测试环境"
                                                      style:UIAlertActionStyleDefault
                                                    handler: ^ (UIAlertAction * action) {
                                                        [[HMDSRWTESTEnvironment new] testActions][@"搭建测试环境"]();
                                                    }];
#ifndef Heimdallr_inspect
    NSString *title;
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kHMDSRW_HOOK_Heimdallr]) title = @"开启 Heimdallr 行为监控";
    else title = @"关闭 Heimdallr 行为监控";
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"开关 Heimdallr 行为监控"
                                                      style:UIAlertActionStyleDefault
                                                    handler: ^ (UIAlertAction * action) {
                                                        [[HMDSRWTESTEnvironment new] testActions][@"开关 Heimdallr 行为监控"]();
                                                    }];
#endif
    
    UIAlertAction* action3 = [UIAlertAction actionWithTitle:@"模块控制台"
                                                      style:UIAlertActionStyleDefault
                                                    handler: ^ (UIAlertAction * action) {
                                                        UIWindow *window = DC_ET(DC_OB(UIApplication.sharedApplication.delegate, window), UIWindow);
                                                        if(window == nil) window = UIApplication.sharedApplication.keyWindow;
                                                        Class aClass = NSClassFromString(@"HMDSRW_floatingWindow");
                                                        if(aClass != nil && [window isKindOfClass:aClass]) window = nil;
                                                        [window.rootViewController showViewController:HMDSRW_ConsoleViewController.moduleConsole sender:nil];
                                                    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消 ( ᖛ ᖛ )ʃ) " style:UIAlertActionStyleCancel handler: ^ (UIAlertAction *action) {
        // Called when user taps outside
    }];
    
    [alert addAction:action1];
#ifndef Heimdallr_inspect
    [alert addAction:action2];
#endif
    [alert addAction:action3];
    [alert addAction:cancelAction];
    [self showViewController:alert sender:self];
    _presented = YES;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    _presented = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if(!HMDSRW_floatingVC_didApear_onceToken) {
        HMDSRW_HeimdallrView.standard.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        HMDSRW_floatingVC_didApear_onceToken = YES;
    }
}

@end

#pragma mark - HMDSRW_floatingWindow

@implementation HMDSRW_floatingWindow

+ (instancetype)standard {
    static HMDSRW_floatingWindow *standard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        standard = [[HMDSRW_floatingWindow alloc] initWithDefault];
    });
    return standard;
}

- (instancetype)initWithDefault {
    if(self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        self.rootViewController = HMDSRW_floatingVC.standard;
        self.windowLevel = UIWindowLevelStatusBar + 2;
    }
    return self;
}

- (instancetype)init {
    return HMDSRW_floatingWindow.standard;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(HMDSRW_floatingVC.standard.presented) return [super hitTest:point withEvent:event];
    CGPoint converted = [HMDSRW_HeimdallrView.standard convertPoint:point fromView:self];
    if([HMDSRW_HeimdallrView.standard pointInside:converted withEvent:nil]) return self.rootViewController.view;
    return nil;
}

- (void)becomeKeyWindow {
    id window = DC_ET(DC_OB(UIApplication.sharedApplication.delegate, window), UIWindow);
    [window makeKeyWindow];
}

- (BOOL)canBecomeFirstResponder {
    return false;
}

@end

@implementation HMDSRW_NOT_TOUCH_WINDOW

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

@end
