//
//  FHUGCVoteDetailCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/11/11.
//

#import "FHUGCVoteDetailCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHCommentBaseDetailViewModel.h"
#import "FHUGCCellOriginItemView.h"
#import "TTRoute.h"
#import <TTBusinessManager+StringUtils.h>
#import <UIViewAdditions.h>

#define leftMargin 20
#define rightMargin 20
#define kFHMaxLines 0

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20
#define originViewHeight 80

@interface FHUGCVoteDetailCell() <TTUGCAttributedLabelDelegate>

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) UILabel *descLabel;// 补充说明
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic, assign)   BOOL       showCommunity;
@property (nonatomic, strong)   UIImageView       *positionImageView;
@property (nonatomic, weak)     FHFeedUGCCellModel       *cellModel;
@property (nonatomic, strong)   FHUGCVoteMainView       *voteView;

@end

@implementation FHUGCVoteDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.showCommunity = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isFromDetail = YES;
        [self setupUIs];
    }
    return self;
}

- (void)setupUIs {
    [self setupViews];
}

- (void)setupViews {
    __weak typeof(self) wself = self;
    
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30 * 2, 0)];
    _contentLabel.numberOfLines = 0;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.descLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:self.descLabel];
    
    self.descLabel.numberOfLines = self.isFromDetail ? 0 : 1;
    
    self.voteView = [[FHUGCVoteMainView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    self.voteView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.voteView];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)setupUIFrames {
    self.userInfoView.top = topMargin;
    self.userInfoView.left = 0;
    self.userInfoView.width = [UIScreen mainScreen].bounds.size.width;
    self.userInfoView.height = userInfoViewHeight;
    
    self.contentLabel.top = self.userInfoView.bottom + 10;
    self.contentLabel.left = 30;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - 30 - 30;
    UIView *lastView = self.contentLabel;
    // 补充说明可以没有
    if (self.cellModel.voteInfo.desc.length > 0) {
        self.descLabel.left = 30;
        self.descLabel.top = self.contentLabel.bottom + 1;
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 30 - 30;
        self.descLabel.hidden = NO;
        lastView = self.descLabel;
    } else {
        self.descLabel.hidden = YES;
    }
    // 投票视图
    self.voteView.top = lastView.bottom + 10;
    self.voteView.left = 0;
    self.voteView.height = 100;
    self.voteView.width = [UIScreen mainScreen].bounds.size.width;
    
    // 底部bottom
    self.bottomView.top = self.voteView.bottom + 10;
    self.bottomView.left = 0;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width;
    self.bottomView.height = bottomViewHeight;
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)gotoCommunityDetail {
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    if (cellModel) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSDictionary *log_pb = cellModel.tracerDic[@"log_pb"];
        dict[@"community_id"] = cellModel.community.socialGroupId;
        NSString *enter_from = cellModel.tracerDic[@"page_type"] ?: @"be_null";
        dict[@"tracer"] = @{@"enter_from":enter_from,
                            @"enter_type":@"click",
                            @"log_pb":log_pb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    self.cellModel = data;
    //设置userInfo
    self.userInfoView.cellModel = self.cellModel;
    self.userInfoView.userName.text = self.cellModel.user.name;
    self.userInfoView.descLabel.attributedText = self.cellModel.desc;
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:self.cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    //设置底部
    self.bottomView.cellModel = self.cellModel;
    
    BOOL showCommunity = self.cellModel.showCommunity && !isEmptyString(self.cellModel.community.name);
    self.bottomView.position.text = self.cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
    
    NSInteger commentCount = [self.cellModel.commentCount integerValue];
    if(commentCount == 0){
        [self.bottomView.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    }else{
        [self.bottomView.commentBtn setTitle:[TTBusinessManager formatCommentCount:commentCount] forState:UIControlStateNormal];
    }
    [self.bottomView updateLikeState:self.cellModel.diggCount userDigg:self.cellModel.userDigg];
    //内容
    self.contentLabel.numberOfLines = self.cellModel.numberOfLines;
    if(isEmptyString(self.cellModel.voteInfo.title)){
        self.contentLabel.hidden = YES;
        self.contentLabel.height = 0;
    }else{
        self.contentLabel.hidden = NO;
        if (self.isFromDetail) {
            // 重新计算高度
            [FHUGCCellHelper setUGCVoteContentString:self.cellModel width:([UIScreen mainScreen].bounds.size.width - 60) numberOfLines:1000];
        }
        self.contentLabel.height = self.cellModel.voteInfo.contentHeight;
        [self.contentLabel setText:self.cellModel.voteInfo.contentAStr];
    }
    if (isEmptyString(self.cellModel.voteInfo.desc)) {
        self.descLabel.hidden = YES;
        self.descLabel.height = 0;
    } else {
        self.descLabel.hidden = NO;
        self.descLabel.text = self.cellModel.voteInfo.desc;
        if (self.isFromDetail) {
            CGSize size = [self.descLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 60, 1000)];
            self.cellModel.voteInfo.descHeight = size.height;
        } else {
            self.cellModel.voteInfo.descHeight = 17;
        }
        self.descLabel.height = self.cellModel.voteInfo.descHeight;
    }
    // Vote View
    
    // 更新布局
    [self setupUIFrames];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat height = topMargin + userInfoViewHeight + 10 + 20.5;
        // 投票 title 高度
        if (cellModel.voteInfo.title.length > 0) {
            height += cellModel.voteInfo.contentHeight;
        }
        if (cellModel.voteInfo.desc.length > 0) {
            height += cellModel.voteInfo.descHeight;
        }
        // 选项开始
        height += 10;
        // 选项（高度）
        height += (cellModel.voteInfo.items.count * 48);
        // 多少人参与 + 按钮（高度）
        height += 70;
        // 按钮底部 + 10
        height += 10;
        // 小区圈底部
        if (cellModel.showCommunity) {
            height += (24 + 10);
        }
        return height;
    }
    return 44;
}

