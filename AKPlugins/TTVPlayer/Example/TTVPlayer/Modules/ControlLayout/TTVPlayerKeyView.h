//
//  TTVPlayerKeyView.h
//  Article
//
//  Created by panxiang on 2018/11/28.
//

#import <UIKit/UIKit.h>
#import "UIView+TTVViewKey.h"

@interface TTVPlayerKeyView : UIView

/**
 通过 key 来获取下面的 subview

 @param key subview 设置的 key
 @return subview
 */
- (UIView *)viewForViewKey:(NSString *)key;

@end

