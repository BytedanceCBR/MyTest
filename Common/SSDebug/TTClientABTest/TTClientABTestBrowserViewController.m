//
//  TTClientABTestBrowserViewController.m
//  Article
//
//  Created by zuopengliu on 6/11/2017.
//

#import "TTClientABTestBrowserViewController.h"
#import "TTExpermimentPreviewViewController.h"
#import <TTABManager/TTABManager.h>
#import <TTABManager/TTABStorageManager.h>
#import <TTABManager/TTABManagerUtil.h>
#import <TTABManager/TTABLayer.h>
#import <TTABManager/TTABHelper.h>



@protocol TTABManagerPrivateData <NSObject>
@property (nonatomic, strong) NSMutableArray<TTABLayer *> *layers;
@optional
- (void)_launchDistributionForABGroup:(NSDictionary *)dict;
@end
@interface TTABManager()
<
TTABManagerPrivateData
>
@end

@protocol TTABHelperPrivateData <NSObject>
@property(nonatomic, strong, readwrite) TTABManager *ABManager;
@end
@interface TTABHelper()
<
TTABHelperPrivateData
>
@end



@interface _TTExperimentCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *rangeLabel;
+ (CGFloat)height;
@end

@implementation _TTExperimentCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        [self initDefaultViews];
    }
    return self;
}

- (void)initDefaultViews
{
    if (!self.nameLabel.superview)  [self.contentView addSubview:self.nameLabel];
    if (!self.resultLabel.superview)  [self.contentView addSubview:self.resultLabel];
    if (!self.rangeLabel.superview)  [self.contentView addSubview:self.rangeLabel];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initDefaultViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat totalWidth = CGRectGetWidth(self.contentView.bounds);
    self.nameLabel.frame = CGRectMake(20, 5, totalWidth - 2 * 20, 20);
    
    self.rangeLabel.frame = CGRectMake(20, self.nameLabel.bottom + 5, totalWidth - 2 * 20, 20);
    
    self.resultLabel.frame = CGRectMake(20, self.rangeLabel.bottom + 5, totalWidth - 2 * 20, 60);
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.numberOfLines = 1;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.text = @"试验名称: ***";
    }
    return _nameLabel;
}

- (UILabel *)resultLabel
{
    if (!_resultLabel) {
        _resultLabel = [UILabel new];
        _resultLabel.numberOfLines = 3;
        _resultLabel.backgroundColor = [UIColor clearColor];
        _resultLabel.textAlignment = NSTextAlignmentLeft;
        _resultLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _resultLabel.font = [UIFont systemFontOfSize:14];
        _resultLabel.textColor = [UIColor redColor];
        _resultLabel.text = @"命中试验结果: {\nfeatureKey: ***, \nfeatureValue: *** }";
    }
    return _resultLabel;
}

- (UILabel *)rangeLabel
{
    if (!_rangeLabel) {
        _rangeLabel = [UILabel new];
        _rangeLabel.numberOfLines = 1;
        _rangeLabel.backgroundColor = [UIColor clearColor];
        _rangeLabel.textAlignment = NSTextAlignmentLeft;
        _rangeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _rangeLabel.font = [UIFont systemFontOfSize:14];
        _rangeLabel.textColor = [UIColor blackColor];
        _rangeLabel.text = @"命中试验区间: [***, ***)";
    }
    return _rangeLabel;
}

+ (CGFloat)height
{
    return 120.f;
}

@end



@implementation TTExperimentResultModel

@end

@interface TTClientABTestBrowserViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;

// 客户端试验及结果
@property (nonatomic, strong) NSArray<TTExperimentResultModel *> *experimentsArray;

@end

@implementation TTClientABTestBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUIKitDefault];
    [self setupNavigationBar];
    [self setupTableView];
    
    [self loadDataSource];
    
    [self.tableView reloadData];
}

- (void)setupUIKitDefault
{
    self.view.backgroundColor = [UIColor whiteColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setupNavigationBar
{
    self.title = @"客户端AB试验";
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.frame = self.view.bounds;
    
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    contentInset.top = [[UIDevice currentDevice].systemVersion floatValue] > 7.0 ? 64.f : 0.f;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            contentInset.top = MAX(88, self.additionalSafeAreaInsets.top);
            contentInset.bottom = MAX(34, self.additionalSafeAreaInsets.bottom);
        }
    }
#endif
    [self.tableView setContentInset:contentInset];
    [self.tableView setScrollIndicatorInsets:contentInset];
    
    [self.view addSubview:self.tableView];
}

