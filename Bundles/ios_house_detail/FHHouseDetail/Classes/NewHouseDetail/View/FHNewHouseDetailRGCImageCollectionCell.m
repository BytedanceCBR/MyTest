//
//  FHNewHouseDetailRGCImageCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/10.
//

#import "FHNewHouseDetailRGCImageCollectionCell.h"
#import "FHHouseDeatilRGCCellHeader.h"
#import "FHHouseDetailRGCMultiImageView.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellUserInfoView.h"
#import "UIViewAdditions.h"
#import "TTBusinessManager+StringUtils.h"

@interface FHNewHouseDetailRGCImageCollectionCell () <TTUGCAsyncLabelDelegate>
@property (strong, nonatomic) TTUGCAsyncLabel *contentLabel;
@property (strong, nonatomic) FHHouseDetailRGCMultiImageView *multiImageView;
@property (strong, nonatomic) FHHouseDeatilRGCCellHeader *headerView;
@property (strong, nonatomic) FHUGCCellUserInfoView *userInfoView;
@property (nonatomic, assign) CGFloat imageViewheight;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation FHNewHouseDetailRGCImageCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = 0;
        height += 50;
        height += 10;
        height += cellModel.contentHeight;
        height += 10;
        
        CGFloat imageHeight = 0;
        if (cellModel.imageList.count > 0) {
            imageHeight = ceilf([FHHouseDetailRGCMultiImageView viewHeightForCount:3 width:width]);
        }
        height += imageHeight;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 40)];
        self.userInfoView.hidden = YES;
        [self.contentView addSubview:self.userInfoView];
        [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        __weak typeof(self) weakSelf = self;
        self.headerView
            = [[FHHouseDeatilRGCCellHeader alloc] init];
        self.headerView.hidden = YES;
        self.headerView.imClick = ^{
            [weakSelf clickImAction];
        };
        self.headerView.phoneCilck = ^{
            [weakSelf clickPhoneAction];
        };
        self.headerView.headerClick = ^{
            [weakSelf clickHeader];
        };
        [self.contentView addSubview:_headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(5);
            make.left.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.right.mas_equalTo(-10);
        }];

        self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 0)];
        self.contentLabel.numberOfLines = 3;
        self.contentLabel.layer.masksToBounds = YES;
        self.contentLabel.backgroundColor = [UIColor whiteColor];
        self.contentLabel.delegate = self;
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(0);
        }];

        self.multiImageView = [[FHHouseDetailRGCMultiImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds) - 15*2, 0) count:3];
        [self.contentView addSubview:self.multiImageView];
        [self.multiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(0);
        }];

        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds) - 15 * 2, .5)];
        self.lineView.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.multiImageView.mas_bottom).mas_offset(16);
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
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
    
    if (cellModel.realtor) {
        self.userInfoView.hidden = YES;
        self.headerView.hidden = NO;
        [self.headerView refreshWithData:cellModel];
    }else {
        self.userInfoView.hidden = NO;
        self.headerView.hidden = YES;
        [self.userInfoView refreshWithData:cellModel];
    }
    
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if (cellModel.content.length) {
        self.contentLabel.hidden = NO;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cellModel.contentHeight);
        }];
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }else {
        self.contentLabel.hidden = YES;
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
        
    self.lineView.hidden = !cellModel.isShowLineView;
    [self.headerView hiddenConnectBtn:cellModel.isHiddenConnectBtn];
       //图片
    [self.multiImageView updateImageView:cellModel.imageList largeImageList:cellModel.largeImageList];
    if (cellModel.imageList.count > 0) {
        CGFloat imageHeight = ceilf([FHHouseDetailRGCMultiImageView viewHeightForCount:3 width:CGRectGetWidth(self.contentView.bounds) - 15 * 2]);
        [self.multiImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageHeight);
        }];
    }
}

// 点击经纪人电话
// 点击经纪人IM

- (void)clickImAction {
    if (self.clickIMBlock) {
        self.clickIMBlock(self.currentData);
    }
}

- (void)clickPhoneAction {
    if (self.clickPhoneBlock) {
        self.clickPhoneBlock(self.currentData);
    }
}

- (void)clickHeader {
    if (self.clickRealtorHeaderBlock) {
        self.clickRealtorHeaderBlock(self.currentData);
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
