//
//  TTRNKitHelper.m
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <IESGeckoKit/IESGeckoKit.h>
// base、business包的metafile中，version字段对应的key
static NSString *kTTRNKitBundleVersion = @"reactNativeVersion";
// base、business包的metafile的名称
static NSString *kTTRNKitMetaFileName = @"manifest.json";
static NSString *kTTRNKitIntact = @"intact";
NSString *defaultBundleVersion = @"baseline";
NSInteger bundleVersionIndex = 0;
NSInteger bundleNeedCombineIndex = 1;

NSString *bundleFullNameForBundleName(NSString *bundleName) {
    if ([bundleName hasSuffix:@"bundle"]) {
        return bundleName;
    }
    return [bundleName stringByAppendingString:@".bundle"];
}

NSString *geckoBundleDirPathForGeckoParams(NSDictionary *geckoParams, NSString *channel) {
    NSString *channelName = channel ?: [geckoParams tt_stringValueForKey:TTRNKitGeckoChannel];
    return [IESGeckoKit rootDirForAccessKey:[geckoParams tt_stringValueForKey:TTRNKitGeckoKey]
                                    channel:channelName];
}
//gecko 默认的bundlepath
NSString *geckoBundlePathForGeckoParams(NSDictionary *geckoParams, NSString *channel) {
    NSString *jsbundleName = bundleFullNameForBundleName([geckoParams tt_stringValueForKey:TTRNKitBundleName]);
    NSString *rootDir = geckoBundleDirPathForGeckoParams(geckoParams, channel);
    NSString *bundleUrlStr = [rootDir stringByAppendingPathComponent:jsbundleName];
    return bundleUrlStr;
}

#pragma mark - Gecko Bundle Info
NSString *bundleIdentifierWithBundlePathAndVersion(NSString *bundlePath, NSString *version) {
    return [NSString stringWithFormat:@"%@_%@", bundlePath, version];
}

NSArray *getValuesForKeysFromDataWithDefaults(NSArray<NSString*> *keys, NSData *data, NSArray *defaultValues) {
    if (!keys.count || keys.count != defaultValues.count) {
        return nil;
    }
    if (data) {
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
        if ([dataDic isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:keys.count];
            [keys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                result[idx] = [dataDic objectForKey:obj] ?: defaultValues[idx];
            }];
            return result;
        }
    }
    return defaultValues;
}

#pragma mark - 判断是否需要合并bundle包
NSString *commonBundleVersionForGeckoParams(NSDictionary *geckoParams) {
    NSData *metaData = [NSData dataWithContentsOfFile:[geckoParams tt_stringValueForKey:TTRNKitCommonBundleMetaPath]];
    return getValuesForKeysFromDataWithDefaults(@[kTTRNKitBundleVersion], metaData, @[defaultBundleVersion])[0];
}

NSArray *geckoBundleInfoForGeckoParams(NSDictionary *geckoParams, NSString *channel) {
    NSString *rootDir = geckoBundleDirPathForGeckoParams(geckoParams, channel);
    NSString *metaFilePath = [rootDir stringByAppendingPathComponent:kTTRNKitMetaFileName];
    NSData *metaData = [NSData dataWithContentsOfFile:metaFilePath];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
    return getValuesForKeysFromDataWithDefaults(@[kTTRNKitBundleVersion, kTTRNKitIntact], metaData, @[defaultBundleVersion, @(YES)]);
}

NSURL *bundleUrlForGeckoParams(NSDictionary *geckoParams, NSString *channel) {
    NSString *geckoBundlePath = geckoBundlePathForGeckoParams(geckoParams, channel);
    if ([[NSFileManager defaultManager] fileExistsAtPath:geckoBundlePath isDirectory:nil]) {
        return [NSURL URLWithString:geckoBundlePath];
    }
    NSDictionary *defaultDic = [geckoParams valueForKey:TTRNKitDefaultBundlePath];
    if ([defaultDic isKindOfClass:[NSString class]]) { //0.2.3-rc.20之前只支持管理单一channel，此字段对应的是字符串
        return [NSURL URLWithString:(NSString *)defaultDic];
    }
    return [NSURL URLWithString:[defaultDic tt_stringValueForKey:channel]];
}

#pragma mark - LRU
static NSMutableDictionary<NSURL*, id> *_cachedBridges;
typedef struct lruNode {
    const char *value;
    struct lruNode *next;
    struct lruNode *pre;
} lruNode;

typedef struct lruList {
    lruNode *head;
    lruNode *tail;
    int length;
} lruList;

