//
//  FHHomeHeaderTableViewCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeHeaderTableViewCell.h"
#import "FHHomeCellHelper.h"
#import "FHHomeTableViewDelegate.h"
#import "FHHomeConfigManager.h"

@interface FHHomeHeaderTableViewCell()
@property (nonatomic, strong) FHHomeTableViewDelegate *tableViewDelegate;
@end

@implementation FHHomeHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableViewDelegate = [[FHHomeTableViewDelegate alloc] init];
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    [self addSubview:self.contentTableView];
    self.contentTableView.backgroundColor = [UIColor whiteColor];
    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _contentTableView.scrollEnabled = NO;
    _contentTableView.estimatedRowHeight = 120;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [FHHomeCellHelper registerCells:self.contentTableView];
    
    [FHHomeCellHelper registerDelegate:self.contentTableView andDelegate:self.tableViewDelegate];
}

- (void)refreshUI
{
    NSInteger num = arc4random()%4;
    switch (num) {
        case 0:
            self.contentTableView.backgroundColor = [UIColor redColor];
            break;
        case 1:
            self.contentTableView.backgroundColor = [UIColor blueColor];
            break;
        case 2:
            self.contentTableView.backgroundColor = [UIColor purpleColor];
            break;
        case 3:
            self.contentTableView.backgroundColor = [UIColor orangeColor];
            break;
        default:
            break;
    }
}

- (void)refreshWithData:(nonnull id)data
{
    
    
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
