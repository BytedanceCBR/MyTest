//
//  TTUploadVideoNetWorkModel.h
//  Article
//
//  Created by xuzichao on 2017/3/9.
//
//

@interface  TTUploadVideoRequestModel : TTRequestModel
@property (strong, nonatomic) NSString<Optional> *upload_id;
@end

@interface  TTUploadVideoResponseModel : TTResponseModel
@property (strong, nonatomic) NSNumber<Optional> * err_no;
@property (strong, nonatomic) NSString<Optional> * upload_id;
@property (strong, nonatomic) NSString<Optional> * upload_url;
@property (strong, nonatomic) NSNumber<Optional> * chunk_size;
@property (strong, nonatomic) NSNumber<Optional> * bytes;
@property (strong, nonatomic) NSString<Optional> * err_tips;
@end
