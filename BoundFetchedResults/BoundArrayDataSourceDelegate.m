#import "BoundArrayDataSourceDelegate.h"

@interface BoundArrayDataSourceDelegate()
    @property(strong) NSMutableArray* sectionTitles;
    @property(strong) NSArray* originalCellData;
@end

@implementation BoundArrayDataSourceDelegate
{
    UITableView *_tableView;
}

@synthesize cellData, textKey, detailKey, cellStyle;
@synthesize sectionTitles, sectionData, originalCellData;

-(BOOL)usesSections
{
    return sectionData && sectionData.count > 0 && [sectionData.firstObject isKindOfClass:NSArray.class];
}

-(NSMutableArray*)sectionDataFor:(NSInteger)s
{
    return [sectionData objectAtIndex:s];
}

-(id)dataAtIndexPath:(NSIndexPath*)ip
{
    if(self.usesSections)
        return [[self sectionDataFor:ip.section] objectAtIndex:ip.row];
    return [cellData objectAtIndex:ip.row];
}

-(NSIndexPath*)indexPathForObject:(id)data
{
    NSArray* array = cellData;
    int s=0;
    if(self.usesSections)
        for(NSArray* section in sectionData)
        {
            if([section containsObject:data])
            {
                array = section;
                break;
            }
            s++;
        }
    return [NSIndexPath indexPathForRow:[array indexOfObject:data] inSection:s];
}

-(void)scrollToObject:(id)data animated:(BOOL)animated
{
    if(data)
        [_tableView scrollToRowAtIndexPath:[self indexPathForObject:data] atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

-(void)convertToIndex:(id(^)())indexTitle
{
    sectionTitles = NSMutableArray.new;
    sectionData   = NSMutableArray.new;
    
    for(id o in cellData)
    {
        NSString* sectionTitle = indexTitle(o);
        if(![sectionTitle isEqualToString:sectionTitles.lastObject])
        {
            [sectionTitles addObject:sectionTitle];
            [sectionData addObject:NSMutableArray.new];
        }
        NSMutableArray* section = sectionData.lastObject;
        [section addObject:o];
    }
}

-(void)convertToAlphaIndex
{
    return [self convertToIndex:^id(id o){return [[o valueForKey:textKey] substringToIndex:1];}];
}

-(void)configureCellForData:(id)o
{
    NSInteger i = [self.cellData indexOfObject:o];
    UITableViewCell* c = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    [self configureCell:c withData:o];
}

-(void)configureCell:(UITableViewCell*)c withData:(id)o
{
    c.textLabel.text       = [o valueForKey:textKey];
    c.detailTextLabel.text = [o valueForKey:detailKey];
}

-(void)didSelectCellWithData:(id)o { }


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    _tableView = tableView;
    return self.usesSections ? sectionData.count : 1;
}

-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)s
{
    _tableView = tableView;
    return self.usesSections ? [sectionTitles objectAtIndex:s] : nil;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)s
{
    _tableView = tableView;
    return self.usesSections ? [self sectionDataFor:s].count : cellData.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)ip
{
    _tableView = tableView;
    UITableViewCell* c;
    if(self.textKey)
        c = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)] ?: [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:NSStringFromClass(self.class)];
    else
        c = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:ip];
    [self configureCell:c withData:[self dataAtIndexPath:ip]];
    return c;
}

-(void)tableView:(UITableView*)tv didSelectRowAtIndexPath:(NSIndexPath*)ip
{
    [self didSelectCellWithData:[self dataAtIndexPath:ip]];
}

-(NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView
{
    _tableView = tableView;
    NSArray* indexTitles = self.usesSections ? sectionTitles : nil;
    return indexTitles;
}

-(NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)t atIndex:(NSInteger)i
{
    _tableView = tableView;
    return i;
}

-(NSArray*)filteredArray:(NSArray*)array usingPredecateFormat:(NSString*)format, ...
{
    va_list args;
    va_start(args, format);
    NSPredicate *pred = [NSPredicate predicateWithFormat:format arguments:args];
    return [array filteredArrayUsingPredicate:pred];
}

-(NSArray*)filteredArray:(NSArray*)array whereKeyPath:(NSString*)keyPath containsIgnoreCase:(id)object
{
    return [self filteredArray:array usingPredecateFormat: [NSString stringWithFormat:@"%@ CONTAINS[c] %%@", keyPath], object];
}

-(void)searchBar:(UISearchBar*)sb textDidChange:(NSString*)searchText
{
    if(!originalCellData)
        self.originalCellData = cellData;
    self.cellData = searchText && searchText.length > 0 ? [self filteredArray:originalCellData whereKeyPath:self.textKey containsIgnoreCase:searchText] : originalCellData;
    [self convertToAlphaIndex];
    [_tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar*)sb
{
    sb.text = NSString.string;
    self.cellData = originalCellData;
    [self convertToAlphaIndex];
    [_tableView reloadData];
    [sb resignFirstResponder];
}

@end
