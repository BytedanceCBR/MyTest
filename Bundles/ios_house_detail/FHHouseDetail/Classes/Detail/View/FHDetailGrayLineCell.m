//
//  FHDetailGrayLineCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/12.
//

#import "FHDetailGrayLineCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"

@interface FHDetailGrayLineCell ()

@property (nonatomic, strong)   UIView       *bottomMaskView;

@end

@implementation FHDetailGrayLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailGrayLineModel class]]) {
        return;
    }
    self.currentData = data;
    CGFloat height = ((FHDetailGrayLineModel *)data).lineHeight;
    [self setBarHeight:height];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bottomMaskView = [[UIView alloc] init];
    _bottomMaskView.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    [self.contentView addSubview:_bottomMaskView];
    [self.bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
}

- (void)setBarHeight:(CGFloat)height {
    [self.bottomMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

@end
