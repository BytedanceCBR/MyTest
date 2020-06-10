//
//  FHUGCCellOriginItemView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/7/19.
//

#import "FHUGCCellOriginItemView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"
#import "FHUserTracker.h"
#import "UIImageView+BDWebImage.h"
#import "TTRoute.h"
#import "JSONAdditions.h"
#import "FHUGCCellHelper.h"
#import "TTImageView+TrafficSave.h"

@interface FHUGCCellOriginItemView ()<TTUGCAsyncLabelDelegate>

@property(nonatomic ,strong) TTImageView *iconView;
@property(nonatomic ,strong) TTUGCAsyncLabel *contentLabel;
@property(nonatomic ,assign) BOOL isClickLink;

@end

@implementation FHUGCCellOriginItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor themeGray7];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
    
    //这里有个坑，加上手势会导致@不能点击
    self.userInteractionEnabled = YES;
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToDetail:)];
//    singleTap
//    [self addGestureRecognizer:singleTap];
    
    self.iconView = [[TTImageView alloc] init];
    _iconView.hidden = YES;
    _iconView.backgroundColor = [UIColor whiteColor];
    _iconView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    _iconView.clipsToBounds = YES;
    [self addSubview:_iconView];
    
    self.contentLabel = [[TTUGCAsyncLabel alloc] initWithFrame:CGRectZero];
    _contentLabel.numberOfLines = 2;
    _contentLabel.layer.masksToBounds = YES;
    _contentLabel.backgroundColor = [UIColor themeGray7];
    _contentLabel.delegate = self;
    [self addSubview:_contentLabel];
}

- (void)initConstraints {
    self.contentLabel.left = 10;
    self.contentLabel.width = self.width - 20;
    self.contentLabel.height = 80;
    self.contentLabel.centerY = self.height/2;

    self.iconView.left = 10;
    self.iconView.width = 60;
    self.iconView.height = 60;
    self.iconView.centerY = self.height/2;
}

- (void)refreshWithdata:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        
        if(self.cellModel == cellModel && !cellModel.ischanged){
            return;
        }
        
        self.cellModel = cellModel;
        if(cellModel.originItemModel.imageModel){
//            [self.iconView bd_setImageWithURL:[NSURL URLWithString:cellModel.originItemModel.imageModel.url] placeholder:nil];
            TTImageInfosModel *imageInfoModel = [FHUGCCellHelper convertTTImageInfosModel:cellModel.originItemModel.imageModel];
            __weak typeof(self) wSelf = self;
            [self.iconView setImageWithModelInTrafficSaveMode:imageInfoModel placeholderImage:nil success:nil failure:^(NSError *error) {
                [wSelf.iconView setImage:nil];
            }];
            _iconView.hidden = NO;
            
            self.contentLabel.left = 80;
            self.contentLabel.width = self.width - 90;
            self.contentLabel.height = 80;
            self.contentLabel.centerY = self.height/2;
        }else{
            _iconView.hidden = YES;
            self.contentLabel.left = 10;
            self.contentLabel.width = self.width - 20;
            self.contentLabel.height = cellModel.originItemHeight;
            self.contentLabel.top = 0;
        }
        [FHUGCCellHelper setOriginRichContent:self.contentLabel model:cellModel numberOfLines:2];
    }
}

- (void)goToDetail {
    NSString *routeUrl = self.cellModel.originItemModel.openUrl;
    if(routeUrl){
        TTRouteUserInfo *userInfo = nil;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSURL *openUrl = [NSURL URLWithString:routeUrl];
        if([openUrl.scheme isEqualToString:@"thread_detail"]){
            dict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"];
            dict[@"category_name"] = self.cellModel.tracerDic[@"category_name"]?:@"be_null";
            dict[@"enter_from"] = self.cellModel.tracerDic[@"page_type"];
            dict[@"enter_type"] = @"feed_content_blank";
            dict[@"rank"] = self.cellModel.tracerDic[@"rank"];
        }else{
            NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
            tracerDic[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
            tracerDic[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
            tracerDic[@"category_name"] = self.cellModel.tracerDic[@"category_name"] ?: @"be_null";
            dict[@"tracer"] = tracerDic;
        }
        
        userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //这里由于单击和长按都会触发这个方法，长按可能会导致黑屏的问题，所以这个只保留单击跳转，屏蔽长按的情况
    UITouch *touch = [touches anyObject];
    BOOL hasLongPress = NO;
    
    for (UIGestureRecognizer *gesture in touch.gestureRecognizers) {
        if([gesture isKindOfClass:[UILongPressGestureRecognizer class]]){
            hasLongPress = YES;
            break;
        }
    }
    
    if(!hasLongPress){
        [self goToDetail];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touch_end");
}

#pragma mark - TTUGCAsyncLabelDelegate

- (void)asyncLabel:(TTUGCAsyncLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if(self.goToLinkBlock){
        self.goToLinkBlock(self.cellModel, url);
    }
}

@end
