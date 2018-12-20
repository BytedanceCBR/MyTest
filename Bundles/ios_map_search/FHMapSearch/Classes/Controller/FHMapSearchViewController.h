//
//  FHMapSearchViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHMapSearchConfigModel.h"
#import "FHMapSearchShowMode.h"
#import <TTRoute.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const OPENURL_CALLBAK ;

typedef  void (^_Nullable HouseListOpenUrlCallback)(NSString *openUrl);

@class SearchConfigFilterItem;
@protocol FHMapSearchOpenUrlDelegate;


@interface FHMapSearchViewController : FHBaseViewController<TTRouteInitializeProtocol>

@property(nonatomic , strong) NSArray<SearchConfigFilterItem *> *filterItems;
@property(nonatomic , copy)   void (^_Nullable choosedConditionFilter)(NSDictionary<NSString * , NSObject *> *_Nullable conditions , NSString *_Nullable suggestion);
@property(nonatomic , weak) id <FHMapSearchOpenUrlDelegate> openUrlDelegate;

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel ;//NS_DESIGNATED_INITIALIZER

-(CGFloat)contentViewHeight;

-(CGFloat)topBarBottom;

-(void)switchNavbarMode:(FHMapSearchShowMode)mode;

/*
 * ratio 0 : hide
 * ratio 1 : show
 */
-(void)showNavTopViews:(CGFloat)ratio animated:(BOOL)animated;

-(void)insertHouseListView:(UIView *)houseListView;

@end


@protocol FHMapSearchOpenUrlDelegate <NSObject>

@required
-(void)handleHouseListCallback:(NSString *)openUrl;

@end

NS_ASSUME_NONNULL_END
