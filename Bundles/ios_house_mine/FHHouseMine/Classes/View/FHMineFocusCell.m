//
//  FHMineFocusCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineFocusCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"

@interface FHMineFocusCell()

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) NSMutableArray<FHMineFavoriteItemView *> *focusItems;

@end

@implementation FHMineFocusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.focusItems = [NSMutableArray array];
        
        [self initViews];
        [self initConstraints];
        [self initDefaultItems];
    }
    return self;
}

- (void)initViews
{
    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:16] textColor:[UIColor themeBlack]];
    [self.contentView addSubview:_titleLabel];
}

- (void)initConstraints
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(22);
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
    self.titleLabel.text = dic[@"name"];
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
    for (UIView *view in self.contentView.subviews) {
        if([view isKindOfClass:[FHMineFavoriteItemView class]]){
            [view removeFromSuperview];
        }
    }
    
    if(items.count > 0){
        CGFloat width = UIScreen.mainScreen.bounds.size.width / items.count;
        
        for (NSInteger i = 0; i < items.count; i++) {
            FHMineFavoriteItemView *view = items[i];
            [self.contentView addSubview:view];
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titleLabel.mas_bottom);
                make.left.mas_equalTo(self.contentView).offset(width * i);
                make.width.mas_equalTo(width);
                make.bottom.mas_equalTo(self.contentView).offset(-5);
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

- (void)goToFocusDetail:(FHHouseType)type {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goToFocusDetail:)]) {
        [self.delegate goToFocusDetail:type];
    }
}

@end
