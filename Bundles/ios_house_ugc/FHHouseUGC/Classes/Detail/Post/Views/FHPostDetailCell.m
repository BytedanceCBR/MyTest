//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHPostDetailCell.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHeaderView.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "FHCommentBaseDetailViewModel.h"
#import "FHUGCCellOriginItemView.h"
#import "TTIndicatorView.h"
#import "FHUGCCellAttachCardView.h"

#define leftMargin 20
#define rightMargin 20
#define kFHMaxLines 0

#define userInfoViewHeight 40
#define bottomViewHeight 49
#define guideViewHeight 17
#define topMargin 20
#define originViewHeight 80
#define attachCardViewHeight 57

@interface FHPostDetailCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellMultiImageView *multiImageView;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,assign) NSInteger       imageCount;
@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic, assign)   BOOL       showCommunity;
@property (nonatomic, assign)   BOOL       hasOriginItem;
@property (nonatomic, assign)   BOOL       hasAttachCard;
@property(nonatomic ,strong) FHUGCCellOriginItemView *originView;
@property (nonatomic, strong)   UIView       *editHistorySepView;
@property(nonatomic ,strong) FHUGCCellAttachCardView *attachCardView;

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
        self.hasOriginItem = NO;
        self.hasAttachCard = NO;
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
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 0;
    _contentLabel.delegate = self;
