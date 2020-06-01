//
//  FHEncyclopediaHeader.m
//  Pods
//
//  Created by liuyu on 2020/5/13.
//

#import "FHEncyclopediaHeader.h"
#import <Lynx/LynxView.h>
#import "FHLynxCoreBridge.h"
#import "FHLynxView.h"
#import "FHLynxManager.h"
#import "Masonry.h"
#import "NSObject+YYModel.h"
#import "FHLynxHeaderSegBridge.h"
@interface FHEncyclopediaHeader()<LynxViewClient>
@property (strong, nonatomic)LynxView *segmentView;
@property(nonatomic ,strong) NSData *currentTemData;
@property (nonatomic, assign) NSTimeInterval loadTime; //页面加载时间
@end

@implementation FHEncyclopediaHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
    [self segmentView];
}

- (LynxView *)segmentView {
    if (!_segmentView) {
                CGRect screenFrame = [UIScreen mainScreen].bounds;
             _segmentView = [[LynxView alloc] initWithBuilderBlock:^(LynxViewBuilder* builder) {
                    builder.isUIRunningMode = YES;
                    builder.config = [[LynxConfig alloc] initWithProvider:LynxConfig.globalConfig.templateProvider];
//                    [builder.config registerModule:[FHLynxCoreBridge class]];
                    [builder.config registerModule:[FHLynxHeaderSegBridge class] param:self];
               }];
             _segmentView.layoutWidthMode = LynxViewSizeModeExact;
             _segmentView.layoutHeightMode = LynxViewSizeModeUndefined;
             _segmentView.preferredLayoutWidth = screenFrame.size.width;
             _segmentView.client = self;
             _segmentView.preferredMaxLayoutHeight = screenFrame.size.height;
             [_segmentView triggerLayout];
             [self addSubview:_segmentView];
        NSData *templateData =  [[FHLynxManager sharedInstance] lynxDataForChannel:@"ugc_encyclopedia_lynx_header" templateKey:[FHLynxManager defaultJSFileName] version:0];
        [_segmentView loadTemplate:templateData withURL:@"local"];
//              NSData *templateData = templateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://10.95.248.197:30334/feed/template.js?1590050059493"]];
            [_segmentView loadTemplate:templateData withURL:@"local"];
              if (templateData) {
                   if (templateData != self.currentTemData) {
                       self.currentTemData = templateData;
                      [self.segmentView loadTemplate:templateData withURL:@"local"];
                   }
               }
    }
    return _segmentView;
}

- (void)updateModel:(EncyclopediaConfigDataModel *)model {
    NSString *lynxData = [model yy_modelToJSONString];
    [_segmentView updateDataWithString:lynxData];
    
}

- (void)onSelectChange:(id )param {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectSegmentWithData:)]){
        [self.delegate selectSegmentWithData:param];
    }
}
@end
