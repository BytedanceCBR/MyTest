//
//  TTVPasterADService.m
//  Article
//
//  Created by lijun.thinker on 2017/3/22.
//
//

#import "TTVPasterADService.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "TTVPasterADModel.h"


@interface TTVPasterADService()

@property (nonatomic, copy) NSString *pasterADRequetURLStr;

@property (nonatomic, strong) fetchPasterADInfoCompletion fetchPasterADInfoCompletion;

@end

@implementation TTVPasterADService

- (void)fetchPasterADInfoWithRequestInfo:(TTVPasterADURLRequestInfo *)requestInfo completion:(fetchPasterADInfoCompletion)completion {
    
    self.fetchPasterADInfoCompletion = completion;
    
    self.pasterADRequetURLStr = [self p_getAPIPrefix];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    [parameters setValue:requestInfo.adFrom forKey:@"ad_from"];
    [parameters setValue:requestInfo.groupID forKey:@"group_id"];
    [parameters setValue:requestInfo.itemID forKey:@"item_id"];
    [parameters setValue:requestInfo.category forKey:@"category"];

    __weak typeof (self) wself = self;

    [[TTNetworkManager shareInstance] requestForJSONWithURL:self.pasterADRequetURLStr params:parameters method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
       
        __strong  TTVPasterADService *sself = wself;
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
    TTVPasterADInfoModel *pasterADInfoModel = [[TTVPasterADInfoModel alloc] initWithDictionary:[ADItem firstObject] error:nil];
    
    TTVPasterADModel *pasterADModel = [TTVPasterADModel new];
    pasterADModel.videoPasterADInfoModel = pasterADInfoModel;

    if (pasterADInfoModel.videoInfo) {
        
        pasterADModel.style = TTVPasterADStyleVideo;
    } else if (pasterADInfoModel.imageList.count > 0) {
        
        pasterADModel.style = TTVPasterADStyleImage;

    }
    
    if (!isEmptyString(pasterADInfoModel.type) &&
        [pasterADInfoModel.type isEqualToString:@"web"]) {
        
        pasterADModel.type = TTVPasterADPageTypeWeb;
        
    } else if (!isEmptyString(pasterADInfoModel.type) &&
               [pasterADInfoModel.type isEqualToString:@"app"]) {
        
        pasterADModel.type = TTVPasterADPageTypeAPP;
    }
    
    pasterADModel = ([self isValidResult:pasterADModel]) ? pasterADModel: nil;
    
    if (self.fetchPasterADInfoCompletion) {
        
        self.fetchPasterADInfoCompletion(pasterADModel, nil);
    }
    
}

- (NSString *)p_getAPIPrefix {

    return [NSString stringWithFormat:@"%@/api/ad/post_patch/v1/", [CommonURLSetting baseURL]];
}

- (BOOL)isValidResult:(TTVPasterADModel *)model {
    
    if (model &&
        !isEmptyString(model.videoPasterADInfoModel.adID.stringValue) &&
        (model.type == TTVPasterADPageTypeWeb || model.type == TTVPasterADPageTypeAPP) &&
        (model.style == TTVPasterADStyleImage || model.style == TTVPasterADStyleVideo)) {
        
        return YES;
    }
    
    return NO;
}

@end
