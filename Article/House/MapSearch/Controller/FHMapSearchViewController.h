//
//  FHMapSearchViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHMapSearchConfigModel.h"


NS_ASSUME_NONNULL_BEGIN

@class SearchConfigFilterItem;

@interface FHMapSearchViewController : FHBaseViewController

//@property(nonatomic , assign) NSInteger houseType;
@property(nonatomic , strong) NSArray<SearchConfigFilterItem *> *filterItems;
//TODO: add other enter configs

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel ;//NS_DESIGNATED_INITIALIZER

@end

NS_ASSUME_NONNULL_END
