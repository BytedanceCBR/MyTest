//
//  FHLoginVerifyCodeTextField.m
//  Pods
//
//  Created by bytedance on 2020/4/15.
//

#import "FHLoginVerifyCodeTextField.h"

@implementation FHLoginVerifyCodeTextField

- (void)deleteBackward {
    [super deleteBackward];
    if (self.deleteDelegate && [self.deleteDelegate respondsToSelector:@selector(didClickBackWard)]) {
        [self.deleteDelegate didClickBackWard];
    }
}

- (BOOL)becomeFirstResponder{
    return [super becomeFirstResponder];
}

@end
