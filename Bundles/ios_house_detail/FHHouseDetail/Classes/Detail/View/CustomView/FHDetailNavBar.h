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
@property(nonatomic , copy) void (^backActionBlock)(void);
@property(nonatomic , copy) void (^shareActionBlock)(void);
@property(nonatomic , copy) void (^messageActionBlock)(void);
@property(nonatomic , copy) void (^collectActionBlock)(BOOL followStatus);

- (instancetype)initWithType:(FHDetailNavBarType)type;
- (void)refreshAlpha:(CGFloat)alpha;
- (void)displayMessageDot:(NSInteger)dotNumber;
- (void)setFollowStatus:(NSInteger)followStatus;
- (void)showRightItems:(BOOL)showItem;
- (void)removeBottomLine;
- (void)showMessageNumber;

//100 版本企业担保 对header的样式修改
- (void)configureVouchStyle;
@property(nonatomic, assign) BOOL isForVouch; //如果是企业担保
@property(nonatomic, copy) NSString *pageType;

@end

NS_ASSUME_NONNULL_END
