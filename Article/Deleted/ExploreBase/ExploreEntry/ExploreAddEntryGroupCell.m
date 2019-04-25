//
//  ExploreAddEntryGroupCell.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "ExploreAddEntryGroupCell.h"

@interface ExploreAddEntryGroupCell()
{
    BOOL _userTouched;
}
@property(nonatomic, retain)UIView * leftLineView;
@property(nonatomic, retain)UILabel * groupTitleLabel;

@end

@implementation ExploreAddEntryGroupCell

+ (CGFloat)defaultHeight
{
    return 66;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.groupTitleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _groupTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _groupTitleLabel.backgroundColor = [UIColor clearColor];
        _groupTitleLabel.font = [UIFont systemFontOfSize:17];
        _groupTitleLabel.textAlignment = NSTextAlignmentCenter;
        _groupTitleLabel.textColor = [UIColor colorWithHexString:@"505050"];
        [self.contentView addSubview:_groupTitleLabel];
        
        self.leftLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, self.contentView.height)];
        _leftLineView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:_leftLineView];

        
        [self themeChanged:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
    _leftLineView.backgroundColor = [UIColor colorWithDayColorName:@"FE3232" nightColorName:@"935656"];
    
    [self changeHighlight:self.isSelected];
}

- (void)changeHighlight:(BOOL)highlight
{
    if(highlight) {
        _groupTitleLabel.textColor = [UIColor colorWithDayColorName:@"fe3232" nightColorName:@"935656"];
        self.contentView.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
        _leftLineView.hidden = NO;
    } else {
        _groupTitleLabel.textColor = [UIColor colorWithHexString:@"#505050"];
        self.contentView.backgroundColor = [UIColor colorWithDayColorName:@"ebebeb" nightColorName:@"303030"];
        _leftLineView.hidden = YES;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (_userTouched) {
        [self changeHighlight:highlighted];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self changeHighlight:selected];
}

- (void)setGroupTitle:(NSString *)title
{
    self.groupTitleLabel.text = title;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    _userTouched = YES;
}

@end
