//
//  FHDetailNavBar.h
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FHDetailNavBarTypeDefault,
    FHDetailNavBarTypeTitle,
} FHDetailNavBarType;

@interface FHDetailNavBar : UIView

@property(nonatomic , assign) FHDetailNavBarType type;
@property(nonatomic , copy) void (^backActionBlock)();
@property(nonatomic , copy) void (^shareActionBlock)();
@property(nonatomic , copy) void (^messageActionBlock)();
@property(nonatomic , copy) void (^collectActionBlock)(BOOL followStatus);

- (instancetype)initWithType:(FHDetailNavBarType)type;
- (void)refreshAlpha:(CGFloat)alpha;
- (void)displayMessageDot:(BOOL)show;
- (void)setFollowStatus:(NSInteger)followStatus;
- (void)showRightItems:(BOOL)showItem;

- (void)removeBottomLine;

@end

NS_ASSUME_NONNULL_END
