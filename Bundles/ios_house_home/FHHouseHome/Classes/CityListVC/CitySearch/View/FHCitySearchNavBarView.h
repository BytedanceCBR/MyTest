//
//  FHCitySearchNavBarView.h
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCitySearchNavBarView : UIView

@property (nonatomic, strong)   UIButton       *backBtn;
@property (nonatomic, strong)   UITextField       *searchInput;

@end

@interface FHCitySearchTableView : UITableView

@property (nonatomic, copy)     dispatch_block_t       handleTouch;

@end

NS_ASSUME_NONNULL_END
