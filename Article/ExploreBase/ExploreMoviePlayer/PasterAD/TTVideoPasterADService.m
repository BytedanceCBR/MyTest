//
//  TTVideoPasterADService.m
//  Article
//
//  Created by lijun.thinker on 2017/3/22.
//
//

#import "TTVideoPasterADService.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTVideoPasterADModel.h"


@interface TTVideoPasterADService()

@property (nonatomic, copy) NSString *pasterADRequetURLStr;

@property (nonatomic, strong) fetchPasterADInfoCompletion fetchPasterADInfoCompletion;

@end

@implementation TTVideoPasterADService

- (void)fetchPasterADInfoWithRequestInfo:(TTVideoPasterADURLRequestInfo *)requestInfo completion:(fetchPasterADInfoCompletion)completion {
    
    self.fetchPasterADInfoCompletion = completion;
    
    self.pasterADRequetURLStr = [self p_getAPIPrefix];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    parameters[@"ad_from"] = requestInfo.adFrom;
    parameters[@"group_id"] = requestInfo.groupID;
    parameters[@"item_id"] = requestInfo.itemID;
    parameters[@"category"] = requestInfo.category;

    __weak typeof (self) wself = self;

    [[TTNetworkManager shareInstance] requestForJSONWithURL:self.pasterADRequetURLStr params:parameters method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
       
        __strong  TTVideoPasterADService *sself = wself;
        if (!sself) {
            return;
        }
        
        if (!error && jsonObj) {
                
            [sself p_handlePasterADRequestFinished:jsonObj[@"data"]];
        } else {
            
            if (completion) {
                
                completion(nil, error);
            }
        }
    }];
}

- (void)p_handlePasterADRequestFinished:(NSDictionary *)result {
    
    if (![result isKindOfClass:[NSDictionary class]]) {
        
        return;
    }
    
    NSArray *ADItem = [result arrayValueForKey:@"ad_item" defaultValue:nil];
    TTVideoPasterADInfoModel *pasterADInfoModel = [[TTVideoPasterADInfoModel alloc] initWithDictionary:[ADItem firstObject] error:nil];
    
    TTVideoPasterADModel *pasterADModel = [TTVideoPasterADModel new];
    pasterADModel.videoPasterADInfoModel = pasterADInfoModel;

    if (pasterADInfoModel.videoInfo) {
        
        pasterADModel.style = TTVideoPasterADStyleVideo;
    } else if (pasterADInfoModel.imageList.count > 0) {
        
        pasterADModel.style = TTVideoPasterADStyleImage;

    }
    
    if (!isEmptyString(pasterADInfoModel.type) &&
        [pasterADInfoModel.type isEqualToString:@"web"]) {
        
        pasterADModel.type = TTVideoPasterADPageTypeWeb;
        
    } else if (!isEmptyString(pasterADInfoModel.type) &&
               [pasterADInfoModel.type isEqualToString:@"app"]) {
        
        pasterADModel.type = TTVideoPasterADPageTypeAPP;
    }
    
    pasterADModel = ([self isValidResult:pasterADModel]) ? pasterADModel: nil;
    
    if (self.fetchPasterADInfoCompletion) {
        
        self.fetchPasterADInfoCompletion(pasterADModel, nil);
    }
    
}

- (NSString *)p_getAPIPrefix {

    return [NSString stringWithFormat:@"%@/api/ad/post_patch/v1/", [CommonURLSetting baseURL]];
}

- (BOOL)isValidResult:(TTVideoPasterADModel *)model {
    
    if (model &&
        !isEmptyString(model.videoPasterADInfoModel.adID.stringValue) &&
        (model.type == TTVideoPasterADPageTypeWeb || model.type == TTVideoPasterADPageTypeAPP) &&
        (model.style == TTVideoPasterADStyleImage || model.style == TTVideoPasterADStyleVideo)) {
        
        return YES;
    }
    
    return NO;
}

@end

@implementation TTVideoPasterADURLRequestInfo

@end
