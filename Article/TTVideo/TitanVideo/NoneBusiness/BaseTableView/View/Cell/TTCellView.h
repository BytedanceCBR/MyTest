
#import <UIKit/UIKit.h>
#import "TTBaseCellEntity.h"
#import "TTCellDefine.h"
#import "SSThemed.h"
#import "TTBaseCellAction.h"


@interface TTCellView : SSThemedView<TTBaseCellAction>

@property (nonatomic) TTBaseCellEntity *cellEntity;
@property (nonatomic) NSIndexPath      *indexPath;
@property(nonatomic ,weak) NSObject <TTBaseCellAction>  *action_delegate;

- (void)renderView;
- (void)fillContent;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
+ (CGFloat)cellHeightWithEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath;
- (void)willBeginReuse;
@end
