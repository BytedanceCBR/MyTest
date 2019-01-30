//
//  FHDetailBaseCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailBaseCell : UITableViewCell

+ (Class)cellViewClass;
+ (NSString *)cellIdentifier;
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width;
- (void)refreshWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
