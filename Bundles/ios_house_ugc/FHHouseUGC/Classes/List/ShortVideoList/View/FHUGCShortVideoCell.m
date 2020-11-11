//
//  FHUGCShortVideoCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/9/18.
//

#import "FHUGCShortVideoCell.h"
#import "UIViewAdditions.h"
#import "UIColor+Theme.h"
#import "FHFeedUGCCellModel.h"
#import "UIImageView+fhUgcImage.h"
#import "UIFont+House.h"
#import "FHUGCCellHelper.h"

@interface FHUGCShortVideoCell ()

// 当前cell的模型数据
@property(nonatomic, weak, nullable) id currentData;
@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UIView *blackCoverView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation FHUGCShortVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstains];
        [self initNotification];
    }
    return self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStateChange:) name:@"kFHUGCDiggStateChangeNotification" object:nil];
    // 评论数变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentCountChange:) name:@"kPostMessageFinishedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRepinChange:) name:@"kFHUGCUserRepinStateChangeNotification" object:nil];
    
}

- (void)initView {
    self.bgView = [[UIImageView alloc] init];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.backgroundColor = [UIColor themeGray7];
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [[UIColor themeGray6] CGColor];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    [self.contentView addSubview:_bgView];
    
    self.blackCoverView = [[UIView alloc] init];
    [self.bgView addSubview:_blackCoverView];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontMedium:14] textColor:[UIColor whiteColor]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 2;
    [self.bgView addSubview:_titleLabel];
}

- (void)initConstains {
    self.bgView.left = 0;
    self.bgView.top = 0;
    self.bgView.width = self.width;
    self.bgView.height = self.height;
    
    self.blackCoverView.left = 0;
    self.blackCoverView.top = self.height - 64;
    self.blackCoverView.width = self.width;
    self.blackCoverView.height = 64;
    
    self.titleLabel.top = self.blackCoverView.top + 14;
    self.titleLabel.left = 10;
    self.titleLabel.width = self.width - 20;
    self.titleLabel.height = 0;

    //背景渐变
    self.gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.blackCoverView.bounds;
    _gradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                              (id)[[UIColor blackColor] colorWithAlphaComponent:0.56].CGColor];
    [self.blackCoverView.layer addSublayer:_gradientLayer];
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
    //图片
    if (cellModel.imageList.count > 0) {
        FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
        if (imageModel) {
            NSArray *urls = [FHUGCCellHelper convertToImageUrls:imageModel];
            [self.bgView bd_setImageWithURLs:urls placeholder:nil options:BDImageRequestDefaultPriority transformer:nil progress:nil completion:nil];
        }else{
            self.bgView.image = nil;
        }
    }else{
        self.bgView.image = nil;
    }

    if(isEmptyString(cellModel.content)){
        self.titleLabel.hidden = YES;
        self.titleLabel.text = @"";
    }else{
        self.titleLabel.hidden = NO;
        self.titleLabel.text = cellModel.content;
        CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.width, MAXFLOAT)];
        self.titleLabel.top = self.height - 10 - size.height;
        self.titleLabel.height = size.height;
    }
}

- (void)likeStateChange:(NSNotification *)notification {
    if (![self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    NSDictionary *userInfo = notification.userInfo;
    
    if(userInfo){
        NSInteger user_digg = [userInfo[@"action"] integerValue];
        NSInteger diggCount = [cellModel.diggCount integerValue];
        NSString *groupId = userInfo[@"group_id"];
        
        if([groupId isEqualToString:cellModel.groupId]){
            // 刷新UI
            if(user_digg == 0){
                //取消点赞
                cellModel.userDigg = @"0";
                if(diggCount > 0 && cellModel.lastUserDiggType != FHFeedUGCDiggType_Decrease){
                    diggCount = diggCount - 1;
                    cellModel.lastUserDiggType = FHFeedUGCDiggType_Decrease;
                }
            }else{
                //点赞
                cellModel.userDigg = @"1";
                if(cellModel.lastUserDiggType != FHFeedUGCDiggType_Increase) {
                    diggCount = diggCount + 1;
                    cellModel.lastUserDiggType = FHFeedUGCDiggType_Increase;
                }
            }
            cellModel.diggCount = [NSString stringWithFormat:@"%li",(long)diggCount];
        }
    }
}

// 评论数变化
- (void)commentCountChange:(NSNotification *)notification {
    if (![self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo){
        if(![[userInfo allKeys] containsObject:@"comment_conut"]){
            return;
        }
        NSInteger comment_conut = [userInfo[@"comment_conut"] integerValue];
        NSString *groupId = userInfo[@"group_id"];
        if (groupId.length > 0 && [groupId isEqualToString:cellModel.groupId]) {
            NSInteger commentCount = comment_conut;
            cellModel.commentCount = [NSString stringWithFormat:@"%ld",(long)commentCount];
        }
    }
}

- (void)userRepinChange:(NSNotification *)notification {
    if (![self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    NSDictionary *userInfo = notification.userInfo;
    if(userInfo){
        NSString *groupId = userInfo[@"group_id"];
        
        if([groupId isEqualToString:cellModel.groupId]){
            cellModel.userRepin = [userInfo[@"action"] boolValue];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
