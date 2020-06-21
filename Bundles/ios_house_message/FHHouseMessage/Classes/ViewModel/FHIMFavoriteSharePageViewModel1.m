//
//  FHIMFavoriteSharePageViewModel1.m
//  FHHouseMessage
//
//  Created by leo on 2019/4/29.
//

#import "FHIMFavoriteSharePageViewModel1.h"
#import "FHHouseBaseItemCell.h"
#import "FHPlaceHolderCell.h"
#import "FHHouseSelectedItemCell.h"
#import "RXCollection.h"
@interface FHIMFavoriteSharePageViewModel1 ()
@property (nonatomic, strong) NSMutableOrderedSet<NSIndexPath*>* selected;
@end

@implementation FHIMFavoriteSharePageViewModel1
- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMyFavoriteViewController *)viewController type:(FHHouseType)type {
    self = [super initWithTableView:tableView controller:viewController type:type];
    if (self) {
        self.selected = [[NSMutableOrderedSet alloc] init];
        self.isDisplay = NO;
    }
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selected containsObject:indexPath]) {
        [_selected removeObject:indexPath];
        [_selectedListener onItemSelected:self];
    } else if([_selected count] < 9){
        [_selected addObject:indexPath];
        [_selectedListener onItemSelected:self];
    }
    [tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[FHHouseSelectedItemCell class]]) {
        FHHouseSelectedItemCell* theCell = (FHHouseSelectedItemCell*) cell;
        [theCell setItemSelected:[_selected containsObject:indexPath]];
        if ((![_selected containsObject:indexPath] && [_selected count] < 9) || [_selected containsObject:indexPath]) {
            [theCell setDisable:NO];
        } else {
            [theCell setDisable:YES];
        }
    }
    return cell;
}

- (void)registerCell:(UITableView *)tableView {
    [tableView registerClass:[FHHouseSelectedItemCell class] forCellReuseIdentifier:kCellId];
    [tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:@"FHIMFavoriteListPlaceholderCellId"];
}

-(void)cleanSelects {
    [self.selected removeAllObjects];
    [self.tableView reloadData];
}

-(NSArray*)selectedItems {
    return [[_selected array] rx_mapWithBlock:^id(NSIndexPath* each) {
        if ([self.dataList count] > [each row]) {
            return self.dataList[[each row]];
        } else {
            return nil;
        }
    }];
}

- (NSDictionary *)categoryLogDict {
    NSMutableDictionary* dict = [[super categoryLogDict] mutableCopy];
    dict[@"category_name"] = nil;
    return dict;
}

- (NSString *)categoryName {
    return @"conversation_detail";
}

- (void)addEnterCategoryLog {
    //DO Nothing
}

- (void)trackRefresh {
    //DO Nothing
}

-(FHEmptyMaskViewType)networkErrorType {
    return FHEmptyMaskViewTypeNoNetWorkAndRefresh;
}
@end
