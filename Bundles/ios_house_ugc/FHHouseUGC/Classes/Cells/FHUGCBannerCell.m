//
//  FHUGCBannerCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/18.
//

#import "FHUGCBannerCell.h"
#import "FHArticleCellBottomView.h"
#import <UIImageView+BDWebImage.h>

@interface FHUGCBannerCell ()

@property(nonatomic ,strong) UIImageView *bannerImageView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic, assign) CGFloat imageWidth;

@end

@implementation FHUGCBannerCell

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

    self.bannerImageView = [[UIImageView alloc] init];
    _bannerImageView.clipsToBounds = YES;
    _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bannerImageView.backgroundColor = [UIColor themeGray6];
    _bannerImageView.layer.masksToBounds = YES;
    _bannerImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_bannerImageView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
//    make.top.left.bottom.mas_equalTo(self);
//    make.width.mas_equalTo(self.imageWidth);
//    make.height.mas_equalTo(self.imageWidth * 251.0f/355.0f);
    self.imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
    
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(self.imageWidth);
        make.height.mas_equalTo(self.imageWidth * 0.5);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bannerImageView.mas_bottom).offset(20);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        //图片
        FHFeedUGCCellImageListModel *imageModel = [cellModel.imageList firstObject];
        if(imageModel){
            CGFloat width = [imageModel.width floatValue];
            CGFloat height = [imageModel.height floatValue];
            [self.bannerImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
            
            [self.bannerImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.imageWidth * height/width);
            }];
        }
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
