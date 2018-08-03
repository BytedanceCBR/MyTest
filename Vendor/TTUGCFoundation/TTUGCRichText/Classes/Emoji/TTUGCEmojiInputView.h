//
//  TTUGCEmojiInputView.h
//  Emoji 输入选择器
//
//  Created by Jiyee Sheng on 5/19/17.
//

#import <UIKit/UIKit.h>

@class TTUGCEmojiInputView;
@class TTUGCEmojiTextAttachment;

@interface TTUGCEmojiInputCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TTUGCEmojiTextAttachment *textAttachment;

@end

@protocol TTUGCEmojiInputViewDelegate <NSObject>

- (void)emojiInputView:(UIView *)emojiInputView didSelectEmojiTextAttachment:(TTUGCEmojiTextAttachment *)emojiTextAttachment;

@end

@interface TTUGCEmojiInputView : SSThemedView

@property (nonatomic, strong) NSArray <TTUGCEmojiTextAttachment *> *textAttachments;

@property (nonatomic, weak) id <TTUGCEmojiInputViewDelegate> delegate;

@property (nonatomic, strong) NSString *source;

@end
