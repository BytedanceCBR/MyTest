//
// Created by zhulijun on 2019-06-17.
//

#import "FHMessageItemCell.h"


@interface FHMessageItemCell()
@end

@implementation FHMessageItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUI {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {

}

- (void)initConstraints {

}

@end