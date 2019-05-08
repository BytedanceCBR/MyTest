//
//  FHHouseRentMainViewModel.h
//  FHHouseRent
//
//  Created by 谷春晖 on 2018/11/22.
//

#import <Foundation/Foundation.h>
#import <FlatRawTableRepository.h>
#import <FHHouseFilterDelegate.h>

NS_ASSUME_NONNULL_BEGIN
@class TTRouteParamObj;
@class FHFakeInputNavbar;
@class FHErrorMaskView;
@class FHSpringboardView;
@class FHBaseViewController;
@class ArticleListNotifyBarView;
@interface FHHouseRentMainViewModel : NSObject <FlatRawTableRepository,FHHouseFilterDelegate>


-(instancetype)initWithViewController:(FHBaseViewController *)viewController tableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj;

//@property(nonatomic , copy) void (^resetConditionBlock)(NSDictionary *condition);
@property(nonatomic , copy) NSString *_Nullable (^conditionNoneFilterBlock)(NSDictionary *params);//获取非过滤器显示的过滤条件
@property(nonatomic , copy) void (^closeConditionFilter)();
@property(nonatomic , copy) void (^clearSortCondition)();
@property(nonatomic , copy) NSString * (^getConditions)();
@property(nonatomic , copy) void (^showNotify)(NSString *message);
@property(nonatomic , copy) NSString *_Nullable (^getSortTypeString)();

//@property(nonatomic , copy) void (^overwriteFilter)(NSString *houseListUrl); //与Android一致，不回写筛选器

@property(nonatomic , strong) FHFakeInputNavbar *navbar;
@property(nonatomic , strong) FHErrorMaskView *errorMaskView;
@property(nonatomic , strong) UIView *headerView;
@property(nonatomic , strong) UIScrollView *containerScrollView;
@property(nonatomic , strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic , weak) UIView *bottomLine;

-(UIView *)iconHeaderView;

-(void)requestData:(BOOL)isHead;

-(void)showInputSearch;

-(void)showMapSearch;

-(CGFloat)headerBottomOffset;

-(void)viewWillAppear;
-(void)viewWillDisapper;

//-(void)notifyChange:(BOOL)show headerHeight:(CGFloat)height;

-(UIImage *)contentSnapshot;
-(void)addStayLog;

@end

NS_ASSUME_NONNULL_END
