//
//  FHCommutePOIHeaderView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCommutePOIHeaderView : UIView

@property(nonatomic , strong) NSString *location;
@property(nonatomic , copy)   void (^refreshBlock)(void);
@property(nonatomic , assign) BOOL showRefresh;
@property(nonatomic , assign) BOOL loading;

@end

NS_ASSUME_NONNULL_END
