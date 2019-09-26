//
//  FHMotionImageView.h
//  MotionAnimate
//
//  Created by 谢飞 on 2019/9/23.
//  Copyright © 2019 谢飞. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMotionImageView : UIView

- (void)updateImageUrl:(NSURL *)imageUrl andPlaceHolder:(UIImage *)placeHolderImage;

@end

NS_ASSUME_NONNULL_END
