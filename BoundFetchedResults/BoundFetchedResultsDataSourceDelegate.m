#import "BoundFetchedResultsDataSourceDelegate.h"

@interface BoundFetchedResultsDataSourceDelegate()<NSFetchedResultsControllerDelegate>
@end

@implementation BoundFetchedResultsDataSourceDelegate
{
    UITableView *_tableView;
}

-(id)init
{
    if(self = [super init])
    {
        self.doOnError = ^(NSError *e){
            NSLog(@"%@", e);
            abort();
        };
    }
    return self;
}


#pragma mark - Properties

// Returns an object if an indexPath is supplied, otherwise returns an indexPath for an object
-(id)objectForKeyedSubscript:(id)indexPathOrObject
{
    if([indexPathOrObject isKindOfClass:NSIndexPath.class])
        return [self objectAtIndexPath:indexPathOrObject];
    else
        return [self indexPathForObject:indexPathOrObject];
}

-(NSFetchedResultsController*)fetchedResultsController
{
    if(!_fetchedResultsController)
    {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.entityClass)];
        fetchRequest.fetchBatchSize = 20;
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error;
        if([self.fetchedResultsController performFetch:&error])
            self.doOnError(error);
        
        return self.fetchedResultsController;
    }
    return _fetchedResultsController;
}

@synthesize entityClass = _entityClass;
-(void)setEntityClass:(Class)entityClass
{
    _entityClass = entityClass;
    _entityName = NSStringFromClass(entityClass);
}

@synthesize entityName = _entityName;
-(void)setEntityName:(NSString*)entityName
{
    _entityName = entityName;
    _entityClass = NSClassFromString(entityName);
}

@synthesize cellReuseIdentifier = _cellReuseIdentifier;
-(NSString*)cellReuseIdentifier { return _cellReuseIdentifier ?: self.entityName; }

// Unless overridden, doOnError returns a block that logs the error and aborts the app.
@synthesize doOnError = _doOnError;
-(void (^)(NSError*))doOnError
{
    return _doOnError ?: ^(NSError *e){
        NSLog(@"%@", e);
        abort();
    };
}

-(void)setDoOnError:(void (^)(NSError*))doOnError
{
    _doOnError = doOnError;
}

-(NSArray*)selectedObjects
{
    NSMutableArray *result = NSMutableArray.new;
    for(NSIndexPath *i in _tableView.indexPathsForSelectedRows)
        [result addObject:self[i]];
    return result.copy;
}

-(id)selectedObject
{
    return self[_tableView.indexPathForSelectedRow];
}


#pragma mark - Object Access

-(NSManagedObject*)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

-(NSIndexPath*)indexPathForObject:(id)o
{
    return [self.fetchedResultsController indexPathForObject:o];
}

-(void)selectObject:(id)o scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    [_tableView selectRowAtIndexPath:self[o] animated:YES scrollPosition:scrollPosition];
}

-(void)deselectObject:(id)o
{
    [_tableView deselectRowAtIndexPath:[self indexPathForObject:o] animated:YES];
}

#pragma mark - Implement

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath with:(id)object
{
    //override
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    [self configureCell:cell atIndexPath:indexPath with:self[indexPath]];
}

-(void)didSelectObject:(id)o { }
-(void)didDeselectObject:(id)o { }

#pragma mark - Table Controller, Datasource, and Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _tableView = tableView;
    return self.fetchedResultsController.sections.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)s
{
    _tableView = tableView;

    id<NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[s];
    return sectionInfo.numberOfObjects;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)s
{
    _tableView = tableView;

    id<NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[s];
    return sectionInfo.name;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    _tableView = tableView;
    
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:c atIndexPath:indexPath];
    
    return c;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)i
{
    _tableView = tableView;
    [self didSelectObject:self[i]];
}

-(void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)i
{
    _tableView = tableView;
    [self didDeselectObject:self[i]];
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)i
{
    _tableView = tableView;
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject *object = [self objectAtIndexPath:i];
        [object.managedObjectContext deleteObject:object];
        NSError *error;
        if(![object.managedObjectContext save:&error])
            self.doOnError(error);
    }
}


#pragma mark - Fetched results controller delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            //TODO: implement
            break;
        case NSFetchedResultsChangeMove:
            //TODO: implement
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView endUpdates];
}

@end
