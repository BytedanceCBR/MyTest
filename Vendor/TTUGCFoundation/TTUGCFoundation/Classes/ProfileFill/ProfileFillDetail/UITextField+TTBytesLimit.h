//
//  UITextField+TTBytesLimit.h
//  Article
//
//  Created by tyh on 2017/6/19.
//
//

#import <UIKit/UIKit.h>

@interface UITextField (TTBytesLimit)
/**
 *  使用时只要调用此方法，加上一个长度(int)，就可以实现了字数限制,可以支持汉字。汉字占2个长度
 *
 *  @param length
 */
- (void)limitTextLength:(int)length;

- (NSUInteger)bytesWithoutUndeterminedForNotEnglishLanguage;

@end
