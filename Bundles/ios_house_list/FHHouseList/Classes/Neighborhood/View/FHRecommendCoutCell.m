//
//  FHRecommendCoutCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/5/6.
//

#import "FHRecommendCoutCell.h"
#import "FHHouseListBaseItemModel.h"
#import <Masonry/Masonry.h>
#import <YYText/YYLabel.h>
#import "UIColor+Theme.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseListBaseItemCell.h"

@interface FHRecommendCoutCell()

@property(nonatomic, strong) FHRecommendCoutItem *data;

@property(nonatomic, strong) UILabel *mainTitleLabel; //主title lable
@property(nonatomic, strong) UILabel *subTitleLabel; // sub title lable
@property(nonatomic, strong) YYLabel *tagInformation; //新房状态信息
@property(nonatomic, strong) UIImageView *houseImage;
@property(nonatomic, strong) UILabel *pricePerSqmLabel; // 价格/平米
@property(nonatomic, strong) UIView *containerView;

@end

@implementation FHRecommendCoutCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)initUI
{
    self.containerView = [[UIView alloc] init];
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
        make.height.mas_equalTo(104);
    }];
    
    self.houseImage = [[UIImageView alloc] init];
    self.houseImage.layer.cornerRadius = 4;
    self.houseImage.layer.masksToBounds = YES;
    [self.containerView addSubview:_houseImage];
    [self.houseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(12);
        make.width.mas_equalTo(106);
        make.height.mas_equalTo(80);
    }];
    
    self.mainTitleLabel = [[UILabel alloc] init];
    self.mainTitleLabel.textColor = [UIColor themeGray1];
    self.mainTitleLabel.font = [UIFont themeFontMedium:16];
    [self.mainTitleLabel sizeToFit];
    [self.containerView addSubview:_mainTitleLabel];
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.houseImage.mas_right).offset(12);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(22);
    }];
    
    self.pricePerSqmLabel = [[UILabel alloc] init];
    self.pricePerSqmLabel.textColor = [UIColor themeOrange1];
    self.pricePerSqmLabel.font = [UIFont themeFontMedium:16];
    [self.pricePerSqmLabel sizeToFit];
    [self.containerView addSubview:_pricePerSqmLabel];
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(22);
    }];
    
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.textColor = [UIColor themeGray1];
    self.subTitleLabel.font = [UIFont themeFontRegular:12];
    [self.containerView addSubview:_subTitleLabel];
    [self.subTitleLabel sizeToFit];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.pricePerSqmLabel.mas_bottom).offset(1);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(17);
    }];
    
    self.tagInformation = [[YYLabel alloc] init];
    self.tagInformation.font = [UIFont themeFontRegular:12];
    self.tagInformation.textColor = [UIColor themeOrange1];
    [self.containerView addSubview:_tagInformation];
    [self.tagInformation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(7);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(12);
    }];
}

- (void)refreshWithData:(id)data
{
    self.data = data;
    FHHouseListBaseItemModel *model = self.data.item;
    FHImageModel *imageModel = model.houseImage.firstObject;
    [self.houseImage bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed:@"default_image"]];
    self.mainTitleLabel.text = model.title;
    //self.pricePerSqmLabel.text = model.pricePerSqm;
    self.subTitleLabel.text = model.displaySubtitle;
    if (model.originPrice) {
        self.pricePerSqmLabel.attributedText = [self originPriceAttr:model.originPrice];
    }else{
        self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc]initWithString:model.displayPricePerSqm attributes:@{}];
    }
    if (model.reasonTags.count>0) {
        self.tagInformation.attributedText = model.recommendReasonStr;
    }else {
        self.tagInformation.attributedText = model.tagString;
    }
}

- (NSAttributedString *)originPriceAttr:(NSString *)originPrice {
    
    if (originPrice.length < 1) {
        return nil;
    }
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:originPrice];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, originPrice.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:[UIColor themeGray1] range:NSMakeRange(0, originPrice.length)];
    return attri;
}

@end

@implementation FHRecommendCoutItem


@end
