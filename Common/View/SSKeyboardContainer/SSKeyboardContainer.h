//
//  KMKeyboardContainer.h
//  Drawus
//
//  Created by Tianhang Yu on 12-4-4.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSKeyboardContainer : UIView

- (void)setShownTarget:(id)target selector:(SEL)selector;
- (void)setHiddenTarget:(id)target selector:(SEL)selector;

@end

