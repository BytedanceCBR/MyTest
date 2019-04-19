//
//  NSString+Emoji.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Emoji)

-(NSString *)stringByRemoveEmoji;

-(BOOL)containsEmoji;

@end

NS_ASSUME_NONNULL_END
