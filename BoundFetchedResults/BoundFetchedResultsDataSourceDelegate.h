#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BoundFetchedResultsDataSourceDelegate : NSObject<UITableViewDataSource, UITableViewDelegate>

#pragma mark - Properties

@property(nonatomic) NSManagedObjectContext     *managedObjectContext;
@property(nonatomic) NSFetchedResultsController *fetchedResultsController;

// If no fetchedResultsController is specified, the following properties will be used to create one.
@property(nonatomic) Class                entityClass;         // | or
@property(nonatomic) NSString            *entityName;          // |
@property(nonatomic) NSString            *cellReuseIdentifier; // Default: entity name
@property(nonatomic) NSString            *sectionNameKeyPath;  // Optional

@property(copy) void(^doOnError)(NSError*); //defaults to log and abort
@property(nonatomic, readonly) NSArray         *selectedObjects;
@property(nonatomic, readonly) NSManagedObject *selectedObject;


#pragma mark - Object Access

-(NSManagedObject*)objectAtIndexPath:(NSIndexPath*)i;
-(NSIndexPath*)indexPathForObject:(id)o;

-(void)selectObject:(id)o scrollPosition:(UITableViewScrollPosition)scrollPosition;
-(void)deselectObject:(id)o;

//Configure these:
-(void)didSelectObject:(id)o;
-(void)didDeselectObject:(id)o;

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath with:(id)object;
-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
@end
