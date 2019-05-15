//
//  ExploreWidgetItemModel.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-11.
//
//

#import "ExploreWidgetItemModel.h"
#import "TTBaseMacro.h"

@implementation ExploreWidgetItemModel

- (void)dealloc{
}

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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.commentCount = [aDecoder decodeObjectForKey:@"commentCount"];
        self.uniqueID = [aDecoder decodeObjectForKey:@"uniqueID"];
        self.beHotTime = [aDecoder decodeObjectForKey:@"beHotTime"];
        self.rightImgDict = [aDecoder decodeObjectForKey:@"rightImgDict"];
        self.abstract = [aDecoder decodeObjectForKey:@"abstract"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.commentCount forKey:@"commentCount"];
    [aCoder encodeObject:self.uniqueID forKey:@"uniqueID"];
    [aCoder encodeObject:self.beHotTime forKey:@"beHotTime"];
    [aCoder encodeObject:self.rightImgDict forKey:@"rightImgDict"];
    [aCoder encodeObject:self.abstract forKey:@"abstract"];

}

- (BOOL)hasRightImg
{
    if ([self.rightImgDict count] == 0) {
        return NO;
    }
    return YES;
}
- (NSArray *)rightImgURLHeaders
{
    if ([self hasRightImg]) {
        NSArray *urls = [_rightImgDict valueForKey:@"url_list"];
        if (![urls isKindOfClass:[NSArray class]]) {
            urls = nil;
        }
        NSMutableArray *decodedURLArray = [NSMutableArray arrayWithCapacity:urls.count];
        for(id urlDict in urls) {
            if (!SSIsEmptyDictionary(urlDict)) {
                NSString *URLStringPre = [urlDict valueForKey:@"url"];
                if (![URLStringPre isKindOfClass:[NSString class]]) {
                    URLStringPre = nil;
                }
                NSString *URLString = [URLStringPre stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (!isEmptyString(URLString)) {
                    [decodedURLArray addObject:@{@"url":URLString}];
                }
            }
        }
        return decodedURLArray;
    }
    return nil;
}


@end
