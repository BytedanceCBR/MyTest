//
//  TTRealnameAuthEncrypt.m
//  Article
//
//  Created by lizhuoli on 17/3/20.
//
//

#import "TTRealnameAuthEncrypt.h"
#import "NSDictionary+TTAdditions.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#define P_SALT @"toutiaompocr"

int compare_arr(const void*, const void*);

#pragma mark - C Helper
int compare_arr(const void* a, const void* b)
{
    const char **a_str = (const char **)a;
    const char **b_str = (const char **)b;
    
    return strcmp(*a_str, *b_str);
}

static inline char **getArray(NSArray *arr)
{
    unsigned count = (unsigned)[arr count];
    char **array = (char **)malloc((count + 1) * sizeof(char*));
    
    for (unsigned i = 0; i < count; i++)
    {
        array[i] = strdup([NSString stringWithFormat:@"%@",arr[i]].UTF8String);
    }
    array[count] = NULL;
    return array;
}

static inline void freeArray(char **arr)
{
    if (arr != NULL)
    {
        for (unsigned index = 0; arr[index] != NULL; index++)
        {
            free(arr[index]);
        }
        free(arr);
    }
}

static inline NSArray *p_sort(NSDictionary *dict)
{
    if (SSIsEmptyDictionary(dict)) {
        return nil;
    }
    
    NSArray *keys = dict.allKeys;
    char **arr = getArray(keys);
    unsigned size = (unsigned)keys.count;
    
    qsort(arr, size, sizeof(char *), compare_arr);
    
    NSMutableArray *results = [NSMutableArray array];
    for (unsigned i = 0; i < size; i++) {
        NSString *str = [[NSString alloc] initWithCString:arr[i] encoding:NSUTF8StringEncoding];
        [results addObject:str];
    }
    
    freeArray(arr);
    
    return results;
}

static inline NSString *p_param(NSDictionary *dict, NSArray<NSString *> *keys)
{
    if (SSIsEmptyDictionary(dict) || SSIsEmptyArray(keys)) {
        return nil;
    }
    
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    NSMutableString *URLQuery = [NSMutableString string];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = [dict tt_stringValueForKey:key];
        if (idx > 0) {
            [URLQuery appendString:@"&"];
        }
        NSString *keyEncoded = [key stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *valueEncoded = [value stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        
        [URLQuery appendString:[NSString stringWithFormat:@"%@=%@", keyEncoded, valueEncoded]];
    }];
    
    return URLQuery;
}

static inline NSString *p_salt(NSString *string)
{
    if (isEmptyString(string)) {
        return nil;
    }
    
    return [string stringByAppendingString:P_SALT];
}

static inline NSString * p_md5(NSString *string)
{
    if (isEmptyString(string)) {
        return nil;
    }
    
    const char* str = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    
    return output;
}

NSString* p_sn(NSDictionary *params)
{
    if (SSIsEmptyDictionary(params)) {
        return nil;
    }
    
    // 第一步，params排序
    NSArray *keys = p_sort(params);
    
    // 第二步，&拼接
    NSString *query = p_param(params, keys);
    
    // 第三步，加salt
    NSString *str = p_salt(query);
    
    // 第四步，md5
    NSString *sn = p_md5(str);
    
    return sn;
}
