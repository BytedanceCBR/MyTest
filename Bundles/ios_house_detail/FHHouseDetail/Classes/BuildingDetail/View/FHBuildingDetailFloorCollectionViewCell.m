//
//  FHBuildingDetailFloorCollectionViewCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailFloorCollectionViewCell.h"
#import "FHBuildingDetailModel.h"
#import "FHDetailTagBackgroundView.h"
#import <BDWebImage/BDWebImage.h>

@interface FHBuildingDetailFloorCollectionViewCell ()
@property (nonatomic , strong) UIImageView *coverImageView;
@property (nonatomic , strong) UILabel *nameLabel;
@property (nonatomic , strong) UILabel *roomSpaceLabel;
@property (nonatomic , strong) UILabel *priceLabel;
@property (nonatomic, strong) FHDetailTagBackgroundView        *tagBacView;

@end

@implementation FHBuildingDetailFloorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.image = [UIImage imageNamed:@"default_image"];
        self.coverImageView.layer.borderColor = RGB(0xed, 0xed, 0xed).CGColor;
        self.coverImageView.layer.borderWidth = 1;
        self.coverImageView.layer.cornerRadius = 8;
        self.coverImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.coverImageView];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.size.mas_equalTo(CGSizeMake(66, 66));
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont themeFontSemibold:16];
        self.nameLabel.textColor = RGB(0x4a, 0x4a, 0x4a);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.nameLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.coverImageView.mas_right).offset(13);
            make.top.mas_equalTo(self.coverImageView.mas_top);
            make.height.mas_equalTo(19);
        }];
        
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.font = [UIFont themeFontSemibold:16];
        self.priceLabel.textColor = [UIColor themeOrange1];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.priceLabel];
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-16);
            make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
            make.height.mas_equalTo(self.nameLabel.mas_height);
            make.left.mas_equalTo(self.nameLabel.mas_right);
        }];
        
        self.roomSpaceLabel = [[UILabel alloc] init];
        self.roomSpaceLabel.font = [UIFont themeFontRegular:12];
        self.roomSpaceLabel.textColor = [UIColor themeGray3];
        self.roomSpaceLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.roomSpaceLabel];
        [self.roomSpaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(14);
        }];
        
        self.tagBacView = [[FHDetailTagBackgroundView alloc] initWithLabelHeight:16.0 withCornerRadius:2.0];
        [self.tagBacView setMarginWithTagMargin:4.0 withInsideMargin:4.0];
        self.tagBacView.textFont = [UIFont themeFontMedium:10.0];
        [self.contentView addSubview:self.tagBacView];
        [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.right.mas_equalTo(-16);
            make.height.mas_equalTo(16);
            make.bottom.mas_equalTo(self.coverImageView.mas_bottom);
        }];
        
        self.bottomLine = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomLine];
        self.bottomLine.backgroundColor =  RGB(0xe7, 0xe7, 0xe7);
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make){
            make.left.mas_equalTo(self.coverImageView.mas_left);
            make.right.mas_equalTo(self.priceLabel.mas_right);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingDetailRelatedFloorpanModel class]]) {
        FHBuildingDetailRelatedFloorpanModel *model = (FHBuildingDetailRelatedFloorpanModel *)data;
        [self.tagBacView removeAllTag];
        self.nameLabel.text = model.title;
        self.priceLabel.text = model.pricing;
        if ([model.squaremeter isKindOfClass:[NSString class]]) {
            if (model.squaremeter.length > 0) {
                NSString *roomSpace = [NSString stringWithFormat:@"建面 %@",model.squaremeter];
                if (model.facingDirection.length > 0) {
                    self.roomSpaceLabel.text = [NSString stringWithFormat:@"%@ | %@", roomSpace, model.facingDirection];
                } else {
                    self.roomSpaceLabel.text = roomSpace;
                }
            } else if (model.facingDirection.length > 0) {
                self.roomSpaceLabel.text = model.facingDirection;
            } else {
                self.roomSpaceLabel.text = @"";
            }
        }else {
            self.roomSpaceLabel.text = @"";
        }
        
        if ([model.images.firstObject isKindOfClass:[FHImageModel class]]) {
            FHImageModel *imageModel = (FHImageModel *)model.images.firstObject;
            if (imageModel.url) {
                NSURL *urlImage = [NSURL URLWithString:imageModel.url];
                if ([urlImage isKindOfClass:[NSURL class]]) {
                    [self.coverImageView bd_setImageWithURL:urlImage placeholder:[UIImage imageNamed:@"default_image"]];
                }else {
                    self.coverImageView.image = [UIImage imageNamed:@"default_image"];
                }
            }
        }
        
        [self.tagBacView refreshWithTags:model.tags withNum:model.tags.count withMaxLen:CGRectGetWidth(self.contentView.bounds) - 16 - 66 - 13 - 16];
    }
    
}

@end
