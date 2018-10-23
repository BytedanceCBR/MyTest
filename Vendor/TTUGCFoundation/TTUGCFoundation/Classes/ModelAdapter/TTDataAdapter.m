//
//  TTDataAdapter.m
//  CSDoubleBindModel
//
//  Created by SongChai on 2017/5/4.
//  Copyright © 2017年 SongChai. All rights reserved.
//

#import "TTDataAdapter.h"
#import <KVOController.h>
#import <objc/runtime.h>

#import "TTRuntimeExtensions.h"
#import "NSValueTransformer+TTAdditions.h"
#import "FBKVOController+TTDataAdapter.h"

SEL TTSelectorWithKeyPattern(NSString *key, const char *suffix);
SEL TTSelectorWithKeyPattern(NSString *key, const char *suffix) {
    NSUInteger keyLength = [key maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger suffixLength = strlen(suffix);
    
    char selector[keyLength + suffixLength + 1];
    
    BOOL success = [key getBytes:selector maxLength:keyLength usedLength:&keyLength encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, key.length) remainingRange:NULL];
    if (!success) return NULL;
    
    memcpy(selector + keyLength, suffix, suffixLength);
    selector[keyLength + suffixLength] = '\0';
    
    return sel_registerName(selector);
}

@interface TTDataAdapter<MetaDataType, ViewDataType> () {
    BOOL _initPrepare;
    
    NSMutableSet<NSString *> *_banMetaKeyPathPrefixs;
}

@property(nonatomic, weak) ViewDataType viewDataObj;
@property(nonatomic, weak) MetaDataType metaDataObj;

@property(atomic, assign) BOOL banKVO;
@property(atomic, assign) BOOL isStatBanMetaKeyPath;
@property(nonatomic, strong) NSDictionary* valueTransformersDictionary;
@end

@implementation TTDataAdapter

- (instancetype)initWithMetaData:(id)tarObj {
    if (self = [super init]) {
        _metaDataObj = tarObj;
        _banMetaKeyPathPrefixs = [NSMutableSet new];
        _valueTransformersDictionary = [[self class] valueTransformersForViewDataClass:[self viewDataClass]
                                                                         metaDataClass:[self metaDataClass]];
    }
    return self;
}

//prepare会在setDataKVOController:之前
- (void)prepareWithViewData:(id)obj {
    if ([obj isKindOfClass:[self viewDataClass]] && [_metaDataObj isKindOfClass:[self metaDataClass]]) {
        _viewDataObj = obj;
        self.isStatBanMetaKeyPath = YES;
        [self mergeValuesForKeysToViewDataObj];
        self.isStatBanMetaKeyPath = NO;
    }
#if DEBUG
    [self checkInDebug];
#endif
}

- (void)prepareConstMetaData:(id)metaData viewData:(id)viewData {
    //template
}

//业务方在认为数据变化时，可以rebind，rebind内部触发条件为_banMetaKeyPathPrefixs不为空，且存在需要移除的k-v
- (void)reBind {
    if (_banMetaKeyPathPrefixs.count == 0)
        return;
    __block BOOL bind = YES;
    for (NSString *keyPath in _banMetaKeyPathPrefixs) {
        NSArray<NSString *> *keys = [keyPath componentsSeparatedByString:@"."];
        long count = keys.count;
        __block id obj = _metaDataObj;
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull inKey, NSUInteger idx, BOOL * _Nonnull stop) {
            obj = [obj valueForKey:inKey];
            if (idx >= count - 2) { //最后一个了，还不是空
                if (obj != nil) {
                    bind = NO;
                }
                *stop = YES;
            } else {
                if (obj == nil) { //不在最后一环，任何一环为nil都不安全
                    *stop = YES;
                }
            }
        }];
        if (bind == NO) {
            break;
        }
    }
    
    if (bind == NO) {
        [_banMetaKeyPathPrefixs removeAllObjects];
        if (_dataKVOController) {
            @try {
                [_dataKVOController unobserve:_viewDataObj];
                [_dataKVOController unobserve:_metaDataObj];
            } @catch (NSException *exception) {
                //可能出现异常: Fatal Exception: NSInternalInconsistencyException
                // Cannot remove an observer <_FBKVOSharedController 0x1704213c0> for the key path "****" from <ExploreOrderedData 0x132a80620>, most likely because the value for the key "**" has changed without an appropriate KVO notification being sent. Check the KVO-compliance of the ExploreOrderedData class.
            } @finally {
            }
        }
        self.isStatBanMetaKeyPath = YES;
        [self mergeValuesForKeysToViewDataObj];
        self.isStatBanMetaKeyPath = NO;
        if (_dataKVOController) {
            [self registerViewDataKVO];
            [self registerMetaDataKVO];
        }
    }
}

