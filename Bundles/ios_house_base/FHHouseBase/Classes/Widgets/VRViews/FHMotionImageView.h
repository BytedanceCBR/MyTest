//
//  FHMotionImageView.h
//  MotionAnimate
//
//  Created by 谢飞 on 2019/9/23.
//  Copyright © 2019 谢飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHMultiMediaModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHMotionImageView : UIView
@property(nonatomic, assign) FHMultiMediaCellHouseType cellHouseType;
- (void)updateImageUrl:(NSURL *)imageUrl andPlaceHolder:(UIImage *)placeHolderImage;

- (void)checkLoadingState;

@end

NS_ASSUME_NONNULL_END
