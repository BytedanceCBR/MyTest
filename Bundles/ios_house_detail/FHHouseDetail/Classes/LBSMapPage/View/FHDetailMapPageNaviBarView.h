//
//  FHDetailMapPageNaviBarView.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/1/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailMapPageNaviBarView : UIView

@property(nonatomic , copy) void (^backActionBlock)();

@property(nonatomic , copy) void (^naviMapActionBlock)();

- (instancetype)initWithBackImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
