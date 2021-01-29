//
//  FHMineMyMutiItemCell.m
//  FHHouseMine
//
//  Created by bytedance on 2021/1/27.
//
#import <Masonry/Masonry.h>
#import "FHMineMyMutiItemCell.h"
#import "FHMineMyItemView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTAccount.h"
#import "FHMineDefine.h"


@interface FHMineMyMutiItemCell()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)NSMutableArray<FHMineFavoriteItemView *> *items;


@end
@implementation FHMineMyMutiItemCell
- (void)hiddenHeaderView
{
    self.headerView.hidden = YES;
}
- (void)setItemTitle:(NSString *)itemTitle
{
    self.titleLabel.text = itemTitle;
}

#pragma mark 截取部分图片
- (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect{
    
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}
- (void)initView
{
    self.headerView = [[UIImageView alloc] init];
    UIImage *img = [self ct_imageFromImage:[UIImage imageNamed:@"fh_mine_header_bg_orange"] inRect:CGRectMake(0, 138, [UIScreen mainScreen].bounds.size.width, 31)];
    self.headerView.image = img;
    [self.contentView addSubview:self.headerView];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    [self.contentView addSubview:self.bgView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor themeGray1]];
    [self.bgView addSubview:self.titleLabel];
    
}
- (UILabel *) LabelWithFont:(UIFont *)font textColor:(UIColor *) textcolor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textcolor;
    return label;
}
- (void)initConstraints
{
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(self.contentView.mas_left).offset(9);
        make.right.bottom.mas_equalTo(self.contentView).offset(-9);
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(32);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(12);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-12);
        make.top.mas_equalTo(self.bgView.mas_top).offset(12);
        make.height.mas_equalTo(19);
    }];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.items = [NSMutableArray array];
        [self initView];
        [self initConstraints];
    }
    return self;
}
- (void)addItems:(NSMutableArray *)items andRow:(NSInteger)row
{
    if(row == 0){
        FHMineMyItemView *item0 = items[0];
        FHMineMyItemView *item1 = items[1];
        FHMineMyItemView *item2 = items[2];
        FHMineMyItemView *item3 = items[3];
        
        [self.bgView addSubview:item0.imgView];
        [self.bgView addSubview:item1.imgView];
        [self.bgView addSubview:item2.imgView];
        [self.bgView addSubview:item3.imgView];
        
        [self.bgView addSubview:item0.label];
        [self.bgView addSubview:item1.label];
        [self.bgView addSubview:item2.label];
        [self.bgView addSubview:item3.label];
        
        [item0.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(21);
        }];
        
        
        [item1.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82+21);
        }];
        
       
        [item2.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*2+21);
        }];
        
        
        [item3.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*3+21);
        }];
        
        [item0.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item0.imgView).offset(54);
            make.centerX.mas_equalTo(item0.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.bgView).offset(-9);
        }];
        
        [item1.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item1.imgView).offset(54);
            make.centerX.mas_equalTo(item1.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item2.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item2.imgView).offset(54);
            make.centerX.mas_equalTo(item2.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item3.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item3.imgView).offset(54);
            make.centerX.mas_equalTo(item3.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];
    }
    else if(row==1){
        FHMineMyItemView *item0 = items[0];
        FHMineMyItemView *item1 = items[1];
        FHMineMyItemView *item2 = items[2];
        FHMineMyItemView *item3 = items[3];
        
        [self.bgView addSubview:item0.imgView];
        [self.bgView addSubview:item1.imgView];
        [self.bgView addSubview:item2.imgView];
        [self.bgView addSubview:item3.imgView];
        
        [self.bgView addSubview:item0.label];
        [self.bgView addSubview:item1.label];
        [self.bgView addSubview:item2.label];
        [self.bgView addSubview:item3.label];
        
        [item0.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(21);
        }];
        
        
        [item1.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82+21);
        }];
        
       
        [item2.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*2+21);
        }];
        
        
        [item3.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*3+21);
        }];
        
        [item0.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item0.imgView).offset(54);
            make.centerX.mas_equalTo(item0.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.bgView).offset(-9);
        }];
        
        [item1.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item1.imgView).offset(54);
            make.centerX.mas_equalTo(item1.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item2.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item2.imgView).offset(54);
            make.centerX.mas_equalTo(item2.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item3.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item3.imgView).offset(54);
            make.centerX.mas_equalTo(item3.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];
    }
    else if(row==2){
        FHMineMyItemView *item0 = items[0];
        FHMineMyItemView *item1 = items[1];
        FHMineMyItemView *item2 = items[2];
        FHMineMyItemView *item3 = items[3];
        FHMineMyItemView *item4 = items[4];
        FHMineMyItemView *item5 = items[5];
        
        [self.bgView addSubview:item0.imgView];
        [self.bgView addSubview:item1.imgView];
        [self.bgView addSubview:item2.imgView];
        [self.bgView addSubview:item3.imgView];
        [self.bgView addSubview:item4.imgView];
        [self.bgView addSubview:item5.imgView];
        
        [self.bgView addSubview:item0.label];
        [self.bgView addSubview:item1.label];
        [self.bgView addSubview:item2.label];
        [self.bgView addSubview:item3.label];
        [self.bgView addSubview:item4.label];
        [self.bgView addSubview:item5.label];
        
        [item0.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(21);
        }];
        
        
        [item1.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82+21);
        }];
        
       
        [item2.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*2+21);
        }];
        
        
        [item3.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42);
            make.left.mas_equalTo(self.bgView).offset(82*3+21);
        }];
        
        [item4.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42+85);
            make.left.mas_equalTo(self.bgView).offset(21);
        }];
        
        [item5.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(56);
            make.top.mas_equalTo(self.bgView).offset(42+85);
            make.left.mas_equalTo(self.bgView).offset(82+21);
        }];
        
        [item0.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item0.imgView).offset(54);
            make.centerX.mas_equalTo(item0.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];
        
        [item1.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item1.imgView).offset(54);
            make.centerX.mas_equalTo(item1.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item2.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item2.imgView).offset(54);
            make.centerX.mas_equalTo(item2.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];

        [item3.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item3.imgView).offset(54);
            make.centerX.mas_equalTo(item3.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];
        
        [item4.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item4.imgView).offset(54);
            make.centerX.mas_equalTo(item4.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.bgView).offset(-9);
        }];
        
        [item5.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(item5.imgView).offset(54);
            make.centerX.mas_equalTo(item5.imgView);
            make.width.mas_equalTo(54);
            make.height.mas_equalTo(20);
        }];
    }
    else{

    }
}
@end
