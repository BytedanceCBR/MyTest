//
//  TTCommentTextAttachment.h
//  Article
//
//  Created by lizhuoli on 17/3/1.
//
//

#import <UIKit/UIKit.h>

@interface TTCommentTextAttachment : NSTextAttachment

// 保存生成的attributeString，在label的attributeText中的range
@property (nonatomic, assign) NSRange range;

/**
 根据要设置的image的大小，还有label的高度限制，比例缩放图片并设置bounds

 @param imageSize image的size
 @param labelHeight label的高度，一般为font的pointSize - 1
 */
- (void)setupBoundsWithImageSize:(CGSize)imageSize labelHeight:(CGFloat)labelHeight;

@end
