//
//  TTAccountStore.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 11/28/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "TTAccountStore.h"
#import "TTAccountKeyChainStore.h"



@interface TTAccountStore ()
@property (nonatomic,   copy) NSString *serviceName;
@property (nonatomic,   copy) NSString *accessGroupName;
@property (nonatomic, strong) TTAccountKeyChainStore *keychainStore;
@end
@implementation TTAccountStore
/**
 *  默认的serviceName: bundleIdentifier
 *       accessGroup: hash(bundleIdentifier).bundleIdentifier[.group]
 */
+ (instancetype)sharedStore
{
    static TTAccountStore *sharedInst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInst = [self new];
    });
    return sharedInst;
}

+ (instancetype)storeWithServiceName:(NSString *)serviceName
                         accessGroup:(NSString *)accessGroupName
{
    TTAccountStore *accountStore = [[self alloc] initWithService:serviceName
                                                     accessGroup:accessGroupName];
    return accountStore;
}

- (instancetype)initWithService:(NSString *)serviceName accessGroup:(NSString *)accessGroupName
{
    if ((self = [super init])) {
        self.serviceName     = serviceName;
        self.accessGroupName = accessGroupName;
        
        self.keychainStore = [TTAccountKeyChainStore keyChainStoreWithService:self.serviceName accessGroup:self.accessGroupName];
    }
    return self;
}

- (instancetype)init
{
    if ((self = [self initWithService:nil accessGroup:nil])) {
        
    }
    return self;
}

/**
 *  使用默认的service和accessGroup
 */
+ (void)tt_setBool:(BOOL)aBool forKey:(NSString *)key
{
    [self tt_setNumber:@(aBool) forKey:key];
}

+ (void)tt_setNumber:(NSNumber *)aNumber forKey:(NSString *)key
{
    [self tt_setString:[aNumber stringValue] forKey:key];
}

+ (void)tt_setString:(NSString *)string forKey:(NSString *)key
{
    [[self sharedStore] tt_setString:string forKey:key];
}

+ (void)tt_setArray:(NSArray *)array forKey:(NSString *)key
{
    [[self sharedStore] tt_setArray:array forKey:key];
}

+ (void)tt_setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    [[self sharedStore] tt_setDictionary:dictionary forKey:key];
}

+ (void)tt_setData:(NSData *)data forKey:(NSString *)key
{
    [[self sharedStore] tt_setData:data forKey:key];
}

+ (BOOL)tt_boolForKey:(NSString *)key
{
    return [[self sharedStore] tt_boolForKey:key];
}

+ (NSNumber *)tt_numberForKey:(NSString *)key
{
    return [[self sharedStore] tt_numberForKey:key];
}

+ (NSString *)tt_stringForKey:(NSString *)key
{
    return [[self sharedStore] tt_stringForKey:key];
}

+ (NSArray *)tt_arrayForKey:(NSString *)key
{
    return [[self sharedStore] tt_arrayForKey:key];
}

+ (NSDictionary *)tt_dictionaryForKey:(NSString *)key
{
    return [[self sharedStore] tt_dictionaryForKey:key];
}

+ (NSData *)tt_dataForKey:(NSString *)key
{
    return [[self sharedStore] tt_dataForKey:key];
}


/**
 *  使用指定的service和accessGroup
 */
+ (void)tt_setBool:(BOOL)aBool forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [self tt_setNumber:@(aBool) forKey:key service:serviceName accessGroup:accessGroup];
}

+ (void)tt_setNumber:(NSNumber *)aNumber forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [self tt_setString:[aNumber stringValue] forKey:key service:serviceName accessGroup:accessGroup];
}

+ (void)tt_setString:(NSString *)string forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_setString:string forKey:key];
}

+ (void)tt_setArray:(NSArray *)array forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_setArray:array forKey:key];
}

+ (void)tt_setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_setDictionary:dictionary forKey:key];
}

+ (void)tt_setData:(NSData *)data forKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_setData:data forKey:key];
}


+ (BOOL)tt_boolForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_boolForKey:key];
}

+ (NSNumber *)tt_numberForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_numberForKey:key];
}

+ (NSString *)tt_stringForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_stringForKey:key];
}

+ (NSArray *)tt_arrayForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_arrayForKey:key];
}

+ (NSDictionary *)tt_dictionaryForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_dictionaryForKey:key];
}

+ (NSData *)tt_dataForKey:(NSString *)key service:(NSString *)serviceName accessGroup:(NSString *)accessGroup
{
    return [[self storeWithServiceName:serviceName accessGroup:accessGroup] tt_dataForKey:key];
}


#pragma mark - implementations
#pragma mark - set values
- (void)tt_setString:(NSString *)string forKey:(NSString *)key
{
    if (!key) return;
    [self.keychainStore setString:string forKey:key];
}

- (void)tt_setArray:(NSArray *)array forKey:(NSString *)key
{
    if (!key) return;
    NSData *data = array ? [NSKeyedArchiver archivedDataWithRootObject:array] : nil;
    [self tt_setData:data forKey:key];
}

- (void)tt_setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    if (!key) return;
    NSData *data = dictionary ? [NSKeyedArchiver archivedDataWithRootObject:dictionary] : nil;
    [self tt_setData:data forKey:key];
}

- (void)tt_setData:(NSData *)data forKey:(NSString *)key
{
    if (!key) return;
    [self.keychainStore setData:data forKey:key];
}

#pragma mark - get values

- (BOOL)tt_boolForKey:(NSString *)key
{
    NSNumber *aNumber = [self tt_numberForKey:key];
    return [aNumber boolValue];
}

- (NSNumber *)tt_numberForKey:(NSString *)key
{
    NSString *aString = [self tt_stringForKey:key];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return aString ? [numberFormatter numberFromString:aString] : nil;
}

- (NSString *)tt_stringForKey:(NSString *)key
{
    if (!key) return nil;
    return [self.keychainStore stringForKey:key];
}

- (NSArray *)tt_arrayForKey:(NSString *)key
{
    if (!key) return nil;
    NSData  *data = [self tt_dataForKey:key];
    NSArray *array = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return array;
}

- (NSDictionary *)tt_dictionaryForKey:(NSString *)key
{
    if (!key) return nil;
    NSData  *data = [self tt_dataForKey:key];
    NSDictionary *dictionary = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    return dictionary;
}

- (NSData *)tt_dataForKey:(NSString *)key
{
    if (!key) return nil;
    return [self.keychainStore dataForKey:key];
}

#pragma mark - operate data

- (NSArray *)tt_allKeys
{
    return [self.keychainStore allKeys];
}

- (NSArray *)tt_allItems
{
    return [self.keychainStore allItems];
}

- (BOOL)tt_removeAllItems
{
    return [self.keychainStore removeAllItems];
}

- (BOOL)tt_removeItemForKey:(NSString *)key
{
    return [self.keychainStore removeItemForKey:key];
}


/**
 *  Set by subscript
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString<NSCopying> *)key
{
    if ([obj isKindOfClass:[NSString class]]) {
        [self tt_setString:obj forKey:key];
    } else if ([obj isKindOfClass:[NSArray class]]) {
        [self tt_setArray:obj forKey:key];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        [self tt_setDictionary:obj forKey:key];
    } else if ([obj isKindOfClass:[NSData class]]) {
        [self tt_setData:obj forKey:key];
    }
}
@end
