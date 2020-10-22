//
//  FHNeighborhoodDetailOwnerSellHouseCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/14.
//

#import "FHNeighborhoodDetailOwnerSellHouseCollectionCell.h"
#import "FHCommonDefines.h"
#import "ByteDanceKit/ByteDanceKit.h"

@interface FHNeighborhoodDetailOwnerSellHouseCollectionCell ()

@property(nonatomic,strong) UIButton *helpMeSellHouseButton;
@property(nonatomic,strong) UILabel *questionLabel;
@property(nonatomic,strong) UILabel *hintLabel;
@property(nonatomic,copy) NSString *helpMeSellHouseOpenUrl;

@end

@implementation FHNeighborhoodDetailOwnerSellHouseCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if(! data || ![data isKindOfClass:[FHNeighborhoodDetailOwnerSellHouseModel class]]) {
        return CGSizeZero;
    }
    FHNeighborhoodDetailOwnerSellHouseModel *model = (FHNeighborhoodDetailOwnerSellHouseModel *) data;
    
    CGSize questionSize = [model.questionText btd_sizeWithFont:[UIFont themeFontRegular:16] width:width];
    CGSize hintSize = [model.hintText btd_sizeWithFont:[UIFont themeFontRegular:12] width:width];
    
    CGFloat height = 0;
    height += questionSize.height + 10 + hintSize.height + 38 + 10 + 12 ;
    
    return CGSizeMake(width, height);
}

- (void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailOwnerSellHouseModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailOwnerSellHouseModel *model = (FHNeighborhoodDetailOwnerSellHouseModel *) data;
    self.questionLabel.text = model.questionText;
    CGSize questionSize = [self.questionLabel.text btd_sizeWithFont:[UIFont themeFontRegular:16] width:(self.contentView.frame.size.width)];
    [self.questionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(questionSize);
    }];
    self.hintLabel.text = model.hintText;
    CGSize hintSize = [self.hintLabel.text btd_sizeWithFont:[UIFont themeFontRegular:12] width:self.contentView.frame.size.width];
    [self.hintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(hintSize);
    }];
    [_helpMeSellHouseButton setTitle:model.helpMeSellHouseText forState:UIControlStateNormal];
    [_helpMeSellHouseButton setTitle:model.helpMeSellHouseText forState:UIControlStateHighlighted];
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
    WeakSelf;
    [_helpMeSellHouseButton btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
        if (wself.sellHouseButtonClickBlock) {
            wself.sellHouseButtonClickBlock();
        }
    }];
}

@end

@implementation FHNeighborhoodDetailOwnerSellHouseModel



@end
