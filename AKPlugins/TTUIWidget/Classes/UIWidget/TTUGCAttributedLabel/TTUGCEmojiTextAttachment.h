//
//  TTUGCEmojiTextAttachment.h
//  扩展 NSTextAttachment，保存 Emoji 对应索引、纯文本等元数据
//
//  Created by Jiyee Sheng on 5/15/17.
//
//

#import <UIKit/UIKit.h>

// 特殊用途的按钮，作为 Emoji 处理
typedef NS_ENUM(NSInteger, TTUGCEmojiType) {
    TTUGCEmojiDelete = -1,
    TTUGCEmojiBlank = 0,
};

@interface TTUGCEmojiTextAttachment : NSTextAttachment

@property (nonatomic, assign) NSInteger idx; // 排序
@property (nonatomic, strong) NSString *imageName; // 图标文件名
@property (nonatomic, assign) CGFloat fontSize; // 文字大小，内部转换到图标大小
@property (nonatomic, assign) CGFloat emojiSize; // 图标大小
@property (nonatomic, assign) CGFloat descender; // font descender
@property (nonatomic, assign) CGFloat padding; // 左右间距
@property (nonatomic, strong) NSString *plainText; // 对应纯文字
@property (nonatomic, strong, readonly) UIImage *coreTextImage; // cached image for Core Text

@end
