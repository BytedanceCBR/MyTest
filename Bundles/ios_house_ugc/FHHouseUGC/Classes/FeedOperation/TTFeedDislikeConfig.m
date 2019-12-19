//
//  TTFeedDislikeConfig.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/20.
//

#import "TTFeedDislikeConfig.h"
#import "TTReportManager.h"
#import "TTAccountManager.h"
#import "FHUGCConfig.h"
#import "TTBaseMacro.h"

static NSString *const kTTNewDislikeReportOptions = @"tt_new_dislike_report_options";
@implementation TTFeedDislikeConfig

+ (BOOL)enableModernStyle {
    return YES;
}

+ (NSArray<NSDictionary *> *)reportOptions {
    NSDictionary *config = [self __newDislikeReportOptions];
    NSArray<NSDictionary *> *reportOptions = config[@"new_report_options"];
    for (NSDictionary *ro in reportOptions) {
        if (![ro isKindOfClass:[NSDictionary class]]) return nil;
    }
    return reportOptions;
}

+ (NSDictionary *)textStrings {
    NSDictionary *config = [self __newDislikeReportOptions];
    NSDictionary *textStrings = config[@"text_strings"];
    if ([textStrings isKindOfClass:[NSDictionary class]]) {
        return textStrings;
    }
    return nil;
}

+ (NSDictionary *)__newDislikeReportOptions {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:kTTNewDislikeReportOptions];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

+ (NSArray *)operationList {
    NSArray *operations = [[FHUGCConfig sharedInstance] operationConfig];
    NSMutableArray *operationList = [NSMutableArray array];
    
    for (FHUGCConfigDataPermissionModel *permissionModel in operations) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if(!isEmptyString(permissionModel.title)){
            dic[@"title"] = permissionModel.title;
        }
        
        if(!isEmptyString(permissionModel.subtitle)){
            dic[@"subTitle"] = permissionModel.subtitle;
        }
        
        dic[@"id"] = [self getTypeString:permissionModel.id];
        dic[@"serverType"] = permissionModel.id;
        
        [operationList addObject:dic];
    }
    
    //为了防止config接口无内容，默认的值
    if(operationList.count == 0){
        operationList = @[
                          @{
                              @"id": @"1",
                              @"title": @"举报",
                              @"subTitle": @"广告、低俗、重复、过时",
                              @"serverType":@"report"
                              },
                          @{
                              @"id": @"8",
                              @"title": @"编辑",
                              @"serverType":@"edit"
                              },
                          @{
                              @"id": @"2",
                              @"title": @"删除",
                              @"serverType":@"delete"
                              }
                          ].mutableCopy;

    }
    
    return operationList;
}

+ (NSArray *)operationList:(NSArray<FHUGCConfigDataPermissionModel> *)permission {
    NSMutableArray *operationList = [NSMutableArray array];
    
    for (FHUGCConfigDataPermissionModel *permissionModel in permission) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if(!isEmptyString(permissionModel.title)){
            dic[@"title"] = permissionModel.title;
        }
        
        if(!isEmptyString(permissionModel.subtitle)){
            dic[@"subTitle"] = permissionModel.subtitle;
        }
        
        dic[@"id"] = [self getTypeString:permissionModel.id];
        dic[@"serverType"] = permissionModel.id;
        [operationList addObject:dic];
    }

    return operationList;
}

+ (NSArray<FHFeedOperationWord *> *)operationWordList:(NSString *)userId {
    NSMutableArray<FHFeedOperationWord *> *items = @[].mutableCopy;

    NSArray *operationList = [self operationList];
    
    BOOL isShowDelete = [TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:userId];
    
    for (NSDictionary *dict in operationList) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
            if(word.type == FHFeedOperationWordTypeReport){
                word.items = [self fetchReportOptions:word.ID];
            }else{
                word.items = @[word];
            }
            
            //显示删除就不会显示举报
            if(word.type == FHFeedOperationWordTypeReport && !isShowDelete){
                [items addObject:word];
            }
            // 编辑 & 删除
            if((word.type == FHFeedOperationWordTypeDelete || word.type == FHFeedOperationWordTypeEdit) && isShowDelete){
                [items addObject:word];
            }
        }
    }
    return items;
}

