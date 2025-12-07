#Odbc framework users guide#

Odbc framework is Cocoa framework providing access to ODBC databases. It works on
top of UnixODBC framework which is a low level C-oriented framework of ODBC routines
that follow ODBC specification. The framework includes also an experimental Cocoa
Core Data Persistent Store for Odbc. It has been tested with IBM DB2, Mimer SQL, MySQL,
Oracle, PostgreSQL, SQL Server and SQLite.

ODBC framework consists of a number of classes. Currently only OdbcConnection,
OdbcStatement, and OdbcException are used in non-Core Data applications. 
OdbcStore class and OdbcAppDelegate class are used in Core Data applications. 
The rest is for internal framework use.

In order to use Odbc framework you **don't** need to know ODBC specification. You
**do** need to know some basics of SQL, relational databases and of course Objective-C. 

The documentation consists of:

* This user guide document
* Odbc framework overview page
* Class hierarchy page
* Invidual pages for each class

#Example console application#

The following is a simple Cocoa console (non-GUI) application that uses Odbc framework.

```objective-c
// main.m

#import <Cocoa/Cocoa.h>
#import <Odbc/Odbc.h>

int main (int argc, char * argv []) {

    OdbcConnection * connection = [OdbcConnection new];
    
    [connection connect: @"testdb" username: @"sysadm" password: @"secret"];
    
    OdbcStatement * stmt = [connection newStatment];
    
    [stmt execDirect: @"select * from book order by title"];
    
    while ([stmt fetch]) {
    
        long bookId = [stmt getLongByName: @"bookId"];
        
        NSString * title = [stmt getStringByName: @"title"];
        
        double price = [stmt getDoubleByName: @"price"];
        
        NSLog (@"%ld %@ %f",bookId,title,price);
    }
    
    [stmt closeCursor];

    return 0;
}
```

In this application we first create an `OdbcConnection` and then use it to connect to
ODBC data source named 'testdb' with username 'sysadm' and passwaord 'secret'. 
__You should replace 'testdb', 'sysadm', 'secret' with your own names used in your own database.__
Then we create a new `OdbcStatement`. We use this statement to execute SQL query 
`select * from book order by title`. After that we go into a loop fetching a new 
row each time around. We get `bookId`, `title` and `price`. Then we write the data 
to the console. When the loop terminates we close the statement.

#Prerequisites#

OS X version 11 or latter is requred. XCode vesion 26 or latter is also required.
Futhermore, you need UnixODBC framework version 2.3.14 or latter. You also need a database
manager running on your workstation or on a network server. And of course you need the
software described here (Odbc framework).

As of this writting, Mac OS X version 11 is available from Apple AppStore
without charge. Before updating you should check/repair your hard drive for errors.
You can do this by booting your Mac in rescue mode.

Then you need XCode version 26 or latter installed on your Mac. If you don't have it
go to Apple AppStore, download and install it. It's free of charge. Test your 
installation by writting and running a small application.

Next you need UnixODBC framework version 2.3.14 or latter. Install it via Homebrew: `brew install unixodbc`

Furthermore you need a database manager, either standalone on your Mac, or on accessible
network server. If you don't have it, you need to download and install it. See Notes
at the end of this document for notes about various database managers that Odbc framework
has been tested with.

Our developer team uses primarily Mimer SQL and MySQL. Mimer SQL is first-class, 
fully-fledged, commercial grade relational database management system that is free
of charge for development purposes. A more direct reason for selecting Mimer SQL
is its concurrency control. Mimer SQL uses optimistic concurrency control, which
means that there is no risk for two or more applications to lock out each other.
Database managers that use locking concurrency control may result in one application 
waiting for another. Mimer SQL can be downloaded from http://developer.mimer.com
On the same site there is an article "Using Mimer SQL with iODBC on Mac OS X". 
You can find it under "How to" heading on the left. It describes how to install
and use Mimer SQL with iODBC on Mac OS X.

The UnixODBC framework mensioned above installs a utility called `isql`.
Run e.g. `isql SQLiteTest` and verify that you can connect to your data source by name.

Now install this software either by using Git clone command or downloading zip-file.
If you downloaded zip-file then unpack it into a directory. Both ways result in Xcode
project directory.

#Building the software#

This repository contains XCode project with 6 targets:

* `Odbc` - builds the framework itself
* `LoginServer` - builds the LoginServer
* `TestConnect` - tests connection to an ODBC data source
* `OdbcExample` - builds Cocoa Core Data application using Odbc
* `OdbcDocumentation` - generates the documentation
* `OdbcTests` - performs unit tests of the framework

If you are going to build some targets, build them in the above order. However you
don't need to build anything if you only will use the framework and documentation.
Simply copy file `Odbc.framework` from project directory to `/System/Library/Frameworks`.
Use Finder, first to delete any old `Odbc.framework` versions, and then Copy/Paste the new
version. Documentation is included in `docs` directory in the project directory.

You can use this project to build and run Odbc framework software.
If you want to build then build at least `Odbc`, `LoginServer`, and `OdbcExample`.
Run `OdbcExample`. If everything works ok then `OdbcExample` shows a login window:

![Login Window](docs/Images/LoginWindow.png)

Enter your DSN, username, and password. If these are correct then the folowing
window is shown:

![Example ODBC Application](docs/Images/OdbcExampleApplication.png)

#Description Cocoa Core Data example#

The example shown above uses the following Core Data model:

![Example CoreData Model Graph](docs/Images/ExampleCoreDataModelGraph.png)

The model consists of two entities and two relationships. Entity `Book` has attributes
`price` and `title`. Entity Author has attributes `firstName` and `lastName`.
The double-headed arrow between the entities represents the two relationships. One
relationship from entity `Book` to entity `Author` is called `bookAuthors` (name not
shown in picture above) and the second relationship from entity `Author` to entity
`Book` is called `authorBooks` (name not shown). Both are one-to-many relationsips. 
In plain words, each book can be written by a number of authors and each author 
may have written a number of books.

The nice picture above was generated by XCode Core Data model editor based on the
following information entered by application developer:

![Example CoreData Model Author](docs/Images/ExampleCoreDataModelAuthor.png)

![Example CoreData Model Book](docs/Images/ExampleCoreDataModelBook.png)

When the example application is run for the first time against a particular ODBC data
source it will generate the following schema in the database:

![Example CoreData Model ODBC Schema](docs/Images/ExampleCoreDataOdbcSchema.png)

There are 4 tables in the schema above. Table `CoreDataEntity` is needed in every
ODBC Core Data application. It keeps track of primary keys used in the other tables. 
For each Core Data entity a table is generated containing column `id` as primary key. 
The other columns correspond to entity attributes. Example application
uses `Author` and `Book`. Each pair of entity relationships results in one table. Example
application uses `authorBooks` and `bookAuthors` pair of relationships. This results
in table `bookAuthors` with columns `Book` and `Author`. This table has also foreign
keys constraints to both `Author` and `Book` tables.

The name of ODBC data source, username, and password to use are specified by an URL.
This URL may be generated by using method `loginUrl` which displays a login dialog
and verifies the infomation by connecting to and disconnecting from the database.

You find the following method in 'AppDelegate' class:

```objective-c
- (NSURL *) persistentStoreUrl {

    return self.loginUrl;
}
```

A lot of code in `AppDelegate` has been generated by XCode when
you specify 'Core Data' for a new project. This code has been included in class
`OdbcAppDelegate` so that you only need to inherit your `AppDelegate` from that.
The other classes in the application has been written by me in order to control 
the UI (mostly drag and drop). Most of work has been done in XCode Interface Builder.

Example application displays the following UI to the user:

![ODBC Example Application](docs/Images/OdbcExampleApplication.png)

Table 'Library Books' displays books in the library. You add/remove books by coresponding
+/- buttons under the table. Table 'Library Authors' displays authors in the library.
You add/remove authors by corresponding +/- buttons under the table. Table 'Book Authors'
displays authors of the selected book. You add book author by dragging an author from
'Library Authors" to 'Book Authors'. Table 'Author Books' displays books for
the selected author. You can drag a book from 'Library Books' into 'Author Books' to
add the book to the selected author. When running the application for the first
time against a particular data source the tables will be empty.

#Unit tests#

Largely identical tests are run for each "backend". More drivers are possibly working, but are not tested.
To change backend configuration, please edit the [config.plist](OdbcTests/config.plist):

