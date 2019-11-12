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
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic, assign)   BOOL       showCommunity;
@property (nonatomic, strong)   UIImageView       *positionImageView;

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
    }
    return self;
}

- (void)setupUIs {
    [self setupViews];
    [self setupConstraints];
}

- (void)setupViews {
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_userInfoView];
    __weak typeof(self) weakSelf = self;
    self.userInfoView.deleteCellBlock = ^{
        FHCommentBaseDetailViewModel *viewModel = weakSelf.baseViewModel;
        [viewModel.detailController goBack];
    };
    
    self.userInfoView.reportSuccessBlock = ^{
        FHCommentBaseDetailViewModel *viewModel = weakSelf.baseViewModel;
        [viewModel.detailController goBack];
    };
    
    self.contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 0;
    _contentLabel.delegate = self;
    NSDictionary *linkAttributes = @{
                                     NSForegroundColorAttributeName : [UIColor themeRed3],
                                     NSFontAttributeName : [UIFont themeFontRegular:16]
                                     };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    [self.contentView addSubview:_contentLabel];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomSepView];
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self.contentView addSubview:_positionView];
    
    self.positionImageView = [[UIImageView alloc] init];
    _positionImageView.image = [UIImage imageNamed:@"fh_ugc_community_icon"];
    [self.positionView addSubview:_positionImageView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_positionView addSubview:_position];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoCommunityDetail)];
    [self.positionView addGestureRecognizer:singleTap];
}

- (void)setupConstraints {
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(30);
        make.right.mas_equalTo(self.contentView).offset(-30);
        make.height.mas_equalTo(0);
    }];
    
    if (self.showCommunity) {
        self.positionView.hidden = NO;
        UIView *lastView = self.contentLabel;
        
        CGFloat topOffset = 10;
        
        [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.height.mas_equalTo(24);
        }];
        
        [self.positionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionView).offset(6);
            make.centerY.mas_equalTo(self.positionView);
            make.width.height.mas_equalTo(12);
        }];
        
        [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionImageView.mas_right).offset(2);
            make.right.mas_equalTo(self.positionView).offset(-6);
            make.centerY.mas_equalTo(self.positionView);
            make.height.mas_equalTo(18);
        }];
        
        [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.positionView.mas_bottom).offset(20);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
            make.bottom.mas_equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(0.5);
        }];
    } else {
        self.positionView.hidden = YES;
        UIView *lastView = self.contentLabel;
        CGFloat topOffset = 20;
        [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
            make.bottom.mas_equalTo(self.contentView).offset(0);
            make.height.mas_equalTo(0.5);
        }];
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
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
    if (self.currentData == data || ![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    FHUGCVoteInfoVoteInfoModel *voteInfo = cellModel.voteInfo;
    self.showCommunity = cellModel.showCommunity;
    [self setupUIs];
    // 设置userInfo
    self.userInfoView.cellModel = cellModel;
    self.userInfoView.userName.text = cellModel.user.name;
    self.userInfoView.descLabel.attributedText = cellModel.desc;
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    // 内容
    [self.contentLabel setText:voteInfo.contentAStr];
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(voteInfo.contentHeight);
    }];
    // 小区
    self.position.text = cellModel.community.name;
    [self.position sizeToFit];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat height = topMargin + userInfoViewHeight + 10 + cellModel.contentHeight + 20.5;
        
        
        height += 20;
        
        if (cellModel.showCommunity) {
            height += (24 + 10);
        }
        return height;
    }
    return 44;
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
