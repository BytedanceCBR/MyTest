//
//  TTVPlayerTipRelatedView.m
//  Article
//
//  Created by panxiang on 2017/10/12.
//

#import "TTVPlayerTipRelatedView.h"
#import "TTRoute.h"
#import "TTURLUtils.h"
#import "JSONAdditions.h"
#import <StoreKit/StoreKit.h>
#import "TTIndicatorView.h"

@implementation TTVPlayerTipRelatedEngityAuthor

//+ (JSONKeyMapper *)keyMapper {
//    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
//}

@end

@implementation TTVPlayerTipRelatedEngityVideo
@end

@implementation TTVPlayerTipRelatedEngityStats
@end

@implementation TTVPlayerTipImageList
@end

@interface TTVPlayerTipRelatedEntity()
@property (nonatomic ,strong)NSDictionary <Optional> *ack_clickDic;
@property (nonatomic ,strong)NSDictionary <Optional> *ack_valid_imprDic;
@end

@implementation TTVPlayerTipRelatedEntity
- (NSDictionary *)ack_clickDic
{
    NSData *data = [self.ack_click dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = _ack_clickDic;
    if (!dic) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if ([dic isKindOfClass:[NSDictionary class]]) {
        _ack_clickDic = (NSDictionary <Optional> *)dic;
        return dic;
    }
    return nil;
}

- (NSDictionary *)ack_valid_imprDic
{
    NSData *data = [self.ack_valid_impr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = _ack_valid_imprDic;
    if (!dic) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    if ([dic isKindOfClass:[NSDictionary class]]) {
        _ack_valid_imprDic = (NSDictionary <Optional> *)dic;
        return dic;
    }
    return nil;
}

@end


@interface TTVPlayerTipRelatedView()<SKStoreProductViewControllerDelegate>
@property (nonatomic ,strong)SKStoreProductViewController * skController;
@end

@implementation TTVPlayerTipRelatedView

- (void)setDataInfo:(NSDictionary *)dataInfo
{
    NSArray *array = [dataInfo valueForKey:@"data"];
    NSMutableArray *entitysArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NSError *error = nil;
        TTVPlayerTipRelatedEntity *entity = [[TTVPlayerTipRelatedEntity alloc] initWithDictionary:dic error:&error];
        if (entity) {
            [entitysArray addObject:entity];
        }
    }
    self.entitys = entitysArray;
}

- (void)startTimer
{
    
}

- (void)pauseTimer
{
    
}

- (void)openDownloadUrl:(TTVPlayerTipRelatedEntity *)entity
{
    
    if ([entity.app_apple_id length] > 0) {
        
        SKStoreProductViewController * skController = [[SKStoreProductViewController alloc] init];
        skController.delegate = self;
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:entity.app_apple_id, SKStoreProductParameterITunesItemIdentifier, nil];
        [skController loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
            if (error && error.code != 0) {
                NSString *message = NSLocalizedString(@"下载失败, 请稍后重试", nil);
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:message indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            }
        }];
        UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
        [topController presentViewController:skController animated:YES completion:^{
        }];
        self.skController = skController;
    }
    if ([self.delegate respondsToSelector:@selector(relatedViewClickAtItem:)]) {
        [self.delegate relatedViewClickAtItem:entity];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self.skController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
