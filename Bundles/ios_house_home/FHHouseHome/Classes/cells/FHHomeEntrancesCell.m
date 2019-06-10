//
//  FHHomeEntrancesCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeEntrancesCell.h"
#import "FHHomeCellHelper.h"
#import <TTDeviceHelper.h>
#import <FHHomeCellHelper.h>

@implementation FHHomeEntrancesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.boardView = [[FHRowsView alloc] initWithRowCount:[FHHomeCellHelper sharedInstance].kFHHomeIconRowCount withRowHight:[FHHomeCellHelper sharedInstance].kFHHomeIconDefaultHeight * [TTDeviceHelper scaleToScreen375] + 10];
        [self setUpSubViews];
    }
    return self;
}

- (void)setUpSubViews
{
    [self.contentView addSubview:_boardView];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [_boardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self.contentView);
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
