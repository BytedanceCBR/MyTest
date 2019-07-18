//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCSingleImageCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 3

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20

@interface FHUGCSingleImageCell ()<TTUGCAttributedLabelDelegate>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) CGFloat imageViewheight;

@end

@implementation FHUGCSingleImageCell

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
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:1];
    _multiImageView.fixedSingleImage = YES;
    [self.contentView addSubview:_multiImageView];
    self.imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.multiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(self.imageViewheight);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.multiImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(49);
        make.left.right.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        //设置userInfo
        self.userInfoView.cellModel = cellModel;
        self.userInfoView.userName.text = cellModel.user.name;
        self.userInfoView.descLabel.attributedText = cellModel.desc;
        [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
        //设置底部
        self.bottomView.cellModel = cellModel;
        
        BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
        self.bottomView.position.text = cellModel.community.name;
        [self.bottomView showPositionView:showCommunity];
        
        NSInteger commentCount = [cellModel.commentCount integerValue];
        if(commentCount == 0){
            [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
        }else{
            [self.bottomView.commentBtn setTitle:cellModel.commentCount forState:UIControlStateNormal];
        }
        [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
        //内容
        if(isEmptyString(cellModel.content)){
            self.contentLabel.hidden = YES;
            [self.multiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
                make.left.mas_equalTo(self.contentView).offset(leftMargin);
                make.right.mas_equalTo(self.contentView).offset(-rightMargin);
                make.height.mas_equalTo(self.imageViewheight);
            }];
        }else{
            self.contentLabel.hidden = NO;
            [self.multiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
                make.left.mas_equalTo(self.contentView).offset(leftMargin);
                make.right.mas_equalTo(self.contentView).offset(-rightMargin);
                make.height.mas_equalTo(self.imageViewheight);
            }];
            [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
        }
        //图片
        [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
        
        [self showGuideView];
    }
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 30;
        
        if(isEmptyString(cellModel.content)){
            height -= 10;
        }
        
        CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:1 width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
        height += imageViewheight;
        
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
            make.height.mas_equalTo(66);
        }];
    }else{
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(49);
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

#pragma mark - TTUGCAttributedLabelDelegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if([url.absoluteString isEqualToString:defaultTruncationLinkURLString]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(lookAllLinkClicked:cell:)]){
            [self.delegate lookAllLinkClicked:self.cellModel cell:self];
        }
    }
}

@end

