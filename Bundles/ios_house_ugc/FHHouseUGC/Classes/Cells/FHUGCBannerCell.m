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
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(58);
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
//        FHFeedUGCCellImageListModel *imageModel = [cellModel.imageList firstObject];
//        if(imageModel){
            [self.bannerImageView bd_setImageWithURL:[NSURL URLWithString:@"http://t11.baidu.com/it/u=1311525232,1138951251&fm=175&app=25&f=JPEG?w=640&h=400&s=F69B15C594B265961C3465270300D043"] placeholder:nil];
//        }
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
