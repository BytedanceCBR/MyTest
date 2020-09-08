//
//  FHOldDetailOwnerSellHouseCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/9/6.
//

#import "FHOldDetailOwnerSellHouseCell.h"
#import "FHCommonDefines.h"
#import "NSString+BTDAdditions.h"

@interface FHOldDetailOwnerSellHouseCell ()
@property(nonatomic,strong) UIButton *helpMeSellHouseButton;
@property(nonatomic,strong) UILabel *questionLabel;
@property(nonatomic,strong) UILabel *hintLabel;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;
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

-(void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHOldDetailOwnerSellHouseModel class]]) {
        return;
    }
    self.currentData = data;
    FHOldDetailOwnerSellHouseModel *model = (FHOldDetailOwnerSellHouseModel *) data;
    if(model.questionText.length > 0) {
        self.questionLabel.text = model.questionText;
    }else {
        self.questionLabel.text = @"要卖房吗？安心无忧委托";
    }
    CGSize questionSize = [self.questionLabel.text btd_sizeWithFont:[UIFont themeFontRegular:16] width:(SCREEN_WIDTH - 30)];
    [self.questionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(questionSize);
    }];
    if(model.hintText.length > 0) {
        self.hintLabel.text = model.hintText;
    } else {
        self.hintLabel.text = @"在线委托，专属顾问全程贴心一条龙服务";
    }
    CGSize hintSize = [self.hintLabel.text btd_sizeWithFont:[UIFont themeFontRegular:12] width:(SCREEN_WIDTH - 30)];
    [self.hintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(hintSize);
    }];
    if(model.helpMeSellHouseText.length > 0) {
        [_helpMeSellHouseButton setTitle:model.helpMeSellHouseText forState:UIControlStateNormal];
        [_helpMeSellHouseButton setTitle:model.helpMeSellHouseText forState:UIControlStateHighlighted];
    } else {
        [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateNormal];
        [_helpMeSellHouseButton setTitle:@"帮我买房" forState:UIControlStateHighlighted];
    }
    self.helpMeSellHouseOpenUrl = model.helpMeSellHouseOpenUrl;
}

-(void)setupUI {
    _questionLabel = [[UILabel alloc] init];
    _questionLabel.font = [UIFont themeFontRegular:16];
    _questionLabel.textColor = [UIColor themeGray1];
    _questionLabel.numberOfLines = 0;
    [self.contentView addSubview:_questionLabel];

    _hintLabel = [[UILabel alloc] init];
    _hintLabel.font = [UIFont themeFontRegular:12];
    _hintLabel.textColor = [UIColor themeGray2];
    _hintLabel.numberOfLines = 0;
    [self.contentView addSubview:_hintLabel];

    _helpMeSellHouseButton = [[UIButton alloc] init];
    _helpMeSellHouseButton.layer.borderWidth = 0.5;
    _helpMeSellHouseButton.layer.borderColor = [UIColor themeGray1].CGColor;
    _helpMeSellHouseButton.layer.cornerRadius = 19;
    _helpMeSellHouseButton.backgroundColor = [UIColor themeGray7];
    _helpMeSellHouseButton.titleLabel.font = [UIFont themeFontRegular:16];
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_helpMeSellHouseButton];
    
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
    }];
    
    [_hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.questionLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView);
    }];

    [_helpMeSellHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(182);
        make.height.mas_equalTo(38);
        make.top.equalTo(self.hintLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
    [_helpMeSellHouseButton addTarget:self action:@selector(jumpToOwnerSellHouse) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)jumpToOwnerSellHouse {
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSURL *openUrl = [NSURL URLWithString:self.helpMeSellHouseOpenUrl];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
}



@end

@implementation FHOldDetailOwnerSellHouseModel


@end
