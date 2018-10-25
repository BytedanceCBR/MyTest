//
//  FHMapSearchViewModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "FHMapSearchConfigModel.h"
#import "FHMapSearchTipView.h"

@class FHMapSearchViewController;
NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchViewModel : NSObject <MAMapViewDelegate>

@property(nonatomic , weak)   FHMapSearchViewController *viewController;
@property(nonatomic , strong) MAMapView *mapView;
@property(nonatomic , strong) FHMapSearchTipView *tipView;


-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configMode;

-(void)requestHouses;

@end

NS_ASSUME_NONNULL_END
