//
//  FHHouseListNoHouseCell.h
//  FHHouseList
//
//  Created by 春晖 on 2019/8/8.
//

#import <UIKit/UIKit.h>
#import <FHCommonUI/FHErrorView.h>
#import <FHHouseBase/FHListBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListNoHouseCell : FHListBaseCell

@property(nonatomic , strong) FHErrorView *errorView;

@end

@interface FHHouseListNoHouseCellModel : NSObject

@property(nonatomic , assign) CGFloat cellHeight;

@end



NS_ASSUME_NONNULL_END
