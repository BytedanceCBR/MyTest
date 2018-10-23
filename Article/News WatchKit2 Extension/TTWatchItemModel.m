//
//  WatchItemModel.m
//  Article
//
//  Created by 邱鑫玥 on 16/8/18.
//
//

#import "TTWatchItemModel.h"
#import "TTWatchMacroDefine.h"

static inline NSArray *arrayValueForDict(NSDictionary *dict,NSString *key,NSArray *defaultValue)
{
    id value = [dict objectForKey:key];
    return (value && [value isKindOfClass:[NSArray class]]) ? value : defaultValue;
}

static inline NSString *stringValueForDict(NSDictionary *dic ,NSString *key ,NSString *defaultValue)
{
    id value = [dic objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }else if(value && [value isKindOfClass:[NSNumber class]]){
        return [value stringValue];
    }else{
        return defaultValue;
    }
}

@implementation TTWatchItemModel


- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.title = [dict objectForKey:@"title"];
        self.commentCount = @([[dict objectForKey:@"comment_count"] longLongValue]);
        self.beHotTime = @([[dict objectForKey:@"behot_time"] longLongValue]);
        if([dict objectForKey:@"middle_image"])
        {
            NSDictionary *rightDict = [dict objectForKey:@"middle_image"];
            if([rightDict isKindOfClass:[NSDictionary class]])
            {
                self.rightImgDict = rightDict;
            }
        }
        self.uniqueID = @([[dict objectForKey:@"group_id"] longLongValue]);
        
        self.abstract = [dict objectForKey:@"abstract"];
        
        
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super init];
//    if (self) {
//        self.title = [aDecoder decodeObjectForKey:@"title"];
//        self.commentCount = [aDecoder decodeObjectForKey:@"commentCount"];
//        self.uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
//        self.beHotTime = [aDecoder decodeObjectForKey:@"beHotTime"];
//        self.rightImgDict = [aDecoder decodeObjectForKey:@"rightImgDict"];
//        self.abstract = [aDecoder decodeObjectForKey:@"abstract"];
//        
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.title forKey:@"title"];
//    [aCoder encodeObject:self.commentCount forKey:@"commentCount"];
//    [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
//    [aCoder encodeObject:self.beHotTime forKey:@"beHotTime"];
//    [aCoder encodeObject:self.rightImgDict forKey:@"rightImgDict"];
//    [aCoder encodeObject:self.abstract forKey:@"abstract"];
//    
//}

- (BOOL)hasRightImg
{
    if ([self.rightImgDict count] == 0) {
        return NO;
    }
    return YES;
}

- (NSString *)imageURLString{
    NSArray *urls = arrayValueForDict(self.rightImgDict,@"url_list",nil);
    
    NSMutableArray *decodedURLArray = [NSMutableArray arrayWithCapacity:urls.count];
    for(id urlDict in urls) {
        if (!SSIsEmptyDictionary(urlDict)) {
            NSString *URLString = [stringValueForDict(urlDict,@"url",nil)
                                   stringByRemovingPercentEncoding];
            if (!isEmptyString(URLString)) {
                [decodedURLArray addObject:@{@"url":URLString}];
            }
        }
    }
    
    if([decodedURLArray count] <= 0) {
        return nil;
    }
    return [[decodedURLArray objectAtIndex:0] objectForKey:@"url"];
}

@end
