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
        [self setupUIs];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voteCompleteNoti:) name:kFHUGCPostVoteSuccessNotification object:nil];
    }
    return self;
}

- (void)setupUIs {
    [self setupViews];
}

- (void)voteCompleteNoti:(NSNotification *)notification {
    if (notification) {
        NSDictionary *userInfo = notification.userInfo;
        
        FHUGCVoteInfoVoteInfoModel *voteInfo = notification.userInfo[@"vote_info"];
        if (voteInfo && voteInfo.selected) {
            // 完成(或者过期)
            FHUGCVoteInfoVoteInfoModel *currentVoteInfo = self.cellModel.voteInfo;
            if ([currentVoteInfo.voteId isEqualToString:voteInfo.voteId] && currentVoteInfo != voteInfo) {
                // 同样的投票
                // 更新数据
                currentVoteInfo.selected = voteInfo.selected;
                currentVoteInfo.voteState = voteInfo.voteState;
                currentVoteInfo.displayCount = voteInfo.displayCount;
                currentVoteInfo.deadline = voteInfo.deadline;
                NSInteger curCount = currentVoteInfo.items.count;
                [voteInfo.items enumerateObjectsUsingBlock:^(FHUGCVoteInfoVoteInfoItemsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx < curCount) {
                        FHUGCVoteInfoVoteInfoItemsModel *temp = currentVoteInfo.items[idx];
                        temp.index = obj.index;
                        temp.content = obj.content;
                        temp.voteCount = obj.voteCount;
                        temp.selected = obj.selected;
                        temp.percent = obj.percent;
                    }
                }];
                // 更新UI
                [self refreshWithData:self.cellModel];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.voteView.backgroundColor = [UIColor whiteColor];
    self.voteView.detailCell = self;
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
    self.voteView.width = [UIScreen mainScreen].bounds.size.width;
    
    // 底部bottom
    self.bottomView.top = self.voteView.bottom + 20;
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
        self.descLabel.numberOfLines = self.isFromDetail ? 0 : 1;
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
    FHUGCVoteInfoVoteInfoModel *voteInfo = self.cellModel.voteInfo;
    if (self.isFromDetail) {
        voteInfo.needFold = NO;// 不需要折叠展开
    }
    // 过期处理
    NSInteger intver = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger deadline = [voteInfo.deadline integerValue];
    if (intver >= deadline) {
        // 结束
        voteInfo.selected = YES;
        voteInfo.voteState = FHUGCVoteStateExpired;
        voteInfo.deadLineContent = @"";
        if (!voteInfo.hasReloadForVoteExpired) {
            // add by zyk 发送通知 当前cell 刷新过了就不用再通知了
        }
    } else {
        NSInteger val = deadline - intver;
        NSInteger day = 24 * 60 * 60;
        NSInteger hour = 60 * 60;
        NSInteger min = 60;
        if (val >= day) {
            NSInteger temp = val / day;
            voteInfo.deadLineContent = [NSString stringWithFormat:@"还有%ld天结束",temp];
        } else if (val >= hour) {
            NSInteger temp = val / hour;
            voteInfo.deadLineContent = [NSString stringWithFormat:@"还有%ld小时结束",temp];
        } else if (val >= min) {
            NSInteger temp = val / min;
            voteInfo.deadLineContent = [NSString stringWithFormat:@"还有%ld分钟结束",temp];
        } else {
            voteInfo.deadLineContent = [NSString stringWithFormat:@"还有1分钟结束"];
        }
    }
    self.voteView.tableView = self.cellModel.tableView;
    [self.voteView refreshWithData:voteInfo];
    self.voteView.height = voteInfo.voteHeight;
    // 更新布局
    [self setupUIFrames];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat height = topMargin + userInfoViewHeight + 10;
        // 投票 title 高度
        if (cellModel.voteInfo.title.length > 0) {
            height += cellModel.voteInfo.contentHeight;
        }
        if (cellModel.voteInfo.desc.length > 0) {
            height += cellModel.voteInfo.descHeight;
        }
        // 选项开始
        height += 10;
        // 选项（高度） + 多少人参与 + 按钮（高度）
        height += (cellModel.voteInfo.voteHeight);
        // 按钮底部 + 20
        height += 20;
        // 小区圈底部
        if (cellModel.showCommunity) {
            height += (24 + 25);
        } else {
            height += 25;
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

@property (nonatomic, strong)   FHUGCVoteInfoVoteInfoModel *voteInfo;
@property (nonatomic, strong)   UIView       *optionBgView;
@property (nonatomic, strong)   UIView       *bottomBgView;
@property (nonatomic, strong)   NSMutableArray       *optionsViewArray;
@property (nonatomic, weak)     FHUGCVoteFoldViewButton *foldButton;
@property (nonatomic, strong)   UILabel        *dateLabel;
@property (nonatomic, strong)   UIButton       *voteButton;
@property (nonatomic, strong)   UILabel        *hasVotedLabel;
@property (nonatomic, strong)   UIButton       *editButton;

@end

@implementation FHUGCVoteMainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.optionsViewArray = [NSMutableArray new];
    }
    return self;
}

- (void)setupViews {
    CGFloat optionWidth = [UIScreen mainScreen].bounds.size.width - 40;
    self.optionBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
    self.optionBgView.clipsToBounds = YES;
    [self addSubview:self.optionBgView];
    // 加入所有选项
    [self.voteInfo.items enumerateObjectsUsingBlock:^(FHUGCVoteInfoVoteInfoItemsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHUGCOptionView *optionV = [[FHUGCOptionView alloc] initWithFrame:CGRectMake(20, idx * 48, optionWidth, 38)];
        optionV.backgroundColor = [UIColor themeWhite];
        optionV.layer.cornerRadius = 19;
        optionV.mainSelected = self.voteInfo.selected;
        optionV.mainView = self;
        [self.optionBgView addSubview:optionV];
        [self.optionsViewArray addObject:optionV];
    }];
    if (self.voteInfo.needFold) {
        if (self.voteInfo.isFold) {
            // 折叠
            self.optionBgView.height = 48 * [self.voteInfo.displayCount integerValue];
        } else {
            // 展开
            self.optionBgView.height = 48 * self.voteInfo.items.count;
        }
    } else {
        self.optionBgView.height = 48 * self.voteInfo.items.count;
    }
    // 底部
    self.bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.optionBgView.bottom, [UIScreen mainScreen].bounds.size.width, 0)];
    [self addSubview:self.bottomBgView];
    CGFloat bottomHeight = 0;
    if (self.voteInfo.needFold) {
        // 添加折叠展开按钮
        bottomHeight += 28;
        FHUGCVoteFoldViewButton *foldButton = [[FHUGCVoteFoldViewButton alloc] initWithDownText:@"展开查看更多" upText:@"收起" isFold:self.voteInfo.isFold];
        foldButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 28);
        [self.bottomBgView addSubview:foldButton];
        [foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.foldButton = foldButton;
    }
    bottomHeight += 10;
    // 已投票和修改投票按钮
    self.hasVotedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, bottomHeight, ([UIScreen mainScreen].bounds.size.width - 40 - 10) / 2, 38)];
    self.hasVotedLabel.layer.cornerRadius = 19;
    self.hasVotedLabel.clipsToBounds = YES;
    self.hasVotedLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5869" alpha:0.24];
    self.hasVotedLabel.text = @"已投票";
    self.hasVotedLabel.font = [UIFont themeFontRegular:16];
    self.hasVotedLabel.textAlignment = NSTextAlignmentCenter;
    self.hasVotedLabel.textColor = [UIColor themeWhite];
    [self.bottomBgView addSubview:self.hasVotedLabel];
    
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.hasVotedLabel.right + 10, bottomHeight, ([UIScreen mainScreen].bounds.size.width - 40 - 10) / 2, 38)];
    editBtn.layer.cornerRadius = 19;
    editBtn.layer.borderWidth = 0.5;
    editBtn.layer.borderColor = [UIColor themeRed1].CGColor;
    editBtn.backgroundColor = [UIColor themeWhite];
    editBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [editBtn setTitle:@"修改投票" forState:UIControlStateNormal];
    [editBtn setTitle:@"修改投票" forState:UIControlStateHighlighted];
    [editBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBgView addSubview:editBtn];
    self.editButton = editBtn;
    self.hasVotedLabel.hidden = YES;
    self.editButton.hidden = YES;
    
    // 投票按钮
    UIButton *voteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, bottomHeight, [UIScreen mainScreen].bounds.size.width - 40, 38)];
    voteBtn.layer.cornerRadius = 19;
    voteBtn.backgroundColor = [UIColor themeRed1];
    voteBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [voteBtn setTitle:@"确定投票" forState:UIControlStateNormal];
    [voteBtn setTitle:@"确定投票" forState:UIControlStateHighlighted];
    [voteBtn setTitleColor:[UIColor themeWhite] forState:UIControlStateNormal];
    [voteBtn setTitleColor:[UIColor themeWhite] forState:UIControlStateHighlighted];
    voteBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5869" alpha:0.24];
    voteBtn.enabled = NO;
    [voteBtn addTarget:self action:@selector(voteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBgView addSubview:voteBtn];
    self.voteButton = voteBtn;
    bottomHeight += 38;
    
    // 还有X天结束 -- 22
    bottomHeight += 5;
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, bottomHeight, [UIScreen mainScreen].bounds.size.width - 40, 17)];
    self.dateLabel.backgroundColor = [UIColor themeWhite];
    self.dateLabel.text = @"还有5天结束";
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.textColor = [UIColor themeGray3];
    self.dateLabel.font = [UIFont themeFontRegular:12];
    [self.bottomBgView addSubview:self.dateLabel];
    bottomHeight += 17;
    
    self.bottomBgView.height = bottomHeight;
}

