//
//  TTKitchenViewController.m
//  Article
//
//  Created by SongChai on 2017/8/21.
//

#if INHOUSE

#import "TTKitchenViewController.h"
#import "TTNavigationController.h"
#import "TTKitchenMgr.h"
#import "TTInstallIDManager.h"
#import "TTNetworkManager.h"
#import "SSThemed.h"
#import "TTDebugRealStorgeService.h"
#import "UIView+TTCSSUIKit.h"
#import "NSString+TTCSSUIKit.h"
#import "Masonry.h"
#import "FlexManager.h"
#import "FRLogViewController.h"
#import "UIView+UGCAdditions.h"
#import "UIViewAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "TTUIResponderHelper.h"
#import "UIButton+TTAdditions.h"
#import "TTSandBoxHelper.h"
#import "CommonURLSetting.h"
//#import "TTDebugAssistant.h"
//#import "TTSystemInfoManager.h"

@interface NSArray (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface NSSet (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end
@interface NSDictionary (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level;
@end

@interface _TTNetWorkCellModel : NSObject
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat summaryHeight;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, strong) NSDictionary *originDict;
@end

@implementation _TTNetWorkCellModel
- (instancetype)initWithTitle:(NSString *)title summary:(NSString *)summary {
    self = [super init];
    self.title = title;
    self.summary = summary;
    self.titleHeight = [title tt_heightWithTheme:@"#TTNetworkTitleLabel" constrainedWidth:[UIScreen mainScreen].bounds.size.width];
    self.summaryHeight = [summary tt_heightWithTheme:@"#TTNetworkContentLabel" constrainedWidth:[UIScreen mainScreen].bounds.size.width];
    return self;
}
@end


@interface _TTNetWorkCell : UITableViewCell
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *summaryLabel;
@end

@implementation _TTNetWorkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [self.contentView ugc_addSubviewWithClass:[SSThemedLabel class] themePath:@"#TTNetworkTitleLabel"];
        _summaryLabel = [self.contentView ugc_addSubviewWithClass:[SSThemedLabel class] themePath:@"#TTNetworkContentLabel"];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [self.contentView ugc_addSubviewWithClass:[SSThemedLabel class] themePath:@"#TTNetworkTitleLabel"];
        _summaryLabel = [self.contentView ugc_addSubviewWithClass:[SSThemedLabel class] themePath:@"#TTNetworkContentLabel"];
    }
    
    return self;
}

- (void)setModel:(_TTNetWorkCellModel *)model {
    _titleLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, model.titleHeight);
    _summaryLabel.frame = CGRectMake(0, _titleLabel.height, [UIScreen mainScreen].bounds.size.width, model.summaryHeight);
    
    _titleLabel.text = model.title;
    _summaryLabel.text = model.summary;
}

@end

@interface _TTNetWorkHistoryViewController : SSViewControllerBase <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDC;

@property (nonatomic, copy) NSDictionary *allNetworkItems;
@property (nonatomic, strong) NSArray *allKeys;
@property (nonatomic, strong) NSArray *searchKeys;

@end

@interface _TTNetWorkHistoryPreviewViewController : SSViewControllerBase <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSDictionary *oneItemDict;

@end

@implementation _TTNetWorkHistoryViewController

