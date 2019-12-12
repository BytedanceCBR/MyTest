//
//  FHHomeEntranceItemView.h
//  FHHouseBase
//
//  Created by 张静 on 2019/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeEntranceItemView : UIControl

@property(nonatomic , strong) UIImageView *iconView;
@property(nonatomic , strong) UILabel *nameLabel;

-(instancetype)initWithFrame:(CGRect)frame iconSize:(CGSize)iconSize;
-(void)updateWithIconUrl:(NSString *)iconUrl name:(NSString *)name placeHolder:(UIImage *)placeHolder;

@end

NS_ASSUME_NONNULL_END
