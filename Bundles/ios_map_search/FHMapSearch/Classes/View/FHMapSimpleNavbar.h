//
//  FHMapSimpleNavbar.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , FHMapSimpleNavbarType) {
    FHMapSimpleNavbarTypeBack = 0 ,
    FHMapSimpleNavbarTypeClose,
    FHMapSimpleNavbarTypeDrawLine,
};

@interface FHMapSimpleNavbar : UIView

@property(nonatomic , assign) FHMapSimpleNavbarType type;

@property(nonatomic , assign) NSInteger houseType;

@property(nonatomic , strong) NSString *title;

@property(nonatomic , copy) void (^backActionBlock)(FHMapSimpleNavbarType type);
@property(nonatomic , copy) void (^rightActionBlock)(FHMapSimpleNavbarType type);
@property(nonatomic,copy) void (^indexHouseChangeBlock)(NSInteger index);

-(CGFloat)titleBottom;

- (void)updateCicleBtn:(BOOL)isShowCircle;

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index;

- (void)updateShowBtn:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
