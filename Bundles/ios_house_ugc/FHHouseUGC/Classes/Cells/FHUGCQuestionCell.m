//
//  FHUGCQuestionCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/7/29.
//

#import "FHUGCQuestionCell.h"
#import "FHArticleCellBottomView.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "UIViewAdditions.h"
#import "UIImageView+fhUgcImage.h"
#import "FHUGCCellUserInfoView.h"

#define maxLines 3
#define bottomViewHeight 39
#define guideViewHeight 27
#define topMargin 15
#define singleImageViewHeight 90
#define userInfoViewHeight 30
#define leftMargin 20
#define rightMargin 20
#define imagePadding 4

@interface FHUGCQuestionCell ()
@property(nonatomic ,strong) FHUGCCellUserInfoView *userInfoView;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCQuestionCell

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
    self.userInfoView = [[FHUGCCellUserInfoView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, userInfoViewHeight)];
    [self.contentView addSubview:_userInfoView];

    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) wself = self;
    _bottomView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_bottomView];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
    
}

- (void)initConstraints {
    self.userInfoView.top = topMargin;
    self.userInfoView.left = 0;
    self.userInfoView.width = [UIScreen mainScreen].bounds.size.width;
    self.userInfoView.height = userInfoViewHeight;
    
    self.bottomView.top = self.userInfoView.bottom + 10;
    self.bottomView.left = 0;
    self.bottomView.width = [UIScreen mainScreen].bounds.size.width;
    self.bottomView.height = bottomViewHeight;
    
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
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
    self.cellModel= cellModel;
    
    //设置userInfo
    [self updateUserInfoView:cellModel];
    
    self.bottomView.cellModel = cellModel;
    if (![cellModel.desc.string isEqualToString:@"0个回答"]) {
            self.bottomView.descLabel.attributedText = cellModel.desc;
    }
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.bottomView.position.text = cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
     [_bottomView updateIsQuestion];
    [self showGuideView];
}

- (void)updateUserInfoView:(FHFeedUGCCellModel *)cellModel {
    [self.userInfoView setTitleModel:cellModel];
//    UILabel *lab = [[UILabel alloc]init];
//      lab.text = !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"问题：%@",cellModel.originItemModel.content] : @"";
    NSString *titleStr =  !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"问题：%@",cellModel.originItemModel.content] : @"";
    CGSize size = [titleStr sizeWithFont:[UIFont themeFontMedium:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 30) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat maxTitleLabelSizeWidth = [UIScreen mainScreen].bounds.size.width - 10 - 50 -5;
    CGFloat userInfoHeight = 0;
    if(size.width > maxTitleLabelSizeWidth){
        self.userInfoView.height = 50;
    }else {
        self.userInfoView.height = 30;
    }
    [self updateFarme];
}

- (void)updateFarme {
      self.bottomView.top = self.userInfoView.bottom + 10;
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
//        UILabel *lab = [[UILabel alloc]init];
//        lab.text = !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"问题：%@",cellModel.originItemModel.content] : @"";
        NSString *titleStr =  !isEmptyString(cellModel.originItemModel.content) ?[NSString stringWithFormat:@"问题：%@",cellModel.originItemModel.content] : @"";
        CGSize size = [titleStr sizeWithFont:[UIFont themeFontMedium:16] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 30) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat maxTitleLabelSizeWidth = [UIScreen mainScreen].bounds.size.width - 10 - 50 -5;
        CGFloat userInfoHeight = 0;
        if(size.width > maxTitleLabelSizeWidth){
            userInfoHeight = 50;
        }else {
            userInfoHeight = 30;
        }
        
        CGFloat height = userInfoHeight + bottomViewHeight + topMargin + 10;
        
        if(cellModel.isInsertGuideCell){
            height += guideViewHeight;
        }
        
        return height;
    }
    return 44;
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        self.bottomView.height = bottomViewHeight + guideViewHeight;
    }else{
        self.bottomView.height = bottomViewHeight;
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

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
        [self.delegate goToCommunityDetail:self.cellModel];
    }
}

@end
