//
//  FHOldDetailOwnerSellHouseCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHOldDetailOwnerSellHouseCell.h"


@interface FHOldDetailOwnerSellHouseCell ()
@property(nonatomic,strong) UIButton *helpMeSellHouseButton;
@property(nonatomic,strong) UILabel *questionLabel;
@property(nonatomic,strong) UILabel *HintLabel;
@end

@implementation FHOldDetailOwnerSellHouseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    _questionLabel = [[UILabel alloc] init];
    _questionLabel.text = @"要卖房吗？安心无忧委托";
    _questionLabel.font = [UIFont themeFontRegular:16];
    _questionLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_questionLabel];

    _HintLabel = [[UILabel alloc] init];
    _HintLabel.text = @"在线委托，专属顾问全程贴心一条龙服务";
    _HintLabel.font = [UIFont themeFontRegular:12];
    _HintLabel.textColor = [UIColor themeGray2];
    [self.contentView addSubview:_HintLabel];

    _helpMeSellHouseButton = [[UIButton alloc] init];
    _helpMeSellHouseButton.layer.borderWidth = 0.5;
    _helpMeSellHouseButton.layer.borderColor = [UIColor themeGray1].CGColor;
    _helpMeSellHouseButton.layer.cornerRadius = 19;
    _helpMeSellHouseButton.backgroundColor = [UIColor themeGray7];
    _helpMeSellHouseButton.titleLabel.font = [UIFont themeFontRegular:16];
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
    [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateHighlighted];
    [self.contentView addSubview:_helpMeSellHouseButton];
    
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(176);
        make.height.mas_equalTo(22);
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
    }];
    
    [_HintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(216);
        make.height.mas_equalTo(17);
        make.top.equalTo(self.questionLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView);
    }];

    [_helpMeSellHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(182);
        make.height.mas_equalTo(38);
        make.top.equalTo(self.HintLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
    [_helpMeSellHouseButton addTarget:self action:@selector(jumpToOwnerSellHouse) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)jumpToOwnerSellHouse {
    NSDictionary *dict = @{}.mutableCopy;
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://house_sale_input?neighbourhood_id=6697827211568742659&neighbourhood_name=%e8%8a%8d%e8%8d%af%e5%b1%85&report_params=%7b%22enter_from%22%3a%22old_detail%22%2c%22element_from%22%3a%22driving_sale_house%22%7d"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}



@end

@implementation FHOldDetailOwnerSellHouseModel


@end
