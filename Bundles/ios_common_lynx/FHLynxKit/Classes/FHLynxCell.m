//
//  FHLynxCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import "FHLynxCell.h"

#import <Lynx/LynxView.h>
#import <mach/mach_time.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"

@implementation FHLynxCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        if (!_lynxView) {
          _lynxView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
                 builder.isUIRunningMode = YES;
                 builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
                 [builder.config registerModule:[FHLynxCoreBridge class]];
            }];
          _lynxView.layoutWidthMode = LynxViewSizeModeExact;
          _lynxView.layoutHeightMode = LynxViewSizeModeUndefined;
          _lynxView.preferredLayoutWidth = screenFrame.size.width;
          _lynxView.preferredMaxLayoutHeight = screenFrame.size.height;
          [_lynxView triggerLayout];
          self.contentView.backgroundColor = [UIColor whiteColor];
          [self.contentView addSubview:_lynxView];
        }
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
    NSString *instr = [NSString stringWithFormat:@"%ld", 0];
    NSString *prifix = @"recycler";
    NSString *path = [prifix stringByAppendingString:instr];
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:path ofType:@"js"];
    NSData *templateData = [NSData dataWithContentsOfFile:templatePath];
    [self.lynxView loadTemplate:templateData withURL:@"local"];
     self.lynxView.client = self;
}

#pragma mark - reload Lynx
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data
{
    _params = params;
    [self.lynxView setHidden:NO];
    if (data) {
        [self loadLynxBaseParams:params];
    }
}

- (void)reload
{
    [self reloadWithBaseParams:self.params data:self.currentData];
}

#pragma mark - load methods
- (void)loadLynxBaseParams:(FHLynxViewBaseParams *)params
{
    id templateData = nil;
    if (params.initialProperties) {
        if ([params.initialProperties isKindOfClass:[NSString class]]) {
            templateData = [[LynxTemplateData alloc] initWithJson:params.initialProperties];
        } else if ([params.initialProperties isKindOfClass:[NSDictionary class]]) {
            templateData = [[LynxTemplateData alloc] initWithDictionary:params.initialProperties];
        }
        LynxTemplateData *initialData = [[LynxTemplateData alloc] initWithDictionary:templateData];
        [self.lynxView loadTemplate:self.currentData withURL:params.sourceUrl initData:initialData];
    } else {
        [self.lynxView loadTemplate:self.currentData withURL:params.sourceUrl];
    }
}

- (void)updateData:(NSDictionary *)dict
{
    if (!dict) return;
    NSError *error = nil;
    [_lynxView updateDataWithString:[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error] encoding:NSUTF8StringEncoding]];
}

- (NSDictionary *)elementHouseShowUpload
{
    return @{};
}

- (void)vc_viewDidAppear:(BOOL)animated {
    
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    
}

- (void)fh_willDisplayCell {
    
}

- (void)fh_didEndDisplayingCell{

}

@end
