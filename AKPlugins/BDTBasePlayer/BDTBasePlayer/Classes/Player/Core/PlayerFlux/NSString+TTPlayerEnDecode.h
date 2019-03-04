//
//  NSString+TTPlayerEnDecode.h
//  BDTBasePlayer
//
//  Created by lishuangyang on 2018/2/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TTPlayerEnDecode)

/** 对字符串进行URL编码 */
- (NSString *)ttPlayer_URLEncodedString;
/** 对字符串进行URL解码 */
- (NSString *)ttPlayer_URLDecodedString;

@end
