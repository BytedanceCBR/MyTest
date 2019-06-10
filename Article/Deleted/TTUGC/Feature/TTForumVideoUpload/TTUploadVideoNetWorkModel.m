//
//  TTUploadVideoNetWorkModel.m
//  Article
//
//  Created by xuzichao on 2017/3/9.
//
//

#import "TTUploadVideoNetWorkModel.h"

@implementation TTUploadVideoRequestModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        self._method = @"POST";
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/ttdiscuss/v2/ugc_video/upload_video_url";
        self._response = @"TTUploadVideoResponseModel";
    }
    
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [params setValue:_upload_id forKey:@"upload_id"];
    
    return params;
}

@end


@implementation TTUploadVideoResponseModel
- (instancetype) init
{
    self = [super init];
    if (self) {
        [self reset];
    }
    
    return self;
}

- (void) reset
{
    self.err_no = nil;
    self.upload_id = nil;
    self.upload_url = nil;
    self.chunk_size = nil;
    self.bytes = nil;
    self.err_tips = nil;
}
@end
