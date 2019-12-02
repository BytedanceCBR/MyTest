//
//  FHSearchFilterOpenUrlModel.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/23.
//

#import "FHSearchFilterOpenUrlModel.h"
#import "FHHouseType.h"

#define HOUSE_TYPE @"house_type"

@interface FHSearchFilterOpenUrlModel ()

@property(nonatomic , strong) NSURLComponents *components;

@end

@implementation FHSearchFilterOpenUrlModel

+(instancetype)instanceFromUrl:(NSString *)url
{
    return  [[FHSearchFilterOpenUrlModel alloc] initWithUrl:url];
}

-(instancetype) initWithUrl:(NSString *)strUrl
{
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        _components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
        
        [self configContents];
        
    }
    return self;
}

-(void)updateWithUrl:(NSString *)strUrl
{
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        return;
    }
    _components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    [self configContents];
}

-(void)mergeWithQuery:(NSString *)query
{
    if (query.length == 0) {
        return;
    }
    
    NSString *strUrl = [@"https://a?" stringByAppendingString:query];
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        return;
    }
    
    NSURLComponents *otherComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    for (NSURLQueryItem *item in [otherComponents queryItems]) {
        if (item.name.length > 0) {
            if([item.name containsString:@"[]"]){
                NSMutableSet *values = self.queryDict[item.name];
                if (!values) {
                    values = [NSMutableSet new];
                    self.queryDict[item.name] = values;
                }
                [values addObject:item.value];
            }else{
                self.queryDict[item.name] = item.value;
            }
        }
    }
    
}

-(void)addQueryParams:(NSDictionary *)params
{
    [self.queryDict addEntriesFromDictionary:params];
}

-(void)overwriteFliter:(NSString *)filter
{
    if (self.noneFilterQuery.length > 0) {
        
        //make a new open url
        
        NSMutableString *strUrl = [[NSMutableString alloc] initWithFormat:@"%@://%@?",_components.scheme,_components.host];
        
        if ([self.noneFilterQuery hasPrefix:@"&"]) {
            [strUrl appendString:[self.noneFilterQuery substringFromIndex:1]];
        }else{
            [strUrl appendString:self.noneFilterQuery];
        }
        if (![filter hasPrefix:@"&"]) {
            [strUrl appendString:@"&"];
        }
        [strUrl appendString:filter];
        NSURL *url = [NSURL URLWithString:strUrl];
        if (!url) {
            return;
        }
        
        //reset all data
        _components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:YES];
        [self configContents];
        return;
    }
    
    
    NSMutableArray *arrayKeys = [NSMutableArray new];
    for (NSString *key in [self.queryDict allKeys]) {
        if ([self isArrayKey: key]) {
            [arrayKeys addObject:key];
        }
    }
    
    for (NSString *key in arrayKeys) {
        [self.queryDict removeObjectForKey:key];
    }
    
    if (filter.length == 0) {
        //nil filter clear filter
        return;
    }
    
    NSString *strUrl = [@"https://a?" stringByAppendingString:filter];
    NSURL *url = [NSURL URLWithString:strUrl];
    if (!url) {
        return;
    }
    
    NSURLComponents *filterComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    
    for (NSURLQueryItem *item in [filterComponents queryItems]) {
        if ([self isArrayKey:item.name]) {
            NSMutableSet *values = self.queryDict[item.name];
            if (!values) {
                values = [NSMutableSet new];
                self.queryDict[item.name] = values;
            }
            [values addObject:item.value];
        }else{
            self.queryDict[item.name] = item.value;
        }
    }
    
}

-(void)removeQueryOfKey:(NSString *)key
{
    [self.queryDict removeObjectForKey:key];
}

-(NSString *)query
{
    NSMutableArray *queryItems = [NSMutableArray new];
    for (NSString *key in [self.queryDict allKeys]) {
        id value = self.queryDict[key];
        if([value isKindOfClass:[NSString class]]){
            NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:value];
            [queryItems addObject:item];
        }else if ([value isKindOfClass:[NSNumber class]]){
            NSString *strValue = [NSString stringWithFormat:@"%@",value];
            NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:strValue];
            [queryItems addObject:item];
        }else if ([value isKindOfClass:[NSSet class]]){
            NSSet* sets = (NSSet *)value;
            for (NSString *v in sets) {
                NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:v];
                [queryItems addObject:item];
            }
        }
    }
    NSURLComponents *component = [[NSURLComponents alloc]initWithString:@"http://aa"];
    component.queryItems = queryItems;
    return  [component.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

-(void)configContents
{
    NSMutableDictionary *queryDict = [NSMutableDictionary new];
    NSArray<NSURLQueryItem *> *queryItems = [_components queryItems];
    for (NSURLQueryItem *item in queryItems) {
        if (item.name.length > 0) {
            if ([self isArrayKey: item.name]) {
                //array value , may contains multiple values for same key
                NSMutableSet *values = queryDict[item.name];
                if(!values){
                    values = [NSMutableSet new];
                    queryDict[item.name] = values;
                }
                if (item.value.length > 0) {
                    [values addObject:item.value];
                }
            }else{
                queryDict[item.name] = item.value?:@"";
            }
        }
    }
    
    self.queryDict = queryDict;
    if (_houseType <= 0) {
        _houseType = FHHouseTypeSecondHandHouse;
    }

}

-(void)setHouseType:(FHHouseType)houseType
{
    if (houseType <= 0) {
        houseType = FHHouseTypeSecondHandHouse;
    }
    _houseType = houseType;
    _queryDict[HOUSE_TYPE] = [@(houseType) description];
}

-(BOOL)isArrayKey:(NSString *)key
{
    if ([key containsString:@"[]"]) {
        //判断是否有数组，与安卓逻辑相同
        return YES;
    }
    return NO;
}


- (NSDictionary *)queryDictBy:(NSString *)queryString
{
    NSMutableDictionary *queryParams = @{}.mutableCopy;
    NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
        NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            //                if ([paramValue rangeOfString:@"%"].length > 0) {
            //                    //v0.2.17 递归decode解析query参数
            //                    paramValue = [TTRoute recursiveDecodeForParamValue:paramValue];
            //                }
            
            //v0.2.19 去掉递归decode，外部保证传入合法encode的url
            [self _decodeWithEncodedURLString:&paramValue];
            
            if (paramValue && paramKey) {
                [[self class] setQueryValue:paramValue forKey:paramKey toDict:queryParams];
            }
        }
    }];
    return queryParams;
}

- (void)_decodeWithEncodedURLString:(NSString **)urlString
{
    if ([*urlString rangeOfString:@"%"].length == 0){
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}


+ (void)setQueryValue:(nullable id)value forKey: (NSString *)key toDict:(NSMutableDictionary*)dict {
    //判断数据是否是数组类型
    NSString* arrayParamRegularExpressionStr = @".*%5B%5D";
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:arrayParamRegularExpressionStr options:0 error:nil];
    if ([regex firstMatchInString:key options:0 range:NSMakeRange(0, key.length)]) {
        if (dict[key] != nil) {
            NSArray* values = dict[key];
            NSMutableArray* newValues = [[NSMutableArray alloc] initWithCapacity:values.count + 1];
            [newValues addObjectsFromArray:values];
            [newValues addObject:value];
            dict[key] = newValues;
        } else {
            dict[key] = @[value];
        }
    } else {
        dict[key] = value;
    }
}

@end
