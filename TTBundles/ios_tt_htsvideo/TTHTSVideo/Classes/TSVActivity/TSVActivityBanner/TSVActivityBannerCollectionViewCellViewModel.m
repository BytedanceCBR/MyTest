//
//  TSVActivityBannerCollectionViewCellViewModel.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityBannerCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVActivityBannerCollectionViewCellViewModel()

@property (nonatomic, strong) TSVActivityBannerModel *model;
@property (nonatomic, strong, readwrite) TTImageInfosModel *coverImageModel;

@end

@implementation TSVActivityBannerCollectionViewCellViewModel

- (instancetype)initWithModel:(TSVActivityBannerModel *)model
{
    if (self = [super init]) {
        _model = model;
        [self bindWithModel];
    }
    return self;
}

- (void)bindWithModel
{
    RAC(self, coverImageModel) = RACObserve(self, model.coverImageModel);
}

@end
