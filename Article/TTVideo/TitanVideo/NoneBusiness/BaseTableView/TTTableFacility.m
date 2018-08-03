
#import "TTTableFacility.h"
#import "TTSectionDataSource.h"

typedef void(^FinishBlock)(void);

@interface TTTableFacility ()
@property (nonatomic) TTTableConfigure          *configure;
@property (nonatomic) UITableView               *tableView;
@property (nonatomic) TTDataSource              *ep_dataSource;
@property (nonatomic) UIView <TTViewProtocol>   *ep_tableHeaderView;
@property (nonatomic) UIView <TTViewProtocol>   *ep_tableFooterView;
@property (nonatomic ,copy) FinishBlock loadFinishedBlock;
@property (nonatomic ,copy) FinishBlock loadMoreFinishedBlock;
@property (nonatomic ,weak) NSObject <TTDataSourceDelegate, TTSectionDataSourceDelegate,TTBaseCellAction> *delegate;
@property (nonatomic ,readwrite) TTTableViewModel *viewModel;
@end

@implementation TTTableFacility
- (instancetype)initWithTableView:(UITableView *)table
                   tableConfigure:(TTTableConfigure *)configure
                    tableDelegate:(NSObject <TTDataSourceDelegate, TTSectionDataSourceDelegate,TTBaseCellAction> *)delegate
{
    self = [super init];
    if (self) {
        self.tableView = table;
        self.configure = configure;
        self.delegate = delegate;
        [self ep_init];
    }
    return self;
}

- (void)dealloc {
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)ep_init {
    _viewModel = [[self.configure.viewModelClass alloc] init];
    _ep_dataSource = [[self.configure.dataSourceClass alloc] init];
    [self renderTableView];
    if ([self.configure.tableFooterClass conformsToProtocol:@protocol(TTViewProtocol)]) {
        _ep_tableFooterView = [[self.configure.tableFooterClass alloc] init];
    }
    
    if ([self.configure.tableHeaderClass conformsToProtocol:@protocol(TTViewProtocol)]) {
        _ep_tableHeaderView = [[self.configure.tableHeaderClass alloc] init];
    }
}

- (void)renderTableView {
    
    if (self.ep_dataSource) {
        self.ep_dataSource.delegate = self.delegate;
        self.ep_dataSource.tableView = self.tableView;
        self.tableView.dataSource = self.ep_dataSource;
        self.tableView.delegate = self.ep_dataSource;
    }
    // 空footer，去掉下面的separatorline
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    if (self.ep_tableHeaderView) {
        self.tableView.tableHeaderView = self.ep_tableHeaderView;
    }
    
    if (self.ep_tableFooterView) {
        self.tableView.tableFooterView = self.ep_tableFooterView;
    }
}

- (void)updateTableFooterView:(id)data
{
    BOOL need = [self.ep_tableHeaderView needUpdate];
    [self.ep_tableHeaderView update:data];
    if (need) {
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;//tableHeaderView frame 变了以后需要重新赋值,tableview的tableHeaderView才能变过来
    }
}

- (void)updateTableHeaderView:(id)data
{
    BOOL need = [self.ep_tableFooterView needUpdate];
    [self.ep_tableFooterView update:data];
    if (need) {
        self.tableView.tableFooterView = self.tableView.tableFooterView;
    }
}

- (void)showErrorWithError:(NSError *)error
{
//    [SVProgressHUD showErrorWithStatus:error.userInfo[kEPNetworkUserinfoTipKey]];
}

- (void)loadLocal:(void(^)(TTTableViewModel *viewModel))finished
{

}

- (void)refreshDataWithParameter:(TTApiParameter *)parameter finished:(void (^)(TTTableViewModel *))finished error:(void (^)(NSError *))errorBlock
{
    WeakSelf;
    if (self.viewModel) {
        [self.viewModel loadDataWithParameters:parameter completeBlock:^() {
            StrongSelf;
            if (self.viewModel.dataArr.count > 0)
            {
                [self.ep_dataSource updateFirstPageDataArray:self.viewModel.dataArr];
            }
            if (self.viewModel.footerData) {
                [self.ep_tableFooterView update:self.viewModel.footerData];
            }
            
            if (self.viewModel.headerData) {
                [self.ep_tableHeaderView update:self.viewModel.headerData];
            }
            
            if (self.viewModel.error.code != 0)
            {
                [self showErrorWithError:self.viewModel.error];
                if (!isNull(errorBlock)) {
                    errorBlock(self.viewModel.error);
                }
            }
            self.tableView.scrollEnabled = self.viewModel.dataArr.count > 0;
            if (!isNull(finished)) {
                finished(self.viewModel);
            }
        }];
    }
}

- (void)loadMoreWithMoreParameter:(TTApiParameter *)moreParameter finished:(void (^)(TTTableViewModel *))finished error:(void (^)(NSError *))errorBlock
{
    WeakSelf;
    if (self.viewModel) {
        [self.viewModel loadMoreWithParameters:moreParameter completeBlock:^() {
            StrongSelf;
            if (self.viewModel.error.code != 0)
            {
                [self showErrorWithError:self.viewModel.error];
                if (!isNull(errorBlock)) {
                    errorBlock(self.viewModel.error);
                }
            }
            else
            {
                if (self.viewModel.dataArr.count > 0)
                {
                    [self.ep_dataSource updateFirstPageDataArray:self.viewModel.dataArr];
                    [self.tableView reloadData];
                }
            }
            self.tableView.scrollEnabled = self.viewModel.dataArr.count > 0;
            if (!isNull(finished)) {
                finished(self.viewModel);
            }
        }];
    }
}

- (void)refreshTableWithData:(id)object
{
    __weak typeof(self) weakSelf = self;
    if (self.viewModel) {
        [self.viewModel loadTableWithData:object completeBlock:^() {
            if (weakSelf.viewModel.dataArr.count > 0)
            {
                [weakSelf.ep_dataSource updateFirstPageDataArray:weakSelf.viewModel.dataArr];
            }
            if (weakSelf.viewModel.footerData) {
                [weakSelf.ep_tableFooterView update:weakSelf.viewModel.footerData];
            }

            if (weakSelf.viewModel.headerData) {
                [weakSelf.ep_tableHeaderView update:weakSelf.viewModel.headerData];
            }
            weakSelf.tableView.scrollEnabled = weakSelf.viewModel.dataArr.count > 0;
        }];
    }
}

- (void)removeCellAtIndexPath:(NSArray<NSIndexPath *> *)indexPaths animation:(UITableViewRowAnimation)animation
{
    [self.ep_dataSource removeCellAtIndexPath:indexPaths animation:animation];
}

- (void)layoutTableViewCell
{
    [self.ep_dataSource updateFirstPageDataArray:self.viewModel.dataArr];
    [self.ep_tableHeaderView doLayoutSubviews];
}
@end
