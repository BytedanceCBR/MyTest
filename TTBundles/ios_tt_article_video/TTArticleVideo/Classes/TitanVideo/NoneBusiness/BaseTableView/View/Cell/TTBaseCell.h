
#import <UIKit/UIKit.h>
#import "TTCellConfigure.h"
#import "TTBaseCellEntity.h"
#import "TTCellView.h"
#import "TTBaseCellDelegate.h"
#import "SSThemed.h"
#import "TTBaseCellAction.h"

#define kTableViewBGColor   0xe0e0e0

@interface TTBaseCell : SSThemedTableViewCell

@property(nonatomic ,strong) NSIndexPath                *indexPath;
@property(nonatomic ,readonly) TTBaseCellEntity         *cellEntity;
@property(nonatomic ,weak) NSObject <TTBaseCellAction>  *action_delegate;
@property(nonatomic ,readonly) TTCellView               *customContentView;
@property(nonatomic ,readonly) UIEdgeInsets             insets;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

//经常被子类用到的
- (TTCellConfigure *)listCellConfigure;
- (void)fillContent:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)cellHeightWithEntity:(TTBaseCellEntity *)cellEntity indexPath:(NSIndexPath *)indexPath;
+ (CGFloat)heightOfContent:(TTBaseCellEntity *)cellEntity;

+ (NSInteger)fixCellHeight;//cell content view高度固定.
- (void)willBeginReuse;

@end
