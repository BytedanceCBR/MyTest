//
//  FHOldDetailOwnerSellHouseCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHOldDetailOwnerSellHouseCell.h"


@interface FHOldDetailOwnerSellHouseCell ()
@property(nonatomic,strong) UIButton *helpMeSellHouseButton;

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
    _helpMeSellHouseButton = [[UIButton alloc] init];
    _helpMeSellHouseButton.layer.borderWidth = 0.5;
    _helpMeSellHouseButton.layer.borderColor = [UIColor themeGray1].CGColor;
    _helpMeSellHouseButton.layer.cornerRadius = 19;
    _helpMeSellHouseButton.backgroundColor = [UIColor themeGray7];
    _helpMeSellHouseButton.titleLabel.font = [UIFont themeFontRegular:16];
    _helpMeSellHouseButton.titleEdgeInsets = UIEdgeInsetsMake(8, 59, 8, 59);
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
    [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateHighlighted];
    [self.contentView addSubview:_helpMeSellHouseButton];
    [_helpMeSellHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(182);
        make.height.mas_equalTo(38);
        make.top.equalTo(self.contentView).offset(59);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
    [_helpMeSellHouseButton addTarget:self action:@selector(jumpToOwnerSellHouse) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)jumpToOwnerSellHouse {
    NSDictionary *dict = @{}.mutableCopy;
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://house_sale_input"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}



@end

@implementation FHOldDetailOwnerSellHouseModel


@end
