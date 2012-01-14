/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import "AppDelegate.h"
#import "Settings.h"
#import "Ushahidi.h"

@implementation AppDelegate

@synthesize window, navigationController;

#pragma mark -
#pragma mark Application lifecycle

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"");
	[[Settings sharedSettings] save];
	[[Ushahidi sharedUshahidi] archive];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Memory management

/*
 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	DLog(@"");
}

- (void)dealloc {
	DLog(@"");
    [navigationController release];
    [window release];
    [super dealloc];
}

@end