+ (void)showNetWorkHistoryViewControllerInViewController:(UIViewController *)vc
{
    NSParameterAssert(vc != nil);
    
    if (!vc) {
        return;
    }
    
    _TTNetWorkHistoryViewController *networkHistoryViewController = [[_TTNetWorkHistoryViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:networkHistoryViewController];
    navigationController.view.backgroundColor = [UIColor whiteColor];
    [vc presentViewController:navigationController animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"网络请求历史";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(cancelActionFired:)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.searchBar = [[UISearchBar alloc] init];
    [self.searchBar sizeToFit];
    
    self.searchDC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDC.delegate = self;
    self.searchDC.searchResultsDataSource = self;
    self.searchDC.searchResultsDelegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[_TTNetWorkCell class] forCellReuseIdentifier:@"Identifier"];
    [self.searchDC.searchResultsTableView registerClass:[_TTNetWorkCell class] forCellReuseIdentifier:@"Identifier"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //[oneItem setValue:storeId forKey:@"store_id"];
        //[oneItem setValue:createAt forKey:@"created_at"];
        //[oneItem setValue:parsedObj forKey:@"value"];
        NSArray *allNetworkItems = [[TTDebugRealStorgeService sharedInstance] allNetworkItems];
        NSUInteger count = allNetworkItems.count;
        
        NSMutableDictionary *datas = [NSMutableDictionary dictionary];
        NSMutableArray *keys = [NSMutableArray array];
        while (count > 0) {
            count--;
            NSDictionary *oneItem = [allNetworkItems objectAtIndex:count];
            NSString *createAt = [oneItem tt_stringValueForKey:@"created_at"];
            NSDictionary *valueObj = [oneItem tt_dictionaryValueForKey:@"value"];
            NSString *title = [valueObj tt_stringValueForKey:@"display_name"];
            NSString *summary = [NSString stringWithFormat:@"%d %@", [valueObj tt_intValueForKey:@"status"], createAt];
            
            /**
            NSString *respContent = [[TTDebugRealStorgeService sharedInstance] networkResponseContentForStoreId:createAt];
            if (isEmptyString(respContent)) {
                respContent = @"null";
            } else {
                NSDictionary *dict = [_TTNetWorkHistoryViewController dictionaryWithJsonString:respContent];
                if (dict) {
                    respContent = [dict description];
                }
            }
             **/
            _TTNetWorkCellModel *model = [[_TTNetWorkCellModel alloc] initWithTitle:title summary:summary];
            model.originDict = oneItem;
            [datas setValue:model forKey:title];
            [keys addObject:title];
        }
        self.allKeys = [keys copy];
        self.allNetworkItems = [datas copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self.allKeys count];
    } else {
        return [self.searchKeys count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = nil;
    if (tableView == self.tableView) {
        key = self.allKeys[indexPath.row];
    } else {
        key = self.searchKeys[indexPath.row];
    }
    _TTNetWorkCellModel *model = [self.allNetworkItems objectForKey:key];
    return model.titleHeight + model.summaryHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _TTNetWorkCell *tableViewCell = (_TTNetWorkCell *)[tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    NSString *key = nil;
    if (tableView == self.tableView) {
        key = self.allKeys[indexPath.row];
    } else {
        key = self.searchKeys[indexPath.row];
    }
    _TTNetWorkCellModel *model = [self.allNetworkItems objectForKey:key];
    [tableViewCell setModel:model];
    return tableViewCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = nil;
    if (tableView == self.tableView) {
        key = self.allKeys[indexPath.row];
    } else {
        key = self.searchKeys[indexPath.row];
    }
    _TTNetWorkCellModel *model = [self.allNetworkItems objectForKey:key];
    
    _TTNetWorkHistoryPreviewViewController *previewVC = [[_TTNetWorkHistoryPreviewViewController alloc] init];
    previewVC.oneItemDict = model.originDict;
    [self.navigationController pushViewController:previewVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    
    self.searchKeys = [NSArray arrayWithArray:[self.allKeys filteredArrayUsingPredicate:preicate]];
    
    return YES;
}

#pragma mark -
- (void)cancelActionFired:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation _TTNetWorkHistoryPreviewViewController {
    UITextView *_valueTextView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _valueTextView = [[UITextView alloc] init];
    _valueTextView.layer.borderColor = [UIColor blackColor].CGColor;
    _valueTextView.layer.borderWidth = 1.f;
    _valueTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _valueTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    _valueTextView.frame = CGRectMake(5, 20, CGRectGetWidth(self.view.frame) - 10, CGRectGetHeight(self.view.frame) - 25);
    _valueTextView.editable = NO;
    [self.view addSubview:_valueTextView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //[oneItem setValue:storeId forKey:@"store_id"];
        //[oneItem setValue:createAt forKey:@"created_at"];
        //[oneItem setValue:parsedObj forKey:@"value"];
        NSString *createAt = [self.oneItemDict tt_stringValueForKey:@"created_at"];
        NSDictionary *valueObj = [self.oneItemDict tt_dictionaryValueForKey:@"value"];
        NSString *title = [valueObj tt_stringValueForKey:@"display_name"];
        
        NSString *respContent = [[TTDebugRealStorgeService sharedInstance] networkResponseContentForStoreId:createAt];
        if (isEmptyString(respContent)) {
            respContent = @"null";
        } else {
            NSDictionary *dict = [_TTNetWorkHistoryViewController dictionaryWithJsonString:respContent];
            if (dict) {
                respContent = [dict kc_descriptionWithLocale:nil indent:0];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"response:\n%@\n\n%@", respContent, self.oneItemDict.description];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = title;
            _valueTextView.text = content;
        });
    });

}

@end

@interface TTKitchenViewController ()
@property (nonatomic, strong) UIView *tableViewHeaderView;
@end

@implementation TTKitchenViewController


+ (void)load {
    RegisterRouteObjWithEntryName(@"ugc_kitchen");
}

+ (void)showInViewController:(UIViewController *)viewController {
    TTKitchenViewController *debugViewController = [[TTKitchenViewController alloc] init];
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:debugViewController];
    navigationController.ttDefaultNavBarStyle = @"White";
    UIViewController *currentVC = viewController ? : [TTUIResponderHelper topmostViewController];
    [currentVC presentViewController:navigationController animated:YES completion:NULL];
}

+ (UIButton *)kitchenShowButton {
    UIButton *btn = [UIButton new];
    
    __weak UIButton* weakButton = btn;
    [btn addTarget:weakButton withActionBlock:^{
        [TTKitchenViewController showInViewController:weakButton.viewController];
    } forControlEvent:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"icon_pen"] forState:UIControlStateNormal]; //随便加了个icon，可以换
    
    return btn;
}

- (UIView *)tableViewHeaderView {
    if (_tableViewHeaderView == nil) {
        _tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 50)];
        WeakSelf;
        UIButton *flexBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
        [flexBtn setTitle:@"FLEX" forState:UIControlStateNormal];
        [flexBtn addTarget:self withActionBlock:^{
            [[FLEXManager sharedManager] showExplorer];
        } forControlEvent:(UIControlEventTouchUpInside)];
        
        UIButton *apiReqBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
        [apiReqBtn setTitle:@"Api历史" forState:UIControlStateNormal];
        [apiReqBtn addTarget:self withActionBlock:^{
            StrongSelf;
            [self gotoNetworkHistory];
        } forControlEvent:(UIControlEventTouchUpInside)];
        
        UIButton *imageReqBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
        [imageReqBtn setTitle:@"FPS" forState:UIControlStateNormal];
        [imageReqBtn addTarget:self withActionBlock:^{
//            [TTDebugAssistant show];
//            [TTSystemInfoManager sharedInstance].sysInfoFlags = TTTopBarShowSysInfoFPS | TTTopBarShowSysInfoMemory | TTTopBarShowSysInfoCPU;
            
//            StrongSelf;
//            FRLogViewController *logViewController = [[FRLogViewController alloc] init];
//            [self presentViewController:logViewController animated:YES completion:nil];
        } forControlEvent:(UIControlEventTouchUpInside)];
        
        UIButton *settingsRefreshBtn = [_tableViewHeaderView ugc_addSubviewWithClass:[SSThemedButton class] themePath:@"#KitchenHeaderButton"];
        [settingsRefreshBtn setTitle:@"刷新Settings" forState:UIControlStateNormal];
        [settingsRefreshBtn addTarget:self withActionBlock:^{
            StrongSelf;
            [self clearSettings];
        } forControlEvent:(UIControlEventTouchUpInside)];

        
        [flexBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_tableViewHeaderView.mas_width).multipliedBy(0.25);
            make.height.equalTo(_tableViewHeaderView.mas_height);
            make.left.equalTo(_tableViewHeaderView.mas_left);
            make.top.equalTo(_tableViewHeaderView.mas_top);
        }];
        
        
        [apiReqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(flexBtn.mas_width);
            make.height.equalTo(flexBtn.mas_height);
            make.left.equalTo(flexBtn.mas_right);
            make.top.equalTo(flexBtn.mas_top);
        }];
        
        [imageReqBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(flexBtn.mas_width);
            make.height.equalTo(apiReqBtn.mas_height);
            make.left.equalTo(apiReqBtn.mas_right);
            make.top.equalTo(apiReqBtn.mas_top);
        }];
        
        [settingsRefreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(flexBtn.mas_width);
            make.height.equalTo(imageReqBtn.mas_height);
            make.left.equalTo(imageReqBtn.mas_right);
            make.top.equalTo(imageReqBtn.mas_top);
        }];
    }
    return _tableViewHeaderView;
}

