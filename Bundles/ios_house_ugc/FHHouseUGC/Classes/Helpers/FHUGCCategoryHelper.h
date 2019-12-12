//
//  FHUGCCategoryHelper.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/5.
//

#import <UIKit/UIKit.h>

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

NS_ASSUME_NONNULL_END
