//
//  FHUGCBannerCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/18.
//

#import "FHUGCBannerCell.h"
#import "FHArticleCellBottomView.h"
#import "UIImageView+BDWebImage.h"

#define topMargin 20

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
    self.imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
    
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(topMargin);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(self.imageWidth);
        make.height.mas_equalTo(self.imageWidth * 58.0/335.0);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bannerImageView.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self.contentView);
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
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.cellModel = cellModel;
    //图片
    FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
    if(imageModel){
        [self.bannerImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
    }
}

+ (CGFloat)heightForData:(id)data {
    CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width - 40;
    CGFloat imageHeight = imageWidth * 58.0/335.0;
    CGFloat height = imageHeight + topMargin + 25;
    
    return height;
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
