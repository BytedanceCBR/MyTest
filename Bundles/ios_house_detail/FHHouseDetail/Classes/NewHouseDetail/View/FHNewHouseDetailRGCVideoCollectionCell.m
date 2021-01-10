//
//  FHNewHouseDetailRGCVideoCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/10.
//

#import "FHNewHouseDetailRGCVideoCollectionCell.h"
#import "FHHouseDeatilRGCCellHeader.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"
#import "FHUGCCellUserInfoView.h"
#import "UIViewAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTImageView+TrafficSave.h"

@interface FHNewHouseDetailRGCVideoCollectionCell ()<TTUGCAsyncLabelDelegate>
@property (strong, nonatomic) TTUGCAsyncLabel *contentLabel;
@property (strong, nonatomic) FHHouseDeatilRGCCellHeader *headerView;
@property (strong ,nonatomic) FHUGCCellUserInfoView *userInfoView;
@property (strong ,nonatomic) UIView *lineView;
@property(nonatomic ,strong) TTImageView *videoImageView;
@property (nonatomic ,assign) CGFloat imageViewheight;
@property (nonatomic  ,assign) CGFloat imageViewWidth;
@property (nonatomic ,strong) UIImageView *playIcon;
@property (nonatomic ,strong) UIView       *timeBgView;
@property (nonatomic ,strong) UILabel       *timeLabel;
@end

@implementation FHNewHouseDetailRGCVideoCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = 0;
        height += 50;
        height += 10;
        height += cellModel.contentHeight;
        CGFloat imageHeight = 0;
        if (cellModel.imageList.count > 0) {
            imageHeight = 200;
        }
        height += imageHeight;
        height += 12;
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
            make.top.left.mas_equalTo(0);
            make.height.mas_equalTo(36);
            make.right.mas_equalTo(0);
        }];

        self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 0)];
        self.contentLabel.numberOfLines = 3;
        self.contentLabel.layer.masksToBounds = YES;
        self.contentLabel.backgroundColor = [UIColor whiteColor];
        self.contentLabel.delegate = self;
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userInfoView.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(0);
        }];
        
        self.videoImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, self.imageViewWidth, self.imageViewheight)];
        self.videoImageView.backgroundColor = [UIColor themeGray7];
        self.videoImageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
        self.videoImageView.layer.masksToBounds = YES;
        self.videoImageView.layer.cornerRadius = 4;
        [self.contentView addSubview:self.videoImageView];
        [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(10);
            make.left.mas_equalTo(12);
            make.width.mas_equalTo(150);
            make.height.mas_equalTo(200);
        }];
        
        self.playIcon = [[UIImageView alloc] init];
        self.playIcon.image = [UIImage imageNamed:@"fh_ugc_icon_videoplay"];
        [self.videoImageView addSubview:self.playIcon];
        [self.playIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.videoImageView);
            make.width.height.mas_equalTo(44);
        }];
        
        self.timeBgView = [[UIView alloc] init];
        self.timeBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.timeBgView.layer.cornerRadius = 10.0;
        self.timeBgView.clipsToBounds = YES;
        [self.videoImageView addSubview:self.timeBgView];
        [self.timeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.videoImageView.mas_right).offset(-4);
            make.bottom.mas_equalTo(self.videoImageView.mas_bottom).offset(-4);
            make.height.mas_equalTo(20);
            make.width.mas_greaterThanOrEqualTo(44);
        }];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont themeFontRegular:10];
        self.timeLabel.textColor = [UIColor themeWhite];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.timeBgView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.timeBgView);
            make.height.mas_equalTo(14);
            make.left.mas_equalTo(6);
            make.right.mas_equalTo(-6);
        }];
        
         self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds) - 12 * 2, .5)];
         self.lineView.backgroundColor = [UIColor themeGray6];
         [self.contentView addSubview:self.lineView];
         [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.top.mas_equalTo(self.videoImageView.mas_bottom).mas_offset(12);
             make.left.mas_equalTo(12);
             make.right.mas_equalTo(-12);
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
    
    if (cellModel.imageList.count > 0) {
        [self.videoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(150);
            make.height.mas_equalTo(200);
        }];
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        self.videoImageView.width = self.imageViewWidth;
        self.videoImageView.height = self.imageViewheight;
        if (imageModel && imageModel.url.length > 0) {
            TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:imageModel];
            __weak typeof(self) wSelf = self;
            [self.videoImageView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
                [wSelf.videoImageView setImage:nil];
            }];
        }
    } else {
        [self.videoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    // 时间
    NSString *timeStr = @"00:00";
    if (cellModel.videoDuration > 0) {
        NSInteger minute = cellModel.videoDuration / 60;
        NSInteger second = cellModel.videoDuration % 60;
        NSString *mStr = @"00";
        if (minute < 10) {
            mStr = [NSString stringWithFormat:@"%02ld",(long)minute];
        } else {
            mStr = [NSString stringWithFormat:@"%ld",(long)minute];
        }
        NSString *sStr = @"00";
        if (second < 10) {
            sStr = [NSString stringWithFormat:@"%02ld",(long)second];
        } else {
            sStr = [NSString stringWithFormat:@"%ld",(long)second];
        }
        timeStr = [NSString stringWithFormat:@"%@:%@",mStr,sStr];
    }
    self.timeLabel.text = timeStr;
    // [self.timeLabel sizeToFit];
    [self.timeLabel layoutIfNeeded];
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
