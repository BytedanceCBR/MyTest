//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHArticleSingleImageCell.h"
#import "FHArticleCellBottomView.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "UIViewAdditions.h"

#define maxLines 3
#define singleImageViewHeight 90
#define bottomViewHeight 39
#define guideViewHeight 27
#define topMargin 15

@interface FHArticleSingleImageCell ()

@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,strong) UIImageView *singleImageView;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHArticleSingleImageCell

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
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = maxLines;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_contentLabel];
    
    self.singleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _singleImageView.backgroundColor = [UIColor themeGray6];
    _singleImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _singleImageView.layer.borderWidth = 0.5;
    _singleImageView.layer.masksToBounds = YES;
    _singleImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_singleImageView];
    
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
    self.contentLabel.top = topMargin;
    self.contentLabel.left = 20;
    self.contentLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 120 - 15;
    self.contentLabel.height = 0;

    self.singleImageView.top = topMargin;
    self.singleImageView.left = self.contentLabel.right + 15;
    self.singleImageView.width = 120;
    self.singleImageView.height = singleImageViewHeight;
    
    self.bottomView.top = self.singleImageView.bottom + 10;
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
    self.currentData = data;
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    self.cellModel = cellModel;
    //内容
    self.contentLabel.numberOfLines = cellModel.numberOfLines;
    if(isEmptyString(cellModel.title)){
        self.contentLabel.hidden = YES;
        self.contentLabel.height = 0;
    }else{
        self.contentLabel.hidden = NO;
        self.contentLabel.height = cellModel.contentHeight;
        [FHUGCCellHelper setAsyncRichContent:self.contentLabel model:cellModel];
    }
    
    self.bottomView.cellModel = cellModel;
    self.bottomView.descLabel.attributedText = cellModel.desc;
    
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.bottomView.position.text = cellModel.community.name;
    [self.bottomView showPositionView:showCommunity];
    //图片
    FHFeedContentImageListModel *imageModel = [cellModel.imageList firstObject];
    if (imageModel && imageModel.url.length > 0) {
        [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
    }
    
    [self showGuideView];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = singleImageViewHeight + bottomViewHeight + topMargin + 10;
        
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

