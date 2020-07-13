//
//  FHHouseRealtorDetailInfoModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import "FHHouseRealtorDetailInfoModel.h"

@implementation FHHouseRealtorDetailInfoModel

@end

@implementation FHHouseRealtorDetailUserEvaluationModel

@end

@implementation FHHouseRealtorDetailrRgcModel

@end

@implementation FHHouseRealtorTitleModel

@end

@implementation FHHouseRealtorDetailModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHHouseRealtorDetailDataDataModel
+ (JSONKeyMapper*)keyMapper
{
    NSDictionary *dict = @{
            @"userName": @"user_name",
            @"userAvatar": @"user_avatar",
            @"userContent": @"user_content",
            @"evaluationData": @"evaluation_data",
    };
    return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
        return dict[keyName]?:keyName;
    }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
