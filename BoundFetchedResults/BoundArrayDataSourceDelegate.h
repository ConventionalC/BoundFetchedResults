#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BoundArrayDataSourceDelegate : NSObject<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property(strong) NSArray*             cellData;
@property(strong) NSString*            textKey;
@property(strong) NSString*            detailKey;
@property(assign) UITableViewCellStyle cellStyle;
@property(strong) NSMutableArray*      sectionData;

@property(readonly) BOOL usesSections;

-(void)convertToIndex:(id(^)())indexTitle;
-(void)convertToAlphaIndex;

-(void)configureCellForData:(id)o;

//Override these:
-(NSArray*)cellData;
-(void)configureCell:(UITableViewCell*)c withData:(id)o;
-(void)didSelectCellWithData:(id)o;

-(NSIndexPath*)indexPathForObject:(id)data;
-(void)scrollToObject:(id)data animated:(BOOL)animated;
@end

