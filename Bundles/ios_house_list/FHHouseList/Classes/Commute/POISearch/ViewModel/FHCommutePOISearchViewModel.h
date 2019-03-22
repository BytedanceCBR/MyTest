//
//  FHCommutePOISearchViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHCommutePOISearchViewController;
@class FHCommutePOIInputBar;
@interface FHCommutePOISearchViewModel : NSObject

@property(nonatomic , weak)  FHCommutePOISearchViewController *viewController;

-(instancetype)initWithTableView:(UITableView *)tableView inputBar:(FHCommutePOIInputBar *)inputBar;

@end

NS_ASSUME_NONNULL_END
