//
//  TTInterestRequestModel.h
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import <TTNetworkManager/TTNetworkManager.h>


/**
 *  @wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=62424459#id-
 *  @url:  http://isub.snssdk.com/2/user/concern_list/
 *
 *  @Class 兴趣列表页请求Model
 */
@interface TTInterestRequestModel : TTRequestModel
@property (nonatomic, strong) NSNumber *offset; // 起始游标
@property (nonatomic,   copy) NSString *user_id;
@end