//    NSDictionary *linkAttributes = @{
//                                     NSForegroundColorAttributeName : [UIColor themeRed3],
//                                     NSFontAttributeName : [UIFont themeFontRegular:16]
//                                     };
//    self.contentLabel.linkAttributes = linkAttributes;
//    self.contentLabel.activeLinkAttributes = linkAttributes;
//    self.contentLabel.inactiveLinkAttributes = linkAttributes;
    [self.contentView addSubview:_contentLabel];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressContentLabel:)];
    longPressGesture.minimumPressDuration = 1.0;
    [_contentLabel addGestureRecognizer:longPressGesture];
    
    self.multiImageView = [[FHUGCCellMultiImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 0) count:self.imageCount];
    [self.contentView addSubview:_multiImageView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomSepView];
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [UIColor themeOrange2];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self.contentView addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeOrange1]];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_position setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_positionView addSubview:_position];
    
    self.originView = [[FHUGCCellOriginItemView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin, 80)];
    _originView.hidden = YES;
    _originView.goToLinkBlock = ^(FHFeedUGCCellModel * _Nonnull cellModel, NSURL * _Nonnull url) {
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(gotoLinkUrl:url:)]){
            [weakSelf.delegate gotoLinkUrl:cellModel url:url];
        }
    };
    [self.contentView addSubview:_originView];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoCommunityDetail)];
    [self.positionView addGestureRecognizer:singleTap];
    
    self.attachCardView = [[FHUGCCellAttachCardView alloc] initWithFrame:CGRectZero];
    _attachCardView.hidden = YES;
    [self.contentView addSubview:_attachCardView];
    
    // 编辑历史底部灰条(只有编辑历史展示)
    self.editHistorySepView = [[UIView alloc] init];
    self.editHistorySepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.editHistorySepView];
    self.editHistorySepView.hidden = YES;
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
        make.height.mas_equalTo(0);
    }];
    
    [self.multiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(leftMargin);
        make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        make.height.mas_equalTo(self.multiImageView.viewHeight);
    }];
    
    [self.editHistorySepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView).offset(0);
        make.height.mas_equalTo(6);
    }];
    
    if (self.showCommunity) {
        self.positionView.hidden = NO;
        UIView *lastView = self.multiImageView;
        if (self.imageCount <= 0) {
            lastView = self.contentLabel;
        }
        
        CGFloat topOffset = 10;
        [self.originView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.height.mas_equalTo(originViewHeight);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        }];
        if (self.hasOriginItem) {
            topOffset += originViewHeight;
            topOffset += 10;
        }
        
        [self.attachCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.height.mas_equalTo(attachCardViewHeight);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        }];
        
        if (self.hasAttachCard) {
            topOffset += attachCardViewHeight;
            topOffset += 10;
        }
        
        [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
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
        
        CGFloat topOffset = 10;
        [self.originView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.height.mas_equalTo(originViewHeight);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        }];
        
        if (self.hasOriginItem) {
            topOffset += originViewHeight;
            topOffset += 10;
        }
        
        [self.attachCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lastView.mas_bottom).offset(topOffset);
            make.height.mas_equalTo(attachCardViewHeight);
            make.left.mas_equalTo(self.contentView).offset(leftMargin);
            make.right.mas_equalTo(self.contentView).offset(-rightMargin);
        }];
        
        if (self.hasAttachCard) {
            topOffset += attachCardViewHeight;
            topOffset += 10;
        }
        
        topOffset += 10;
        
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
        NSString *originFrom = cellModel.tracerDic[@"origin_from"] ?: @"be_null";
        dict[@"tracer"] = @{
            @"origin_from":originFrom,
            @"enter_from":enter_from,
            @"enter_type":@"click",
            @"group_id":cellModel.groupId ?: @"be_null",
            @"log_pb":log_pb ?: @"be_null"
        };
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
    
    for (UIView *v in self.contentView.subviews) {
        [v removeFromSuperview];
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.imageCount = cellModel.largeImageList.count;
    if (self.imageCount > 9) {
        self.imageCount = 9;
    }
    self.showCommunity = cellModel.showCommunity;
    self.hasOriginItem = cellModel.originItemModel != nil;
    self.hasAttachCard = cellModel.attachCardInfo != nil;
    [self setupUIs];
    // 设置userInfo
    self.userInfoView.cellModel = cellModel;
    self.userInfoView.userName.text = !isEmptyString(cellModel.user.name) ? cellModel.user.name : @"用户";
    [self.userInfoView updateDescLabel];
    [self.userInfoView updateEditState];
    [self.userInfoView.icon bd_setImageWithURL:[NSURL URLWithString:cellModel.user.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    // 内容
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.multiImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(10);
        }];
    }else{
        self.contentLabel.hidden = NO;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cellModel.contentHeight);
        }];
        [self.multiImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).offset(20 + cellModel.contentHeight);
        }];
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    // 图片
    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    if(self.imageCount == 1) {
        [self.multiImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.multiImageView.viewHeight);
        }];
    }
    // origin
    if(cellModel.originItemModel){
        self.originView.hidden = NO;
        [self.originView refreshWithdata:cellModel];
    }else{
        self.originView.hidden = YES;
    }
    // attachCard
    if(cellModel.attachCardInfo){
        self.attachCardView.hidden = NO;
        [self.attachCardView refreshWithdata:cellModel];
    }else{
        self.attachCardView.hidden = YES;
    }
    // 小区
    self.position.text = cellModel.community.name;
    [self.position sizeToFit];
    
    // 是否来源于编辑历史
    self.editHistorySepView.hidden = !cellModel.isFromEditHistory;
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        CGFloat height = topMargin + userInfoViewHeight + 10 + cellModel.contentHeight + 20.5;
        
        if(isEmptyString(cellModel.content)){
            height -= 10;
        }
        NSInteger imageCount = cellModel.largeImageList.count;
        if (imageCount > 9) {
            imageCount = 9;
        }
        CGFloat imageViewheight = [FHUGCCellMultiImageView viewHeightForCount:imageCount width:[UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin];
        if (imageCount == 1) {
            // 单独计算单图显示高度
            FHFeedContentImageListModel *imageData = [cellModel.imageList firstObject];
            if (imageData && [imageData isKindOfClass:[FHFeedContentImageListModel class]] && [imageData.width floatValue] > 0) {
                imageViewheight = ([UIScreen mainScreen].bounds.size.width - leftMargin - rightMargin) * [imageData.height floatValue] / [imageData.width floatValue];
            }
        }
        if (imageCount > 0) {
            height += (imageViewheight + 10);
        }
        
        if(cellModel.originItemModel){
            height += (originViewHeight + 10);
        }
        
        if (cellModel.showCommunity) {
            height += (24 + 10);
        }
        return height;
    }
    return 44;
}

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
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

- (void)asyncLabel:(TTUGCAsyncLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point {
    [self didLongPress];
}

- (void)didLongPressContentLabel:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self didLongPress];
    }
}

- (void)didLongPress {
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@", cellModel.content];
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拷贝成功" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
}

@end