#if DEBUG
- (void)checkInDebug {
    NSAssert([self viewDataClass], @"viewDataClass can not be null");
    NSAssert([self metaDataClass], @"metaDataClass can not be null");
    NSAssert([_viewDataObj isKindOfClass:[self viewDataClass]], @"_viewDataObj must be an instance of viewDataClass");
    NSAssert([_metaDataObj isKindOfClass:[self metaDataClass]], @"_metaDataObj must be an instance of metaDataClass");
    NSDictionary* keyMap = [self.class DAKeyMap];
    NSAssert(keyMap, @"keyMap can not be null");
    
    [keyMap enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
        NSAssert([key isKindOfClass:NSString.class], @"key must be a string");
        NSAssert(([obj isKindOfClass:NSArray.class] || [obj isKindOfClass:NSString.class]), @"obj must be an instance of NSArray or NSString");
    }];
    
}
#endif

- (void)setDataKVOController:(FBKVOController *)dataKVOController {
    if (_dataKVOController != nil && _dataKVOController == dataKVOController) {
        [self reBind];
        return;
    }
    
    if (_dataKVOController == nil) {
        [self mergeValuesForKeysToViewDataObj];
    }
    if (_dataKVOController != dataKVOController) {
        if (_dataKVOController) {
            @try {
                [_dataKVOController unobserve:_viewDataObj];
                [_dataKVOController unobserve:_metaDataObj];
            } @catch (NSException *exception) {
                //可能出现异常: Fatal Exception: NSInternalInconsistencyException
                // Cannot remove an observer <_FBKVOSharedController 0x1704213c0> for the key path "****" from <ExploreOrderedData 0x132a80620>, most likely because the value for the key "**" has changed without an appropriate KVO notification being sent. Check the KVO-compliance of the ExploreOrderedData class.
            } @finally {
            }
            
        }
        _dataKVOController = dataKVOController;
        [self registerViewDataKVO];
        [self registerMetaDataKVO];
    }
    
    _initPrepare = YES;
}


- (void) registerViewDataKVO {
    if (_dataKVOController == nil) {
        return;
    }
    __weak TTDataAdapter* weakSelf = self;
    
    NSDictionary* keyMap = [[self class] DAKeyMap];
    
    NSMutableSet<NSString*>* keySet = [NSMutableSet setWithArray:[keyMap allKeys]];
    
    //循环依赖问题处理 viewDataObj中非当前修改元素反依赖metaData被修改元素
    [_dataKVOController observe:_viewDataObj keyPaths:[keySet allObjects] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        id kvoNew = change[NSKeyValueChangeNewKey];
        id kvoOld = change[NSKeyValueChangeOldKey];
        
        if (kvoNew == kvoOld || [kvoNew isEqual:kvoOld]) {
            return;
        }
        if ([kvoNew isKindOfClass:[NSString class]] && [kvoOld isKindOfClass:[NSString class]]) {
            if ([kvoNew isEqualToString:kvoOld]) {
                return;
            }
        }
        
        if (weakSelf.banKVO || [change objectForKey:NSKeyValueChangeNewKey] == [change objectForKey:NSKeyValueChangeOldKey]) {
            return ;
        }
        
        weakSelf.banKVO = YES;
        
        NSString* keyPath = change[FBKVONotificationKeyPathKey];
        
        if ([keySet containsObject:keyPath]) {
            NSString* metaDataKey = [keyMap objectForKey:keyPath];
            if ([metaDataKey isKindOfClass:[NSString class]]) {
                [weakSelf mergeViewDataToMetaDataWithViewDataKey:keyPath metaDataKey:metaDataKey];
                [keyMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (![key isEqualToString:keyPath]) { //其它key
                        if (([obj isKindOfClass:[NSString class]] && [metaDataKey isEqualToString:obj])
                            || ([obj isKindOfClass:[NSArray class]] && [((NSArray*)obj) containsObject:metaDataKey])) {
                            [weakSelf mergeMetaDataToViewDataWithViewDataKey:key metaDataKey:obj];
                        }
                    }
                }];
            }
            
        }
        
        weakSelf.banKVO = NO;
    }];
}

