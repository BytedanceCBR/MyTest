//
//  NSString+Emoji.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/4/10.
//

#import "NSString+Emoji.h"

@implementation NSString (Emoji)

-(NSString *)stringByRemoveEmoji
{
    if (self.length == 0) {
        return self;
    }    
    NSString *result = [self stringByApplyingTransform:@"[:^Letter:] Remove" reverse:NO];
    return result;
    
//    NSMutableString *str = [[NSMutableString alloc] init];
//    [self rangeOfComposedCharacterSequenceAtIndex:<#(NSUInteger)#>]
//    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
//                             options:NSStringEnumerationByComposedCharacterSequences
//                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//                              NSLog(@"[EMOJI] substring %@ range is: %@",substring,NSStringFromRange(substringRange));
//                              const unichar high = [substring characterAtIndex: 0];
//                              BOOL isEmoji = NO;
//                              // Surrogate pair (U+1D000-1F9FF)
//                              if (0xD800 <= high && high <= 0xDBFF) {
//                                  const unichar low = [substring characterAtIndex: 1];
//                                  const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
//
//                                  if (0x1D000 <= codepoint && codepoint <= 0x1F9FF){
//                                      isEmoji = YES;
//                                  }
//
//                                  // Not surrogate pair (U+2100-27BF)
//                              } else {
//                                  if (0x2100 <= high && high <= 0x27BF){
//                                      isEmoji = YES;
//                                  }
//                              }
//
//                              if (!isEmoji) {
//                                  [str appendString:substring];
//                              }
//                          }];
//    return str;
}

-(BOOL)containsEmoji
{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar high = [substring characterAtIndex: 0];
                                
                                // Surrogate pair (U+1D000-1F9FF)
                                if (0xD800 <= high && high <= 0xDBFF) {
                                    if (substring.length > 1) {
                                        const unichar low = [substring characterAtIndex: 1];
                                        const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
                                        
                                        if (0x1D000 <= codepoint && codepoint <= 0x1F9FF){
                                            returnValue = YES;
                                        }
                                    }                                    
                                    // Not surrogate pair (U+2100-27BF)
                                } else {
                                    if (0x2100 <= high && high <= 0x27BF){
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end