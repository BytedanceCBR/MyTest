//
//  TTBubbleViewManager.m
//  Article
//
//  Created by 王双华 on 2017/7/10.
//
//

#import "TTBubbleViewManager.h"
#import "TTArticleTabBarController.h"
#import "NSDictionary+TTAdditions.h"
//#import "TTUGCPermissionService.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTTabBarProvider.h"
#import "TTTabBarManager.h"

extern NSString *TTLaunchTimerTaskLaunchTimeIntervalKey;

static NSString *const TTBubbleViewManagerShowTipsKey = @"TTBubbleViewManagerShowTipsKey";

static NSString *const TTBubbleViewGeneralTypeStreamTipKey = @"tab_stream";
static NSString *const TTBubbleViewGeneralTypeVideoTipKey = @"tab_video";
static NSString *const TTBubbleViewGeneralTypePublisherTipKey = @"tab_publisher";
static NSString *const TTBubbleViewGeneralTypeTopicTipKey = @"tab_topic";
static NSString *const TTBubbleViewGeneralTypeWeitoutiaoTipKey = @"tab_weitoutiao";
static NSString *const TTBubbleViewGeneralTypeMineTipKey = @"tab_mine";
static NSString *const TTBubbleViewGeneralTypeHuoShanKey = @"tab_huoshan";

@interface TTBubbleViewManager ()
@property (nonatomic, strong, readwrite) NSString *field;
@property (nonatomic, strong, readwrite) NSString *text;
@property (nonatomic, assign, readwrite) NSTimeInterval displayInterval;
@property (nonatomic, assign, readwrite) NSTimeInterval autoDismissInterval;
@property (nonatomic, assign, readwrite) BOOL showClose;
@property (nonatomic, strong, readwrite) NSString *contentID;
@property (nonatomic, copy) NSDictionary *extraDic;
@property (nonatomic, strong) NSString *trackLabelForTipType;
@property (nonatomic, copy) NSDictionary *showTipsDict;
@end

@implementation TTBubbleViewManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    static TTBubbleViewManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _showTipsDict = [[NSUserDefaults standardUserDefaults] objectForKey:TTBubbleViewManagerShowTipsKey];
        _isValid = NO;

        BOOL tipHasShow = [_showTipsDict tt_boolValueForKey:@"tip_has_show"];
        
        if ([_showTipsDict objectForKey:@"field"]) {
            _field = [_showTipsDict stringValueForKey:@"field" defaultValue:nil];
        }
        
        if ([_showTipsDict objectForKey:@"text"]) {
            _text = [_showTipsDict stringValueForKey:@"text" defaultValue:nil];
        }
        
        if ([_showTipsDict objectForKey:@"display_interval"]) {
            _displayInterval = [_showTipsDict floatValueForKey:@"display_interval" defaultValue:5.f];
        }
        if (_displayInterval <= 0) {
            _displayInterval = 5.0f;
        }
        
        if ([_showTipsDict objectForKey:@"auto_dismiss_interval"]) {
            _autoDismissInterval = [_showTipsDict floatValueForKey:@"auto_dismiss_interval" defaultValue:4.f];
        }
        if (_autoDismissInterval <= 0) {
            _autoDismissInterval = 4.0f;
        }
        
        if ([_showTipsDict objectForKey:@"content_id"]) {
            _contentID = [_showTipsDict stringValueForKey:@"content_id" defaultValue:nil];
        }
        
        NSDictionary *fieldArray = @{TTBubbleViewGeneralTypeStreamTipKey: @(TTBubbleViewTypeTimerNewsTip),
                                     TTBubbleViewGeneralTypeVideoTipKey: @(TTBubbleViewTypeTimerVideoTip),
                                     TTBubbleViewGeneralTypePublisherTipKey: @(TTBubbleViewTypeTimerPostUGCTip),
                                     TTBubbleViewGeneralTypeTopicTipKey: @(TTBubbleViewTypeTimerFollowTip),
                                     TTBubbleViewGeneralTypeWeitoutiaoTipKey: @(TTBubbleViewTypeTimerWeitoutiaoTip),
                                     TTBubbleViewGeneralTypeMineTipKey: @(TTBubbleViewTypeTimerMineTabTip),
                                     TTBubbleViewGeneralTypeHuoShanKey: @(TTBubbleViewTypeTimerHTSTabTip)};
        
        if (!tipHasShow && !isEmptyString(_field) && !isEmptyString(_text) && [[fieldArray allKeys] containsObject:_field]) {
            _isValid = YES;
            _viewType = [[fieldArray objectForKey:_field] integerValue];
            if (_viewType == TTBubbleViewTypeTimerMineTabTip && ![TTTabBarProvider isMineTabOnTabBar]) {
                _viewType = TTBubbleViewTypeTimerMineTopEntranceTip;
            }
            if (([TTDeviceHelper isPadDevice]) ||
                (_viewType == TTBubbleViewTypeTimerFollowTip && [TTTabBarProvider isWeitoutiaoOnTabBar]) ||
                (_viewType == TTBubbleViewTypeTimerWeitoutiaoTip && ![TTTabBarProvider isWeitoutiaoOnTabBar]) ||
                (_viewType == TTBubbleViewTypeTimerHTSTabTip && ![TTTabBarProvider isHTSTabOnTabBar]) ||
                (_viewType == TTBubbleViewTypeTimerPostUGCTip /*&& !([GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCEntrancePosition] == TTPostUGCEntrancePositionTabbar)*/)) {
                /*
                 如果：
                 0、如果是ipad，没有tab;
                 1、下发关注tab出tip，但是无关注tab;
                 2、下发微头条tab出tip,但是无微头条tab;
                 3、下发火山tab出tip，但是无火山tab;
                 4、下发发布器出tip，但是发布器不在底tab;
                 那么是无效的，等到有相应tab了再出tip
                 */
                _isValid = NO;
            }
        }
    }
    return self;
}

