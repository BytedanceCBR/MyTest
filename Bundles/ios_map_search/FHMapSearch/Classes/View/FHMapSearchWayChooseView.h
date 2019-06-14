//
//  FHMapSearchWayChooseView.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , FHMapSearchWayChooseViewType){
    FHMapSearchWayChooseViewTypeDraw = 0 , //只显示画圈找房
    FHMapSearchWayChooseViewTypeSubway = 1, //只显示地图
    FHMapSearchWayChooseViewTypeBoth , //显示地铁找房和画圈找房
} ;

NS_ASSUME_NONNULL_BEGIN
@protocol FHMapSearchWayChooseViewDelegate ;
//地铁找房、画圈找房选择view
@interface FHMapSearchWayChooseView : UIView

@property(nonatomic , weak) id<FHMapSearchWayChooseViewDelegate> delegate;
@property(nonatomic , assign) FHMapSearchWayChooseViewType type;

@end

@protocol FHMapSearchWayChooseViewDelegate <NSObject>
@required
-(void)chooseSubWay;

-(void)chooseDrawLine;

@end


NS_ASSUME_NONNULL_END
