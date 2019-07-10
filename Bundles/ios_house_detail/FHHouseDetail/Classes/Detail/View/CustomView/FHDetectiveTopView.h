//
//  FHDetectiveTopView.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetectiveTopView : UIView

@property(nonatomic, copy)void(^tapBlock)(void);

- (void)updateWithTitle:(NSString *)title tip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
