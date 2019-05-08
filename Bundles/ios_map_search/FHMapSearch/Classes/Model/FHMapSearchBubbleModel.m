//
//  FHMapSearchBubbleModel.m
//  FHMapSearch
//
//  Created by 谷春晖 on 2018/11/19.
//

#import "FHMapSearchBubbleModel.h"

#define RESIZE_LEVEL @"resize_level"
#define CENTER_LATITUDE @"center_latitude"
#define CENTER_LONGITUDE @"center_longitude"
#define HOUSE_TYPE   @"house_type"

@interface FHMapSearchBubbleModel ()

@property(nonatomic , strong) NSURLComponents *components;

@end

@implementation FHMapSearchBubbleModel

+(instancetype)bubbleFromUrl:(NSString *)url
{
    return  [[FHMapSearchBubbleModel alloc] initWithUrl:url];
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
    _resizeLevel = [self.queryDict[RESIZE_LEVEL] floatValue];
    _centerLatitude = [self.queryDict[CENTER_LATITUDE] floatValue];
    _centerLongitude = [self.queryDict[CENTER_LONGITUDE] floatValue];
    _houseType = [self.queryDict[HOUSE_TYPE] integerValue];
    if (_houseType <= 0) {
        if ([_components.host isEqualToString:@"mapfind_house"]) {
            _houseType = FHHouseTypeSecondHandHouse;
        }else if([_components.host isEqualToString:@"mapfind_rent"]){
            //租房
            _houseType = FHHouseTypeRentHouse;
        }else{        
            _houseType = FHHouseTypeSecondHandHouse;
        }
    }
    
    if (self.resizeLevel < 1) {
        self.resizeLevel = 1;
    }else if (self.resizeLevel > 20){
        self.resizeLevel = 20;
    }
}

-(void)setResizeLevel:(CGFloat)resizeLevel
{
    if (resizeLevel < 1 ) {
        resizeLevel = 1;
    }else if (resizeLevel > 20){
        resizeLevel = 20;
    }
    _resizeLevel = resizeLevel;
    _queryDict[RESIZE_LEVEL] = [@(resizeLevel) description];
}

-(void)setCenterLatitude:(CGFloat)centerLatitude
{
    _centerLatitude = centerLatitude;
    _queryDict[CENTER_LATITUDE] = [@(centerLatitude) description];
}

-(void)setCenterLongitude:(CGFloat)centerLongitude
{
    _centerLongitude = centerLongitude;
    _queryDict[CENTER_LONGITUDE] = [@(centerLongitude) description];
}

-(void)setHouseType:(FHHouseType)houseType
{
    if (houseType <= 0) {
        houseType = FHHouseTypeSecondHandHouse;
    }
    _houseType = houseType;
    _queryDict[HOUSE_TYPE] = [@(houseType) description];
}


-(void)updateResizeLevel:(CGFloat)resizeLevel centerLatitude:(CGFloat)centerLatitude centerLongitude:(CGFloat)centerLongitude
{
    self.resizeLevel = resizeLevel;
    self.centerLongitude = centerLongitude;
    self.centerLatitude = centerLatitude;
}

-(BOOL)isArrayKey:(NSString *)key
{
    if ([key containsString:@"[]"]) {
        //判断是否有数组，与安卓逻辑相同
        return YES;
    }
    return NO;
}


-(BOOL)validCenter
{
    return _centerLatitude > 1 && _centerLongitude > 1;
}

-(BOOL)validResizeLevel
{
    return _resizeLevel >= 1 && _resizeLevel <= 20;
}


@end