+ (NSArray<FHFeedOperationWord *> *)operationWordListWithViewModel:(FHFeedOperationViewModel *)viewModel {
    NSMutableArray<FHFeedOperationWord *> *items = @[].mutableCopy;
    
    if(viewModel.permission.count > 0){
        NSArray *operationList = [self operationList:viewModel.permission];
        
        // 管理员
        NSString *userId = viewModel.userID;
        BOOL isShowDelete = [TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:userId]; // 是自己发的内容，第一条添加编辑选项，帖子
        if (isShowDelete && viewModel.cellType == FHUGCFeedListCellTypeUGC) {
            NSDictionary *dict = @{
                                   @"id": @"8",
                                   @"title": @"编辑",
                                   @"serverType":@"edit"
                                   };
            FHFeedOperationWord *editData = [[FHFeedOperationWord alloc] initWithDict:dict];
            if (editData) {
                [items addObject:editData];
            }
        }
        
        for (NSDictionary *dict in operationList) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
                if(word.type == FHFeedOperationWordTypeReport){
                    word.items = [self fetchReportOptions:word.ID];
                }else{
                    word.items = @[word];
                }
                
                if((word.type == FHFeedOperationWordTypeTop && viewModel.isTop) || (word.type == FHFeedOperationWordTypeCancelTop && !viewModel.isTop) || (word.type == FHFeedOperationWordTypeGood && viewModel.isGood) || (word.type == FHFeedOperationWordTypeCancelGood && !viewModel.isGood)){
                    continue;
                }
                
                [items addObject:word];
            }
        }
        
    }else{
        items = [self operationWordList:viewModel.userID];
    }
    
    return items;
}

+ (NSArray<FHFeedOperationWord *> *)operationWordListWithPermission:(NSArray<FHUGCConfigDataPermissionModel> *)permission {
    NSMutableArray<FHFeedOperationWord *> *items = @[].mutableCopy;
    
    NSArray *operationList = [self operationList:permission];
    
    for (NSDictionary *dict in operationList) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
            if(word.type == FHFeedOperationWordTypeReport){
                word.items = [self fetchReportOptions:word.ID];
            }else{
                word.items = @[word];
            }
            
            [items addObject:word];
        }
    }
    return items;
}

+ (NSArray *)fetchReportOptions:(NSString *)reportId {
    NSArray *options = [TTReportManager fetchReportArticleOptions];
    
    NSMutableArray<FHFeedOperationWord *> *items = [NSMutableArray array];
    for (NSDictionary *option in options) {
        if ([option isKindOfClass:[NSDictionary class]]) {
            NSInteger type = [option[@"type"] integerValue];
            if(type != 0){
                FHFeedOperationWord *word = [[FHFeedOperationWord alloc] init];
                word.ID = [NSString stringWithFormat:@"%@:%@",reportId,option[@"type"]];
                word.title = option[@"text"];
                [items addObject:word];
            }
        }
    }
    
    return items;
}

//把服务端的key转成枚举值
+ (NSString *)getTypeString:(NSString *)serverKey {
    NSInteger type = 0;
    
    if([serverKey isEqualToString:@"report"]){
        type = FHFeedOperationWordTypeReport;
    }else if([serverKey isEqualToString:@"delete"]){
        type = FHFeedOperationWordTypeDelete;
    }else if([serverKey isEqualToString:@"topping"]){
        type = FHFeedOperationWordTypeTop;
    }else if([serverKey isEqualToString:@"un_topping"]){
        type = FHFeedOperationWordTypeCancelTop;
    }else if([serverKey isEqualToString:@"essence"]){
        type = FHFeedOperationWordTypeGood;
    }else if([serverKey isEqualToString:@"un_essence"]){
        type = FHFeedOperationWordTypeCancelGood;
    }else if([serverKey isEqualToString:@"self_visiable"]){
        type = FHFeedOperationWordTypeSelfLook;
    }else if([serverKey isEqualToString:@"edit"]){
        type = FHFeedOperationWordTypeEdit;
    }else{
        type = FHFeedOperationWordTypeOther;
    }
    
    return [NSString stringWithFormat:@"%d",type];
}

@end
