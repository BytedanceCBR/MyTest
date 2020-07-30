//
//  FHNeighbourhoodCommentCell.m
//  Pods
//
//  Created by wangzhizhou on 2020/2/24.
//

#import "FHNeighbourhoodCommentCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIViewAdditions.h"

#define maxLines 3
#define vGap 10
#define userInfoViewHeight 40
#define bottomViewHeight 49

#define minImageCount 1
#define maxImageCount 3

@interface FHNeighbourhoodCommentCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) UIView *contentContainer;
@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat imageViewheight;

@end

@implementation FHNeighbourhoodCommentCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    // Cell本身配置
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // 背景容器
    self.contentContainer = [UIView new];
    self.contentContainer.backgroundColor = [UIColor themeWhite];
    [self.contentView addSubview:self.contentContainer];

    // 用户信息区
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentContainer addSubview:self.userInfoView];
    
    // 文本区
    self.contentLabel = [TTUGCAsyncLabel new];
    self.contentLabel.numberOfLines = maxLines;
    self.contentLabel.layer.masksToBounds = YES;
    self.contentLabel.backgroundColor = [UIColor whiteColor];
    self.contentLabel.delegate = self;
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

+ (CGFloat)heightForData:(id)data {
    
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat leftMargin = 0;
        CGFloat rightMargin = 0;
        CGFloat topMargin = 0;
        
        CGFloat leftPadding = 16;
        CGFloat rightPadding = 16;
        CGFloat topPadding = 20;
        
        if(cellModel.isInNeighbourhoodCommentsList) {
            topMargin = 15;
            leftMargin = 15;
            rightMargin = 15;
            
            leftPadding = 20;
            rightPadding = 20;
        }
        
        BOOL isContentEmpty = isEmptyString(cellModel.content);
        
        CGFloat height = topMargin + topPadding + userInfoViewHeight;
        height += isContentEmpty ? 0 : vGap;
        height += (isContentEmpty ? 0 : cellModel.contentHeight);
        height += vGap;
        if(cellModel.imageList.count > 0) {
            NSInteger count = (cellModel.imageList.count == 1) ? 1 : 3;
            CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:count width:[UIScreen mainScreen].bounds.size.width - leftMargin - leftPadding - rightMargin - rightPadding];
            height += imageViewheight;
            
            if(cellModel.isInNeighbourhoodCommentsList){
                height += vGap;
            }
        }
        
        if(cellModel.isInNeighbourhoodCommentsList){
            height += vGap;
        }
//        height += bottomViewHeight;

        return height;
    }
    return 44;
}

- (void)layoutViews {
    
    CGFloat leftMargin = 0;
    CGFloat rightMargin = 0;
    CGFloat topMargin = 0;
    
    CGFloat leftPadding = 16;
    CGFloat rightPadding = 16;
    CGFloat topPadding = 20;
    
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width - 30;
    if(self.cellModel.isInNeighbourhoodCommentsList) {
        topMargin = 15;
        leftMargin = 15;
        rightMargin = 15;
        
        leftPadding = 20;
        rightPadding = 20;
        
        cellWidth = [UIScreen mainScreen].bounds.size.width;
    }

    CGFloat cellHeight = [self.class heightForData:self.cellModel];
    
    self.contentContainer.frame = CGRectMake(leftMargin, topMargin, cellWidth - leftMargin - rightMargin, cellHeight - topMargin);
    
    if(self.cellModel.isInNeighbourhoodCommentsList) {
        self.contentContainer.layer.masksToBounds = YES;
        self.contentContainer.layer.cornerRadius = 10;
    };
    
    // 用户信息
    self.userInfoView.frame = CGRectMake(0, topPadding, self.contentContainer.width, userInfoViewHeight);
    //设置userInfo
//    self.userInfoView.cellModel = self.cellModel;
//    self.userInfoView.userName.text = self.cellModel.user.name;
    self.userInfoView.userAuthLabel.text = self.cellModel.user.userAuthInfo;
//    [self.userInfoView updateDescLabel];
//    [self.userInfoView updateEditState];
//    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:self.cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    
    [self.userInfoView refreshWithData:self.cellModel];
    
    self.userInfoView.moreBtn.hidden = YES;
    
    // 文本内容标签
    self.contentLabel.frame = CGRectMake(leftPadding, self.userInfoView.bottom + vGap, self.contentContainer.width - leftPadding - rightPadding, 0);
    self.contentLabel.numberOfLines = self.cellModel.numberOfLines;
    BOOL isContentEmpty = isEmptyString(self.cellModel.content);
    self.contentLabel.hidden = isContentEmpty;
    self.contentLabel.height = isContentEmpty ? 0 : self.cellModel.contentHeight;
    [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:self.cellModel ];
    
    // 设置图片
    CGFloat imageViewTop = isContentEmpty ? (self.userInfoView.bottom + vGap) : self.userInfoView.bottom + vGap + self.cellModel.contentHeight + vGap;
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
    
    if(self.cellModel.isStick && self.cellModel.stickStyle == FHFeedContentStickStyleGood) {
        if(self.cellModel.isInNeighbourhoodCommentsList){
            self.decorationImageView.frame = CGRectMake(cellWidth - rightMargin - 66, topMargin, 66, 66);
            [self.decorationImageView setImage:[UIImage imageNamed:@"fh_ugc_wenda_essence"]];
        }else{
            self.decorationImageView.width = 44;
            self.decorationImageView.height = 44;
            self.decorationImageView.centerY = self.userInfoView.centerY;
            self.decorationImageView.right = self.userInfoView.right - 20;
            [self.decorationImageView setImage:[UIImage imageNamed:@"fh_ugc_wenda_essence_small"]];
        }
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

// 评论点击
- (void)commentBtnClick {
    if(self.delegate && [self.delegate respondsToSelector:@selector(commentClicked:cell:)]){
        [self.delegate commentClicked:self.cellModel cell:self];
    }
}

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([url.absoluteString isEqualToString:defaultTruncationLinkURLString]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(lookAllLinkClicked:cell:)]){
            [self.delegate lookAllLinkClicked:self.cellModel cell:self];
        }
    } else {
        if (url) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(gotoLinkUrl:url:)]){
                [self.delegate gotoLinkUrl:self.cellModel url:url];
            }
        }
    }
}

@end
