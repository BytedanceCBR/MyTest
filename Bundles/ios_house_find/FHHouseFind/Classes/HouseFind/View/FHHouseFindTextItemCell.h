//
//  FHHouseFindTextItemCell.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 默认显示的cell
@interface FHHouseFindTextItemCell : UICollectionViewCell

@property(nonatomic , strong) UIFont *titleFont;
-(void)updateWithTitle:(NSString *)title highlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