// 确认投票按钮点击
- (void)voteButtonClick:(UIButton *)btn {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.voteInfo.selected = YES;
        self.voteInfo.voteState = FHUGCVoteStateExpired;
        [self refreshWithData:self.voteInfo];
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:self.voteInfo forKey:@"vote_info"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCPostVoteSuccessNotification object:nil userInfo:userInfo];
    });
}

// 编辑按钮点击
- (void)editButtonClick:(UIButton *)btn {
    self.voteInfo.selected = NO;
    self.voteInfo.voteState = FHUGCVoteStateNone;
    [self refreshWithData:self.voteInfo];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHUGCVoteInfoVoteInfoModel class]]) {
        return;
    }
    if (self.voteInfo == data) {
        // 只需要修改frame
    } else {
        self.voteInfo = (FHUGCVoteInfoVoteInfoModel *)data;
        for (UIView *v in self.subviews) {
            [v removeFromSuperview];
        }
        [self.optionsViewArray removeAllObjects];
        [self setupViews];
    }
    // 更新数据以及布局
    __block BOOL hasSelected = NO;
    __block NSInteger selectCount = 0;
    __block NSInteger totalCount = 0;
    [self.optionsViewArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHUGCOptionView *optionV = obj;
        if (idx < self.voteInfo.items.count) {
            FHUGCVoteInfoVoteInfoItemsModel *item = self.voteInfo.items[idx];
            NSInteger voteCount = [item.voteCount integerValue];
            totalCount += voteCount;
            if (item.selected) {
                hasSelected = YES;
                selectCount++;
                totalCount += 1;
            }
            optionV.mainSelected = self.voteInfo.selected;
            [optionV refreshWithData:item];
        }
    }];
    for (FHUGCVoteInfoVoteInfoItemsModel *item in self.voteInfo.items) {
        if (totalCount <= 0) {
            item.percent = 0;
        } else {
            NSInteger voteCount = [item.voteCount integerValue];
            if (item.selected) {
                voteCount += 1;
            }
            item.percent = (double)voteCount / totalCount;
        }
    }
    if (self.voteInfo.voteState == FHUGCVoteStateExpired) {
        self.voteInfo.selected = YES;
    }
    // 按钮状态等等
    if (self.voteInfo.selected) {
        // 已投票
        self.editButton.hidden = NO;
        self.hasVotedLabel.hidden = NO;
        self.voteButton.hidden = YES;
    } else {
        self.editButton.hidden = YES;
        self.hasVotedLabel.hidden = YES;
        self.voteButton.hidden = NO;
        if (hasSelected) {
            // 有选中项
            self.voteButton.backgroundColor = [UIColor themeRed1];
            self.voteButton.enabled = YES;
        } else {
            self.voteButton.backgroundColor = [UIColor colorWithHexString:@"#ff5869" alpha:0.24];
            self.voteButton.enabled = NO;
        }
    }
    // 布局
    if (self.voteInfo.needFold) {
        if (self.voteInfo.isFold) {
            // 折叠
            self.optionBgView.height = 48 * [self.voteInfo.displayCount integerValue];
        } else {
            // 展开
            self.optionBgView.height = 48 * self.voteInfo.items.count;
        }
    } else {
        self.optionBgView.height = 48 * self.voteInfo.items.count;
    }
    
    self.bottomBgView.top = self.optionBgView.bottom;
    // 过期逻辑处理
    if (self.voteInfo.voteState == FHUGCVoteStateExpired) {
        // 过期
        self.bottomBgView.height = self.voteButton.bottom;
        self.dateLabel.hidden = YES;
        // 按钮
        self.editButton.hidden = YES;
        self.hasVotedLabel.hidden = YES;
        self.voteButton.hidden = NO;
        self.voteButton.backgroundColor = [UIColor colorWithHexString:@"#ff5869" alpha:0.24];
        [self.voteButton setTitle:@"投票已结束" forState:UIControlStateNormal];
        [self.voteButton setTitle:@"投票已结束" forState:UIControlStateHighlighted];
        self.voteButton.enabled = NO;
    } else {
        self.dateLabel.hidden = NO;
        self.dateLabel.text = self.voteInfo.deadLineContent;
        self.bottomBgView.height = self.dateLabel.bottom;
        [self.voteButton setTitle:@"确定投票" forState:UIControlStateNormal];
        [self.voteButton setTitle:@"确定投票" forState:UIControlStateHighlighted];
    }
    self.voteInfo.voteHeight = self.bottomBgView.bottom;
    self.height = self.bottomBgView.bottom;
    if (self.voteInfo.voteState == FHUGCVoteStateExpired) {
        // 过期--刷新一次 够了
        if (!self.voteInfo.hasReloadForVoteExpired) {
            self.voteInfo.hasReloadForVoteExpired = YES;
            [self.detailCell setupUIFrames];
            if (self.detailCell.isFromDetail) {
               // 详情页 过期 布局有问题 add by zyk
            } else {
                NSIndexPath *ind = [self.tableView indexPathForCell:self.detailCell];
                if (ind) {
                    [self.tableView reloadRowsAtIndexPaths:@[ind] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }
    }
}

// 折叠展开
- (void)foldButtonClick:(UIButton *)button {
    self.voteInfo.isFold = !self.voteInfo.isFold;
    self.foldButton.isFold = self.voteInfo.isFold;
    [self updateItems:YES];
}

- (void)updateItems:(BOOL)animated {
    if (animated) {
        [self.tableView beginUpdates];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self refreshWithData:self.voteInfo];
        [self.detailCell setupUIFrames];
    }];
    if (animated) {
        [self.tableView endUpdates];
    }
}