- (void) registerMetaDataKVO {
    if (_dataKVOController == nil) {
        return;
    }
    
    __weak TTDataAdapter* weakSelf = self;
    
    NSDictionary* keyMap = [[self class] DAKeyMap];
    NSArray* allValue = [keyMap allValues];
    
    NSMutableSet<NSString*>* valueSet = [NSMutableSet set];
    for (id obj in allValue) {
        if ([obj isKindOfClass:[NSString class]]) {
            if (![TTDataAdapter isExistBanObserverKey:obj inPrefifxs:_banMetaKeyPathPrefixs]) {
                [valueSet addObject:obj];
            }
        } else if ([obj isKindOfClass:[NSArray class]]) {
            for (id childObj in obj) {
                if ([childObj isKindOfClass:[NSString class]]) {
                    if (![TTDataAdapter isExistBanObserverKey:childObj inPrefifxs:_banMetaKeyPathPrefixs]) {
                        [valueSet addObject:childObj];
                    }
                }
            }
        }
    }
    
    [_dataKVOController observe:_metaDataObj keyPaths:[valueSet allObjects] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        id kvoNew = change[NSKeyValueChangeNewKey];
        id kvoOld = change[NSKeyValueChangeOldKey];
        
        if (kvoNew == kvoOld || [kvoNew isEqual:kvoOld]) {
            return;
        }
        if ([kvoNew isKindOfClass:[NSString class]] && [kvoOld isKindOfClass:[NSString class]]) {
            if ([kvoNew isEqualToString:kvoOld]) {
                return;
            }
        }
        
        if (weakSelf.banKVO || [change objectForKey:NSKeyValueChangeNewKey] == [change objectForKey:NSKeyValueChangeOldKey]) {
            return ;
        }
        
        weakSelf.banKVO = YES;
        
        NSString* keyPath = change[FBKVONotificationKeyPathKey];
        [keyMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (([obj isKindOfClass:[NSString class]] && [keyPath isEqualToString:obj])
                || ([obj isKindOfClass:[NSArray class]] && [((NSArray*)obj) containsObject:keyPath])) {
                [weakSelf mergeMetaDataToViewDataWithViewDataKey:key metaDataKey:obj];
            }
        }];
        
        weakSelf.banKVO = NO;
    }];
}

//将源数据全部搞到宿主obj
- (void)mergeValuesForKeysToViewDataObj {
    if ([_viewDataObj isKindOfClass:[self viewDataClass]] && [_metaDataObj isKindOfClass:[self metaDataClass]]) {
        NSDictionary* keyMap = [self.class DAKeyMap];
        [keyMap enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
            [self mergeMetaDataToViewDataWithViewDataKey:key metaDataKey:obj];
        }];
        
        if ([self respondsToSelector:@selector(prepareConstMetaData:viewData:)]) {
            [self prepareConstMetaData:_metaDataObj viewData:_viewDataObj];
            
            /**
            
            NSArray* convertKeys = [self DAConvertKeys];
            for (NSString* key in convertKeys) {
                id value = nil;
                
                SEL selector = TTSelectorWithKeyPattern(key, ":");
                if ([self respondsToSelector:selector]) { //一定要手动写方法
                    IMP imp = [self methodForSelector:selector];
                    NSMethodSignature *typeSignature = [self methodSignatureForSelector:selector];
                    

// wiki https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 
                    switch (typeSignature.methodReturnType[0]) {
#ifndef TTDA_CASE
    #define TTDA_CASE(_value, _type) \
            case _value: { \
                _type (*function)(id, SEL, id) = (__typeof__(function))imp; \
                _type result = function(self, selector, self.metaDataObj); \
                value = @(result); \
            } \
            break;
#endif
                            TTDA_CASE(_C_CHR, char)
                            TTDA_CASE(_C_UCHR, unsigned char)
                            TTDA_CASE(_C_SHT, short)
                            TTDA_CASE(_C_USHT, unsigned short)
                            TTDA_CASE(_C_INT, int)
                            TTDA_CASE(_C_UINT, unsigned int)
                            TTDA_CASE(_C_LNG, long)
                            TTDA_CASE(_C_ULNG, unsigned long)
                            TTDA_CASE(_C_LNG_LNG, long long)
                            TTDA_CASE(_C_ULNG_LNG, unsigned long long)
                            TTDA_CASE(_C_FLT, float)
                            TTDA_CASE(_C_DBL, double)
                            TTDA_CASE(_C_BOOL, BOOL)
                        case _C_ID: {
                            id (*function)(id, SEL, id) = (__typeof__(function))imp;
                            value = function(self, selector, self.metaDataObj);
                        }
                            break;
                        default: {
                            };
                            break;
                        }
                }
                if (value != nil) {
                    [_viewDataObj setValue:value forKey:key];
                }
            }
    */
        }
    }
}


