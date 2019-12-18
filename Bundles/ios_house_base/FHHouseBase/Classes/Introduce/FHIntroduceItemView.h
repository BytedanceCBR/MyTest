//
//  FHIntroduceItemView.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import <UIKit/UIKit.h>
#import <FHIntroduceModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHIntroduceItemViewDelegate <NSObject>

@optional
- (void)close;

@end

@interface FHIntroduceItemView : UIView

- (instancetype)initWithFrame:(CGRect)frame model:(FHIntroduceItemModel *)model;

@property(nonatomic , weak) id<FHIntroduceItemViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
