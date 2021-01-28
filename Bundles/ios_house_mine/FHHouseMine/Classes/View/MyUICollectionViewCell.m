//
//  MyUICollectionViewCell.m
//  FHHouseMine
//
//  Created by bytedance on 2021/1/28.
//

#import "MyUICollectionViewCell.h"
@interface MyUICollectionViewCell()
@property(nonatomic,strong)UIView *borldView;

@end

@implementation MyUICollectionViewCell


- (void) initUI
{
   self.borldView = [[UIView alloc] init];
   self.borldView.layer.borderWidth = 1;
   self.backgroundColor = [UIColor blackColor];
   self.borldView.layer.cornerRadius = 7.5;
   self.borldView.layer.masksToBounds = YES;
}
- (void) initLayout
{
    [self.borldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self.contentView);
    }];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self initLayout];
    }
    return self;
}
@end
