//
//  FHHomeEntrancesCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeEntrancesCell.h"

@implementation FHHomeEntrancesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.boardView = [[FHRowsView alloc] initWithRowCount:4];
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews
{
    [self addSubview:_boardView];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self);
    }];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