* `DataSourceName`: this should correspond to the data source name in your `~/.odbc.ini` file
* `Username` and `Password`: these are the credentials (empty for SQLite)

Please ensure you've setup the databases you want to test with and you can connect to them (e.g. via `isql`).

The tests will create tables named `BOOK`, `AUTHOR`, `BOOKAUTHORS`, `COREDATAENTITY`,
and `TESTTAB` in the data source.

# Tasks to be performed #

In order to build, test and run this software you can follow the list below:

1. Upgrade Mac OS X to at least version 10.9.1 using AppStore. It is free of charge.
1. Upgrade or install XCode at least version 5.0.2 using AppStore. It is free of charge.
1. Install [Homebrew](https://brew.sh)
2. Install UnixODBC framework at least version 2.3.14 via Homebrew: `brew install unixodbc`. It is free of charge.
3. Install git via Homebrew: `brew install git`. It is free of charge.
4. Clone (using Git) or unpack (not using Git) this repository into an empty directory. This will result in an XCode project directory. It is free of charge.
5. Now you should be able to open the project in XCode and build the targets.
6. Download a database manager with ODBC driver and client tools.
7. Use client tools to create a database.
8. Use TextEdit to setup your ODBC connector and to create an ODBC data source in `~/.odbc.ini` (or in the system location)
9. Now you shoud be able to run the unit tests and example application.

# Creating new XCode project using Persistent Store for ODBC #

In this section I will guide you in creating a new XCode project using Persistent
Store for ODBC. The section contains the following topics:

1. [Creating new project](#creating-new-project).
2. [Adding required frameworks](#adding-required-frameworks).
3. [Modifying AppDelegate](#modifying-appdelegate).
4. [Creating new data model](#creating-new-data-model).
5. [Adding NSArrayController](#adding-nsarraycontroller).
6. [Adding NSTableView](#adding-nstableview).
7. [Adding buttons](#adding-buttons).

### Creating new project

Create new XCode project of type 'Application/Cocoa Application'. Uncheck 'Use
Core Data' checkbox. If you check it then it will generate a lot of code in your `AppDelegate`.
This code is already contained in `Odbc.framework` and therefore we do not want to
generate it.

Build and run your new application. It should build without errors and warnings. 
It should run without problems. Quit the application.

### Adding required frameworks

Copy `Odbc.framework` from Odbc project directory to either
`/System/Library/Frameworks` or to your project directory. Copying to 
`/System/Library/Frameworks` makes things a lttle easier and you will have the framework
in right place for other projects.

Select 'Frameworks' in your project Project Navigator. Add file `Odbc.framework` . 
Uncheck 'Copy items to destination...' checkbox. You find
the files in either your project directory or in `/System/Library/frameworks/`
depending where you copied them.

Select 'Frameworks' in your Project Navigator. Add file `CoreData.framework`
from `/System/Library/Frameworks`. Uncheck 'Copy items to destination...'.

If you copied `Odbc.framework` to your project directory then
you need to modify your project settings. If you copied the framework to 
`/System/Library/Frameworks/` then you don't need to do the following. Select your
project in Project Navigator. You should see the Project Editor now. Select your
project in Project Editor. Select 'Build Settings' tab. Find 'Run Search Path' in
the build settings area. Select 'Run Search Path", click on the settings row and
enter `$(PROJECT_DIR)`. Press Enter.

Build and run your application. There shouldn't be any problems. Quit your application.

### Modifying AppDelegate

Modify your AppDelegate.h. Add the following line to imports directives:

```objective-c
#import <Odbc/Odbc.h>
```
    
Modify the @interface statement to read:

```objective-c
@interface AppDelegate : OdbcAppDelegate <NSApplicationDelegate>
```
    
Your `AppDelegate.h` should now look like the following:

```objective-c
#import <Cocoa/Cocoa.h>

#import <Odbc/Odbc.h>

@interface AppDelegate : OdbcAppDelegate <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow * window;

@end
```

Modify your `AppDelegate.m`. Change the `applicationDidFinishLaunching` method:

```objective-c
- (void) applicationDidFinishLaunching : (NSNotification *) notification {

    [super applicationDidFinishLaunching : notification];
}
```

Method `applicationDidFinishLaunching` is invoked by Cocoa when the application 
is ready to run (all the windows has been created etc.). The expression:

```objective-c
[super applicationDidFinishLaunching : notification];
```
    
calls the corresponding method in the superclass (`OdbcAppDelegate`).

Add also the following method:

```objective-c
- (NSURL *) persistentStoreUrl {

    return self.loginUrl;
}
```
    
The method `loginUrl` displays login dialog box. It lets the user to specify data
source name, username, and password. Then it verifies the information by trying to
connect to and disconnect from the database. If everything goes ok then it returns
the required url.

Your `AppDelegate.m` should now look like the followig:

```objective-c
#import "AppDelegate.h"

@implementation AppDelegate

- (void) applicationDidFinishLaunching : (NSNotification *) notification {

    [super applicationDidFinishLaunching : notification];
}

- (NSURL *) persistentStoreUrl {

    return self.loginUrl;
}

@end
```

Build and run your application. There shouldn't be any problems. Quit the application.
The login dialog box will not be shown because it is not requred yet.

The above is all the Objective-C code we need to write. Rest of the work will be
done using XCode Model Editor and Xcode Interface Builder.
 
### Creating new data model

In this section we will create a data model for your application.

Select your application folder in the Project Navigator, right or control click on it.
Select 'New File...' on the popup menu. Select 'Core Data'/'Data Model' on the
dialog. Press 'Next' button. On the 'Save As' dialog specify name of the model.
To keep things easy specify the same name as your application. Press 'Create' button.

Build and run your application. It shouldn't be any problems. Quit the application.

Now your are set up and can continue to build your application as any other Core
Data application. However if you don't know Core Data very well then you may follow
the guide below. We will create an application that does something real. The application
will display a list of authors from the database and let the user add, modify,
and delete authors.

Select your model file (extension .xcdatamodeld) in the Project Navigator. You should see Model Editor now.
Press 'Add Entity' button. Specifiy entity name `Author` in Data Model Inspector.
Press Enter.
Add attribute `firstName` of type string, non optional. Add attribute `lastName` 
of type String, non aptional.

Now we have a simple data model with entity `Author` with two attributes `firstName`
and `lastName`. In model editor this looks like the following:

![Own CoreData Model Author](docs/Images/OwnCoreDataModelAuthor.png)

Build and run your application. There shouldn't be any problems. Quit the application.

### Adding NSArrayController

Now we will continue the work in XCode Interface Builder. Select the `MainMenu.xib` 
file in the Project Navigator. You should see the Interface Builer UI. We will build
the following UI:

![Own CoreData application](docs/Images/OwnCoreDataApplication.png)

Add an Array Controller to the list of objects contained within the `xib` file.
Select the new 'Array Controller' object. In the Inspector pane select 'Attributes Inspector'.
Specify 'Entity Name' in the 'Mode' field. Specify 'Author' in the 'Entity Name' field, press Enter.
Check the 'Prepare Content' checkbox. The Attributes Inspector should look as following:

![Own CoreData Array Controller Attributes](docs/Images/OwnCoreDataArrayControllerAttributes.png)

Select Bindings Inspector in the Inspector pane. Find 'Parameters' heading. Find
'Managed Object Context' and expand it. Check the 'Bind to' checkbox and choose 
'App Delegate' in the drop down box. Specify `managedObjectContext` in 
'Model Key Path' field. The Bindings Inspector should look as following:

![Own CoreData Array Controller Bindings](docs/Images/OwnCoreDataArrayControllerBindnings.png)

Build and run your application. There shouldn't be any problems. The application
should display a login dialog. Fill in the required information and press 'Login'
button. If the information was correct then applcation window is shown. Otherwise
an error dialog is shown. Quit the application.

### Adding NSTableView

Still in the Interface Builder add a Table View to your view. 

Select Table Header. Click on it two or three times until it goes gray/white. Now
adjust the table columns widths to be approximately equal.

Select the first table column. In Attributes Inspector set Title to 'First Name', press Enter.
In Bindings Inspector heading Value check 'Bind to' check box, select 'Array Controller' 
in the drop down list, Controller Key should be `arrangedObjects` and Model Key 
Path set to `firstName`. Press Enter. This is depicted below:

![Own CoreData First Column Bindings](docs/Images/OwnCoreDataFirstColumnBindnings.png)

Select second table column. In Attributes Inspector set Title to 'Last Name', press Enter.
In Bindings Inspector heading Value check 'Bind to' check box, select 'Array Controller' 
in the drop down list, Controller Key should be `arrangedObjects` and Model Key 
Path set to `lastName`. Press Enter. This is depicted below:

![Own CoreData Second Column Bindings](docs/Images/OwnCoreDataSecondColumnBindnings.png)

Build and run your application. There shouldn't be any problems. It should present
a nice table with two columns named 'First Name' and 'Last Name'. It still lacks
means to enter the data. Quit the application.

### Adding buttons

Still in Interface Builder.

Add Square Button to the view. In Attributes Inspector find 'Image' drop down list.
Select `NSAddTemplate`. Control-click (or use right mouse button) on the button 
in the view and drag to 'Array Controller' object. Drop there and select `add:` on
the popup menu.

Add another Square Button to the view. In Attributes Inspector find 'Image' drop down list. 
Select `NSRemoveTemplate`. Control-click (or use right mouse button) on the button 
in the view and drag to 'Array Controller' object. Drop there and select `remove:` on
the popup menu.

Control-click (or right-click) on the Array Controller. You should obtain the following popup:

![Own CoreData ArrayController Popup](docs/Images/OwnCoreDataArrayControllerPopup.png)

Build and run the application. It should display a window like following:

![Own CoreData application](docs/Images/OwnCoreDataApplication.png)

When you run your application for the first time, the table will be empty. You
can add an author using + button.
You can remove an author using - button. You can modify an author by double-clicking on it.
Your changes will automatically be saved to the database when you quit the application.

# Notes #

### TestConnectApp ###

Use the provided `TestConnectApp` application for basic connectivity testing.

### IBM DB2 ###

The installation of DB2 on OS X is not what you expect on a Mac. It is more Unix
oriented, no GUI, you work in a terminal window. It works if you follow instructions on
https://www.ibm.com/developerworks/community/forums/html/topic?id=77777777-0000-0000-0000-000014927797

After installation you create a database using DB2 command.

ODBC driver for DB2 and OS X is available from OpenLink.

### Mimer SQL###

Mimer SQL can be dowloaded from http://developer.mimer.com/downloads/index.htm.

ODBC driver and client tools are included in Mimer SQL for OS X.

After installation you should create a databank using Mimer Batch SQL utility.

### SQLite ###

Please install the ODBC driver via Homebrew:

```bash
brew install sqliteodbc
```

Your `~/.odbc.ini` should contain the following:

```
[SQLiteTest]
Driver      = /opt/homebrew/lib/libsqlite3odbc.dylib
Database    = /path/to/test.db
Timeout     = 2000
```

### MySQL ###

Please install the ODBC driver via Homebrew:

```bash
brew install mariadb-connector-odbc
```

Your `~/.odbc.ini` should contain the following:

```
[MariaDBTest]
Driver      = /opt/homebrew/Cellar/mariadb-connector-odbc/3.2.7/lib/mariadb/libmaodbc.dylib
Server      = localhost
Database    = odbctestdb
UID         = odbctestuser
PWD         = odbctestpassword
Port        = 3306
```

### Oracle ###

Currently, Oracle is not avaiable on OS X. However, there is an Oracle ODBC driver for
OS X available from OpenLink. You can use it and run with Oracle running on a server.

### PostgreSQL ###

Please install the ODBC driver via Homebrew:

```bash
brew install psqlodbc
```

Your `~/.odbc.ini` should contain the following:

```
[PostgresTest]
Driver      = /opt/homebrew/lib/psqlodbcw.so
Servername  = 192.168.50.15
Port        = 5432
Database    = odbctestdb
Username    = odbctestuser
Password    = odbctestpassword
```

### Microsoft SQL Server ###

Please install via Homebrew:

```bash
brew install microsoft/mssql-release/msodbcsql18
```

Your `~/.odbc.ini` should contain the following:

```
[MSSQLTest]
Driver = /opt/homebrew/Cellar/msodbcsql18/18.5.1.1/lib/libmsodbcsql.18.dylib
Server = localhost
Port = 1433
Database = odbctestdb
UID = odbctestuser
PWD = odbctestpassword
TrustServerCertificate=YES
```
