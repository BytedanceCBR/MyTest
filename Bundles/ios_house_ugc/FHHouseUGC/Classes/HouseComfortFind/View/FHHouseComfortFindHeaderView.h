//
//  FHHouseComfortFindHeaderView.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import <UIKit/UIKit.h>
#import <FHHomeEntranceItemView.h>

#define iconWidth        52
#define itemViewHeight   70
#define horizontalMargin 20
#define verticalMargin   12
#define comfortFindHeaderViewHeight 94

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseComfortFindHeaderView : UIView
@property(nonatomic,assign) NSUInteger itemsCount;
- (void)loadItemViews;
@end

NS_ASSUME_NONNULL_END
