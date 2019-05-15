//
//  TTRealnameAuthResponseModel.h
//  Article
//
//  Created by lizhuoli on 16/12/23.
//
//

#import <JSONModel/JSONModel.h>

@interface TTRealnameAuthUploadResponseModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *identity_number;
@property (nonatomic, copy) NSString<Optional> *uri;
@property (nonatomic, copy) NSString<Optional> *real_name;

@end

@interface TTRealnameAuthStatusResponseModel : JSONModel

@property (nonatomic, copy) NSNumber<Optional> *status;

@end
