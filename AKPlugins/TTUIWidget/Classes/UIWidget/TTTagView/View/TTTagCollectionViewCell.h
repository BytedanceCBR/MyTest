//
//  TTTagCollectionViewCell.h
//  Article
//
//  Created by fengyadong on 16/5/25.
//
//

#import <UIKit/UIKit.h>

@class TTTagItem;
@class SSThemedButton;
@class TTTagButton;

@interface TTTagCollectionViewCell : UICollectionViewCell

NS_ASSUME_NONNULL_BEGIN
+ (CGSize)cellSizeWithTagItem:(TTTagItem *)tagItem maxWidth:(CGFloat)maxWidth;
- (void)updateCellWithTagItem:(TTTagItem *)tagItem;
- (void)registerCellButtonClass:(Class)clazz;
NS_ASSUME_NONNULL_END

@end