static lruList *_bridgeInfoList;
static void bringNodeToFront(lruList *list, lruNode *node);
static void insertHeadNode(lruList *list, lruNode *node) {
    if (NULL == node || NULL == node->value) {
        return;
    }
    if (NULL == list->head) {
        list->head = list->tail = node;
        list->length += 1;
    } else {
        lruNode *cur = list->head;
        while (NULL != cur && NULL != cur->value) {
            if (strcmp(cur->value, node->value) == 0) {
                return bringNodeToFront(list, cur);
            }
            cur = cur->next;
        }
        node->next = list->head;
        list->head->pre = node;
        list->head = node;
        node->pre = NULL;
        list->length += 1;
    }
}

static void *deleteTail(lruList *list) {
    if (NULL != list->tail) {
        lruNode *node = list->tail;
        list->tail = node->pre;
        if (NULL != list ->tail) {
            list->tail->next = NULL;
        }
        list->length -= 1;
        void *value = node->value;
        free(node);
        return value;
    }
    return NULL;
}

static void bringNodeToFront(lruList *list, lruNode *node) {
    if (NULL == list->head || NULL == node) {
        return;
    }
    if (strcmp(list->head->value, node->value) == 0) {
        return;
    }
    lruNode *curNode = node;
    if (curNode) { //非首节点
        curNode->pre->next = curNode->next;
        if (NULL != curNode->next) {
            curNode->next->pre = curNode->pre;
        }
        if (list->tail == curNode) {
            list->tail = curNode->pre;
        }
        list->length -= 1;
        curNode->pre = NULL;
        curNode->next = NULL;
        insertHeadNode(list, curNode);
    }
}

static void bringValueToFront(lruList *list, const char *value) {
    if (NULL == list->head || strcmp(list->head->value, value) == 0) {
        return;
    }
    lruNode *curNode = list->head->next;
    while (curNode != NULL) {
        if (strcmp(value, curNode->value) == 0) {
            break;
        }
        curNode = curNode->next;
    }
    bringNodeToFront(list, curNode);
}

static void trimToCount(int count) {
    if (count <= 0) {
        [_cachedBridges removeAllObjects];
        _bridgeInfoList->head = _bridgeInfoList->tail = NULL;
        _bridgeInfoList->length = 0;
    } else {
        while (_bridgeInfoList->length > count) {
            void *value = deleteTail(_bridgeInfoList);
            [_cachedBridges enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, id obj, BOOL * _Nonnull stop) {
                if (strcmp([[key absoluteString] UTF8String], value) == 0) {
                    [_cachedBridges removeObjectForKey:key];
                }
            }];
            free(value);
        }
    }
}

static const char *convertedKeyForURL(NSURL *url) {
    return [[url absoluteString] UTF8String];
}

static const char *copyStr(const char *value) {
    size_t strLen = strlen(value);
    const char *c = malloc(strLen+1);
    memset(c, 0, strLen+1);
    memcpy(c, value, strLen);
    return c;
}

static void insertHeadURL(NSURL *url, id value, BOOL useLRU) {
    _cachedBridges[url] = value;
    if (useLRU) {
        const char *key = copyStr(convertedKeyForURL(url));
        lruNode *node = malloc(sizeof(lruNode));
        node->value = key;
        node->pre = NULL;
        node->next = NULL;
        insertHeadNode(_bridgeInfoList, node);
    }
}

static id getValueForURL(NSURL *url, BOOL useLRU) {
    id value = [_cachedBridges objectForKey:url];
    if (useLRU && value) {
        const char *key = convertedKeyForURL(url);
        bringValueToFront(_bridgeInfoList, key);
    }
    return value;
}

static void deleteNodeForURL(NSURL *url) {
    [_cachedBridges removeObjectForKey:url];
    const char *key = convertedKeyForURL(url);
    lruNode *node = _bridgeInfoList->head;
    while (NULL != node) {
        if (strcmp(key, node->value) == 0) {
            if (NULL != node->pre) {
                node->pre->next = node->next;
            }
            if (NULL != node->next) {
                node->next->pre = node->pre;
            }
            if (_bridgeInfoList->head == node) {
                _bridgeInfoList->head = node->next;
            }
            if (_bridgeInfoList->tail == node) {
                _bridgeInfoList->tail = node->pre;
            }
            _bridgeInfoList->length -= 1;
            free(node->value);
            free(node);
            break;
        }
        node = node->next;
    }
}

@implementation TTRNKitRouteParams
@end

