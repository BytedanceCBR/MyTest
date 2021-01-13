//
//  FHUGCSmallVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCSmallVideoCell.h"
#import "FHUGCCellUserInfoView.h"
#import "FHUGCCellBottomView.h"
#import "FHUGCCellMultiImageView.h"
#import "FHUGCCellHelper.h"
#import "TTRoute.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIViewAdditions.h"
#import "UIImageView+fhUgcImage.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHSmallVideoLayout.h"

#define maxLines 3
#define userInfoViewHeight 40
#define bottomViewHeight 45

@interface FHUGCSmallVideoCell ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHUGCCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,strong) UIImageView *playIcon;
@property(nonatomic ,strong) UIView *timeBgView;
@property(nonatomic ,strong) UILabel *timeLabel;

@end

@implementation FHUGCSmallVideoCell

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
    [self.contentView addSubview:_userInfoView];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] init];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.delegate = self;
    [self.contentView addSubview:_contentLabel];
    
    self.videoImageView = [[UIImageView alloc] init];
    _videoImageView.backgroundColor = [UIColor themeGray7];
    _videoImageView.layer.masksToBounds = YES;
    _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    _videoImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _videoImageView.layer.borderWidth = 0.5;
    _videoImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_videoImageView];
    
    self.playIcon = [[UIImageView alloc] init];
    self.playIcon.image = [UIImage imageNamed:@"fh_ugc_icon_videoplay"];
    [self.videoImageView addSubview:self.playIcon];
    
    self.timeBgView = [[UIView alloc] init];
    self.timeBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.timeBgView.layer.cornerRadius = 10.0;
    self.timeBgView.clipsToBounds = YES;
    [self.videoImageView addSubview:self.timeBgView];
    
    self.timeLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeWhite]];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.timeBgView addSubview:self.timeLabel];
    
    self.bottomView = [[FHUGCCellBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, bottomViewHeight)];
    [_bottomView.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
}

- (void)updateConstraints:(FHBaseLayout *)layout {
    if (![layout isKindOfClass:[FHSmallVideoLayout class]]) {
        return;
    }
    
    FHSmallVideoLayout *cellLayout = (FHSmallVideoLayout *)layout;
    
    [FHLayoutItem updateView:self.userInfoView withLayout:cellLayout.userInfoViewLayout];
    [FHLayoutItem updateView:self.contentLabel withLayout:cellLayout.contentLabelLayout];
    [FHLayoutItem updateView:self.videoImageView withLayout:cellLayout.videoImageViewLayout];
    [FHLayoutItem updateView:self.playIcon withLayout:cellLayout.playIconLayout];
    [FHLayoutItem updateView:self.timeBgView withLayout:cellLayout.timeBgViewLayout];
    [FHLayoutItem updateView:self.timeLabel withLayout:cellLayout.timeLabelLayout];
    [FHLayoutItem updateView:self.bottomView withLayout:cellLayout.bottomViewLayout];
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
    [self updateConstraints:cellModel.layout];
    //设置userInfo
    [self.userInfoView refreshWithData:cellModel];
    //设置底部
    [self.bottomView refreshWithData:cellModel];
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel && imageModel.url.length > 0) {
            NSURL *url = [NSURL URLWithString:imageModel.url];
            [self.videoImageView fh_setImageWithURL:url placeholder:nil reSize:self.videoImageView.size];
        }
    }
 
    self.timeLabel.text = cellModel.videoDurationStr;
    if(isEmptyString(cellModel.content)){
        self.contentLabel.hidden = YES;
    }else{
        self.contentLabel.hidden = NO;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
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
