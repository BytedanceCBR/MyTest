//
//  FHBrowsingHistoryEmptyView.h
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol  FHBrowsingHistoryEmptyViewDelegate;


@interface FHBrowsingHistoryEmptyView : UIView

@property (nonatomic, assign) FHHouseType    houseType;
@property (nonatomic, weak) id<FHBrowsingHistoryEmptyViewDelegate> delegate;

@end

@protocol FHBrowsingHistoryEmptyViewDelegate <NSObject>

- (void)clickFindHouse:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
