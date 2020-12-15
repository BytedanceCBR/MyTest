//
//  FHArticleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/7/6.
//

#import "FHArticleCell.h"
#import "FHArticleCellBottomView.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "UIViewAdditions.h"
#import "UIImageView+fhUgcImage.h"
#import "UIFont+House.h"
#import "FHArticleLayout.h"

#define bottomViewHeight 35

@interface FHArticleCell ()

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) NSMutableArray *imageViewList;
@property(nonatomic ,strong) UIView *imageViewContainer;
@property(nonatomic ,strong) UIImageView *singleImageView;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHArticleCell

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
    [self initViews];
}

- (void)initViews {
    self.contentLabel = [[TTUGCAsyncLabel alloc] init];
    _contentLabel.numberOfLines = 3;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.font = [UIFont themeFontMedium:16];
    [self.contentView addSubview:_contentLabel];
    
    //单图
    self.singleImageView = [[UIImageView alloc] init];
    _singleImageView.hidden = YES;
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _singleImageView.backgroundColor = [UIColor themeGray6];
    _singleImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _singleImageView.layer.borderWidth = 0.5;
    _singleImageView.layer.masksToBounds = YES;
    _singleImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_singleImageView];
    
    self.imageViewContainer = [[UIView alloc] init];
    _imageViewContainer.hidden = YES;
    [self.contentView addSubview:_imageViewContainer];
    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    __weak typeof(self) wself = self;
    _bottomView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [self.contentView addSubview:_bottomView];
    
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
        [self.imageViewContainer addSubview:imageView];
        [self.imageViewList addObject:imageView];
    }
}

- (void)updateConstraints:(FHBaseLayout *)layout {
    if (![layout isKindOfClass:[FHArticleLayout class]]) {
        return;
    }
    
    FHArticleLayout *cellLayout = (FHArticleLayout *)layout;
    
    [FHLayoutItem updateView:self.contentLabel withLayout:cellLayout.contentLabelLayout];
    [FHLayoutItem updateView:self.singleImageView withLayout:cellLayout.singleImageViewLayout];
    [FHLayoutItem updateView:self.imageViewContainer withLayout:cellLayout.imageViewContainerLayout];
    [FHLayoutItem updateView:self.bottomView withLayout:cellLayout.bottomViewLayout];
    
    for (NSInteger i = 0; i < self.imageViewList.count; i++) {
        UIImageView *imageView = self.imageViewList[i];
        if(i < cellLayout.imageLayouts.count){
            [FHLayoutItem updateView:imageView withLayout:cellLayout.imageLayouts[i]];
        }
    }
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
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(self.currentData == data && !cellModel.ischanged){
        return;
    }
    self.currentData = data;
    self.cellModel = cellModel;
    //更新布局
    [self updateConstraints:cellModel.layout];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.title)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    
    [self.bottomView refreshWithData:cellModel];
    //图片
    NSArray *imageList = cellModel.imageList;
    if(imageList.count > 1){
        self.imageViewContainer.hidden = NO;
        self.singleImageView.hidden = YES;
        for (NSInteger i = 0; i < self.imageViewList.count; i++) {
            UIImageView *imageView = self.imageViewList[i];
            if(i < imageList.count){
                FHFeedContentImageListModel *imageModel = imageList[i];
                imageView.hidden = NO;
                if (imageModel) {
                    NSArray *urls = [FHUGCCellHelper convertToImageUrls:imageModel];
                    [imageView fh_setImageWithURLs:urls placeholder:nil reSize:imageView.size];
                }
            }else{
                imageView.hidden = YES;
            }
        }
    }else if(imageList.count == 1){
        self.imageViewContainer.hidden = YES;
        self.singleImageView.hidden = NO;
        //图片
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel) {
            NSArray *urls = [FHUGCCellHelper convertToImageUrls:imageModel];
            [self.singleImageView fh_setImageWithURLs:urls placeholder:nil reSize:self.singleImageView.size];
        }
    }else{
        self.imageViewContainer.hidden = YES;
        self.singleImageView.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        return cellModel.layout.height;
    }
    return 44;
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
