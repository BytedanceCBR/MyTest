//
//  TTAsyncTextLine.m
//  Pods
//
//  Created by zhaoqin on 16/11/2016.
//
//

#import "TTAsyncTextLine.h"

@implementation TTAsyncTextLine

- (void)setCTLine:(CTLineRef)ctLineRef position:(CGPoint)position {
    _CTLine = ctLineRef;
    _position = position;
    
    _lineWidth = CTLineGetTypographicBounds(_CTLine, &_ascent, &_descent, &_leading);
    if (CTLineGetGlyphCount(_CTLine) > 0) {
        CFArrayRef runs = CTLineGetGlyphRuns(_CTLine);
        CTRunRef run = CFArrayGetValueAtIndex(runs, 0);
        CGPoint pos;
        CTRunGetPositions(run, CFRangeMake(0, 1), &pos);
        _firstGlyphPos = pos.x;
    } else {
        _firstGlyphPos = 0;
    }
    _bounds = CGRectMake(_position.x, _position.y - _ascent, _lineWidth, _ascent + fabs(_descent));
    _bounds.origin.x += _firstGlyphPos;
    
    _height = CGRectGetHeight(_bounds);
    _top = CGRectGetMinY(_bounds);
    
}


@end
