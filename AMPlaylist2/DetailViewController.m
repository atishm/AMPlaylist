//
//  DetailViewController.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "TrackCell.h"
#include <stdlib.h>

@interface DetailViewController () {
  BOOL _cueListMode;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize selectedDiscName = _selectedDiscName;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize fetchedSearchResultsController = __fetchedSearchResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize searchBar = _searchBar;
@synthesize cueListButton = _cueListButton;
@synthesize randomButton = _randomButton;
@synthesize delegate = _delegate;

#pragma mark - Managing the detail item



- (void)setSelectedDiscName:(id)newSelectedDiscName
{
  if (_selectedDiscName != newSelectedDiscName) {
    _selectedDiscName = newSelectedDiscName;
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }        
}

- (void)configureView
{
  if (self.selectedDiscName) {
    self.fetchedResultsController = nil;
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    [self.tableView reloadData];
    
    NSArray *sectionInfos = [self.fetchedResultsController sections];
    int indexOfSectionToScrollTo = 0;
    for (id<NSFetchedResultsSectionInfo> sectionInfo in sectionInfos) {
      if ([sectionInfo.name isEqualToString:_selectedDiscName]) {
        break;
      }
      indexOfSectionToScrollTo++;
    }
    
    CGRect sectionRect = [self.tableView rectForSection:indexOfSectionToScrollTo];
    sectionRect.size.height = self.tableView.frame.size.height;
    [self.tableView scrollRectToVisible:sectionRect animated:YES];
    
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

#pragma mark - Fetched results controller

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
  if (__managedObjectContext != nil) {
    return __managedObjectContext;
  }
  
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSPersistentStoreCoordinator *coordinator = [appDelegate persistentStoreCoordinator];
  if (coordinator != nil) {
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return __managedObjectContext;
}


- (NSFetchRequest*)fetchRequest:(BOOL)highlightedOnly {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track"
                                            inManagedObjectContext:[self managedObjectContext]];
  [fetchRequest setEntity:entity];
  [fetchRequest setFetchBatchSize:20];
    
  NSSortDescriptor *sortDescriptorDiscName = [[NSSortDescriptor alloc] initWithKey:@"discName" ascending:YES];
  NSSortDescriptor *sortDescriptorTrackNum = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
  NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorDiscName, sortDescriptorTrackNum, nil];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  if (highlightedOnly) {
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"highlighted = 1"];
    [fetchRequest setPredicate:predicate];
  }

  return fetchRequest;
}

- (NSFetchedResultsController *)correctFetchedResultsController {
  
  NSString *trimmedString = [self.searchBar.text stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (trimmedString.length > 0) {
    return [self fetchedSearchResultsController];
  } else {
    return [self fetchedResultsController:_cueListMode];
  }
  
}

- (NSFetchedResultsController *)fetchedResultsController:(BOOL)highlighted
{
  
  if (__fetchedResultsController != nil) {
    return __fetchedResultsController;
  }
  
  NSFetchRequest *fetchRequest = [self fetchRequest:highlighted];
  
  NSFetchedResultsController *aFetchedResultsController = 
  [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                       sectionNameKeyPath:@"discName" cacheName:nil];
  
  aFetchedResultsController.delegate = self;
  self.fetchedResultsController = aFetchedResultsController;
  
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  
  return __fetchedResultsController;
}    



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  UITableView *tableView = self.tableView;
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
//      [self configureCell:(TrackCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
      
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView endUpdates];
}


- (void)configureCell:(TrackCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

  NSManagedObject *object = [[self correctFetchedResultsController] objectAtIndexPath:indexPath];
  NSNumber *highlighted = [object valueForKey:@"highlighted"];
  if ([highlighted boolValue] == YES) {
    cell.contentView.backgroundColor = [UIColor cyanColor];
  } else {
    cell.contentView.backgroundColor = [UIColor clearColor];
  }

  cell.artist.text = [[object valueForKey:@"artist"] description];
  cell.track.text = [[object valueForKey:@"title"] description];
  cell.bpm.text = [[object valueForKey:@"bpm"] description];
  cell.trackNumber.text = [[object valueForKey:@"key"] description];
  cell.comment.text = [[object valueForKey:@"comment"] description];
  cell.discName = [[object valueForKey:@"discName"] description];
  
  NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[object valueForKey:@"fileName"] description]];
  NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];

  UIImage *image = [UIImage imageWithContentsOfFile:filepath];
  cell.albumArt.image = image;
  
  UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
  doubleTap.numberOfTapsRequired = 2;
  doubleTap.numberOfTouchesRequired = 1;
  [cell addGestureRecognizer:doubleTap];
}

