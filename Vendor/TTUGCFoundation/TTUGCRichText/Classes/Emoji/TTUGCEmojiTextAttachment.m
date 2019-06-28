//
//  TTUGCEmojiTextAttachment.m
//  Article
//
//  Created by Jiyee Sheng on 5/15/17.
//
//

#import "TTUGCEmojiTextAttachment.h"
#import "TTUGCRichTextPodBridge.h"
#import <TTBaseLib/TTBaseMacro.h>

@implementation TTUGCEmojiTextAttachment {
    UIImage *_cachedCoreTextImage;
}

- (void)forceChangeCacheImage:(UIImage *)image {
    if (image) {
        _cachedCoreTextImage = image;
    }
}

- (UIImage *)coreTextImage {
    if (isEmptyString(self.imageName)) {
        return nil;
    }

    if (!_cachedCoreTextImage) {
        _cachedCoreTextImage = [TTUGCRichTextPodBridge themedImageNamed:self.imageName];
    }

    return _cachedCoreTextImage;
}

- (UIImage *)image {
    if (isEmptyString(self.imageName)) {
        return nil;
    }
    return [self textKitImage:[TTUGCRichTextPodBridge themedImageNamed:self.imageName]];
}

- (UIImage *)textKitImage:(UIImage *)image {
    CGFloat padding = self.padding * 2;

    CGSize targetSize = image.size;
    targetSize.width += padding * 2;
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, image.scale);
    [image drawInRect:CGRectMake(padding, 0, image.size.width, image.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (CGFloat)emojiSize {
    if (_emojiSize > 0) {
        return _emojiSize;
    }

    return self.fontSize + 5.f;
}

// 仅 TextKit 方式渲染使用，如 UITextView, UILabel
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    return CGRectMake(0.f, self.descender, ceilf(self.image.size.width / self.image.size.height * self.emojiSize), self.emojiSize);
}

@end
