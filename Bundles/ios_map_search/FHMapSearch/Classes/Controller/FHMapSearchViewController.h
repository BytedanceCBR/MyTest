//
//  FHMapSearchViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHMapSearchConfigModel.h"
#import "FHMapSearchShowMode.h"
#import "TTRoute.h"

NS_ASSUME_NONNULL_BEGIN

typedef  void (^_Nullable HouseListOpenUrlCallback)(NSString *openUrl);

@class SearchConfigFilterItem;
@protocol FHMapSearchOpenUrlDelegate;


@interface FHMapSearchViewController : FHBaseViewController<TTRouteInitializeProtocol>

@property(nonatomic , strong) NSArray<SearchConfigFilterItem *> *filterItems;
@property(nonatomic , copy)   void (^_Nullable choosedConditionFilter)(NSDictionary<NSString * , NSObject *> *_Nullable conditions , NSString *_Nullable suggestion);
@property(nonatomic , weak) id <FHMapSearchOpenUrlDelegate> openUrlDelegate;

@property(nonatomic , strong , readonly) UIButton *locationButton;

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel ;//NS_DESIGNATED_INITIALIZER

-(CGFloat)contentViewHeight;

-(CGFloat)topBarBottom;

-(void)switchNavbarMode:(FHMapSearchShowMode)mode;

-(UIView *)navBarView;

/*
 * ratio 0 : hide
 * ratio 1 : show
 */
-(void)showNavTopViews:(CGFloat)ratio animated:(BOOL)animated;

-(void)insertHouseListView:(UIView *)houseListView;

-(void)enterMapDrawMode;

-(void)enterSubwayMode;

-(void)switchToNormalMode;

-(BOOL)isShowingMaskView;

-(void)backAction;


@end




NS_ASSUME_NONNULL_END
