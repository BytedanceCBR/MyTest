//
//  FHMapSearchBottomBar.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//画圈找房、地铁找房底部交互view 包括  关闭 房源数量 地铁线路
@protocol FHMapSearchBottomBarDelegate ;
@interface FHMapSearchBottomBar : UIView

@property(nonatomic , weak) id<FHMapSearchBottomBarDelegate> delegate;

-(void)showDrawLine:(NSString *)content withNum:(NSInteger)num showIndicator:(BOOL)showIndicator;

//-(void)showSubway:(NSString *)line;

-(void)hideContentBgView;

@end

@protocol FHMapSearchBottomBarDelegate <NSObject>
@required
//-(void)closeBottomBar;

-(void)showNeighborList:(NSString *)tip;

//-(void)showSubwayInBottombar:(FHMapSearchBottomBar *)bottomBar;

@end

NS_ASSUME_NONNULL_END