// 选项点击
- (void)optionClickItem:(FHUGCVoteInfoVoteInfoItemsModel *)item {
    if (item == nil) {
        return;
    }
    if ([self.voteInfo.voteType isEqualToString:@"1"]) {
        // 单选
        [self.voteInfo.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHUGCVoteInfoVoteInfoItemsModel *temp = obj;
            temp.selected = NO;
        }];
        item.selected = YES;
    } else if ([self.voteInfo.voteType isEqualToString:@"2"]) {
        // 多选
        item.selected = !item.selected;
    }
    // 刷新数据
    [self refreshWithData:self.voteInfo];
}

@end


// FHUGCOptionView
@interface FHUGCOptionView ()

@property (nonatomic, strong)   FHUGCVoteInfoVoteInfoItemsModel       *item;
@property (nonatomic, strong)   UIView       *bgView;
@property (nonatomic, strong)   UILabel       *contentLabel;
@property (nonatomic, strong)   UIImageView       *selectedIcon;
@property (nonatomic, strong)   UILabel       *percentLabel;

@end

@implementation FHUGCOptionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithHexStr:@"#aab5bd"].CGColor;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
    self.bgView.backgroundColor = [UIColor colorWithHexStr:@"#ebeef0"];// fef2ec
    [self addSubview:self.bgView];
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 22)];
    self.contentLabel.text = @"";
    if ([UIScreen mainScreen].bounds.size.width <= 321) {
        self.contentLabel.font = [UIFont themeFontRegular:12];
    } if ([UIScreen mainScreen].bounds.size.width <= 376) {
        self.contentLabel.font = [UIFont themeFontRegular:14];
    } else {
        self.contentLabel.font = [UIFont themeFontRegular:16];
    }
    self.contentLabel.textAlignment = NSTextAlignmentCenter;
    self.contentLabel.textColor = [UIColor colorWithHexStr:@"#7c848a"];
    [self addSubview:self.contentLabel];
    [self.contentLabel sizeToFit];
    self.contentLabel.centerX = self.width / 2;
    self.selectedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_vote_selected"]];
    [self addSubview:self.selectedIcon];
    self.selectedIcon.frame = CGRectMake(0, 8, 22, 22);
    self.selectedIcon.left = self.contentLabel.right;
    
    self.percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, 40, 22)];
    self.percentLabel.text = @"";
    self.percentLabel.textColor = [UIColor colorWithHexStr:@"#7c848a"];
    self.percentLabel.textAlignment = NSTextAlignmentRight;
    if ([UIScreen mainScreen].bounds.size.width <= 321) {
        self.percentLabel.font = [UIFont themeFontRegular:13];
    } if ([UIScreen mainScreen].bounds.size.width <= 376) {
        self.percentLabel.font = [UIFont themeFontRegular:14];
    } else {
        self.percentLabel.font = [UIFont themeFontRegular:15];
    }
    self.percentLabel.left = self.width - 50;// 40 + 10
    [self addSubview:self.percentLabel];
    // 初始状态
    self.bgView.hidden = YES;
    self.contentLabel.hidden = NO;
    self.selectedIcon.hidden = YES;
    self.percentLabel.hidden = YES;
    
    [self addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHUGCVoteInfoVoteInfoItemsModel class]]) {
        return;
    }
    self.item = data;
    self.contentLabel.text = self.item.content;
    if (self.mainSelected) {
        // 做动画--已提交
        self.bgView.hidden = NO;
        self.contentLabel.hidden = NO;
        self.selectedIcon.hidden = YES;
        self.percentLabel.hidden = NO;
        
        [self.contentLabel sizeToFit];
        self.bgView.width = 0;
        if (self.item.selected) {
            self.selectedIcon.hidden = NO;
            self.contentLabel.textColor = [UIColor colorWithHexStr:@"#ff8151"];
            self.layer.borderColor = [UIColor colorWithHexStr:@"#ff8151"].CGColor;
            self.percentLabel.textColor = [UIColor colorWithHexStr:@"#ff8151"];
            self.bgView.backgroundColor = [UIColor colorWithHexStr:@"#fef2ec"];// fef2ec
        } else {
            self.selectedIcon.hidden = YES;
            self.contentLabel.textColor = [UIColor colorWithHexStr:@"#7c848a"];
            self.layer.borderColor = [UIColor colorWithHexStr:@"#aab5bd"].CGColor;
            self.percentLabel.textColor = [UIColor colorWithHexStr:@"#7c848a"];
            self.bgView.backgroundColor = [UIColor colorWithHexStr:@"#ebeef0"];// fef2ec
        }
        
        double per = self.item.percent;
        CGFloat wid = [UIScreen mainScreen].bounds.size.width - 40;
        NSString *perStr = [NSString stringWithFormat:@"%.0f%%",per * 100];
        self.percentLabel.text = perStr;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.bgView.width = wid * per;
            self.contentLabel.left = 10;
            self.selectedIcon.left = self.contentLabel.right;
        }];
        
    } else {
        self.bgView.hidden = YES;
        self.contentLabel.hidden = NO;
        self.selectedIcon.hidden = YES;
        self.percentLabel.hidden = YES;
        
        [self.contentLabel sizeToFit];
        self.contentLabel.centerX = self.width / 2;
        if (self.item.selected) {
            self.selectedIcon.hidden = NO;
            self.selectedIcon.left = self.contentLabel.right;
            self.contentLabel.textColor = [UIColor colorWithHexStr:@"#ff8151"];
            self.layer.borderColor = [UIColor colorWithHexStr:@"#ff8151"].CGColor;
        } else {
            self.selectedIcon.hidden = YES;
            self.contentLabel.textColor = [UIColor colorWithHexStr:@"#7c848a"];
            self.layer.borderColor = [UIColor colorWithHexStr:@"#aab5bd"].CGColor;
        }
    }
}

