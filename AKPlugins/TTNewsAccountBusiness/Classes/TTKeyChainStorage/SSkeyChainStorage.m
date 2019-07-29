//
//  SSkeyChainStorage.m
//  Article
//
//  Created by Dianwei on 13-5-9.
//
//

#import "SSkeyChainStorage.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTBaseMacro.h"

#define kKeyChainServiceName        @"ssKeyChainService"
#define kKeyChainStorageException   @"kKeyChainStorageException"

@implementation SSkeyChainStorage
+ (id)objectForKey:(NSString*)key
{
    if(isEmptyString(key))
    {
        @throw [NSException exceptionWithName:kKeyChainStorageException reason:@"key cannot be nil" userInfo:nil];
    }
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:6];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [query setObject:kKeyChainServiceName forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [query setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [query setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    CFTypeRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    
    if(status != errSecSuccess)
    {
        if (result) {
            CFRelease(result);
        }
        return nil;
    }
    
    NSData *data = [NSData dataWithData:(__bridge NSData *)(result)];
    if (result) {
        CFRelease(result);
    }
    NSString *stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(!isEmptyString(stringResult))
    {
        return [stringResult tt_JSONValue];
    }
    else
    {
        return nil;
    }
}

+ (BOOL)setObject:(id)value key:(NSString*)key
{
    if(![value respondsToSelector:@selector(tt_JSONRepresentation)])
    {
        @throw [NSException exceptionWithName:@"SSRuntimeException" reason:@"value must be JSON respresentable" userInfo:[NSDictionary dictionaryWithObject:value forKey:@"value"]];
    }
    
    NSString *stringValue = [value tt_JSONRepresentation];
    return [self setData:[stringValue dataUsingEncoding:NSUTF8StringEncoding] key:key];
}

+ (BOOL)setData:(NSData*)data key:(NSString*)key
{
    if(isEmptyString(key))
    {
        @throw [NSException exceptionWithName:kKeyChainStorageException reason:@"key cannot be nil" userInfo:nil];
    }
    
    BOOL result = NO;
    
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:4];
    [query setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [query setObject:kKeyChainServiceName forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [query setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [query setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
    if(status == errSecSuccess)
    {
        if(data)
        {
            NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithCapacity:2];
            [updateDict setObject:data forKey:(__bridge id<NSCopying>)(kSecValueData)];
            status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateDict);
            if(status == errSecSuccess)
            {
                result = YES;
            }
        }
        else
        {
            result = [self removeValueForKey:key];
        }
    }
    else if(status == errSecItemNotFound)
    {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithCapacity:5];
        [attrs setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
        [attrs setObject:kKeyChainServiceName forKey:(__bridge id<NSCopying>)(kSecAttrService)];
        [attrs setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
        [attrs setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
        [attrs setObject:data forKey:(__bridge id<NSCopying>)(kSecValueData)];
        status = SecItemAdd((__bridge CFDictionaryRef)attrs, NULL);
        result = (status == errSecSuccess);
    }
    
    return result;
}

+ (BOOL)removeValueForKey:(NSString*)key
{
    if(isEmptyString(key))
    {
        @throw [NSException exceptionWithName:kKeyChainStorageException reason:@"key cannot be nil" userInfo:nil];
    }
    
    NSMutableDictionary *itemToDelete = [NSMutableDictionary dictionaryWithCapacity:6];
    [itemToDelete setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
    [itemToDelete setObject:kKeyChainServiceName forKey:(__bridge id<NSCopying>)(kSecAttrService)];
    [itemToDelete setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
    [itemToDelete setObject:key forKey:(__bridge id<NSCopying>)(kSecAttrGeneric)];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
    BOOL result = (status == errSecSuccess || status == errSecItemNotFound);
    return result;
}

@end
