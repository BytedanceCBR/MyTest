//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHArticleMultiImageCell.h"
#import "FHArticleCellBottomView.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "TTImageView+TrafficSave.h"

#define maxLines 3
#define bottomViewHeight 39
#define guideViewHeight 27
#define topMargin 15

#define leftMargin 20
#define rightMargin 20
#define imagePadding 4

@interface FHArticleMultiImageCell ()

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) NSMutableArray *imageViewList;
@property(nonatomic ,strong) UIView *imageViewContainer;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
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
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentLabel];
    
    self.imageViewContainer = [[UIView alloc] init];
    [self.contentView addSubview:_imageViewContainer];
    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) wself = self;
    _bottomView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    
    for (NSInteger i = 0; i < 3; i++) {
        TTImageView *imageView = [[TTImageView alloc] initWithFrame:CGRectZero];
        imageView.clipsToBounds = YES;
        imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
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
        make.top.mas_equalTo(self.contentView).offset(topMargin);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.imageViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.height.mas_equalTo(self.imageHeight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageViewContainer.mas_bottom).offset(10);
        make.height.mas_equalTo(bottomViewHeight);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
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
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.cellModel= cellModel;
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.title)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    self.bottomView.cellModel = cellModel;
    self.bottomView.descLabel.attributedText = cellModel.desc;
    
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.bottomView.position.text = cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
    //图片
    NSArray *imageList = cellModel.imageList;
    for (NSInteger i = 0; i < self.imageViewList.count; i++) {
        TTImageView *imageView = self.imageViewList[i];
        if(i < imageList.count){
            FHFeedContentImageListModel *imageModel = imageList[i];
            imageView.hidden = NO;
            if (imageModel && imageModel.url.length > 0) {
                TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:imageModel];
                __weak typeof(imageView) wImageView = imageView;
                [imageView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
                    [wImageView setImage:nil];
                }];
            }
        }else{
            imageView.hidden = YES;
        }
    }
    
    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + + bottomViewHeight + topMargin + 20;
        
        CGFloat imageViewHeight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin - imagePadding * 2)/3 * 82.0f/109.0f;
        height += imageViewHeight;
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        
        return height;
    }
    return 44;
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(bottomViewHeight + guideViewHeight);
        }];
    }else{
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(bottomViewHeight);
        }];
    }
}

- (void)closeGuideView {
    self.cellModel.isInsertGuideCell = NO;
    [self.cellModel.tableView beginUpdates];
    
    [self showGuideView];
    self.bottomView.cellModel = self.cellModel;
    
    [self setNeedsUpdateConstraints];
    
    [self.cellModel.tableView endUpdates];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeFeedGuide:)]){
        [self.delegate closeFeedGuide:self.cellModel];
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

