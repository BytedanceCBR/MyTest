//
//  FHMainOldTopCell.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainOldTopCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHHouseBase/FHConfigModel.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <Masonry/Masonry.h>

#define TITLE_HOR_MARGIN 10
#define TITLE_TOP_MARGIN 14
#define TITLE_VER_PADDING 3

@interface FHMainOldTopCell ()

@property(nonatomic , strong) UIImageView *bgView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *subtitleLabel;

@end

@implementation FHMainOldTopCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:15];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontLight:12];
        _subtitleLabel.textColor = RGB(0xff, 0xec, 0xcb);
        
        [self.contentView addSubview:_bgView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subtitleLabel];
        
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.bottom.mas_equalTo(self);
        }];
        
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(TITLE_HOR_MARGIN);
            make.right.mas_equalTo(self).offset(-TITLE_HOR_MARGIN);
            make.top.mas_equalTo(TITLE_TOP_MARGIN);
            make.height.mas_equalTo(18);
        }];
        
        [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel);
            make.right.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(TITLE_VER_PADDING);
        }];
        
    }
    return self;
}

-(void)updateWithModel:(FHConfigDataOpData2ItemsModel *)model
{
    _titleLabel.text = model.title;
    _subtitleLabel.text = model.descriptionStr;
    
    FHConfigDataOpData2ItemsImageModel *img = [model.image firstObject];
    [_bgView bd_setImageWithURL:[NSURL URLWithString:img.url] placeholder:[UIImage imageNamed:@"house_cell_placeholder"]];
    
}

@end
