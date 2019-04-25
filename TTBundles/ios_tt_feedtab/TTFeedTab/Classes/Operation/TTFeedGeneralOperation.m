//
//  TTFeedGeneralOperation.m
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTFeedGeneralOperation.h"
#import "TTFeedContainerViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTFeedGeneralOperation ()

@property (nonatomic, copy)   NSString *categoryID;
@property (nonatomic, copy)   NSString *concernID;
@property (nonatomic, assign) ListDataOperationReloadFromType reloadType;
@property (nonatomic, assign) ExploreOrderedDataListType listType;
@property (nonatomic, assign) ExploreOrderedDataListLocation listLocation;
@property (nonatomic, assign) NSUInteger loadMoreCount;
@property (nonatomic, strong) TTFeedContainerViewModel *viewModel;
@property (nonatomic, weak)   UIViewController *targetVC;

@end

@implementation TTFeedGeneralOperation

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super init]) {
        self.reloadType = viewModel.reloadType;
        self.targetVC = viewModel.targetVC;
        
        if([viewModel.delegate respondsToSelector:@selector(categoryID)]) {
             _categoryID =  [viewModel.delegate categoryID];
        } else {
            _categoryID = @"";
        }
        
        if([viewModel.delegate respondsToSelector:@selector(concernID)]) {
            _concernID = [viewModel.delegate concernID];
        } else {
            _concernID = @"";
        }
        
        if ([viewModel.delegate respondsToSelector:@selector(listType)]) {
            _listType = [viewModel.delegate listType];
        } else {
            _listType = ExploreOrderedDataListTypeCategory;
        }
        
        if ([viewModel.delegate respondsToSelector:@selector(listLocation)]) {
            _listLocation = [viewModel.delegate listLocation];
        }else {
            _listLocation = ExploreOrderedDataListLocationCategory;
        }
        
        if ([viewModel.delegate respondsToSelector:@selector(loadMoreCount)]) {
            _loadMoreCount = [viewModel.delegate loadMoreCount];
        } else {
        }
        
        _viewModel = viewModel;
    }
    return self;
}

- (Class)orderedDataClass {
    Class orderdDataClass = [[NSNull null] class];
    if ([self.viewModel.delegate respondsToSelector:@selector(orderedDataClass)]) {
        orderdDataClass = [self.viewModel.delegate orderedDataClass];
    } else {
        orderdDataClass = [ExploreOrderedData class];
    }
    return orderdDataClass;
}

@end
