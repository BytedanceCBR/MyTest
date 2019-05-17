//
//  TSVFeedPublishCollectionViewCellViewModel.m
//  Article
//
//  Created by 王双华 on 2017/11/21.
//

#import "TSVFeedPublishCollectionViewCellViewModel.h"
#import "TSVPublishStatusOriginalData.h"
#import <ReactiveObjC/ReactiveObjC.h>
//#import "TSVPublishManager.h"

@interface TSVFeedPublishCollectionViewCellViewModel()

@property (nonatomic, strong) TSVPublishStatusOriginalData *model;
@property (nonatomic, strong, readwrite) UIImage *coverImage;
@property (nonatomic, copy, readwrite) NSString *uploadingProgress;
@property (nonatomic, copy, readwrite) NSString *uploadingStr;
@property (nonatomic, copy, readwrite) NSString *failedStr;
@property (nonatomic, assign, readwrite) BOOL isFailed;

@end

@implementation TSVFeedPublishCollectionViewCellViewModel

- (instancetype)initWithModel:(TSVPublishStatusOriginalData *)model;
{
    if (self = [super init]) {
        _model = model;
        _uploadingProgress = @"0%";
        _uploadingStr = @"视频上传中";
        _failedStr = @"上传失败";
        _isFailed = NO;
        [self bindWithModel];
    }
    return self;
}

- (void)bindWithModel
{
    @weakify(self);
    [RACObserve(self, model.uploadingProgress) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.uploadingProgress = [NSString stringWithFormat:@"%d%%", (int)(self.model.uploadingProgress * 100.0)];
    }];
    [RACObserve(self, model.status) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.model.status == TTForumPostThreadTaskStatusFailed) {
            self.isFailed = YES;
        } else {
            self.isFailed = NO;
        }
    }];
    RAC(self, coverImage) = RACObserve(self, model.coverImage);
}

- (void)handleRetryButtonClick
{
//    [TSVPublishManager retryWithFakeID:self.model.fakeID concernID:self.model.concernID];
}

- (void)handleDeleteButtonClick
{
//    [TSVPublishManager deleteWithFakeID:self.model.fakeID concernID:self.model.concernID];
}

@end
