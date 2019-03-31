//
//  FHImmersionNavBarViewModel.h
//  Pods
//
//  Created by leo on 2019/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHImmersionNavBarViewModel : NSObject
@property (nonatomic, assign) CGPoint currentContentOffset;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, strong) UIColor* titleColor;
@property (nonatomic, strong) UIImage* backButtonImage;
@end

NS_ASSUME_NONNULL_END
