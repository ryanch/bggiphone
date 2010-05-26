//
//  DataTableViewController.m
//  TestApp
//
//  Created by rchristi on 4/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataTableViewController.h"
#import "DataRow.h"
#import "DataList.h"
#import "TableCellImageLoader.h"
#import "BaseAppDelegate.h"
#import "BGCore.h"

#import "DownloadImageOperation.h"

@implementation DataTableViewController

@synthesize managedObjectContext, fetchedResultsController,dataListKey,imageDiscCache;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
		
		tableCellImageLoader = [[TableCellImageLoader alloc] init];
		
		
    }
    return self;
}

- (void) setImageDiscCache: (ImageDiscCache*) cache {
	[imageDiscCache release];
	imageDiscCache = cache;
	[imageDiscCache retain];
	tableCellImageLoader.discCache = cache;
}



#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[fetchedResultsController sections] count];
    
	if (count == 0) {
		count = 1;
	}
	
    return count;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [fetchedResultsController sectionIndexTitles];	
}
 

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
	
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Configure the cell...
	DataRow* dataRow = (DataRow*)[fetchedResultsController objectAtIndexPath:indexPath];    
	
	UITableViewCell *cell = nil;
	if (dataRow.detailText == nil ) {
		static NSString *CellIdentifier = @"Cell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else {
		static NSString *CellIdentifier2Row = @"Cell2Row";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2Row];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier2Row] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		cell.detailTextLabel.text = dataRow.detailText;
	}
	
	
	if ( dataRow.actionURL == nil ) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	
	
	cell.textLabel.text = dataRow.topText;

	if ( dataRow.imageURL != nil ) {
	
		UIImage * image = nil;
		
		// see if the image is in the cache
		if ( [dataRow.imageURL hasPrefix:@"images/"] ) {
			image = [UIImage imageNamed:dataRow.imageURL];
		}
		else {
			image = [tableCellImageLoader fetchImageIfExists:dataRow.imageURL];
		}
		
		
		if ( image == nil ) {
			// use default
			cell.imageView.image = [UIImage imageNamed:@"default_image_table_cell.png"];
			
			// see if we are still, if so, then fetch
			if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
				[tableCellImageLoader fetchImageForTableView:self forPath:indexPath withImageURL:dataRow.imageURL];
			}
			
		}
		else {
			cell.imageView.image = image;
		}
		
	} // end if image url
	
	
	
    return cell;
}




#pragma mark -
#pragma mark Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


	
	DataRow* dataRow = (DataRow*)[fetchedResultsController objectAtIndexPath:indexPath];    
	
	if (dataRow.actionURL == nil ) {
		return;
	}
	
	BaseAppDelegate * baseAppDelegate = (BaseAppDelegate*)[UIApplication sharedApplication].delegate;
	BGCore * core = [baseAppDelegate core];
	[core pushAction:dataRow.actionURL animated:YES];
	
	
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
	[tableCellImageLoader cancelAll];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[tableCellImageLoader release];
	[dataListKey release];
	[fetchedResultsController release];
	[managedObjectContext release];	
	[imageDiscCache release];
    [super dealloc];
}

- (void) viewWillAppear:(BOOL)animated {

	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
	
	
	[super viewWillAppear:animated];
	
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataRow" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
		// Set example predicate and sort orderings...
		NSPredicate *predicate = [NSPredicate predicateWithFormat:
								  @"(parentList.key ==  %@) ", dataListKey];
		[fetchRequest setPredicate:predicate];
		
		
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortTitle" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = 
			[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
												managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionTitle" cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
} 


/// this is called when the image is ready
- (void) cellImageIsReady: (DownloadImageOperation*) operation {
	
	if ( [self.tableView superview] == nil ) {
		return;
	}
	
	UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:operation.indexPath];
	if ( cell == nil ) {
		return;
	}
	
	cell.imageView.image = operation.downloadedImage;
	
	
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate){
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

- (void)loadImagesForOnscreenRows {

	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		DataRow* dataRow = (DataRow*)[fetchedResultsController objectAtIndexPath:indexPath];   
		if ( dataRow.imageURL != nil ) {
			[tableCellImageLoader fetchImageForTableView:self forPath:indexPath withImageURL:dataRow.imageURL];
		}
	}
    
}

@end

