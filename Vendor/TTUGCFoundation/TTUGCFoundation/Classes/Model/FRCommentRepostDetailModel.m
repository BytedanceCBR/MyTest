//
//  TTCommentRepostDetailModel.m
//  Article
//
//  Created by ranny_90 on 2017/9/19.
//
//

#import "FRCommentRepostDetailModel.h"
#import "TTBaseMacro.h"
#import "NSDictionary+TTAdditions.h"

@implementation FRCommentRepostDetailModel

- (void)updateCommentRepostModel{
    if (!SSIsEmptyDictionary(_comment)) {
        NSString *idStr = [self.comment tt_stringValueForKey:@"id"];
        if (!isEmptyString(idStr)) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.comment];
            self.commentRepostModel = [FRCommentRepost updateWithDictionary:dict commentId:idStr parentPrimaryKey:nil];
            [self.commentRepostModel save];
        }
    }
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"commentRepostModel"]) {
        return YES;
    }
    return NO;
}


@end