- (void)configDataSources {
    
    NSArray *array = [[KitchenMgr allKitchenModels] copy];
    
    NSMutableArray *cellItems = [NSMutableArray arrayWithCapacity:array.count];
    
    for (TTKitchenModel *model in array) {
        if (model.type == TTKitchenModelTypeBOOL) {
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:model.summary target:model action:NULL];
            item.switchStyle = YES;
            item.switchAction = @selector(switchAction:);
            item.checked = [model isSwitchOpen];
            [cellItems addObject:item];
        } else {
            STTableViewCellItem *item = [[STTableViewCellItem alloc] initWithTitle:model.summary target:model action:nil];
            item.textFieldStyle = YES;
            item.textFieldAction = @selector(textFieldAction:);
            item.textFieldContent = [model text];
            [cellItems addObject:item];
        }
    }
    self.dataSource = @[[[STTableViewSectionItem alloc] initWithSectionTitle:@"kitchen" items:cellItems]];
}

- (void)viewDidLoad {
    self.title = @"Kitchen";
    [self configDataSources];
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.tableViewHeaderView;
}

- (void)clearSettings {
    NSMutableDictionary * getPara = [NSMutableDictionary dictionaryWithCapacity:10];
    [getPara setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    [getPara setValue:[TTSandBoxHelper appName] forKey:@"app_name"];
    [getPara setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [getPara setValue:[[TTInstallIDManager sharedInstance] installID] forKey:@"iid"];
    [getPara setObject:@1 forKey:@"app"];
    if ([TTSandBoxHelper isInHouseApp]) {
        [getPara setValue:@(1) forKey:@"inhouse"];
    }
    [getPara setValue:@(1) forKey:@"debug"];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting appSettingsURLString] params:getPara method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        StrongSelf;
        if (!error) {
            NSDictionary * appSettings = [[jsonObj tt_dictionaryValueForKey:@"data"] tt_dictionaryValueForKey: @"app"];
            if (appSettings) {
                [KitchenMgr parseSettings:appSettings];
                [self configDataSources];
                [self.tableView reloadData];
            }
        }
    }];
}

