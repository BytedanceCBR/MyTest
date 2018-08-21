//
//  TTExpermimentPreviewViewController.m
//  Article
//
//  Created by zuopengliu on 6/11/2017.
//

#import "TTExpermimentPreviewViewController.h"
#import "TTClientABTestBrowserViewController.h"
#import <TTABManager/TTABManager.h>
#import <TTABManager/TTABStorageManager.h>
#import <TTABManager/TTABManagerUtil.h>
#import <TTABManager/TTABLayer.h>
#import <TTABManager/TTABHelper.h>



@interface TTExpermimentPreviewViewController ()
<
UITextViewDelegate
>

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) UILabel *experimentLabel;

@property (nonatomic, strong) UITextView *hitExperimentPreviewTextView;

@property (nonatomic, strong) UITextView *experimentContentTextView;

@property (nonatomic, strong) TTExperimentResultModel *experimentModel;

@end

@implementation TTExpermimentPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUIKitDefault];
    [self setupNavigationBar];
    [self setupCustomViews];
    
    [self previewExperiment];
}

- (void)setupUIKitDefault
{
    self.view.backgroundColor = [UIColor whiteColor];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.contentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.contentSize = self.view.bounds.size;
    self.contentView.showsHorizontalScrollIndicator = NO;
    self.contentView.showsVerticalScrollIndicator = YES;
    self.contentView.scrollEnabled = NO;
    
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    contentInset.top = [[UIDevice currentDevice].systemVersion floatValue] > 7.0 ? 64.f : 0.f;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11.0, *)) {
        [self.contentView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            contentInset.top = MAX(88, self.additionalSafeAreaInsets.top);
            contentInset.bottom = MAX(34, self.additionalSafeAreaInsets.bottom);
        }
    }
#endif
    [self.contentView setContentOffset:CGPointZero animated:NO];
    [self.contentView setContentInset:contentInset];
    [self.contentView setScrollIndicatorInsets:contentInset];
    [self.contentView setContentOffset:CGPointMake(0, -contentInset.top) animated:NO];
    
    [self.view addSubview:self.contentView];
}

- (void)setupNavigationBar
{
    self.title = @"客户端试验***详情";
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(cancelExperimentVCAction:)];
}

- (void)setupCustomViews
{
    [self.contentView addSubview:self.hitExperimentPreviewTextView];
    [self.contentView addSubview:self.experimentContentTextView];
}

- (void)cancelExperimentVCAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showExperiment:(TTExperimentResultModel *)experimentData
{
    _experimentModel = experimentData;
}

- (void)previewExperiment
{
    {
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = [NSString stringWithFormat:@"试验:%@详情", self.experimentModel.layer.layerName ? : @"***"];
        titleLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 2 * 30, 44);
        self.navigationItem.titleView = titleLabel;
    }
    
    CGFloat marginInset = 20.f;
    CGFloat maxWidth = CGRectGetWidth(self.contentView.bounds) - 2 * marginInset;
    CGFloat maxHeight = CGRectGetHeight(self.contentView.bounds) - (self.contentView.contentInset.top + self.contentView.contentInset.bottom);
    {
        NSMutableString *exprimentResultText = [NSMutableString string];
        
        [exprimentResultText appendString:@"-----命中试验结果如下-----"];
        [exprimentResultText appendFormat:@"\n名称: %@", self.experimentModel.layer.layerName ? : @"***"];
        [exprimentResultText appendFormat:@"\nrandomValue: %ld", self.experimentModel.hitRandomValue];
        [exprimentResultText appendFormat:@"\nminRegion: %ld", (long)self.experimentModel.hitExperiment.minRegion];
        [exprimentResultText appendFormat:@"\nmaxRegion: %ld", (long)self.experimentModel.hitExperiment.maxRegion];
        [exprimentResultText appendFormat:@"\nfeatureKey: %@", self.experimentModel.featureKey];
        [exprimentResultText appendFormat:@"\nfeatureValue: %@", self.experimentModel.featureValue];
        
        self.hitExperimentPreviewTextView.text = [exprimentResultText copy];
        self.hitExperimentPreviewTextView.frame = CGRectMake(marginInset, 10, maxWidth, 160);
    }
    
    {
        NSDictionary *ABJSON = [TTABManagerUtil readABJSON];
        NSArray *abJSONTraficOrigLayers = ABJSON[@"traffic_map"];
        
        __block NSDictionary *hitOrigLayerData = nil;
        [abJSONTraficOrigLayers enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] && [obj count] > 0) {
                NSString *currentLayerName = obj[@"layer_name"];
                if (currentLayerName && self.experimentModel.layer.layerName &&
                    [currentLayerName isEqualToString:self.experimentModel.layer.layerName]) {
                    hitOrigLayerData = obj;
                    *stop = YES;
                }
            }
        }];
        
        self.experimentContentTextView.text = hitOrigLayerData.description;
        CGFloat topTextRangeHeight = self.hitExperimentPreviewTextView.bottom + 15;
        self.experimentContentTextView.frame = CGRectMake(marginInset, topTextRangeHeight, maxWidth, maxHeight - topTextRangeHeight);
    }
}

- (UILabel *)experimentLabel
{
    if (!_experimentLabel) {
        _experimentLabel = [UILabel new];
        _experimentLabel.numberOfLines = 0;
        _experimentLabel.clipsToBounds = YES;
        _experimentLabel.userInteractionEnabled = YES;
        _experimentLabel.backgroundColor = [UIColor clearColor];
        _experimentLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        _experimentLabel.layer.borderWidth = 1.0;
        _experimentLabel.textAlignment = NSTextAlignmentLeft;
        _experimentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _experimentLabel.font = [UIFont boldSystemFontOfSize:17];
        _experimentLabel.textColor = [UIColor blackColor];
    }
    return _experimentLabel;
}

- (UITextView *)hitExperimentPreviewTextView
{
    if (!_hitExperimentPreviewTextView) {
        _hitExperimentPreviewTextView = [[UITextView alloc] init];
        _hitExperimentPreviewTextView.font = [UIFont boldSystemFontOfSize:17];
        _hitExperimentPreviewTextView.backgroundColor = [UIColor whiteColor];
        _hitExperimentPreviewTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        _hitExperimentPreviewTextView.layer.borderWidth = 1.0;
        _hitExperimentPreviewTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _hitExperimentPreviewTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _hitExperimentPreviewTextView.editable = NO;
    }
    return _hitExperimentPreviewTextView;
}

- (UITextView *)experimentContentTextView
{
    if (!_experimentContentTextView) {
        _experimentContentTextView = [[UITextView alloc] init];
        _experimentContentTextView.font = [UIFont systemFontOfSize:16.f];
        _experimentContentTextView.backgroundColor = [UIColor whiteColor];
        _experimentContentTextView.layer.borderColor = [[UIColor blackColor] CGColor];
        _experimentContentTextView.layer.borderWidth = 1.0;
        _experimentContentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _experimentContentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        _experimentContentTextView.delegate = self;
        _experimentContentTextView.editable = NO;
    }
    return _experimentContentTextView;
}

@end
