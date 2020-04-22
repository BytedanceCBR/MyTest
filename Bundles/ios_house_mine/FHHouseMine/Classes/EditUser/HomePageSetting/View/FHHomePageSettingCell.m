//
//  FHHomePageSettingCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import "FHHomePageSettingCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "FHHomePageSettingItemModel.h"

@interface FHHomePageSettingCell ()

@property(nonatomic ,strong) UILabel *nameLabel;
@property(nonatomic ,strong) UIImageView *checkView;

@end

@implementation FHHomePageSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.nameLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_nameLabel];
    
    self.checkView = [[UIImageView alloc] init];
    _checkView.image = [UIImage imageNamed:@"fh_mine_home_page_normal_orange"];
    [self.contentView addSubview:_checkView];
}

- (void)initConstraints {
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(22);
    }];
    
    [self.checkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(20);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHHomePageSettingItemModel class]]) {
        return;
    }
    
    FHHomePageSettingItemModel *model = (FHHomePageSettingItemModel *)data;
    
    self.nameLabel.text = model.name;
    
    if(model.isSelected){
        self.checkView.image = [UIImage imageNamed:@"fh_mine_home_page_selected_orange"];
    }else{
        self.checkView.image = [UIImage imageNamed:@"fh_mine_home_page_normal_orange"];
    }
}

@end
