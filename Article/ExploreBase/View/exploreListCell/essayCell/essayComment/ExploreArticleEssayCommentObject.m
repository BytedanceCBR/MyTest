//
//  ExploreArticleEssayCommentObject.m
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import "ExploreArticleEssayCommentObject.h"

@implementation ExploreArticleEssayCommentObject

- (void)updateWithDictionary:(NSDictionary *)dict
{
    if ([dict objectForKey:@"content"]) {
        self.content = [NSString stringWithFormat:@"%@", [dict objectForKey:@"content"]];
    } else {
        self.content = @"";
    }
    
    if ([[dict objectForKey:@"user"] isKindOfClass:[NSDictionary class]]) {
        self.user = [[SSUserBaseModel alloc] initWithDictionary:[dict objectForKey:@"user"]];
    } else {
        self.user = nil;
    }
}

@end
