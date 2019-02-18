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

@end

@implementation FHMineFocusCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self initViews];
        [self initConstraints];
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
                make.bottom.mas_equalTo(self.contentView);
            }];
        }
    }
}

@end
