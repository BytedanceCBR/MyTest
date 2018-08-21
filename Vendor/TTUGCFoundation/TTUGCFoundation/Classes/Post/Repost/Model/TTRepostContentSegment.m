//
//  TTRepostContentSegment.m
//  Article
//
//  Created by ranny_90 on 2017/9/14.
//
//

#import "TTRepostContentSegment.h"
#import "TTBaseMacro.h"

@implementation TTRepostContentSegment

- (instancetype)initWithRichSpanText:(TTRichSpanText *)richSpanText
                              userID:(NSString *)userID
                            username:(NSString *)username {
    self = [super init];
    if (self) {
        self.content = richSpanText;
        self.userID = userID;
        self.username = username;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
                      userID:(NSString *)userID
                    username:(NSString *)username {
    self = [super init];
    if (self) {
        TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:text richSpans:nil];
        self.content = richSpanText;
        self.userID = userID;
        self.username = username;
    }
    return self;
}

+ (TTRichSpanText *)richSpanTextForRepostSegments:(NSArray<TTRepostContentSegment *> *)segments {
    TTRichSpanText *finalText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    [segments enumerateObjectsUsingBlock:^(TTRepostContentSegment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTRepostContentSegment class]]) {
            NSString *userNameSegment = [NSString stringWithFormat:@"//@%@:", obj.username];
            NSString *link = nil;
            if (!isEmptyString(obj.userSchema)) {
                link = obj.userSchema;
            }
            else {
                link = [NSString stringWithFormat:@"sslocal://profile?uid=%@", obj.userID];
            }
            TTRichSpanLink *userNameRichSpanLink = [[TTRichSpanLink alloc] initWithStart:2 length:(obj.username.length + 1) link:link];
            TTRichSpanText *richSpanText = [[TTRichSpanText alloc] initWithText:userNameSegment richSpanLinks:@[userNameRichSpanLink]];
            [richSpanText appendRichSpanText:obj.content];
            [finalText appendRichSpanText:richSpanText];
        }
    }];
    return finalText;
}

@end

@implementation TTRichSpanText(UserScheme)

- (void)appendUserName:(NSString *)name userID:(NSString *)userID {
    if (isEmptyString(name)) {
        return;
    }
    if (isEmptyString(userID)) {
        [self appendUserName:name schema:nil];
    } else {
        [self appendUserName:name schema:[NSString stringWithFormat:@"sslocal://profile?uid=%@", userID]];
    }
}

- (void)appendUserName:(NSString *)name schema:(NSString *)schema {
    if (isEmptyString(name)) {
        return;
    }
    name = [NSString stringWithFormat:@"@%@", name];
    
    TTRichSpanLink *link = [[TTRichSpanLink alloc] initWithStart:0 length:name.length link:schema];
    TTRichSpans *richSpans = [[TTRichSpans alloc] initWithRichSpanLinks:@[link]];
    TTRichSpanText *richText = [[TTRichSpanText alloc] initWithText:name richSpans:richSpans];
    [self appendRichSpanText:richText];
}

@end
