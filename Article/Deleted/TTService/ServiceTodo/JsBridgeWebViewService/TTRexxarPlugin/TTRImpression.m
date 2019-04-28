//
//  TTRImpression.m
//  Article
//
//  Created by Chen Hong on 2017/6/27.
//
//

#import "TTRImpression.h"
#import "SSImpressionManager.h"
#import <Aspects.h>
#import <objc/runtime.h>

// 由于webView是共享的，webView的属性也变为共享，所以把属性关联到目标VC，为了与VC的生命周期同步
@interface TTRImpressionObj : NSObject <SSImpressionProtocol>

// webView里每一个需要添加impression的控件组是一个group，keyStore保存每个group的当前param，用于对当前显示对象重新计时
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *keyStore;

// 前端调用impression的param参数里只有当前显示的item，需要客户端比较前后两次的差异，判断新显示出来的item，所以需要保存一下每个group已显示的所有itemId
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *visibleItemIds;

@property(nonatomic, weak) UIView<TTRexxarEngine> *webview;

@end

@implementation TTRImpressionObj

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SSImpressionManager shareInstance] addRegist:self];
        self.keyStore = [NSMutableDictionary dictionary];
        self.visibleItemIds = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (void)resetVisibleItemIds {
    self.visibleItemIds = [NSMutableDictionary dictionary];
}

// isReset=YES 表示将当前所有impression记录全部取出发送，显示中的item重新开始计时
- (void)handleImpressions:(NSDictionary *)param restartVisibleItems:(BOOL)isReset {
    NSString *keyName = [param tt_stringValueForKey:@"imp_group_key_name"];
    int listType = [param tt_intValueForKey:@"imp_group_list_type"];
    
    if (isReset) {
        [self resetVisibleItemIds];
    } else {
        if (!isEmptyString(keyName)) {
            [self.keyStore setValue:param forKey:keyName];
        }
    }
    
    NSDictionary *groupExtra = [param tt_dictionaryValueForKey:@"imp_group_extra"];
    NSArray *visibleItems = [param tt_arrayValueForKey:@"impressions_in"];
    NSArray *currentVisibleItemIds = [self.visibleItemIds tt_arrayValueForKey:keyName];
    
    // 过滤出新显示的item
    NSMutableArray *impIn = [NSMutableArray array];
    NSMutableArray *itemIds = [NSMutableArray arrayWithCapacity:visibleItems.count];
    
    for (NSDictionary *item in visibleItems) {
        if (![item isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSString *itemId = [item tt_stringValueForKey:@"imp_item_id"];
        
        if (!isEmptyString(itemId)) {
            if (![currentVisibleItemIds containsObject:itemId]) {
                [impIn addObject:item];
            }
            [itemIds addObject:itemId];
        }
    }
    
    [self.visibleItemIds setValue:[NSArray arrayWithArray:itemIds] forKey:keyName];
    
    //item begin dislay
    [impIn enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self recordItem:obj visible:YES groupKey:keyName listType:listType groupExtra:groupExtra];
    }];
    
    if (!isReset) {
        //item end display
        NSArray *impOut = [param tt_arrayValueForKey:@"impressions_out"];
        [impOut enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self recordItem:obj visible:NO groupKey:keyName listType:listType groupExtra:groupExtra];
        }];
    }
}

- (void)recordItem:(NSDictionary *)item visible:(BOOL)impIn groupKey:(NSString *)key listType:(int)listType groupExtra:(NSDictionary *)groupExtra{
    if (![item isKindOfClass:[NSDictionary class]]) return;
    
    int itemType = [item tt_intValueForKey:@"imp_item_type"];
    NSString *itemId = [item tt_stringValueForKey:@"imp_item_id"];
    NSDictionary *userInfo = nil;
    
    if (groupExtra) {
        userInfo = [NSDictionary dictionaryWithObject:groupExtra forKey:@"extra"];
    }
    
    SSImpressionStatus status = impIn ? SSImpressionStatusRecording : SSImpressionStatusEnd;
    [[SSImpressionManager shareInstance] recordWithListKey:key listType:listType itemID:itemId modelType:itemType adID:nil status:status userInfo:userInfo];
    
//    if (impIn) {
//        NSLog(@"~~begin %@", itemId);
//    } else {
//        NSLog(@"~~end %@", itemId);
//    }
}

- (void)enterView {
    [self.keyStore enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull param, BOOL * _Nonnull stop) {
        [self handleImpressions:param restartVisibleItems:YES];
    }];
}

- (void)leaveView {
    [self.keyStore enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull param, BOOL * _Nonnull stop) {
        //        [[SSImpressionManager shareInstance] leaveWithListKey:key listType:listType];
        NSDictionary *groupExtra = [param tt_dictionaryValueForKey:@"imp_group_extra"];
        int listType = [param tt_intValueForKey:@"imp_group_list_type"];
        NSArray *visibleItems = [param tt_arrayValueForKey:@"impressions_in"];
        
        [visibleItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self recordItem:(NSDictionary *)obj visible:NO groupKey:key listType:listType groupExtra:groupExtra];
        }];
    }];

    [self resetVisibleItemIds];
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions {
    if (_webview.window) {
        [self.keyStore enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
//            NSLog(@"~~~~~~~restart~~~~~~~~~~");
            [self handleImpressions:obj restartVisibleItems:YES];
        }];
    }
}

@end

#pragma mark - 

@interface UIViewController (TTRImpression)

- (TTRImpressionObj *)ttrImpressionObj;

- (void)setTtrImpressionObj:(TTRImpressionObj *)ttrImpressionObj;

@end

@implementation UIViewController (TTRImpression)

- (TTRImpressionObj *)ttrImpressionObj {
    return (TTRImpressionObj *)objc_getAssociatedObject(self, @selector(ttrImpressionObj));
}

- (void)setTtrImpressionObj:(TTRImpressionObj *)ttrImpressionObj {
    objc_setAssociatedObject(self, @selector(ttrImpressionObj), ttrImpressionObj, OBJC_ASSOCIATION_RETAIN);
}

@end

#pragma mark -

@implementation TTRImpression

+ (TTRJSBInstanceType)instanceType {
    return TTRJSBInstanceTypeWebView;
}

// 前端调用客户端的impression方法
- (void)onWebImpressionWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    if (!controller) {
        callback(TTRJSBMsgFailed, @{});
        return;
    }
    
    if (!controller.ttrImpressionObj) {
        TTRImpressionObj *impObj = [[TTRImpressionObj alloc] init];
        impObj.webview = webview;
        controller.ttrImpressionObj = impObj;
        
        [controller aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
            [impObj enterView];
        } error:nil];
        
        [controller aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
            [impObj leaveView];
        } error:nil];
    }
    
    [controller.ttrImpressionObj handleImpressions:param restartVisibleItems:NO];
    
    callback(TTRJSBMsgSuccess, @{});
}

// 返回webview相对屏幕的位置
//- (void)onWebRectWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
//    CGRect r = [webview convertRect:webview.bounds toView:nil];
//    NSString *frame = [NSString stringWithFormat:@"(%d,%d,%d,%d)", (int)r.origin.x, (int)r.origin.y, (int)r.size.width, (int)r.size.height];
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:frame forKey:@"frame"];
//    callback(TTRJSBMsgSuccess, dict);
//}

@end


