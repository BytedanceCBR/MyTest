//
//  UITextField+TTBytesLimit.m
//  Article
//
//  Created by tyh on 2017/6/19.
//
//

#import "UITextField+TTBytesLimit.h"
#import "NSString+TTLength.h"
#import <objc/runtime.h>

@implementation UITextField (TTBytesLimit)
static NSString *kLimitTextLengthKey = @"kLimitTextLengthKey";
- (void)limitTextLength:(int)length
{
    objc_setAssociatedObject(self, (__bridge const void *)(kLimitTextLengthKey), [NSNumber numberWithInt:length], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addTarget:self action:@selector(textFieldTextLengthLimit:) forControlEvents:UIControlEventEditingChanged];
}

- (NSUInteger)bytesWithoutUndeterminedForNotEnglishLanguage
{
    BOOL isNotEnglish;
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    if ([current.primaryLanguage isEqualToString: @"en-US"]) {
        isNotEnglish = NO;
    } else {
        isNotEnglish = YES;
    }
    if (isNotEnglish) {
        //中文输入法下
        UITextRange *markedTextRange = [self markedTextRange];
        UITextPosition* beginning = self.beginningOfDocument;
        UITextPosition* selectionStart = markedTextRange.start;
        UITextPosition* selectionEnd = markedTextRange.end;
        
        const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
        const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
        
        NSRange markedRange = NSMakeRange(location, length);
        NSString *withoutMarkedString = [self.text stringByReplacingCharactersInRange:markedRange withString:@""];
        
        return [withoutMarkedString tt_lengthOfBytes];
    } else {
        return [self.text tt_lengthOfBytes];
    }
}

- (void)textFieldTextLengthLimit:(id)sender
{
    NSNumber *lengthNumber = objc_getAssociatedObject(self, (__bridge const void *)(kLimitTextLengthKey));
    int length = [lengthNumber intValue];
    //下面是修改部分
    bool isChinese;//判断当前输入法是否是中文
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    //[[UITextInputMode currentInputMode] primaryLanguage]，废弃的方法
    if ([current.primaryLanguage isEqualToString: @"en-US"]) {
        isChinese = false;
    } else {
        isChinese = true;
    }
    
    if(sender == self) {
        // length是自己设置的位数
        NSString *str = [[self text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
        if (isChinese) {
            //中文输入法下
            UITextRange *selectedRange = [self markedTextRange];
            //获取高亮部分
            UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if ([str tt_lengthOfBytes] > length) {
                    //加这个判定条件保证中间插入的时候光标位置不会错
                    while ([str tt_lengthOfBytes] > length) {
                        str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - 1, 1) withString:@""];
                    }
                    [self setText:str];
                }
            } else {
                //do nothing
            }
        }else{
            if ([str tt_lengthOfBytes] > length) {
                while ([str tt_lengthOfBytes] > length) {
                    str = [str stringByReplacingCharactersInRange:NSMakeRange([str length] - 1, 1) withString:@""];
                }
                [self setText:str];
            }
        }
    }
}

@end
