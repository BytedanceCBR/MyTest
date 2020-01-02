//
//  FHHomeEntranceItemView.h
//  FHHouseBase
//
//  Created by 张静 on 2019/12/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ITEM_PER_ROW  5
#define TOP_MARGIN_PER_ROW 10
#define NORMAL_ICON_WIDTH  56
#define NORMAL_NAME_HEIGHT 20
#define NORMAL_ITEM_WIDTH  40
#define ITEM_TAG_BASE      100

@interface FHHomeEntranceItemView : UIControl

@property(nonatomic , strong) UIImageView *iconView;
@property(nonatomic , strong) UILabel *nameLabel;

-(instancetype)initWithFrame:(CGRect)frame iconSize:(CGSize)iconSize;
-(void)updateWithIconUrl:(NSString *)iconUrl name:(NSString *)name placeHolder:(UIImage *)placeHolder;

@end

NS_ASSUME_NONNULL_END
