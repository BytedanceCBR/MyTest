//
//  FHNeighborhoodDetailPostCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailPostCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIViewAdditions.h"

#define maxLines 3
#define userInfoViewHeight 40

#define minImageCount 1
#define maxImageCount 3

@interface FHNeighborhoodDetailPostCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) UIView *contentContainer;
@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) UIImageView *essenceIcon;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat imageViewheight;

@end

@implementation FHNeighborhoodDetailPostCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    // Cell本身配置
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // 背景容器
    self.contentContainer = [UIView new];
    self.contentContainer.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.contentContainer];
    
    self.essenceIcon = [[UIImageView alloc] init];
    _essenceIcon.image = [UIImage imageNamed:@"fh_ugc_wenda_essence_small"];
    _essenceIcon.hidden = YES;
    [self.contentContainer addSubview:_essenceIcon];

    // 用户信息区
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentContainer addSubview:self.userInfoView];
    
    // 文本区
    self.contentLabel = [TTUGCAsyncLabel new];
    self.contentLabel.numberOfLines = maxLines;
    self.contentLabel.layer.masksToBounds = YES;
    self.contentLabel.delegate = self;
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    [self.contentContainer addSubview:self.contentLabel];
    
    // 图片区
    self.multiImageView = [FHUGCCellMultiImageView new];
    [self.contentContainer addSubview:self.multiImageView];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
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
    self.cellModel = cellModel;
    self.cellModel.isCustomDecorateImageView = YES; // 本地定制装饰图片
    self.currentData = data;

    [self layoutViews];
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHFeedUGCCellModel class]]) {
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat leftMargin = 0;
        CGFloat rightMargin = 0;
        CGFloat topMargin = 0;
        
        CGFloat leftPadding = 16;
        CGFloat rightPadding = 16;
        CGFloat topPadding = 16;
        
        CGFloat elementMargin = 10; //元素之间的间距
        
        BOOL isContentEmpty = isEmptyString(cellModel.content);
        
        CGFloat height = topMargin + topPadding + userInfoViewHeight;
        height += isContentEmpty ? 0 : elementMargin;
        height += (isContentEmpty ? 0 : cellModel.contentHeight);
        if(cellModel.imageList.count > 0) {
            if(cellModel.isInNeighbourhoodCommentsList){
                height += elementMargin;
            }
            NSInteger count = (cellModel.imageList.count == 1) ? 1 : 3;
            CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:count width:[UIScreen mainScreen].bounds.size.width - leftMargin - leftPadding - rightMargin - rightPadding];
            height += imageViewheight;
        }
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)layoutViews {
    
    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;
    CGFloat topMargin = 0;
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 16;
    CGFloat topPadding = 16;//往上10个像素剩余10+6
    
    CGFloat elementMargin = 10; //元素之间的间距
    
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width - 30;
    CGFloat cellHeight = [self.class cellSizeWithData:self.cellModel width:cellWidth].height;
    
    self.contentContainer.frame = CGRectMake(leftMargin, topMargin, cellWidth - leftMargin - rightMargin, cellHeight - topMargin);
    
    // 用户信息
    self.userInfoView.frame = CGRectMake(0, topPadding, self.contentContainer.width, userInfoViewHeight);
    //设置userInfo
    self.userInfoView.userAuthLabel.text = self.cellModel.user.userAuthInfo;
    [self.userInfoView refreshWithData:self.cellModel];
    self.userInfoView.moreBtn.hidden = YES;
    
    // 文本内容标签
    self.contentLabel.frame = CGRectMake(leftPadding, self.userInfoView.bottom + elementMargin, self.contentContainer.width - leftPadding - rightPadding, 0);
    self.contentLabel.numberOfLines = self.cellModel.numberOfLines;
    BOOL isContentEmpty = isEmptyString(self.cellModel.content);
    self.contentLabel.hidden = isContentEmpty;
    self.contentLabel.height = isContentEmpty ? 0 : self.cellModel.contentHeight;
    [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:self.cellModel ];
    
    // 设置图片
    CGFloat imageViewTop = isContentEmpty ? (self.userInfoView.bottom + elementMargin) : self.userInfoView.bottom + elementMargin + self.cellModel.contentHeight + elementMargin;
    NSInteger imageCount = self.cellModel.imageList.count;
    if(imageCount == minImageCount) {
        [self.multiImageView removeFromSuperview];
        self.multiImageView = nil;
        self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(leftPadding, imageViewTop, self.contentContainer.width - leftPadding - rightPadding, 0) count:minImageCount];
        self.multiImageView.fixedSingleImage = YES;
        self.imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:minImageCount width:self.contentContainer.width - leftPadding - rightPadding];
        [self.contentContainer addSubview:self.multiImageView];
    } else if(imageCount > minImageCount) {
        [self.multiImageView removeFromSuperview];
        self.multiImageView = nil;
        self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(leftPadding, imageViewTop, self.contentContainer.width - leftPadding - rightPadding, 0) count:maxImageCount];
        self.multiImageView.fixedSingleImage = NO;
        self.imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:maxImageCount width:self.contentContainer.width - leftPadding - rightPadding];
        [self.contentContainer addSubview:self.multiImageView];
    } else {
        self.imageViewheight = 0;
    }
    // 更新视图布局
    self.multiImageView.height = self.imageViewheight;
    //图片
    [self.multiImageView updateImageView:self.cellModel.imageList largeImageList:self.cellModel.largeImageList];
    
    if(self.cellModel.isStick && (self.cellModel.stickStyle == FHFeedContentStickStyleGood || self.cellModel.stickStyle == FHFeedContentStickStyleTopAndGood)){
        self.essenceIcon.width = 42;
        self.essenceIcon.height = 42;
        self.essenceIcon.centerY = self.userInfoView.centerY;
        self.essenceIcon.right = self.userInfoView.right - 16;
        self.essenceIcon.hidden = NO;
    }else{
        self.essenceIcon.hidden = YES;
    }
}

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([url.absoluteString isEqualToString:defaultTruncationLinkURLString] || url){
        if (self.clickLinkBlock) {
            self.clickLinkBlock(self.currentData, url);
        }
    }
}

@end
