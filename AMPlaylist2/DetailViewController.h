//
//  DetailViewController.h
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMTrack;
@protocol DetailViewControllerDelegate <NSObject>

- (void)didSelectDisc:(NSString*)disc;

@end

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id selectedDiscName;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedSearchResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cueListButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *randomButton;
@property (nonatomic, assign)id<DetailViewControllerDelegate> delegate;
@end
