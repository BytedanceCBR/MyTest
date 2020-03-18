//
//  FHCardSliderFlowLayout.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import <UIKit/UIKit.h>
#import "FHCardSliderView.h"

NS_ASSUME_NONNULL_BEGIN

static const int visibleItemsCount = 3;
@interface FHCardSliderFlowLayout : UICollectionViewFlowLayout

@property(nonatomic , assign) FHCardSliderViewType type;

@end

NS_ASSUME_NONNULL_END
