//
//  FHIMFavoriteShareViewModel.m
//  AKCommentPlugin
//
//  Created by leo on 2019/4/28.
//

#import "FHIMFavoriteShareViewModel.h"
#import "RXCollection.h"
@implementation FHIMFavoriteShareViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)onItemSelected:(id)vm {
    [[_pageViewModels rx_filterWithBlock:^BOOL(id each) {
        return ![vm isEqual:each];
    }] enumerateObjectsUsingBlock:^(FHIMFavoriteSharePageViewModel1 * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cleanSelects];
    }];

    self.selectedItems = [_pageViewModels rx_foldInitialValue:[[NSMutableArray alloc] init] block:^id(NSMutableArray* memo, FHIMFavoriteSharePageViewModel1* each) {
        [[each selectedItems] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [memo addObject:obj];
        }];
        return memo;
    }];
}

@end
