//
//  TTRelationshipMapper.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTRelationshipMapper.h"
#import "SSCommonLogic.h"

@implementation TTRelationshipMapper
- (NSString *)key {
    return @"relation";
}

- (NSString *)mapString:(NSString *)target {
    NSString *result = target;
    
    if([result isEqualToString:@"relation"] || [result isEqualToString:@"ArticleRelationViewController"]) {
        result = @"TTRelationshipViewController";
    }
    return result;
}
@end
