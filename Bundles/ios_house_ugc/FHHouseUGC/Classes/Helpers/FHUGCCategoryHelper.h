//
//  FHUGCCategoryHelper.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/5.
//

#import <UIKit/UIKit.h>
#import <TTUGCTextView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(Helper)
- (BOOL)isCurrentVisible;
@end

@interface UITextField(Helper)


/**
 处理TextField字数长度限制，包含中文输入法的处理

 @param maxLength textField文本字数限制
 */
- (void)textFieldDidChangeLimitTextLength:(NSInteger)maxLength;
@end

@interface TTUGCTextView(Helper)


/**
 处理TTUGCTextView字数长度限制，包含中文输入法的处理

 @param maxLength TTUGCTextView文本字数限制
 */
- (void)textViewDidChangeLimitTextLength:(NSInteger)maxLength;

@end

NS_ASSUME_NONNULL_END
