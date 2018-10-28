//
//  FHMapSearchViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHMapSearchConfigModel.h"


typedef NS_ENUM(NSInteger , FHMapSearchShowMode) {
    FHMapSearchShowModeMap = 0 ,
    FHMapSearchShowModeHouseList = 1 ,
    FHMapSearchShowModeHalfHouseList = 2,
};

NS_ASSUME_NONNULL_BEGIN

@class SearchConfigFilterItem;

@interface FHMapSearchViewController : FHBaseViewController

//@property(nonatomic , assign) NSInteger houseType;
@property(nonatomic , strong) NSArray<SearchConfigFilterItem *> *filterItems;
//TODO: add other enter configs

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel ;//NS_DESIGNATED_INITIALIZER

-(CGFloat)contentViewHeight;

-(CGFloat)topBarBottom;

-(void)switchNavbarMode:(FHMapSearchShowMode)mode;

-(void)showNavTopViews:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