/**
 检查改keyPath在所有节点是否存在nil，只要携带多级，且除了最后一级，还有其它级别出现了nil，则返回YES

 @param keyPath 需要KVO的keypath
 */
- (BOOL) checkBanObserverKey:(NSString *)keyPath {
    if (self.isStatBanMetaKeyPath) {
        return [TTDataAdapter checkBanObserverWithObj:_metaDataObj keyPath:keyPath inPrefifxs:_banMetaKeyPathPrefixs];
    }
    return NO;
}

- (void) mergeMetaDataToViewDataWithViewDataKey:(NSString*) key metaDataKey:(id) obj {
    id value;
    
    if ([obj isKindOfClass:NSArray.class]) {
        NSArray* JSONKeyPaths = (NSArray*) obj;
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        for (NSString *keyPath in JSONKeyPaths) {
            if (![self checkBanObserverKey:keyPath]) {
                id value = [_metaDataObj valueForKeyPath:keyPath];
                if (value != nil) dictionary[keyPath] = value;
            }
        }
        
        value = dictionary;
    } else {
        if ([self checkBanObserverKey:obj]) {
            value = nil;
        } else {
            value = [_metaDataObj valueForKeyPath:obj];
        }
    }
    
    @try {
        NSValueTransformer *transformer = self.valueTransformersDictionary[key];
        if (transformer != nil) {
            value = [transformer transformedValue:value];
        }
        if (value != nil) {
            [_viewDataObj setValue:value forKeyPath:key];
        }
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception %@ mergeMetaDataToViewDataWithViewDataKey \"%@\" metaDataKey: %@", ex, key, obj);
        // Fail fast in Debug builds.
#if DEBUG
        @throw ex;
#endif
    }

}

- (void) mergeViewDataToMetaDataWithViewDataKey:(NSString*) key metaDataKey:(NSString*) obj {
    if (![obj isKindOfClass:[NSString class]]) {
        return;
    }
    
    id value = [_viewDataObj valueForKeyPath:key];
    
    @try {
        NSValueTransformer *transformer = self.valueTransformersDictionary[key];
        if (transformer != nil) {
            value = [transformer reverseTransformedValue:value];
        }
        if (value != nil) {
            [_metaDataObj setValue:value forKeyPath:obj];
        }
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception %@ mergeViewDataToMetaDataWithViewDataKey \"%@\" metaDataKey: %@", ex, key, obj);
        
        // Fail fast in Debug builds.
#if DEBUG
        @throw ex;
#endif
    }
    
}

