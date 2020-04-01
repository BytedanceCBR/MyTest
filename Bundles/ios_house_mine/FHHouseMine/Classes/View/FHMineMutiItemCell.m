//
//  FHMineFocusCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineMutiItemCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTAccount.h"
#import "FHMineDefine.h"

#define itemPadding ((CGRectGetWidth([UIScreen mainScreen].bounds) > 320) ? 10 : 7)
#define eachRowCount 4
#define bgPadding ((CGRectGetWidth([UIScreen mainScreen].bounds) > 320) ? 20 : 15)

@interface FHMineMutiItemCell()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *headerView;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) NSMutableArray<FHMineFavoriteItemView *> *items;

@end

@implementation FHMineMutiItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.items = [NSMutableArray array];
        
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.headerView = [[UIImageView alloc] init];
    UIImage *image = [self ct_imageFromImage:[UIImage imageNamed:@"fh_mine_header_bg_orange2"] inRect:CGRectMake(0, 138, [UIScreen mainScreen].bounds.size.width, 32)];
    _headerView.image = image;
    _headerView.hidden = YES;
    [self.contentView addSubview:_headerView];
    
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.masksToBounds = YES;
    _bgView.layer.cornerRadius = 4;
    [self.contentView addSubview:_bgView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeGray1]];
    [self.bgView addSubview:_titleLabel];
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).offset(15);
        make.right.mas_equalTo(self.bgView).offset(-15);
        make.top.mas_equalTo(self.bgView).offset(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(32);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(bgPadding);
        make.right.mas_equalTo(self.contentView).offset(-bgPadding);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateCell:(FHMineConfigDataIconOpDataModel *)model isFirst:(BOOL)isFirst {
    self.model = model;
    
    _headerView.hidden = !isFirst;
    
    if(model.title && ![model.title isEqualToString:@""]){
        self.titleLabel.text = model.title;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgView).offset(15);
            make.right.mas_equalTo(self.bgView).offset(-15);
            make.top.mas_equalTo(self.bgView).offset(15);
            make.height.mas_equalTo(22);
        }];
    }else{
        self.titleLabel.text = @"";
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgView).offset(15);
            make.right.mas_equalTo(self.bgView).offset(-15);
            make.top.mas_equalTo(self.bgView).offset(10);
            make.height.mas_equalTo(0);
        }];
    }
    
    [self initDefaultItems];
}

- (void)initDefaultItems {
    __weak typeof(self) wself = self;
    [self.items removeAllObjects];
    
    for (FHMineConfigDataIconOpDataMyIconItemsModel *itemModel in self.model.myIcon.items) {
        NSString *title = itemModel.title;
        if([self.model.myIconId integerValue] == FHMineModuleTypeHouseFocus){
            title = [self getFocusItemTitle:itemModel.title];
        }
        NSString *imageUrl = ((FHMineConfigDataIconOpDataMyIconItemsImageModel *)[itemModel.image firstObject]).url;
        FHMineFavoriteItemView *view = [[FHMineFavoriteItemView alloc] initWithName:title imageName:imageUrl];
        view.itemClickBlock = ^{
            [wself didItemClick:itemModel];
        };
        [self.items addObject:view];
    }
    
    [self setItemViews:self.items];
}

- (void)setItemViews:(NSArray<FHMineFavoriteItemView *> *)items {
    for (UIView *view in self.bgView.subviews) {
        if([view isKindOfClass:[FHMineFavoriteItemView class]]){
            [view removeFromSuperview];
        }
    }
    
    if(items.count > 0){
        CGFloat width = (UIScreen.mainScreen.bounds.size.width - bgPadding * 2 - (eachRowCount - 1) * itemPadding) / eachRowCount;
        
        UIView *topView = self.titleLabel;
        
        for (NSInteger i = 0; i < items.count; i++) {
            FHMineFavoriteItemView *view = items[i];
            [self.bgView addSubview:view];
            
            NSInteger column = i % eachRowCount;
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                if(topView == self.titleLabel){
                    make.top.mas_equalTo(topView.mas_bottom).offset(3);
                }else{
                    make.top.mas_equalTo(topView.mas_bottom).offset(-10);
                }
                make.left.mas_equalTo(self.bgView).offset((width + itemPadding) * column);
                make.width.mas_equalTo(width);
                if(i == items.count - 1){
                    make.bottom.mas_equalTo(self.bgView).offset(-10);
                }
            }];
            
            if(column == eachRowCount - 1){
                topView = view;
            }
        }
    }
}

- (NSString *)getFocusItemTitle:(NSString *)name {
    return [NSString stringWithFormat:@"%@ (*)",name];
}

- (void)updateFocusTitles {
    for (NSInteger i = 0; i < self.items.count; i++) {
        FHMineConfigDataIconOpDataMyIconItemsModel *itemModel = self.model.myIcon.items[i];
        FHMineFavoriteItemView *view = self.items[i];
        view.nameLabel.text = [NSString stringWithFormat:@"%@ (*)",itemModel.title];
    }
}

- (void)setItemTitles:(NSArray *)itemTitles {
    for (NSInteger i = 0; i < self.items.count; i++) {
        FHMineFavoriteItemView *view = self.items[i];
        view.nameLabel.text = itemTitles[i];
    }
}

- (void)setItemTitlesWithItemDic:(NSDictionary *)itemDic {
    for (NSInteger i = 0; i < self.items.count; i++) {
        FHMineConfigDataIconOpDataMyIconItemsModel *itemModel = self.model.myIcon.items[i];
        NSString *key = itemModel.id;
        FHMineFavoriteItemView *view = self.items[i];
        NSInteger num = [itemDic[key] integerValue];
        NSString *numStr = [NSString stringWithFormat:@"%i",[itemDic[key] integerValue]];
        if(num > 99){
            numStr = @"99+";
        }
        view.nameLabel.text = [NSString stringWithFormat:@"%@ (%@)",itemModel.title,numStr];
    }
}

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

- (void)didItemClick:(FHMineConfigDataIconOpDataMyIconItemsModel *)model {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didItemClick:)]) {
        [self.delegate didItemClick:model];
    }
}

@end

