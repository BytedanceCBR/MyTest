//
//  FHMapSearchWayChooseView.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol FHMapSearchWayChooseViewDelegate ;
//地铁找房、画圈找房选择view
@interface FHMapSearchWayChooseView : UIView

@property(nonatomic , weak) id<FHMapSearchWayChooseViewDelegate> delegate;

@end

@protocol FHMapSearchWayChooseViewDelegate <NSObject>
@required
-(void)chooseSubWay;

-(void)chooseDrawLine;

@end


NS_ASSUME_NONNULL_END
