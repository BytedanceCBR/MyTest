//
//  FHHouseFindHelpMainViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import <Foundation/Foundation.h>
#import<TTRoute/TTRoute.h>
#import "FHHouseFindRecommendModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseFindMainViewController;
@interface FHHouseFindHelpMainViewModel : NSObject

@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

- (instancetype)initWithViewController:(FHHouseFindMainViewController *)viewController paramObj:(TTRouteParamObj *)paramObj;
- (void)startLoadData;

@end

NS_ASSUME_NONNULL_END
