//
//  SSFeedbackModel.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-7.
//
//

#import "SSFeedbackModel.h"

@implementation SSFeedbackModel

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"pub_date" : @"pubDate",
                                                       @"content" : @"content",
                                                       @"type" : @"feedbackType",
                                                       @"image_url" : @"imageURLStr",
                                                       @"avatar_url" : @"avatarURLStr",
                                                       @"id" : @"feedbackID",
                                                       @"image_width" : @"imageWidth",
                                                       @"image_height" : @"imageHeight",
                                                       @"links" : @"links",
                                                       }];
}

- (void)dealloc
{
    self.links = nil;
    self.pubDate = nil;
    self.content = nil;
    self.feedbackType = nil;
    self.imageURLStr = nil;
    self.avatarURLStr = nil;
    self.feedbackID = nil;
    self.imageWidth = nil;
    self.imageHeight = nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.pubDate = [aDecoder decodeObjectForKey:@"pubDate"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.feedbackType = [aDecoder decodeObjectForKey:@"feedbackType"];
        self.imageURLStr = [aDecoder decodeObjectForKey:@"imageURLStr"];
        self.avatarURLStr = [aDecoder decodeObjectForKey:@"avatarURLStr"];
        self.feedbackID = [aDecoder decodeObjectForKey:@"feedbackID"];
        self.imageWidth = [aDecoder decodeObjectForKey:@"imageWidth"];
        self.imageHeight = [aDecoder decodeObjectForKey:@"imageHeight"];
        self.links = [aDecoder decodeObjectForKey:@"links"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_pubDate forKey:@"pubDate"];
    [aCoder encodeObject:_content forKey:@"content"];
    [aCoder encodeObject:_feedbackType forKey:@"feedbackType"];
    [aCoder encodeObject:_imageURLStr forKey:@"imageURLStr"];
    [aCoder encodeObject:_avatarURLStr forKey:@"avatarURLStr"];
    [aCoder encodeObject:_feedbackID forKey:@"feedbackID"];
    [aCoder encodeObject:_imageHeight forKey:@"imageHeight"];
    [aCoder encodeObject:_imageWidth forKey:@"imageWidth"];
    [aCoder encodeObject:_links forKey:@"links"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"content %@, feedbackType %@", _content, _feedbackType];
}

@end

@implementation SSFeedbackResponse

+ (JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"data" : @"data",
                                                       @"default_item" : @"defaultItem",
                                                       @"message" : @"message",
                                                       @"has_more" : @"hasMore",
                                                       }];
}

@end
