//
//  FHMessageTagViewCell.h
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import <UIKit/UIKit.h>
#import "FHMessageCellTagModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageTagViewCell : UICollectionViewCell
+(NSString *)reuseIdentifier;
-(void)updateWithTag:(FHMessageCellTagModel *)tag;
@end

NS_ASSUME_NONNULL_END
