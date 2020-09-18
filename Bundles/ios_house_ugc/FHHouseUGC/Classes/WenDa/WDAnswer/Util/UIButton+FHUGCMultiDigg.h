//
//  UIButton+FHUGCMultiDigg.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (FHUGCMultiDigg)

//调用前，保证button已经被加到一个view中
- (void)registMulitDiggEmojiAnimation;

@end

NS_ASSUME_NONNULL_END
