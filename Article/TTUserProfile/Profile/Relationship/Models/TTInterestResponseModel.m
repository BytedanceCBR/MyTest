//
//  TTInterestResponseModel.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTInterestResponseModel.h"



@implementation TTInterestItemModel
+(JSONKeyMapper*)keyMapper {
    /**
     * Map model key to jsonModel
     */
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"description": @"desp"}];
}

- (NSString *)nameString {
    return [self.class stringByReplacingNewline:(self.show_name ? : self.concern_name)];
}

- (NSString *)avatarURLString {
    return self.avatar_url;
}

- (NSString *)descriptionString {
     return [self.class stringByReplacingNewline:self.desp];
}

- (NSString *)urlString {
    return [self.url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)stringByReplacingNewline:(NSString *)string {
    return [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
}
@end


@implementation TTInterestDataModel
- (void)appendDataModel:(TTInterestDataModel *)aModel {
    if (!aModel) return;
    
    self.has_more = aModel.has_more;
    self.offset   = aModel.offset;
    self.count    = @([self.count integerValue] + [aModel.count integerValue]);
    self.user_concern_list = (NSArray<Optional, TTInterestItemModel> *)[self.user_concern_list arrayByAddingObjectsFromArray:aModel.user_concern_list];
}
@end


@implementation TTInterestResponseModel
@end
