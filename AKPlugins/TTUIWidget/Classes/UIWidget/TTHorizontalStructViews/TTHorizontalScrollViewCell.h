//
//  TTHorizontalScrollViewCell.h
//  Article
//
//  Created by Zhang Leonardo on 16-6-25.
//
//

#import "SSViewBase.h"

@protocol TTHorizontalScrollViewCellDelegate;

@interface TTHorizontalScrollViewCell : SSViewBase
@property(nonatomic, weak)id<TTHorizontalScrollViewCellDelegate> delegate;
@property(nonatomic, assign)NSUInteger index; //default is 0
@property(nonatomic, retain)NSString * reuseIdentifier; // default is nil
@property(nonatomic, assign)BOOL isCurrentDisplayCell;
@property(nonatomic, strong)NSString * enterType;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)isCurrentDisplayWhenEndDecelerating:(BOOL)currentDisplay;
- (void)parentViewWillBeginDragging;

- (UIView *)contentView;
@end

@protocol TTHorizontalScrollViewCellDelegate <NSObject>

@optional

- (void)horizenScrollCellContentViewStartLoading:(TTHorizontalScrollViewCell *)cell;
- (void)horizenScrollCellContentViewStopLoading:(TTHorizontalScrollViewCell *)cell isUserPull:(BOOL)userPull;

@end
