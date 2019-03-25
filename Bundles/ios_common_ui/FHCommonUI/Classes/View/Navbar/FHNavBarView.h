//
//  FHNavBarView.h
//  Article
//
//  Created by 张元科 on 2018/12/9.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHNavBarView : UIView

@property (nonatomic, strong) UILabel   *title;
@property (nonatomic, strong) UIButton  *leftBtn;
@property (nonatomic , copy) void (^leftButtonBlock)();

// 添加导航栏右边视图，移除之前视图，从右向左排列，默认第一个viewRightOffset：@18.0，NSNumber类型
- (void)addRightViews:(NSArray *)rightViews viewsWidth:(NSArray *)viewsWidth viewsHeight:(NSArray *)viewsHeight viewsRightOffset:(NSArray *)viewsRightOffset;

- (void)cleanStyle:(BOOL)isCleanStyle;

@end

@interface FHHotAreaButton : UIButton

@end

NS_ASSUME_NONNULL_END
