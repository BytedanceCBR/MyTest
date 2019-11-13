//
//  FHListBaseCell.h
//  FHHouseList
//
//  Created by 张静 on 2019/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHListBaseCell : UITableViewCell

- (void)refreshWithData:(id)data;

+ (CGFloat)heightForData:(id)data;

@end

NS_ASSUME_NONNULL_END
