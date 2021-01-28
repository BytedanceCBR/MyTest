//
//  FHMineMyItemView.h
//  FHHouseMine
//
//  Created by bytedance on 2021/1/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMineMyItemView : UIView
@property(nonatomic,strong) UIImageView *imgView;
@property(nonatomic,strong) UILabel *label;
- (instancetype)initWithImageView:(UIImageView *)imgView andLabel:(UILabel *) label;
@end

NS_ASSUME_NONNULL_END
