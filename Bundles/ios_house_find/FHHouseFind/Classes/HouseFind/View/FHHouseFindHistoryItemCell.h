//
//  FHHouseFindHistoryItemCell.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/*
 * 找房历史下的子cell
 */
@interface FHHouseFindHistoryItemCell : UICollectionViewCell


+(CGFloat)widthForTitle:(NSString *)title subtitle:(NSString *)subtitle;

-(void)udpateWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
