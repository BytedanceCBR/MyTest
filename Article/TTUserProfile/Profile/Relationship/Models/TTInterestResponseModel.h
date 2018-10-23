//
//  TTInterestResponseModel.h
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTResponseModel.h"


@class TTInterestItemModel;
@class TTInterestDataModel;
@class TTInterestResponseModel;


@protocol TTInterestItemModel <NSObject>
@end

/**
 * @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=62424459#id-
 */
@interface TTInterestItemModel : TTResponseModel
@property (nonatomic, strong) NSNumber <Optional> *concern_count;
@property (nonatomic,   copy) NSString <Optional> *desp; // description
@property (nonatomic,   copy) NSString <Optional> *concern_id;
@property (nonatomic,   copy) NSString <Optional> *concern_name;
@property (nonatomic,   copy) NSString <Optional> *avatar_url;
@property (nonatomic,   copy) NSString <Optional> *show_name;
@property (nonatomic,   copy) NSString <Optional> *url;

- (NSString *)nameString;
- (NSString *)avatarURLString;
- (NSString *)descriptionString;
- (NSString *)urlString;
@end



@interface TTInterestDataModel : TTResponseModel
@property (nonatomic, assign) BOOL has_more;
@property (nonatomic, strong) NSNumber<Optional> *offset;
@property (nonatomic, strong) NSNumber<Optional> *count;

@property (nonatomic, strong) NSArray<Optional, TTInterestItemModel> *user_concern_list;

- (void)appendDataModel:(TTInterestDataModel *)aModel;
@end



@interface TTInterestResponseModel : TTResponseModel
@property (nonatomic,   copy) NSString<Optional> *message;
@property (nonatomic, strong) TTInterestDataModel<Optional> *data;
@end