+ (NSDictionary *)valueTransformersForViewDataClass:(Class)modelClass metaDataClass:(Class)metaDataClass{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if ([self respondsToSelector:@selector(prepareCustomTransformer:)]) {
        [self prepareCustomTransformer:result];
    }
    NSDictionary* keyMap = [self.class DAKeyMap];
    
    [keyMap enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([result objectForKey:key]) { //已经有了就不遍历了
            return;
        }
        
        SEL selector = TTSelectorWithKeyPattern(key, "DATransformer");
        if ([self respondsToSelector:selector]) { //手动写了方法
            IMP imp = [self methodForSelector:selector];
            NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
            NSValueTransformer *transformer = function(self, selector);
            
            if (transformer != nil) result[key] = transformer;
        } else { //没有写，认为类型一样
            objc_property_t property = class_getProperty(modelClass, key.UTF8String);
            
            if (property == NULL) return;
            
            tt_propertyAttributes *attributes = tt_copyPropertyAttributes(property);
            
            NSValueTransformer *transformer = nil;
            
            if (*(attributes->type) == *(@encode(id))) { //非基本数据类型
                Class propertyClass = attributes->objectClass;
                
                if (propertyClass != nil) {
                    transformer = [self transformerForModelPropertiesOfClass:propertyClass];
                }
                
                if (transformer == nil) transformer = [NSValueTransformer tt_validatingTransformerForClass:propertyClass ?: NSObject.class];
            } else { //基本数据类型处理
                transformer = [self transformerForModelPropertiesOfObjCType:attributes->type] ?: [NSValueTransformer tt_validatingTransformerForClass:NSValue.class];
            }
            
            if (transformer != nil) result[key] = transformer;
            
            free(attributes);
        }
    }];
    
    return result;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
    NSParameterAssert(objCType != NULL);
    
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [NSValueTransformer valueTransformerForName:TTBooleanValueTransformerName];
    }
    
    return nil;
}

+ (NSValueTransformer *)transformerForModelPropertiesOfClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);
    
    SEL selector = TTSelectorWithKeyPattern(NSStringFromClass(modelClass), "DATransformer");
    if (![self respondsToSelector:selector]) return nil;
    
    IMP imp = [self methodForSelector:selector];
    NSValueTransformer * (*function)(id, SEL) = (__typeof__(function))imp;
    NSValueTransformer *result = function(self, selector);
    
    return result;
}

- (void)dealloc {
    
}

#pragma - mark “子类必须覆写”
- (Class)metaDataClass {
    return [_viewDataObj class];
}

- (Class)viewDataClass {
    return [_metaDataObj class];
}

+ (NSDictionary *)DAKeyMap {
    return @{};
}

+ (BOOL)isExistBanObserverKey:(NSString *)key inPrefifxs:(NSSet<NSString *>*)sets{
    for (NSString *prefix in sets) {
        if ([key hasPrefix:prefix]) { //只要前缀在里面，就不能kvo
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkBanObserverWithObj:(id) inputMetaDataObj keyPath:(NSString *)key inPrefifxs:(NSMutableSet<NSString *>*)sets{
    if ([self isExistBanObserverKey:key inPrefifxs:sets]) {
        return YES;
    }
    
    NSArray<NSString *> *keys = [key componentsSeparatedByString:@"."];
    long count = keys.count;
    if (keys.count > 1) {
        __block id obj = inputMetaDataObj;
        NSMutableString *mutableStr = [NSMutableString string];
        __block BOOL bind = NO;
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull inKey, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < count - 1) {
                obj = [obj valueForKey:inKey];
                [mutableStr appendFormat:@"%@.", inKey];
                if (obj == nil) { //不在最后一环，任何一环为nil都不安全
                    [sets addObject:[mutableStr copy]];
                    bind = YES;
                    *stop = YES;
                }
            }
        }];
        return bind;
    }
    return NO;
}

@end

@implementation NSMutableDictionary (TTDataAdapter)

- (void)addKey:(NSString *)key forwardBlock:(TTValueTransformerBlock)transformation {
    [self setObject:[TTValueTransformer transformerUsingForwardBlock:transformation] forKey:key];
}

- (void)addKey:(NSString *)key reversibleBlock:(TTValueTransformerBlock)transformation {
    [self setObject:[TTValueTransformer transformerUsingReversibleBlock:transformation] forKey:key];
}

- (void)addKey:(NSString *)key forwardBlock:(TTValueTransformerBlock)forwardTransformation reverseBlock:(TTValueTransformerBlock)reverseTransformation {
    [self setObject:[TTValueTransformer transformerUsingForwardBlock:forwardTransformation reverseBlock:reverseTransformation] forKey:key];
}

@end
