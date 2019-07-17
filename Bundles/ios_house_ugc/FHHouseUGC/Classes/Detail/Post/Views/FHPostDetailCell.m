//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHPostDetailCell.h"
#import <UIImageView+BDWebImage.h>
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHCommentBaseDetailViewModel.h"

#define leftMargin 20
#define rightMargin 20
#define kFHMaxLines 0

@interface FHPostDetailCell ()

@property(nonatomic ,strong) TTUGCAttributedLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,assign) NSInteger       imageCount;
@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic, assign)   BOOL       showCommunity;

@end

@implementation FHPostDetailCell

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
    [self.contentView addSubview:_contentLabel];
    
    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:self.imageCount];
    [self.contentView addSubview:_multiImageView];
    
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
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    [self.multiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
    }];
    
    if (self.showCommunity) {
        self.positionView.hidden = NO;
        UIView *lastView = self.multiImageView;
        if (self.imageCount <= 0) {
            lastView = self.contentLabel;
        }
        [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(lastView.mas_bottom).offset(10);
            make.height.mas_equalTo(24);
        }];
        
        [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionView).offset(6);
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
        UIView *lastView = self.multiImageView;
        if (self.imageCount <= 0) {
            lastView = self.contentLabel;
        }
        [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(20);
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
        dict[@"tracer"] = @{@"enter_from":@"feed_detail",
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
    self.imageCount = cellModel.largeImageList.count;
    self.showCommunity = cellModel.showCommunity;
    [self setupUIs];
    // 设置userInfo
    self.userInfoView.cellModel = cellModel;
    self.userInfoView.userName.text = cellModel.user.name;
    self.userInfoView.descLabel.attributedText = cellModel.desc;
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    // 内容
    [FHUGCCellHelper setRichContent:self.contentLabel model:cellModel numberOfLines:kFHMaxLines];
    // 图片
    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    // 小区
    self.position.text = cellModel.community.name;
    [self.position sizeToFit];
}

@end

