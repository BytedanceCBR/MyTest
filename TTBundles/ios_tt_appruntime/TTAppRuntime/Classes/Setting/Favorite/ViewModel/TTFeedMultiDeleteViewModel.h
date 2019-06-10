//
//  TTFeedMultiDeleteViewModel.h
//  Article
//
//  Created by fengyadong on 16/11/20.
//
//

#import "TTFeedMultiDeleteViewModel.h"
#import "TTFeedContainerViewModel.h"

@interface TTFeedMultiDeleteViewModel : TTFeedContainerViewModel

@property (nonatomic, strong) NSMutableSet *deletingItems;

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate;

@end