// 删除
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

// 进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

- (void)attributedLabel:(TTUGCAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if (url) {
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
        if (cellModel) {
            NSMutableDictionary *dict = @{}.mutableCopy;
            NSDictionary *log_pb = cellModel.tracerDic[@"log_pb"];
            NSString *enter_from = cellModel.tracerDic[@"page_type"] ?: @"be_null";
            dict[@"tracer"] = @{@"from_page":enter_from,
                                @"element_from":@"feed_topic",
                                @"enter_type":@"click",
                                @"log_pb":log_pb ?: @"be_null"};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

@end

// FHUGCVoteMainView
@interface FHUGCVoteMainView()

@end

@implementation FHUGCVoteMainView


@end


// FHUGCVoteFoldViewButton
@interface FHUGCVoteFoldViewButton ()

@property (nonatomic, strong)   UIImageView       *iconView;
@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, copy)     NSString       *upText;
@property (nonatomic, copy)     NSString       *downText;

@end

@implementation FHUGCVoteFoldViewButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithDownText:(NSString *)down upText:(NSString *)up isFold:(BOOL)isFold
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.upText = up;
        self.downText = down;
        self.isFold = isFold;
    }
    return self;
}

- (void)setupUI {
    _upText = @"收起";
    _downText = @"展开";
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-2"]];
    [self addSubview:_iconView];
    _keyLabel = [[UILabel alloc] init];
    _keyLabel.text = @"";
    _keyLabel.textColor = [UIColor themeRed1];
    _keyLabel.font = [UIFont themeFontRegular:14];
    [self addSubview:_keyLabel];
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).offset(-11);
        make.top.mas_equalTo(self).offset(20);
        make.height.mas_equalTo(18);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(4);
        make.centerY.mas_equalTo(self.keyLabel);
        make.height.width.mas_equalTo(18);
    }];
}

- (void)setIsFold:(BOOL)isFold {
    _isFold = isFold;
    if (isFold) {
        _keyLabel.text = self.downText;
        _iconView.image = [UIImage imageNamed:@"arrowicon-feed-3"];
    } else {
        _keyLabel.text = self.upText;
        _iconView.image = [UIImage imageNamed:@"arrowicon-feed-2"];
    }
}

@end
