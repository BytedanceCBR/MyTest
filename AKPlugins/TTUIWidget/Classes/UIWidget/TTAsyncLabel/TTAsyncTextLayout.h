//
//  TTAsyncTextLayout.h
//  Pods
//
//  Created by zhaoqin on 16/11/2016.
//
//

#import <Foundation/Foundation.h>

@class TTAsyncTextLine;

@interface TTAsyncTextLayout : NSObject

@property (nonatomic, strong) NSArray *lines;
@property (nonatomic, strong) TTAsyncTextLine *truncatedLine;


/**
 因为需要为Label增加参数numberOfLines，并且使用lineBreakMode，但原有的frame描绘不能增加lineBreakMode;
 用Core Text逐行描绘Label，在最后一行附加attributeString，添加lineBreakMode效果

 @param context context
 @param size size
 @param cancel cancel
 */
- (void)drawInTextWithContext:(CGContextRef)context size:(CGSize)size cancel:(BOOL (^)(void))cancel;
@end
