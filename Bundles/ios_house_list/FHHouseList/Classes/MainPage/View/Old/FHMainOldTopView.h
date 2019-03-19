//
//  FHMainOldTopView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class FHConfigDataOpData2ItemsModel;
@protocol FHMainOldTopViewDelegate;
@interface FHMainOldTopView : UIView

@property(nonatomic , strong) NSArray<FHConfigDataOpData2ItemsModel *> *items;
@property(nonatomic , weak) id<FHMainOldTopViewDelegate> delegate;

@end

@protocol FHMainOldTopViewDelegate <NSObject>

-(void)selecteOldItem:(FHConfigDataOpData2ItemsModel *)item;

@end

NS_ASSUME_NONNULL_END
