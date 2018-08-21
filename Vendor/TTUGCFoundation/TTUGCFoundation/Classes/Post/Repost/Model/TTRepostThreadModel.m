//
//  TTRepostThreadModel.m
//  Article
//
//  Created by ranny_90 on 2017/9/11.
//
//

#import "TTRepostThreadModel.h"
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"

@implementation TTRepostThreadModel

- (instancetype)initWithRepostParam:(NSDictionary *)repostParam{
    self = [super init];
    if (self) {
        
        if (!SSIsEmptyDictionary(repostParam)) {
            self.cover_url = [repostParam tt_stringValueForKey:@"cover_url"];
            self.content = [repostParam tt_stringValueForKey:@"content"];
            self.content_rich_span = [repostParam tt_stringValueForKey:@"content_rich_span"];
            self.repost_type = [repostParam tt_integerValueForKey:@"repost_type"];
            self.group_id = [repostParam tt_stringValueForKey:@"group_id"];
            self.fw_id = [repostParam tt_stringValueForKey:@"fw_id"];
            self.fw_id_type = [repostParam tt_integerValueForKey:@"fw_id_type"];
            self.opt_id = [repostParam tt_stringValueForKey:@"opt_id"];
            self.opt_id_type = [repostParam tt_integerValueForKey:@"opt_id_type"];
            self.fw_user_id = [repostParam tt_stringValueForKey:@"fw_user_id"];
            self.repost_operation_type = [repostParam tt_integerValueForKey:@"repost_operation_type"];
            self.repostSchema = [repostParam tt_stringValueForKey:@"schema"];
            self.repostTitle = [repostParam tt_stringValueForKey:@"title"];
            self.repostToComment = [repostParam tt_boolValueForKey:@"repost_to_comment"];
        }
    }
    return self;
}

@end