-(void)doubleTap:(UITapGestureRecognizer*)sender { 
  TrackCell *cell = (TrackCell *)sender.view;

  
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
  NSManagedObject *object = [[self correctFetchedResultsController] objectAtIndexPath:indexPath];
  
  
  NSNumber *highlighted = [object valueForKey:@"highlighted"];
  if ([highlighted boolValue] == YES) {
    cell.contentView.backgroundColor = [UIColor clearColor];
    [object setValue:[NSNumber numberWithBool:NO] forKey:@"highlighted"];
  } else {
    cell.contentView.backgroundColor = [UIColor cyanColor];
    [object setValue:[NSNumber numberWithBool:YES] forKey:@"highlighted"];
  }
  
  NSError *saveError = nil;
  [self.managedObjectContext save:&saveError];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.searchBar resignFirstResponder];
  TrackCell *trackCell =  (TrackCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
  [self.delegate didSelectDisc:trackCell.discName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[[self correctFetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo = [[[self correctFetchedResultsController] sections] objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  TrackCell *cell = (TrackCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}
  
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionLabel = 
    [[[self correctFetchedResultsController] sections] objectAtIndex:section];
  return sectionLabel.name;
}


- (void)viewDidUnload {
  [self setSearchBar:nil];
  [self setCueListButton:nil];
  [self setRandomButton:nil];
  [super viewDidUnload];
}


#pragma mark -
#pragma mark Search Stuff
- (NSFetchRequest*)fetchSearchRequest:(NSString*)searchText {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track"
                                            inManagedObjectContext:[self managedObjectContext]];
  [fetchRequest setEntity:entity];
  [fetchRequest setFetchBatchSize:20];
  
  
  NSArray *searchWords = [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  NSString *predicateString = @"";
  BOOL first = YES;
  NSMutableArray *argumentArray = [NSMutableArray array];
  for (NSString *searchWord in searchWords) {
    NSString *trimmedString = [searchWord stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedString length] > 0) {
      NSString *thisPredicate = @"(artist CONTAINS[cd] %@ OR title CONTAINS[cd] %@ or comment CONTAINS[CD] %@) ";
      [argumentArray addObject:trimmedString];
      [argumentArray addObject:trimmedString];
      [argumentArray addObject:trimmedString];
      if (!first)  {
        predicateString = [predicateString stringByAppendingString:@" AND "];
      }
      predicateString = [predicateString stringByAppendingString:thisPredicate];
      first = NO;
    }
  }
  
  NSPredicate *predicate =[NSPredicate predicateWithFormat:predicateString argumentArray:argumentArray];
  [fetchRequest setPredicate:predicate];
  
  
  NSSortDescriptor *sortDescriptorDiscName = [[NSSortDescriptor alloc] initWithKey:@"discName" ascending:YES];
  NSSortDescriptor *sortDescriptorTrackNum = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
  NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptorDiscName, sortDescriptorTrackNum, nil];
  
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  return fetchRequest;
}

- (NSFetchedResultsController *)fetchedSearchResultsController:(NSString*)searchText
{  
  NSFetchRequest *fetchRequest = [self fetchSearchRequest:searchText];
  
  NSFetchedResultsController *aFetchedResultsController = 
  [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                     managedObjectContext:self.managedObjectContext
                                       sectionNameKeyPath:@"discName" cacheName:nil];
  
  aFetchedResultsController.delegate = self;
  self.fetchedSearchResultsController = aFetchedResultsController;
  
	NSError *error = nil;
	if (![self.fetchedSearchResultsController performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
	}
  return __fetchedSearchResultsController;
}    

#pragma mark - 
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

  NSString *trimmedString = [searchText stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if ([trimmedString length] > 0) {
    self.fetchedSearchResultsController = [self fetchedSearchResultsController:searchText];
  }
  [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  self.cueListButton.enabled = NO;
  self.randomButton.enabled = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
  self.cueListButton.enabled = YES;
  self.randomButton.enabled = YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  self.cueListButton.enabled = YES;
  self.randomButton.enabled = YES;
}

#pragma mark - 
#pragma mark Button taps

- (IBAction)cutListButtonTapped:(id)sender {

  _cueListMode = !_cueListMode;
  self.cueListButton.title = _cueListMode ? @"Switch to Full List" : @"Switch to Cue List" ;
  self.fetchedResultsController = nil;
  [self.tableView reloadData];
}

- (IBAction)randomButtonTapped:(id)sender {
        [self.searchBar resignFirstResponder];
  int numItems = [self.fetchedResultsController.fetchedObjects count];
  int randomItemNumber = arc4random() % numItems;

  int count = 0;
  int sectionCount = 0;
  for (id section in [self.fetchedResultsController sections]) {
    int numRowsInSection = [self tableView:self.tableView numberOfRowsInSection:sectionCount];
    count += numRowsInSection;
    if (randomItemNumber < count) {
      int rowInSection = numRowsInSection - (count - randomItemNumber);
//      NSLog(@"item %d, section %d, count %d, rowInSection: %d", randomItemNumber, sectionCount, count, rowInSection);
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowInSection inSection:sectionCount];
      [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
      

      TrackCell *trackCell =  (TrackCell*)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
      [self.delegate didSelectDisc:trackCell.discName];
      break;
    }
    sectionCount++;
  }
  
}

@end
