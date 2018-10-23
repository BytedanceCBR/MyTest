//
//  TSVActivityBannerModel.h
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import <JSONModel/JSONModel.h>

@interface TSVActivityBannerModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *groupID;
@property (nonatomic, copy) NSString<Optional> *forumID;
@property (nonatomic, strong) NSDictionary<Optional> *logPb;
@property (nonatomic, strong) TTImageInfosModel<Optional> *coverImageModel;
@property (nonatomic, copy) NSString<Optional> *openURL;

@end
