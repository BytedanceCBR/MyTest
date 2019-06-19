//
//  FHUGCGuideCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/19.
//

#import "FHUGCGuideCell.h"

@interface FHUGCGuideCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) UIButton *closeBtn;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCGuideCell

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
    self.contentView.backgroundColor = [UIColor themeGray7];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    _contentLabel.numberOfLines = 2;
    _contentLabel.text = @"点击✌️关联小区，进入小区圈查看更多有趣的新鲜事";
    [self.contentView addSubview:_contentLabel];
    
    self.closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(deleteCell) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_closeBtn];
    
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-20);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
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
    }
}

- (void)deleteCell {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
        [self.delegate deleteCell:self.cellModel];
    }
}

@end
