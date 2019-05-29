//
//  FHSuggestionRealHouseTopCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/29.
//

#import "FHSuggestionRealHouseTopCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import <Masonry.h>
#import "FHSugSubscribeModel.h"
#import <FHEnvContext.h>
#import <ToastManager.h>
#import <NSDictionary+TTAdditions.h>

@interface FHSuggestionRealHouseTopCell()
@property (nonatomic, strong)FHSugSubscribeDataDataSubscribeInfoModel *currentModel;
@end

@implementation FHSuggestionRealHouseTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _backImageView = [UIImageView new];
    [self.contentView addSubview:_backImageView];
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 28) / 3;
    
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(101);
        make.bottom.mas_equalTo(self.contentView);
    }];
    
    UIImageView *imageRight = [[UIImageView alloc] init];
    [imageRight setImage:[UIImage imageNamed:@"suglist_subscribe_right"]];
    [_backImageView addSubview:imageRight];
    [imageRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(61);
        make.width.mas_equalTo(166);
        make.bottom.equalTo(self.backImageView).offset(-8);
    }];
    
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(36);
        make.top.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    
    UIView *segementContentView = [UIView new];
    segementContentView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:segementContentView];
    
    [segementContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.bottom.mas_equalTo(-10);
        make.height.mas_equalTo(30);
    }];
    
    _realHouseLabel = [[UILabel alloc] init];
    _realHouseLabel.font = [UIFont themeFontRegular:11];
    _realHouseLabel.textColor = [UIColor themeGray3];
    _realHouseLabel.textAlignment = NSTextAlignmentRight;
    [segementContentView addSubview:_realHouseLabel];
    
    
    [_realHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(segementContentView).offset(10);
        make.centerY.equalTo(segementContentView);
        make.height.mas_equalTo(20);
    }];
    
    _segementLine = [UIView new];
    [_segementLine setBackgroundColor:[UIColor blackColor]];
    [segementContentView addSubview:_segementLine];
    [_segementLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(segementContentView);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(20);
    }];
    
    
    _falseHouseLabel = [[UILabel alloc] init];
    _falseHouseLabel.font = [UIFont themeFontRegular:12];
    _falseHouseLabel.textColor = [UIColor themeGray2];
    _falseHouseLabel.textAlignment = NSTextAlignmentLeft;
    [segementContentView addSubview:_falseHouseLabel];
    [_falseHouseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(segementContentView).offset(-10);
        make.centerY.equalTo(segementContentView);
        make.right.equalTo(segementContentView).offset(-36);
    }];
    
    
    _allWebHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allWebHouseBtn setTitle:@"问号" forState:UIControlStateNormal];
    _allWebHouseBtn.layer.masksToBounds = YES;
    _allWebHouseBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _allWebHouseBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    _allWebHouseBtn.layer.borderWidth = 0.5;
    _allWebHouseBtn.layer.cornerRadius = 10.5;
    [_allWebHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allWebHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [self.contentView addSubview:_allWebHouseBtn];
    

    [_allWebHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.top.equalTo(self.titleLabel);
        make.width.mas_equalTo(52);
        make.height.mas_equalTo(21);
    }];
    
    
    _allFalseHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allFalseHouseBtn setTitle:@"箭头" forState:UIControlStateNormal];
    _allFalseHouseBtn.layer.masksToBounds = YES;
    _allFalseHouseBtn.titleLabel.font = [UIFont themeFontRegular:12];
    _allFalseHouseBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    _allFalseHouseBtn.layer.borderWidth = 0.5;
    _allFalseHouseBtn.layer.cornerRadius = 10.5;
    [_allFalseHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_allFalseHouseBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [segementContentView addSubview:_allFalseHouseBtn];
    
    [_allFalseHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(segementContentView).offset(0);
        make.top.equalTo(segementContentView);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)allWebHouseBtnClick:(UIButton *)button
{
    
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    _allWebHouseBtn.userInteractionEnabled = NO;
    if ([_allWebHouseBtn.titleLabel.text isEqualToString:@"订阅"]) {
        //        [_allWebHouseBtn setTitle:@"已订阅" forState:UIControlStateNormal];
        if(self.addSubscribeAction)
        {
            
            self.addSubscribeAction(self.currentModel.text);
        }
    }else
    {
        if(self.deleteSubscribeAction)
        {
            self.deleteSubscribeAction(self.currentModel.subscribeId);
        }
        //        [_allWebHouseBtn setTitle:@"订阅" forState:UIControlStateNormal];
    }
    [self performSelector:@selector(enabelSubscribBtn) withObject:nil afterDelay:1];
}

#pragma mark -
- (void)subscribeStatusChanged:(NSNotification *)notification {

}

- (void)enabelSubscribBtn
{
    _allWebHouseBtn.userInteractionEnabled = YES;
}

- (void)refreshUI:(JSONModel *)data
{
    if ([data isKindOfClass:[FHSugListRealHouseTopInfoModel class]]) {
        FHSugSubscribeDataDataSubscribeInfoModel *model = (FHSugSubscribeDataDataSubscribeInfoModel *)data;
        self.currentModel = model;
        _titleLabel.text = @"订阅当前搜索条件";
        _realHouseLabel.text = @"新上房源立刻通知";
    }
    
    _titleLabel.text = @"已为您找到50000000套全网房源";
    _realHouseLabel.text = @"幸福里优选好房 400万套";
    _falseHouseLabel.text = @"已过滤虚假房源 100万套";
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
