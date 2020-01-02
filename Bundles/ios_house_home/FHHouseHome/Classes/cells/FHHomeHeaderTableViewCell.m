//
//  FHHomeHeaderTableViewCell.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeHeaderTableViewCell.h"
#import "FHHomeTableViewDelegate.h"
#import "FHHomeConfigManager.h"
#import <FHHouseBase/FHBaseTableView.h>
#import <UIColor+Theme.h>
@interface FHHomeHeaderTableViewCell()
@property (nonatomic, strong) FHHomeTableViewDelegate *tableViewDelegate;
@end

@implementation FHHomeHeaderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentTableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.contentTableView.scrollsToTop = NO;
        self.tableViewDelegate = [[FHHomeTableViewDelegate alloc] init];
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    [self addSubview:self.contentTableView];

    [self.contentTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.contentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.1)];
    self.contentTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.1)];

    _contentTableView.scrollEnabled = NO;
    _contentTableView.estimatedRowHeight = 120;
    self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [FHHomeCellHelper registerCells:self.contentTableView];
    
    [FHHomeCellHelper registerDelegate:self.contentTableView andDelegate:self.tableViewDelegate];
}

- (void)refreshUI:(FHHomeHeaderCellPositionType)type
{
    [[FHHomeCellHelper sharedInstance] refreshFHHomeTableUI:_contentTableView andType:type];
    self.contentTableView.backgroundColor = [UIColor themeHomeColor];
    self.backgroundColor = [UIColor themeHomeColor];
    self.contentView.backgroundColor = [UIColor themeHomeColor];
}

- (void)refreshUI
{
    self.contentTableView.backgroundColor = [UIColor themeHomeColor];
    self.backgroundColor = [UIColor themeHomeColor];
    self.contentView.backgroundColor = [UIColor themeHomeColor];
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
