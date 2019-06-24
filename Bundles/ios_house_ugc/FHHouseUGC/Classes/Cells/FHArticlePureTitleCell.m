//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHArticlePureTitleCell.h"
#import "FHArticleCellBottomView.h"

@interface FHArticlePureTitleCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHArticlePureTitleCell

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
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 3;
    [self.contentView addSubview:_contentLabel];
    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
    __weak typeof(self) wself = self;
    _bottomView.deleteCellBlock = ^{
        [wself deleteCell];
    };
    [self.contentView addSubview:_bottomView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-50);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(39);
        make.left.right.bottom.mas_equalTo(self.contentView);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        self.cellModel = cellModel;
        self.contentLabel.text = cellModel.title;
        
        self.bottomView.cellModel = cellModel;
        self.bottomView.descLabel.attributedText = cellModel.desc;
        
        BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
        self.bottomView.position.text = cellModel.community.name;
        [self.bottomView showPositionView:showCommunity];
        
        [self showGuideView];
    }
}

- (void)showGuideView {
    if(_cellModel.isInsertGuideCell){
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(66);
        }];
    }else{
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(39);
        }];
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
