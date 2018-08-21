//
//  TSVActivityEntranceCollectionViewCellViewModel.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityEntranceCollectionViewCellViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVActivityEntranceCollectionViewCellViewModel ()

@property (nonatomic, strong) TSVActivityEntranceModel *model;
@property (nonatomic, strong, readwrite) TTImageInfosModel *coverImageModel;
@property (nonatomic, copy, readwrite) NSString *activityPromotionText;
@property (nonatomic, copy, readwrite) NSString *activityNameText;
@property (nonatomic, copy, readwrite) NSString *participateCountText;

@end

@implementation TSVActivityEntranceCollectionViewCellViewModel

- (instancetype)initWithModel:(TSVActivityEntranceModel *)model
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
    RAC(self, activityPromotionText) = RACObserve(self, model.label);
    RAC(self, activityNameText) = RACObserve(self, model.name);
    RAC(self, participateCountText) = RACObserve(self, model.activityInfo);
    RAC(self, style) = RACObserve(self, model.style);
}

@end
