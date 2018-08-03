//
//  TTCommentTextAttachment.m
//  Article
//
//  Created by lizhuoli on 17/3/1.
//
//

#import "TTCommentTextAttachment.h"

@implementation TTCommentTextAttachment

- (void)setupBoundsWithImageSize:(CGSize)imageSize labelHeight:(CGFloat)labelHeight
{
    CGFloat width = imageSize.width;
    if (imageSize.height > labelHeight) { // 限高等比例缩放宽度
        width = imageSize.width / imageSize.height * labelHeight;
    }
    
    self.bounds = CGRectMake(0, 0, width, labelHeight);
}

- (CGRect)attachmentBoundsForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect result = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    result.origin.y = -1;
    return result;
}

@end
