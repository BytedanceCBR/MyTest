//
//  TTNetworkStubSwitchViewController.m
//  Article
//
//  Created by 延晋 张 on 16/5/30.
//
//

#import "TTNetworkStubSwitchViewController.h"
#import "TTNetworkStub.h"
#import "TTMagicSwitchTableViewCell.h"

static NSDictionary *switchItemDict;
static NSArray *switchItemSortedKeys;

@interface TTNetworkStubSwitchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableDictionary *statusDict;

@end

@implementation TTNetworkStubSwitchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *file = [[NSBundle mainBundle] pathForResource:@"NetworkStubItems" ofType:@"plist"];
            switchItemDict = [NSDictionary dictionaryWithContentsOfFile:file];
            switchItemSortedKeys = [switchItemDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *key1 = obj1;
                NSString *key2 = obj2;
                return [key1 compare:key2];
            }];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.listTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self.view addSubview:self.listTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"NetworkStubStatus"];
    self.statusDict = [NSMutableDictionary dictionaryWithDictionary:dict];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.statusDict) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:self.statusDict];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"NetworkStubStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return switchItemDict.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"switchCell";
    TTMagicSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TTMagicSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.row >= switchItemDict.count) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.on = NO;
        cell.valueChangedAction = nil;
        return cell;
    }
    
    NSString *key = switchItemSortedKeys[indexPath.row];
    NSDictionary *item = switchItemDict[key];
    
    cell.textLabel.text = key;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.on = [self.statusDict[key] boolValue];
    
    NSArray *configArray = nil;
    NSDictionary *subRequestsDict = item[@"subRequests"];
    if (subRequestsDict) {
        configArray = subRequestsDict.allValues;
        NSArray *nameArray = subRequestsDict.allKeys;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"子项目: %@", [nameArray componentsJoinedByString:@";"]];
    } else {
        configArray = @[item];
        cell.detailTextLabel.text = item[@"path"];
    }
    
    cell.valueChangedAction = ^void(BOOL newValue) {
        if (newValue && item) {
            [[TTNetworkStub sharedInstance] setupStub:key withConfigArray:configArray];
            [self.statusDict setObject:@(newValue) forKey:key];
        } else {
            [[TTNetworkStub sharedInstance] removeStub:key];
            [self.statusDict removeObjectForKey:key];
        }
    };
    
    return cell;
}

@end

