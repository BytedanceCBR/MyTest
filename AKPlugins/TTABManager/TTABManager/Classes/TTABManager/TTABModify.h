//
//  TTABPatch.h
//  AFgzipRequestSerializer
//
//  Created by zuopengliu on 2/11/2017.
//

#import <Foundation/Foundation.h>



/**
 主要负责给客户端实验打补丁。
 
 如客户端某实验的某个实验组出问题，这时便可通过settings接口来下发字段来删除或者修改该实验组
 */
@interface TTABModify : NSObject

/**
 给客户端实验打补丁

 @param patchMappers 客户端补丁数据
 补丁数据格式如下：{
     "layerName1": {
         @"groupName1": @"",
         @"groupName2": @"",
         ...
     },
     "layerName2": {
         @"groupName1": @"",
         @"groupName2": @"",
         ...
     },
     ...
 */
+ (void)modifyClientAB:(NSDictionary *)modifyMappers;

@end
