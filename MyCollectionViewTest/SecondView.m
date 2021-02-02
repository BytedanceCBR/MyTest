//
//  SecondView.m
//  MyCollectionViewTest
//
//  Created by bytedance on 2021/2/2.
//

#import "SecondView.h"
@interface SecondView()
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UILabel *label;
@end
@implementation SecondView

- (void)initView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 20;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:self.tableView];
    
    self.label = [[UILabel alloc] init];
    self.label.text = @"123";
    [self.view addSubview:self.label];
    
}
- (void)initConstraint
{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initConstraint];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"123";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text=@"1222222";
   
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cell.contentView);
        make.centerX.mas_equalTo(cell.contentView);
        make.width.mas_equalTo(cell.contentView);
        make.height.mas_equalTo(40);
    }];
    if(indexPath.row>=3){
        cell.detailTextLabel.text = @"1232151251";
        cell.detailTextLabel.font = cell.textLabel.font;
        [cell.detailTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cell.textLabel.mas_bottom);
            make.left.mas_equalTo(cell.contentView);
            make.width.mas_equalTo(cell.contentView);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(cell.mas_bottom);
        }];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
        
    return cell;
}
@end
