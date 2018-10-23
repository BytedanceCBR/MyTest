//
//  NSArrayAdditions.m
//  Article
//
//  Created by fengyadong on 16/4/25.
//
//

#import "NSMutableArrayAdditions.h"

@implementation NSMutableArray (Sorted)

+ (NSMutableArray *)distinguishArrayItemsWithSortedArray:(NSArray *)sortedArray {
    NSMutableArray *distinguishedArray = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [sortedArray count]; i++){
        if ([distinguishedArray containsObject:[sortedArray objectAtIndex:i]] == NO){
            [distinguishedArray addObject:[sortedArray objectAtIndex:i]];
        }
        
    }
    return distinguishedArray;
}

+ (NSMutableArray *)mergeTwoSortedArrayWithoutSameElementWithFirstArray:(NSArray *)firstArray secondArray:(NSArray *)secondArray {
    NSMutableArray *distinguishedArray = [NSMutableArray arrayWithArray:firstArray];
    for (NSUInteger i = 0; i < [secondArray count]; i++){
        if ([distinguishedArray containsObject:[secondArray objectAtIndex:i]] == NO){
            [distinguishedArray addObject:[secondArray objectAtIndex:i]];
        }
        
    }
    return distinguishedArray;
}

@end

@implementation NSMutableArray (TTFingerprint)

- (NSString *)tt_base64StringWithFingerprintType:(TTFingerprintType)type {
    if (self.count == 0) {
        return nil;
    }
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (!error && JSONData.length > 0) {
        return [[JSONData tt_dataWithFingerprintType:type] ss_base64EncodedString];
    }
    return nil;
}

@end

@implementation NSArray (JSONValue)

- (NSString *)JSONRepresentation {
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
