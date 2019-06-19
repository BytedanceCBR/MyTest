//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHArticleMultiImageCell.h"
#import "FHArticleCellBottomView.h"
#import <UIImageView+BDWebImage.h>

#define leftMargin 20
#define rightMargin 20
#define imagePadding 4

@interface FHArticleMultiImageCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) NSMutableArray *imageViewList;
@property(nonatomic ,strong) UIView *imageViewContainer;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,assign) CGFloat imageWidth;
@property(nonatomic ,assign) CGFloat imageHeight;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHArticleMultiImageCell

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
    _imageViewList = [[NSMutableArray alloc] init];
    _imageWidth = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin - imagePadding * 2)/3;
    _imageHeight = _imageWidth * 82.0f/109.0f;
    
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 3;
    [self.contentView addSubview:_contentLabel];
    
    self.imageViewContainer = [[UIView alloc] init];
    [self.contentView addSubview:_imageViewContainer];
    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) wself = self;
    _bottomView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor themeGray6];
        imageView.layer.borderColor = [[UIColor themeGray6] CGColor];
        imageView.layer.borderWidth = 0.5;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 4;
        imageView.hidden = YES;
        [self.contentView addSubview:imageView];
        
        [self.imageViewList addObject:imageView];
    }
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    [self.imageViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.height.mas_equalTo(self.imageHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageViewContainer.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(24);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(10);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
    
    UIView *firstView = self.imageViewContainer;
    for (UIImageView *imageView in self.imageViewList) {
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.imageViewContainer);
            if(firstView == self.imageViewContainer){
                make.left.mas_equalTo(firstView);
            }else{
                make.left.mas_equalTo(firstView.mas_right).offset(imagePadding);
            }
            make.width.mas_equalTo(self.imageWidth);
            make.height.mas_equalTo(self.imageWidth);
        }];
        firstView = imageView;
    }
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
        self.cellModel= cellModel;
        //内容
        self.contentLabel.text = cellModel.title;
        self.bottomView.descLabel.attributedText = cellModel.desc;
        self.bottomView.position.text = @"左家庄";
        //图片
        NSArray *imageList = cellModel.imageList;
        for (NSInteger i = 0; i < self.imageViewList.count; i++) {
            UIImageView *imageView = self.imageViewList[i];
            if(i < imageList.count){
                FHFeedUGCCellImageListModel *imageModel = imageList[i];
                imageView.hidden = NO;
                [imageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
            }else{
                imageView.hidden = YES;
            }
        }
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

@end