// 点击
- (void)optionClick:(UIButton *)btn {
    if (self.mainSelected){
        // 已做题目
        return;
    }
    [self.mainView optionClickItem:self.item];
}

@end

// FHUGCVoteFoldViewButton
@interface FHUGCVoteFoldViewButton ()

@property (nonatomic, strong)   UIImageView   *iconView;
@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, copy)     NSString      *upText;
@property (nonatomic, copy)     NSString      *downText;

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
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_up_arrow"]];
    [self addSubview:_iconView];
    _keyLabel = [[UILabel alloc] init];
    _keyLabel.text = @"";
    _keyLabel.textColor = [UIColor colorWithHexStr:@"#ff8151"];
    _keyLabel.font = [UIFont themeFontRegular:13];
    [self addSubview:_keyLabel];
    
    [self.keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self).offset(-5);
        make.top.mas_equalTo(self).offset(0);
        make.height.mas_equalTo(18);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.keyLabel.mas_right).offset(2);
        make.centerY.mas_equalTo(self.keyLabel);
        make.height.width.mas_equalTo(10);
    }];
}

- (void)setIsFold:(BOOL)isFold {
    _isFold = isFold;
    if (isFold) {
        _keyLabel.text = self.downText;
        _iconView.image = [UIImage imageNamed:@"fh_ugc_down_arrow"];
    } else {
        _keyLabel.text = self.upText;
        _iconView.image = [UIImage imageNamed:@"fh_ugc_up_arrow"];
    }
}

@end
