//
// Created by zhulijun on 2019-07-03.
//

#import "FHDetailBlankLineCell.h"

@interface FHDetailBlankLineCell ()

@property(nonatomic, strong) UIView *bottomMaskView;

@end

@implementation FHDetailBlankLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailBlankLineModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailBlankLineModel *model = (FHDetailBlankLineModel *) data;
    CGFloat height = model.lineHeight;
    UIColor *color = model.lineColor;
    [self setBarHeight:height color:color];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bottomMaskView = [[UIView alloc] init];
    _bottomMaskView.backgroundColor = [UIColor themeWhite];
    [self.contentView addSubview:_bottomMaskView];
    [self.bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
}

- (void)setBarHeight:(CGFloat)height color:(UIColor *)color {
    if (color) {
        self.bottomMaskView.backgroundColor = color;
    }
    [self.bottomMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

@end


@implementation FHDetailBlankLineModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineHeight = 20.0;
        _lineColor = [UIColor whiteColor];
    }
    return self;
}

@end
