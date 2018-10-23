//
//  TTAsyncTextLine.h
//  Pods
//
//  Created by zhaoqin on 16/11/2016.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface TTAsyncTextLine : NSObject
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic) CTLineRef CTLine;
@property (nonatomic) CGPoint position;
@property (nonatomic) NSRange range;
@property (nonatomic) CGRect bounds;

@property (nonatomic) CGFloat ascent;     ///< line ascent
@property (nonatomic) CGFloat descent;    ///< line descent
@property (nonatomic) CGFloat leading;    ///< line leading
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGFloat firstGlyphPos;

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat top;

- (void)setCTLine:(CTLineRef)ctLineRef position:(CGPoint)position;

@end
