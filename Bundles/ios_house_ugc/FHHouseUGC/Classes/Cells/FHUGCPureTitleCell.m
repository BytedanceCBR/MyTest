//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCPureTitleCell.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import <UIImageView+BDWebImage.h>
#import "TTUGCAttributedLabel.h"
#import "FHUGCCellHelper.h"

#define leftMargin 20
#define rightMargin 20
#define maxLines 5

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20

@interface FHUGCPureTitleCell ()<TTUGCAttributedLabelDelegate>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCPureTitleCell

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
    __weak typeof(self) wself = self;
    
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectZero];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)initConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(topMargin);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(userInfoViewHeight);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(bottomViewHeight);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
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
        
        [self.bottomView.commentBtn setTitle:cellModel.commentCount forState:UIControlStateNormal];
        [self.bottomView updateLikeState:cellModel.diggCount userDigg:cellModel.userDigg];
        //内容
        if(isEmptyString(cellModel.content)){
            self.contentLabel.hidden = YES;
        }else{
            self.contentLabel.hidden = NO;
            [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel];
        }
        
        [self showGuideView];
    }
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = cellModel.contentHeight + userInfoViewHeight + bottomViewHeight + topMargin + 20;
        
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
