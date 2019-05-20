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

#define itemPadding 10

@interface FHMineMutiItemCell()

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UIImageView* headerView;
@property(nonatomic, strong) UIView* bgView;
@property(nonatomic, strong) NSMutableArray<FHMineFavoriteItemView *> *focusItems;

@end

@implementation FHMineMutiItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.focusItems = [NSMutableArray array];
        
        [self initViews];
        [self initConstraints];
        [self initDefaultItems];
    }
    return self;
}

- (void)initViews {
    self.headerView = [[UIImageView alloc] init];
    UIImage *image = [self ct_imageFromImage:[UIImage imageNamed:@"fh_mine_header_bg"] inRect:CGRectMake(0, 138, [UIScreen mainScreen].bounds.size.width, 32)];
    _headerView.image = image;
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
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
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

- (void)updateCell:(NSDictionary *)dic
{
    if(dic[@"name"] && ![dic[@"name"] isEqualToString:@""]){
        self.titleLabel.text = dic[@"name"];
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
}

- (void)initDefaultItems {
    __weak typeof(self) wself = self;
    [self.focusItems removeAllObjects];
    NSArray *typeArray = @[@(FHHouseTypeSecondHandHouse),@(FHHouseTypeRentHouse),@(FHHouseTypeNewHouse),@(FHHouseTypeNeighborhood)];
    NSArray *nameArray = @[@"二手房",@"租房",@"新房",@"小区"];
    NSArray *imageNameArray = @[@"icon-ershoufang",@"icon-zufang",@"icon-xinfang",@"icon-xiaoqu"];

    for (NSInteger i = 0; i < typeArray.count; i++) {
        NSInteger type = [typeArray[i] integerValue];
        NSString *title = [NSString stringWithFormat:@"%@ (*)",nameArray[i]];
        FHMineFavoriteItemView *view = [[FHMineFavoriteItemView alloc] initWithName:title imageName:imageNameArray[i]];
        view.focusClickBlock = ^{
            [wself goToFocusDetail:type];
        };
        [self.focusItems addObject:view];
    }
    [self setItems:self.focusItems];
}

- (void)setItems:(NSArray<FHMineFavoriteItemView *> *)items
{
    for (UIView *view in self.bgView.subviews) {
        if([view isKindOfClass:[FHMineFavoriteItemView class]]){
            [view removeFromSuperview];
        }
    }
    
    if(items.count > 0){
        CGFloat width = (UIScreen.mainScreen.bounds.size.width - 40 - (items.count - 1) * itemPadding) / items.count;
        
        for (NSInteger i = 0; i < items.count; i++) {
            FHMineFavoriteItemView *view = items[i];
            [self.bgView addSubview:view];
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
                make.left.mas_equalTo(self.bgView).offset((width + itemPadding) * i);
                make.width.mas_equalTo(width);
                make.bottom.mas_equalTo(self.bgView).offset(-10);
            }];
        }
    }
}

- (void)setItemTitles:(NSArray *)itemTitles {
    for (NSInteger i = 0; i < self.focusItems.count; i++) {
        FHMineFavoriteItemView *view = self.focusItems[i];
        view.nameLabel.text = itemTitles[i];
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

- (void)goToFocusDetail:(FHHouseType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goToFocusDetail:)]) {
        [self.delegate goToFocusDetail:type];
    }
}

@end

