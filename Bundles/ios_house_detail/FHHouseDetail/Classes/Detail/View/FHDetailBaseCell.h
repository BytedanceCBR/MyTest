//
//  FHDetailBaseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailBaseCell : UITableViewCell

+ (Class)cellViewClass;
- (void)refreshWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
