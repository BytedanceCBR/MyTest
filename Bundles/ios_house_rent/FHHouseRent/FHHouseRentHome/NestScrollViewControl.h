//
//  NestScrollViewControl.h
//  FHHouseRent
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NestScrollViewControl : NSObject<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView* majorScrollView;
@property (nonatomic, weak) UIScrollView* nestScrollView;
@property (nonatomic, assign) CGFloat thresholdYOffset;
+ (instancetype)instanceWithMajorScrollView:(UIScrollView*)majorScrollView
                         withNestScrollView:(UIScrollView*)nestScrollView;

- (instancetype)initWithMajorScrollView:(UIScrollView*)majorScrollView
                     withNestScrollView:(UIScrollView*)nestScrollView;

@end

NS_ASSUME_NONNULL_END