@implementation TTRNKitHelper
+ (BOOL)isEmptyString:(NSString *)str{
    return (!str || ![str isKindOfClass:[NSString class]] || str.length == 0);
}

+ (UIViewController *)findWrapperController:(UIView *)view {
    for (UIView* next = view; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


+ (void)closeViewController:(UIViewController *)viewController{
    if (viewController) {
        if (viewController.navigationController && viewController.navigationController.viewControllers.count > 1 && ![viewController isEqual:viewController.navigationController.viewControllers.firstObject]){
            [viewController.navigationController popViewControllerAnimated:YES];
        }else {
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
+ (UIView *)getLoadingViewWith:(NSString *)className size:(CGSize)size {
    UIView *view;
    if (![self isEmptyString:className] && !CGSizeEqualToSize(size, CGSizeZero)) {
        Class class = NSClassFromString(className);
        id instance = [[class alloc] init];
        if ([instance isKindOfClass:[UIView class]]) {
            view = instance;
            [(UIView *)view setFrame:CGRectMake(0, 0, size.width, size.height)];
        }
    }
    if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)view startAnimating];
    }
    return view;
}

+ (void)decodeWithEncodedURLString:(NSString **)urlString {
    if ([*urlString rangeOfString:@"%"].length == 0){
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

+ (TTRNKitRouteParams *)routeParamObjWithString:(NSString *)str {
    NSString *urlString = [str copy];
    if (!urlString.length) {
        NSAssert(NO, @"urlStr为空，请确保url创建成功!");
        return nil;
    }
    
    TTRNKitRouteParams *paramObj = [[TTRNKitRouteParams alloc] init];
    
    NSString *scheme = nil;
    NSString *host = nil;
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
    
    NSRange schemeSegRange = [urlString rangeOfString:@"://"];
    NSString *outScheme = nil;
    if (schemeSegRange.location != NSNotFound) {
        scheme = [urlString substringToIndex:NSMaxRange(schemeSegRange)];
        outScheme = [urlString substringFromIndex:NSMaxRange(schemeSegRange)];
    }
    else {
        outScheme = urlString;
    }
    
    NSArray *substrings = [outScheme componentsSeparatedByString:@"?"];
    NSString *path = [substrings objectAtIndex:0];
    NSArray *hostSeg = [path componentsSeparatedByString:@"/"];
    
    host = [hostSeg objectAtIndex:0];
    
    if ([substrings count] > 1) {
        NSString *queryString = [substrings objectAtIndex:1];
        NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
        [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
            NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
            if ([keyAndValue count] > 1) {
                NSString *paramKey = [keyAndValue objectAtIndex:0];
                NSString *paramValue = [keyAndValue objectAtIndex:1];
                
                //v0.2.19 去掉递归decode，外部保证传入合法encode的url
                [self decodeWithEncodedURLString:&paramValue];
                
                if (paramValue && paramKey) {
                    [queryParams setValue:paramValue forKey:paramKey];
                }
            }
        }];
    }
    
    if ([hostSeg count] > 1) {
        paramObj.segment = [hostSeg objectAtIndex:1];
    }
    
    paramObj.scheme = scheme;
    paramObj.host = host;
    paramObj.queryParams = [queryParams copy];
    
    return paramObj;
}

#pragma mark - LRU
static BOOL urlIsLegal(NSURL *url) {
    if (!url.absoluteString.length) {
        return NO;
    }
    return YES;
}

+ (void)initLRUList {
    _cachedBridges = [NSMutableDictionary dictionary];
    _bridgeInfoList = malloc(sizeof(lruList));
    _bridgeInfoList->head = _bridgeInfoList->tail = NULL;
    _bridgeInfoList->length = 0;
}

+ (void)insertURL:(id)url withValue:(id)value useLRU:(BOOL)lru {
    if (urlIsLegal(url)) {
        insertHeadURL(url, value, lru);
    }
}

+ (void)deleteURL:(NSURL *)url {
    if (urlIsLegal(url)) {
        deleteNodeForURL(url);
    }
}

+ (void)trimToCount:(NSInteger)count {
    trimToCount(count);
}

+ (id)getValueForURL:(NSURL *)url updateLRU:(BOOL)update {
    if (urlIsLegal(url)) {
        return getValueForURL(url, update);
    }
    return nil;
}

#if DEBUG
+ (NSString *)LRUListDebugDescription {
    NSString *string = @"";
    lruNode *node = _bridgeInfoList->head;
    while (NULL != node) {
        string = [string stringByAppendingString:[NSString stringWithUTF8String:node->value]];
        node = node->next;
    }
    return string;
}
#endif
@end
