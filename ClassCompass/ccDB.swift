/*
 Project Name: Class Compass Database
 Developer: David Teixeira
 Date: 11/16/2023
 Abstract: This project is vol 0.0.1 to store and retrieve data for final project SDEV260
 */

// Import Swift Libraries
import Foundation
import SQLite3

// Create Class
class Database {
/*
 Class Name: Database
 Class Purpose: Class of object for the database
 */
    // Delcare Public Variables. (pointer used for C API's ie. SQLite with C library)
    var db: OpaquePointer?

    // Initialize the variables
    
    // Create DB connection
    func openDatabase() -> OpaquePointer? {
    /*
     Function Name: openDatabase
     Function Purpose: Function is to connect to the database
     */
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("classcompass.sqlite")
        
        // First check if the file can open
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opeing the database")
            return nil
        } else {
            print("Successfully opened database connection at \(fileURL.path)")
            return db
        }
    }
    
    // Create Base Table
    func createTable() {
    /*
     Function Name: createTable
     Function Purpose: Function is to Add person table
     */
        // Declare Local SQL string
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Person(
        Id INT PRIMARY KEY NOT NULL,
        Name CHAR(255));
        """
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Person table created.")
            } else {
                print("Person table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(id: Int, name: String) {
    /*
     Function Name: insert
     Function Purpose: Function is to insert a person to table 'Person'
     */
        // Declare Local Variables
        let insertStatementString = "INSERT INTO Person (Id, Name) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(id))
            sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func initialize_Use_Database() {
    /*
     Function Name: initialize_Use_Database
     Function Purpose: Function is to initialize the db and insert an item
     */
        // Create the db instance
        db = openDatabase()
        createTable()

        // Insert a new person
        insert(id: 1, name: "John Doe")
    }
}
