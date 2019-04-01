//
//  FHSectionCellPlaceHolder.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHSectionCellPlaceHolder <NSObject>
@property (nonatomic, assign) NSUInteger sectionOffset;
-(void)registerCellToTableView:(UITableView*)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)numberOfSection;
-(NSUInteger)numberOfRowInSection:(NSUInteger)section;
-(BOOL)isDisplayData;
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)traceCellDisplayAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
