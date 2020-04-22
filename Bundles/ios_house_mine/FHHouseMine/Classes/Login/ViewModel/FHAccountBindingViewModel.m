//
//  FHAccountBindingViewModel.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import "FHAccountBindingViewModel.h"
#import "FHThirdAccountsHeaderView.h"
#import "TTAccountManager.h"
#import "TTAccount+PlatformAuthLogin.h"
#import "FHDouYinBindingCell.h"
#import "FHPhoneBindingCell.h"

typedef NS_ENUM(NSUInteger, FHSectionType) {
    kFHSectionTypeNone,
    kFHSectionTypeBindingInfo,      // 绑定修改（手机号、密码等）
    kFHSectionTypeThirdAccounts,    // 关联帐号
};

typedef NS_ENUM(NSUInteger, FHCellType) {
    kFHCellTypeNone,
    kFHCellTypeBindingPhone,        //绑定的手机号
    kFHCellTypeBindingDouYin,       //抖音一键登录
};

@interface FHAccountBindingViewModel ()<UITableViewDelegate,UITableViewDataSource,
        FHDouYinBindingCellDelegate>

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) FHAccountBindingViewController *viewController;


@end

@implementation FHAccountBindingViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHAccountBindingViewController *)viewController {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        [self registerCellClasses];
        
        self.viewController = viewController;
    }
    return self;
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHDouYinBindingCell class] forCellReuseIdentifier:@"kFHCellTypeBindingDouYin"];
    [self.tableView registerClass:[FHPhoneBindingCell class] forCellReuseIdentifier:@"kFHCellTypeBindingPhone"];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < 2 && indexPath.row < 1) {
        switch ([self cellTypeOfIndexPath:indexPath]) {
            case kFHCellTypeBindingPhone:{
                FHPhoneBindingCell *cell = (FHPhoneBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHCellTypeBindingPhone"];
                cell.contentLabel.text = [self mobilePhoneNumber];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
            case kFHCellTypeBindingDouYin:{
                FHDouYinBindingCell *cell = (FHDouYinBindingCell *)[tableView dequeueReusableCellWithIdentifier:@"kFHCellTypeBindingDouYin"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.delegate = self;
                [cell refreshSwitch];
                return cell;
            }
                break;
            default:
                break;
        }
    }
    return [[UITableViewCell alloc]init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch ([self sectionTypeOfIndex:section]) {
            case kFHSectionTypeBindingInfo:{
                return 6.0;
                break;
            }
            case kFHSectionTypeThirdAccounts:{
                return 42.0;
                break;
            }
            default:{
                return 0.0;
            }
                break;
        }
        return 0.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = nil;
    switch ([self sectionTypeOfIndex:section]) {
        case kFHSectionTypeBindingInfo:{
            UIView *sectionHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 6.0)];
            aView = sectionHeaderView;
            break;
        }
        case kFHSectionTypeThirdAccounts:{
            FHThirdAccountsHeaderView *sectionHeaderView = [[FHThirdAccountsHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 42.0)];
            aView = sectionHeaderView;
            break;
        }
        default:{
            aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.0)];
        }
            break;
    }
    aView.backgroundColor = [UIColor clearColor];
    return aView;
}



#pragma mark - UITableViewDelegate


#pragma mark - private methods
- (NSString *)mobilePhoneNumber
{
    return [[TTAccount sharedAccount] user].mobile;
}



-(void)initData{
    if (!_sections) {
        _sections = [NSMutableArray array];
    }
    [self.sections removeAllObjects];
    [self.sections addObjectsFromArray:@[
        @(kFHSectionTypeBindingInfo),
        @(kFHSectionTypeThirdAccounts)
    ]
    ];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (FHSectionType)sectionTypeOfIndex:(NSUInteger)section{
    if (section >= [self.sections count]) return kFHSectionTypeNone;
    return [[self.sections objectAtIndex:section] unsignedIntegerValue];
}

- (FHCellType)cellTypeOfIndexPath:(NSIndexPath *)indexPath
{
    FHCellType cellType = kFHCellTypeNone;
    switch ([self sectionTypeOfIndex:indexPath.section]) {
        case kFHSectionTypeBindingInfo:
            if (indexPath.row == 0) {
                cellType = kFHCellTypeBindingPhone;
            }
            break;
        case kFHSectionTypeThirdAccounts:
            if (indexPath.row == 0) {
                cellType = kFHCellTypeBindingDouYin;
            }
            break;
        default:
            break;
    }
    return cellType;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (section >= [self.sections count]) {
        return 0;
    }
    NSUInteger numberOfRows = 0;
    switch ([self sectionTypeOfIndex:section]) {
        case kFHSectionTypeBindingInfo:
            numberOfRows = 1;
            break;
        case kFHSectionTypeThirdAccounts:
            numberOfRows = 1;
            break;
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark - public methods
- (BOOL)hasDouYinAccount{
    NSArray<TTAccountPlatformEntity *> *connects = [[TTAccount sharedAccount] user].connects;
    for (TTAccountPlatformEntity *ent in connects) {
        if ([ent.platformUID isEqualToString:@"97353843919" ]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL)transformDouYinAccount:(BOOL)isOn{
    
    if (!isOn) {
        [TTAccount requestBindV2ForPlatform:TTAccountAuthTypeDouyin inCustomWebView:NO willBind:^(NSString * _Nonnull Bindinfo){
            NSLog(@"luowentao Bindinfo:%@",Bindinfo);
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"luowentao success = %d error = %@",success,error);
        }];
    } else {
        [TTAccount requestLogoutForPlatform:TTAccountAuthTypeDouyin completion:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"luowentao success = %d error = %@",success,error);
        }];
    }

    return YES;
};



@end
