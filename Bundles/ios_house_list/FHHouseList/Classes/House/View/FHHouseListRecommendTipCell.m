//
//  FHHouseListRecommendTipCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/11/12.
//

#import "FHHouseListRecommendTipCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHSearchHouseModel.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "NSAttributedString+YYText.h"
#import "YYLabel.h"
#import "TTroute.h"

@interface FHHouseListRecommendTipCell ()

@property (nonatomic, strong) YYLabel *noDataTipLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation FHHouseListRecommendTipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.noDataTipLabel = [[YYLabel alloc] init];
        [self.contentView addSubview:self.noDataTipLabel];
        [self.contentView addSubview:self.leftLine];
        [self.contentView addSubview:self.rightLine];
        [self initConstraints];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)refreshWithData:(id)data houseType:(NSInteger)houseType
{
    if ([data isKindOfClass:[FHSearchGuessYouWantTipsModel class]]) {
        FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)data;
        if(model.content){
            model.text = model.content;
        }
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:model.text];
        NSDictionary *commonTextStyle = @{ NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        [attrText yy_setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrText.length)];
        if(model.content){
            NSRange tapRange = [attrText.string rangeOfString:model.emphasisContent];
            [attrText yy_setTextHighlightRange:tapRange color:[UIColor colorWithHexStr:@"#fe5500"] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                NSMutableDictionary *infos = [NSMutableDictionary new];
                NSMutableDictionary *tracer = [NSMutableDictionary new];
                tracer[@"element_from"] = houseType == FHHouseTypeNewHouse ? @"channel_switch_new_result" : @"channel_switch_old_result";
                tracer[@"enter_from"] = houseType == FHHouseTypeNewHouse ? @"new_list" : @"old_list";
                tracer[@"enter_type"] = @"click";
                tracer[@"origin_from"] = @"maintab_search";
                infos[@"tracer"] = tracer;
                TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:model.realSearchOpenUrl] userInfo:userInfo];
            }];
        }
        self.noDataTipLabel.attributedText = attrText;
    }
}

- (NSString *)elementFromNameByhouseType:(NSInteger)houseType{
    if(houseType == FHHouseTypeNewHouse){
        return @"channel_switch_new_result";
    }else if(houseType == FHHouseTypeSecondHandHouse){
        return @"channel_switch_old_result";
    }else if(houseType == FHHouseTypeRentHouse){
        return  @"channel_switch_renting_result";
    }else if(houseType == FHHouseTypeNeighborhood){
        return  @"channel_switch_neighborhood_result";
    }
    return @"be_null";
}

+ (CGFloat)heightForData:(id)data
{
    return 60;
}

- (void)initConstraints {
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(1);
        make.width.mas_greaterThanOrEqualTo(30);
    }];
    [self.noDataTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 90);
        make.height.mas_equalTo(20);
    }];
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.leftLine);
    }];
}

- (UIView *)leftLine
{
    if (!_leftLine) {
        _leftLine = [[UIView alloc]init];
        _leftLine.backgroundColor = [UIColor themeGray6];
    }
    return _leftLine;
}

- (UIView *)rightLine
{
    if (!_rightLine) {
        _rightLine = [[UIView alloc]init];
        _rightLine.backgroundColor = [UIColor themeGray6];
    }
    return _rightLine;
}

@end
