//
//  TTQutoedCommentModel.m
//  Article
//
//  Created by muhuai on 16/8/22.
//
//

#import "TTQutoedCommentModel.h"

@implementation TTQutoedCommentModel
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        //有时会出现NSNumber.....
        if ([dict[@"id"] respondsToSelector:@selector(stringValue)]) {
            self.commentID = [dict[@"id"] stringValue];
        } else {
            self.commentID = dict[@"id"];
        }
        self.userName = dict[@"user_name"];
        if ([dict[@"user_id"] respondsToSelector:@selector(stringValue)]) {
            self.userID = [dict[@"user_id"] stringValue];
        } else {
            self.userID = dict[@"user_id"];
        }
        
        self.commentContent = dict[@"text"];
        self.commentContentRichSpanJSONString = dict[@"content_rich_span"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:7];
    [dic setValue:self.commentID forKey:@"id"];
    [dic setValue:self.userName forKey:@"user_name"];
    [dic setValue:self.userID forKey:@"user_id"];
    [dic setValue:self.commentContent forKey:@"text"];
    [dic setValue:self.commentContentRichSpanJSONString forKey:@"content_rich_span"];
    return [dic mutableCopy];
}

#pragma mark - JSONModel
+ (JSONKeyMapper *)keyMapper {
    NSDictionary *keyMapperDic = @{
        @"id" : @"commentID",
        @"user_name" : @"userName",
        @"user_id" : @"userID",
        @"text" : @"commentContent",
        @"content_rich_span" : @"commentContentRichSpanJSONString",
    };
    return [[JSONKeyMapper alloc] initWithDictionary:keyMapperDic];
}
@end

