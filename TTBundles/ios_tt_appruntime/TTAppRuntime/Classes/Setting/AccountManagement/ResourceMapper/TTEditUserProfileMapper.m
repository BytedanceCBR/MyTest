//
//  TTEditUserProfileMapper.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTEditUserProfileMapper.h"
#import "SSCommonLogic.h"


@implementation TTEditUserProfileMapper
- (NSString *)key {
    return @"account_manager";
}

- (NSString *)mapString:(NSString *)target {
    NSString *result = target;
    
    if([result isEqualToString:@"account_manager"] || [result isEqualToString:@"SSEditUserProfileViewController"]) {
        result = @"TTEditUserProfileViewController";
    }
    return result;
}
@end