- (void)gotoNetworkHistory {
    [_TTNetWorkHistoryViewController showNetWorkHistoryViewControllerInViewController:self];
}
@end

@implementation NSArray (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"";
    if (level > 0) {
        tab = tabString;
    }
    [desc appendString:@"\t(\n"];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]
            || [obj isKindOfClass:[NSArray class]]
            || [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) kc_descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"%@\t%@,\n", tab, str];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t\"%@\",\n", tab, obj];
        } else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) kc_descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@,\n", tab, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t\"%@\",\n", tab, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t\"%@\",\n", tab, str];
                    } else {
                        [desc appendFormat:@"%@\t%@,\n", tab, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@,\n", tab, obj];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@,\n", tab, obj];
        }
    }
    
    [desc appendFormat:@"%@)", tab];
    
    return desc;
}
@end

@implementation NSDictionary (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"";
    if (level > 0) {
        tab = tabString;
    }
    
    [desc appendString:@"\t{\n"];
    
    // 遍历数组,self就是当前的数组
    for (id key in self.allKeys) {
        id obj = [self objectForKey:key];
        
        if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, obj];
        } else if ([obj isKindOfClass:[NSArray class]]
                   || [obj isKindOfClass:[NSDictionary class]]
                   || [obj isKindOfClass:[NSSet class]]) {
            [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, [obj kc_descriptionWithLocale:locale indent:level + 1]];
        } else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) kc_descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, str];
                    } else {
                        [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
        }
    }
    
    [desc appendFormat:@"%@}", tab];
    
    return desc;
}
@end

@implementation NSSet (KitchenUnicodeReadable)
- (NSString *)kc_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = @"\t";
    if (level > 0) {
        tab = tabString;
    }
    [desc appendString:@"\t{(\n"];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]
            || [obj isKindOfClass:[NSArray class]]
            || [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) kc_descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"%@\t%@,\n", tab, str];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [desc appendFormat:@"%@\t\"%@\",\n", tab, obj];
        } else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) kc_descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@\t%@,\n", tab, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@\t\"%@\",\n", tab, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@\t\"%@\",\n", tab, str];
                    } else {
                        [desc appendFormat:@"%@\t%@,\n", tab, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@\t%@,\n", tab, obj];
                }
            }
        } else {
            [desc appendFormat:@"%@\t%@,\n", tab, obj];
        }
    }
    
    [desc appendFormat:@"%@)}", tab];
    
    return desc;
}
@end

#endif
