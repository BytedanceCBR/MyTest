//
//  TTRichSpanText+Comment.m
//  Article
//
//  Created by Jiyee Sheng on 17/11/2017.
//
//

#import "TTRichSpanText+Comment.h"
#import "TTBaseMacro.h"

@implementation TTRichSpanText (Comment)

- (void)appendCommentQuotedUserName:(NSString *)userName userId:(NSString *)userId {
    if (isEmptyString(userName)) {
        return;
    }

    NSString *commentQuotedFormat = @"//@%@：";
    NSString *appendText = [NSString stringWithFormat:commentQuotedFormat, userName];
    NSString *schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@", userId];

    TTRichSpanLink *richSpanLink = [[TTRichSpanLink alloc] initWithStart:2 length:(userName.length + 1) link:schema text:nil type:TTRichSpanLinkTypeQuotedCommentUser];
    TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:appendText richSpanLinks:@[richSpanLink]];
    [self appendRichSpanText:richSpanText];
}

@end
