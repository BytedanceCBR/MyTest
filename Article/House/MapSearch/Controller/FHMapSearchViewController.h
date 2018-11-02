//
//  FHMapSearchViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHMapSearchConfigModel.h"
#import "FHMapSearchShowMode.h"

NS_ASSUME_NONNULL_BEGIN

@class SearchConfigFilterItem;

@interface FHMapSearchViewController : FHBaseViewController

@property(nonatomic , strong) NSArray<SearchConfigFilterItem *> *filterItems;
@property(nonatomic , copy)   void (^_Nullable choosedConditionFilter)(NSDictionary<NSString * , NSObject *> *_Nullable conditions , NSString *_Nullable suggestion);

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel ;//NS_DESIGNATED_INITIALIZER

-(CGFloat)contentViewHeight;

-(CGFloat)topBarBottom;

-(void)switchNavbarMode:(FHMapSearchShowMode)mode;

-(void)showNavTopViews:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
