//
//  TTAsyncTextLayout.m
//  Pods
//
//  Created by zhaoqin on 16/11/2016.
//
//

#import "TTAsyncTextLayout.h"
#import "TTAsyncTextLine.h"
#import <CoreText/CoreText.h>

@implementation TTAsyncTextLayout

- (void)drawInTextWithContext:(CGContextRef)context size:(CGSize)size cancel:(BOOL (^)(void))cancel {
    if (context) {
        if (cancel && cancel()) {
            return;
        }
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, 0);
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        NSMutableArray *mutableLines = [self.lines mutableCopy];
        for (NSInteger i = 0; i < mutableLines.count; i++) {
            if (cancel && cancel()) break;
            TTAsyncTextLine *line = mutableLines[i];
            if (self.truncatedLine && [self.truncatedLine.index isEqualToNumber:line.index]) {
                line = self.truncatedLine;
            }
            CGFloat posX = line.position.x;
            CGFloat posY = line.position.y;
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, posX, posY);
            CFArrayRef runs = CTLineGetGlyphRuns(line.CTLine);
            for (NSUInteger r = 0, rMax = CFArrayGetCount(runs); r < rMax; r++) {
                if (cancel && cancel()) break;
                CTRunRef run = CFArrayGetValueAtIndex(runs, r);
                CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                CGContextSetTextPosition(context, posX, posY);
                CGAffineTransform runTextMatrix = CTRunGetTextMatrix(run);
                BOOL runTextMatrixIsID = CGAffineTransformIsIdentity(runTextMatrix);
//                CFDictionaryRef runAttrs = CTRunGetAttributes(run);
                if (!runTextMatrixIsID) {
                    CGContextSaveGState(context);
                    CGAffineTransform trans = CGContextGetTextMatrix(context);
                    CGContextSetTextMatrix(context, CGAffineTransformConcat(trans, runTextMatrix));
                }
                CTRunDraw(run, context, CFRangeMake(0, 0));
                if (!runTextMatrixIsID) {
                    CGContextRestoreGState(context);
                }
            }
        }
        CGContextSaveGState(context);
    }
}

@end