- (void)loadDataSource
{
    NSMutableArray *experimentsModels = [NSMutableArray array];
    
    NSArray<TTABLayer *> *layers = [[[TTABHelper sharedInstance_tt].ABManager layers] copy];
    if (!layers)  {
        NSDictionary *ABJSON = [TTABManagerUtil readABJSON];
        
        if ((![ABJSON isKindOfClass:[NSDictionary class]] || [ABJSON count] == 0)) {
            NSLog(@"没有找到ab.json文件或读取异常！！！！！！");
        }
        if ([[TTABHelper sharedInstance_tt].ABManager respondsToSelector:@selector(_launchDistributionForABGroup:)]) {
            [[TTABHelper sharedInstance_tt].ABManager _launchDistributionForABGroup:ABJSON];
        } else {
            NSLog(@"请确认TTABManager函数名称是否发生变更！！！！！！");
        }
        
        layers = [[[TTABHelper sharedInstance_tt].ABManager layers] copy];
    }
    
    [layers enumerateObjectsUsingBlock:^(TTABLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        if (layer) {
            __block NSArray *featureKeys = nil;
            [layer.experiments enumerateObjectsUsingBlock:^(TTABLayerExperiment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[obj.results allKeys] count] > 0) {
                    featureKeys = [[obj.results allKeys] copy];
                    *stop = YES;
                }
            }];
            
            __block NSString *featureKey = nil;
            __block NSString *featureValue = nil;
            [featureKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tmpFeatureValue = [[TTABHelper sharedInstance_tt] valueForFeatureKey:obj];
                if (tmpFeatureValue && [tmpFeatureValue length] > 0) {
                    featureKey = [obj copy];
                    featureValue = [tmpFeatureValue copy];
                    *stop = YES;
                }
            }];
            
            // {layerName: ranodmValue}
            NSDictionary *randomValues = [TTABStorageManager randomNumber];
            NSInteger hitRandomValue = layer.layerName ? [[randomValues valueForKey:layer.layerName] integerValue] : -1;
            
            TTExperimentResultModel *model = [TTExperimentResultModel new];
            model.layer = layer;
            model.hitRandomValue = hitRandomValue;
            model.hitExperiment = [layer experimentForRandomValue:hitRandomValue];
            model.featureKey = featureKey;
            model.featureValue = featureValue;
            
            if (model) [experimentsModels addObject:model];
        }
    }];
    
    self.experimentsArray = [experimentsModels copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.experimentsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_TTExperimentCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kTTClientABCellIdentifier = @"clientABCellIdentifier";
    _TTExperimentCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTClientABCellIdentifier];
    if (!cell) {
        cell = [[_TTExperimentCell alloc] initWithReuseIdentifier:kTTClientABCellIdentifier];
    }
    
    {
        TTExperimentResultModel *selectedExperimentMdl = indexPath.row < self.experimentsArray.count ? self.experimentsArray[indexPath.row] : nil;
        if (selectedExperimentMdl) {
            cell.nameLabel.text = [NSString stringWithFormat:@"试验名称: %@",
                                   selectedExperimentMdl.layer.layerName];
            cell.resultLabel.text = [NSString stringWithFormat:@"命中试验结果: {\nfeatureKey: %@, \nfeatureValue: %@ }",
                                     selectedExperimentMdl.featureKey ? : @"***",
                                     selectedExperimentMdl.featureValue ? : @"***"];
            cell.rangeLabel.text = [NSString stringWithFormat:@"命中试验区间: [%ld, %ld)",
                                    (long)selectedExperimentMdl.hitExperiment.minRegion,
                                    (long)selectedExperimentMdl.hitExperiment.maxRegion];
        }
    }
    
    return cell ? : [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TTExperimentResultModel *selectedExperimentMdl = indexPath.row < self.experimentsArray.count ? self.experimentsArray[indexPath.row] : nil;
    if (selectedExperimentMdl) {
        TTExpermimentPreviewViewController *experimentVC = [TTExpermimentPreviewViewController new];
        [experimentVC showExperiment:selectedExperimentMdl];
        UINavigationController *experimentNavVC = [[UINavigationController alloc] initWithRootViewController:experimentVC];
        [self presentViewController:experimentNavVC animated:YES completion:^{
            
        }];
    }
}

@end