- (NSString *)tabbarIdentifier
{
    switch (_viewType) {
        case TTBubbleViewTypeTimerNewsTip:
            return kTTTabHomeTabKey;
            
        case TTBubbleViewTypeTimerVideoTip:
            return kTTTabVideoTabKey;
            
        case TTBubbleViewTypeTimerFollowTip:
            return kTTTabFollowTabKey;
            
        case TTBubbleViewTypeTimerWeitoutiaoTip:
            return kTTTabWeitoutiaoTabKey;
            
        case TTBubbleViewTypeTimerMineTabTip:
            return kTTTabMineTabKey;
            
        case TTBubbleViewTypeTimerHTSTabTip:
            return kTTTabHTSTabKey;
        default:
            return @"unknown";
    }
    return @"unknown";
}

- (void)saveShowTips:(NSDictionary *)dict
{
    if (dict && [dict count] > 0) {
        NSDictionary *lastDict = [[NSUserDefaults standardUserDefaults] objectForKey:TTBubbleViewManagerShowTipsKey];
        if ([dict objectForKey:@"content_id"]) {
            NSInteger lastContentID = [lastDict tt_integerValueForKey:@"content_id"];
            NSInteger currentContentID = [dict tt_integerValueForKey:@"content_id"];
            if (lastContentID == 0 || currentContentID > lastContentID) {
                [[NSUserDefaults standardUserDefaults] setValue:dict forKey:TTBubbleViewManagerShowTipsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
}

- (void)sendTrackForTipsShow
{
    wrapperTrackEventWithCustomKeys(@"navbar", [NSString stringWithFormat:@"%@_show_notice",self.trackLabelForTipType], nil, nil, self.extraDic);
}

- (void)sendTrackForTipsActiveClose
{
    wrapperTrackEventWithCustomKeys(@"navbar", [NSString stringWithFormat:@"%@_close_notice",self.trackLabelForTipType], nil, nil, self.extraDic);}

- (void)sendTrackForTipsAutoClose
{
    wrapperTrackEventWithCustomKeys(@"navbar", [NSString stringWithFormat:@"%@_auto_close_notice",self.trackLabelForTipType], nil, nil, self.extraDic);
}

- (void)sendTrackForTipsEnterClick
{
    wrapperTrackEventWithCustomKeys(@"navbar", [NSString stringWithFormat:@"enter_%@_click_notice",self.trackLabelForTipType], nil, nil, self.extraDic);
}

- (NSString *)trackLabelForTipType
{
    if(!_trackLabelForTipType){
        switch (_viewType) {
            case TTBubbleViewTypeTimerNewsTip:
                _trackLabelForTipType = @"home";
                break;
            case TTBubbleViewTypeTimerVideoTip:
                _trackLabelForTipType = @"video";
                break;
            case TTBubbleViewTypeTimerPostUGCTip:
                _trackLabelForTipType = @"publisher";
                break;
            case TTBubbleViewTypeTimerFollowTip:
                _trackLabelForTipType = @"topic";
                break;
            case TTBubbleViewTypeTimerWeitoutiaoTip:
                _trackLabelForTipType = @"weitoutiao";
                break;
            case TTBubbleViewTypeTimerMineTabTip:
            case TTBubbleViewTypeTimerMineTopEntranceTip:
                _trackLabelForTipType = @"mine";
                break;
            case TTBubbleViewTypeTimerHTSTabTip:
                _trackLabelForTipType = @"huoshan";
                break;
            default:
                break;
        }
    }
    return _trackLabelForTipType;
}

- (NSDictionary *)extraDic
{
    if (!_extraDic) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:0];
        [extra setValue:_contentID forKey:@"content_id"];
        _extraDic = extra;
    }
    return _extraDic;
}

- (void)setTipHasShow
{
    if (_isValid) {//只展示一次
        NSMutableDictionary *mutDict = [NSMutableDictionary dictionaryWithDictionary:_showTipsDict];
        [mutDict setValue:@(YES) forKey:@"tip_has_show"];
        _showTipsDict = [mutDict copy];
        
        NSDictionary *lastDict = [[NSUserDefaults standardUserDefaults] objectForKey:TTBubbleViewManagerShowTipsKey];
        if ([mutDict objectForKey:@"content_id"]) {
            NSInteger lastContentID = [lastDict tt_integerValueForKey:@"content_id"];
            NSInteger currentContentID = [mutDict tt_integerValueForKey:@"content_id"];
            if (currentContentID == lastContentID) {//确保只修改当前id的dict
                [[NSUserDefaults standardUserDefaults] setValue:[mutDict copy] forKey:TTBubbleViewManagerShowTipsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        _isValid = NO;
    }
}

//判断是不是定时出的tip
+ (BOOL)isViewTypeTimer:(TTBubbleViewType)viewType
{
    return  viewType == TTBubbleViewTypeTimerNewsTip ||
    viewType == TTBubbleViewTypeTimerVideoTip ||
    viewType == TTBubbleViewTypeTimerPostUGCTip||
    viewType == TTBubbleViewTypeTimerFollowTip ||
    viewType == TTBubbleViewTypeTimerWeitoutiaoTip ||
    viewType == TTBubbleViewTypeTimerMineTabTip||
    viewType == TTBubbleViewTypeTimerHTSTabTip ||
    viewType == TTBubbleViewTypeTimerMineTopEntranceTip;
}
@end
