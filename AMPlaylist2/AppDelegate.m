//
//  AppDelegate.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "AMFetcher.h"
#import "AMTrack.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
      UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
      splitViewController.delegate = (id)navigationController.topViewController;
      
      UINavigationController *masterNavigationController = [splitViewController.viewControllers objectAtIndex:0];
      MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
      controller.managedObjectContext = self.managedObjectContext;
  } else {
      UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
      MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
      controller.managedObjectContext = self.managedObjectContext;
  }
  
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AMPlaylist2" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AMPlaylist2.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(void)didDownloadData:(NSMutableDictionary*)data {
  if ([data allKeys].count > 0) {
    [self deleteAllObjects];
    [self deleteAllTracks];
    for (NSString *discName in [data allKeys]) {
      [self insertNewDisc:discName];
      
      NSArray *tracks = [data objectForKey:discName];
      for (AMTrack *track in tracks) {
        [self insertNewTrack:track];
      }
    }
  }
  
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle: @"Sync complete"
                        message: @"Zapf!"
                        delegate: nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
  [alert show];
}


- (void)deleteAllObjects {
  NSFetchRequest * allDiscs = [[NSFetchRequest alloc] init];
  [allDiscs setEntity:[NSEntityDescription entityForName:@"Disc" inManagedObjectContext:self.managedObjectContext]];
  [allDiscs setIncludesPropertyValues:NO]; //only fetch the managedObjectID
  
  NSError * error = nil;
  NSArray * cars = [self.managedObjectContext executeFetchRequest:allDiscs error:&error];
  allDiscs = nil;
  //error handling goes here
  for (NSManagedObject * car in cars) {
    [self.managedObjectContext deleteObject:car];
  }
  NSError *saveError = nil;
  [self.managedObjectContext save:&saveError];
}

- (void)deleteAllTracks {
  NSFetchRequest * allDiscs = [[NSFetchRequest alloc] init];
  [allDiscs setEntity:[NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext]];
  [allDiscs setIncludesPropertyValues:NO]; //only fetch the managedObjectID
  
  NSError * error = nil;
  NSArray * cars = [self.managedObjectContext executeFetchRequest:allDiscs error:&error];
  allDiscs = nil;
  //error handling goes here
  for (NSManagedObject * car in cars) {
    [self.managedObjectContext deleteObject:car];
  }
  NSError *saveError = nil;
  [self.managedObjectContext save:&saveError];
}


- (void)insertNewDisc:(NSString*)playlistTitle
{
  NSManagedObject *titleMO = [NSEntityDescription insertNewObjectForEntityForName:@"Disc"
                                                           inManagedObjectContext:self.managedObjectContext];
  [titleMO setValue:playlistTitle forKey:@"title"];
  
  // Save the context.
  NSError *error = nil;
  if (![self.managedObjectContext save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

- (void)insertNewTrack:(AMTrack*)track
{
  NSManagedObject *trackMO = [NSEntityDescription insertNewObjectForEntityForName:@"Track"
                                                           inManagedObjectContext:self.managedObjectContext];
  [trackMO setValue:track.title forKey:@"title"];
  [trackMO setValue:track.artist forKey:@"artist"];
  [trackMO setValue:track.bpm forKey:@"bpm"];
  [trackMO setValue:track.time forKey:@"time"];
  [trackMO setValue:track.comment forKey:@"comment"];
  [trackMO setValue:track.discName forKey:@"discName"];
  [trackMO setValue:[NSNumber numberWithInt:track.trackNumber] forKey:@"trackNumber"];
  [trackMO setValue:track.key forKey:@"key"];
  [trackMO setValue:track.fileName forKey:@"fileName"];
  
  // Save the context.
  NSError *error = nil;
  if (![self.managedObjectContext save:&error]) {
    // Replace this implementation with code to handle the error appropriately.
    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}


@end
