//
//  FHUGCCategoryHelper.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/5.
//

#import "FHUGCCategoryHelper.h"

@implementation UIViewController(Helper)
- (BOOL)isCurrentVisible {
    return self.isViewLoaded && self.view.window;
}
@end


@implementation UITextField(Helper)

- (void)textFieldDidChangeLimitTextLength:(NSInteger)maxLength {
    
    if(maxLength <= 0) {
        maxLength = NSIntegerMax;
    }
    
    UITextField *textField = self;
    NSString *toBeString = textField.text;
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; // 键盘输入模
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxLength)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
                if (rangeIndex.length == 1)
                {
                    textField.text = [toBeString substringToIndex:maxLength];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
    else {
        // 处理非中文的情况
        if(textField.text.length > maxLength) {
            textField.text = [textField.text substringToIndex:maxLength];
        }
    }
}

@end
