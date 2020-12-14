//
//  FHUGCPostCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/7/6.
//

#import "FHUGCPostCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "FHUGCCellAttachCardView.h"
#import "FHPostLayout.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 46
#define guideViewHeight 17
#define topMargin 20
#define originViewHeight 80
#define attachCardViewHeight 57

@interface FHUGCPostCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellMultiImageView *singleImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,strong) FHUGCCellOriginItemView *originView;
@property(nonatomic ,strong) FHUGCCellAttachCardView *attachCardView;

@end

@implementation FHUGCPostCell

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
}

- (void)initViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    __weak typeof(self) wself = self;
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] init];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:3];
    _multiImageView.hidden = YES;
    [self.contentView addSubview:_multiImageView];
    
    self.singleImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:1];
    _singleImageView.hidden = YES;
    _singleImageView.fixedSingleImage = YES;
    [self.contentView addSubview:_singleImageView];
    
    self.originView = [[FHUGCCellOriginItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, originViewHeight)];
    _originView.hidden = YES;
    _originView.goToLinkBlock = ^(FHFeedUGCCellModel * _Nonnull cellModel, NSURL * _Nonnull url) {
        if(wself.delegate && [wself.delegate respondsToSelector:@selector(gotoLinkUrl:url:)]){
            [wself.delegate gotoLinkUrl:cellModel url:url];
        }
    };
    [self.contentView addSubview:_originView];
    
    self.attachCardView = [[FHUGCCellAttachCardView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, attachCardViewHeight)];
    _attachCardView.hidden = YES;
    [self.contentView addSubview:_attachCardView];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)updateConstraints:(FHBaseLayout *)layout {
    if (![layout isKindOfClass:[FHPostLayout class]]) {
        return;
    }
    
    FHPostLayout *cellLayout = (FHPostLayout *)layout;
    
    [FHLayoutItem updateView:self.userInfoView withLayout:cellLayout.userInfoViewLayout];
    [FHLayoutItem updateView:self.contentLabel withLayout:cellLayout.contentLabelLayout];
    [FHLayoutItem updateView:self.multiImageView withLayout:cellLayout.multiImageViewLayout];
    [FHLayoutItem updateView:self.singleImageView withLayout:cellLayout.singleImageViewLayout];
    [FHLayoutItem updateView:self.bottomView withLayout:cellLayout.bottomViewLayout];
    [FHLayoutItem updateView:self.originView withLayout:cellLayout.originViewLayout];
    [FHLayoutItem updateView:self.attachCardView withLayout:cellLayout.attachCardViewLayout];
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
    
    self.currentData = data;
    self.cellModel = cellModel;
    //设置userInfo
    [self.userInfoView refreshWithData:cellModel];
    //设置底部
    [self.bottomView refreshWithData:cellModel];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    //图片
    if(cellModel.imageList.count > 1){
        self.multiImageView.hidden = NO;
        self.singleImageView.hidden = YES;
        [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else if(cellModel.imageList.count == 1){
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = NO;
        [self.singleImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    }else{
        self.multiImageView.hidden = YES;
        self.singleImageView.hidden = YES;
    }
     //origin
    if(cellModel.originItemModel){
        self.originView.hidden = NO;
        [self.originView refreshWithdata:cellModel];
    }else{
        self.originView.hidden = YES;
    }
    //attach card
    if(cellModel.attachCardInfo){
        self.attachCardView.hidden = NO;
        [self.attachCardView refreshWithdata:cellModel];
    }else{
        self.attachCardView.hidden = YES;
    }

    [self updateConstraints:cellModel.layout];
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
