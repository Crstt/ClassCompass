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
    
    init() {
        /*
         Function Name: initialize_Use_Database
         Function Purpose: Function is to initialize the db and insert an item
         */
        // Create the db instance
        db = openDatabase()
        
        // Ensure the db file exists
        if db != nil {
            // Create the base tables
            createStudentTable()
            createCoursesTable()
            createAssignmentsTable()
            
            // Create the views
            createStudentsView()
            createCoursesView()
            createAssignmentsView()
            createAssignmentsToDoView()
            createAssignmentsInProgressView()
            createAssignmentsCompletedView()
        }
    }
    
    
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
    
    // Close the SQLite database
    private func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
            print("Database closed.")
        }
    }
    
    /* ########################################################################
     Create Tables
     ######################################################################## */
    private func createStudentTable() {
        /*
         Function Name: createStudentTable
         Function Purpose: Function is to create Students table if the table does not exist
         */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TStudents (
            id INTEGER PRIMARY KEY NOT NULL,
            token_id TEXT,
            first_name TEXT,
            last_name TEXT,
            login_name TEXT,
            login_password TEXT
        );
        """
        
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TStudents table created.")
            } else {
                print("TStudents table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TStudents could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    private func createCoursesTable() {
        /*
         Function Name: createCoursesTable
         Function Purpose: Function is to create Courses table if the table does not exist
         */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TCourses (
            id INTEGER PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            course_code TEXT,
            start_date TEXT,
            end_date TEXT
        );
        """
        
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TCourses table created.")
            } else {
                print("TCourses table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TCourses could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    private func createAssignmentsTable() {
        /*
         Function Name: createAssignmentsTable
         Function Purpose: Function is to create Assignments table if the table does not exist
         */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TAssignments (
            id INTEGER PRIMARY KEY NOT NULL,
            name TEXT NOT NULL,
            dueDate TEXT,
            dueOnDate TEXT,
            description TEXT NOT NULL,
            grade REAL,
            courseID INTEGER NOT NULL,
            status TEXT,
            FOREIGN KEY (courseID) REFERENCES TCourses(id)
        );
        """
        
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TAssignments table created.")
            } else {
                print("TAssignments table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TAssignments could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    /* ########################################################################
     Create Views
     ######################################################################## */
    private func createStudentsView() {
        /*
         Function Name: createStudentsView
         Function Purpose: Function is to create a view for the TStudents table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTStudents AS
        SELECT
            first_name      AS FirstName,
            last_name       AS LastName,
            login_name      AS LoginEmail
        FROM TStudents;
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTStudents view created.")
            } else {
                print("vTStudents view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTStudents could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    private func createCoursesView() {
        /*
         Function Name: createCoursesView
         Function Purpose: Function is to create a view for the TCourses table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTCourses AS
        SELECT
            name            AS CourseName,
            course_code     AS CourseCode,
            start_date      AS CourseStartDate,
            end_date        AS CourseEndDate
        FROM TCourses;
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTCourses view created.")
            } else {
                print("vTCourses view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTCourses could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    private func createAssignmentsView() {
        /*
         Function Name: createAssignmentsView
         Function Purpose: Function is to create a view for the TAssignments table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTAssignments AS
        SELECT
            name            AS AssignmentName,
            dueDate         AS DueDate,
            dueOnDate       AS DueOnDate,
            description     AS AssignmentDescription,
            grade           AS Grade,
            courseID        AS CourseID,
            status          AS AssignmentStatus
        FROM TAssignments;
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTAssignments view created.")
            } else {
                print("vTAssignments view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTAssignments could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    private func createAssignmentsToDoView() {
        /*
         Function Name: createAssignmentsToDoView
         Function Purpose: Function is to create a view for the TAssignmentsToDo table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTAssignmentsToDo AS
        SELECT
            name            AS AssignmentName,
            dueDate         AS DueDate,
            dueOnDate       AS DueOnDate,
            description     AS AssignmentDescription,
            grade           AS Grade,
            courseID        AS CourseID,
            status          AS AssignmentStatus
        FROM TAssignments
        WHERE status = 'ToDo';
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTAssignmentsToDo view created.")
            } else {
                print("vTAssignmentsToDo view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTAssignmentsToDo could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    private func createAssignmentsInProgressView() {
        /*
         Function Name: createAssignmentsInProgressView
         Function Purpose: Function is to create a view for the TAssignmentsInProgress table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTAssignmentsInProgress AS
        SELECT
            name            AS AssignmentName,
            dueDate         AS DueDate,
            dueOnDate       AS DueOnDate,
            description     AS AssignmentDescription,
            grade           AS Grade,
            courseID        AS CourseID,
            status          AS AssignmentStatus
        FROM TAssignments
        WHERE status = 'InProgress';
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTAssignmentsInProgress view created.")
            } else {
                print("vTAssignmentsInProgress view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTAssignmentsInProgress could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    private func createAssignmentsCompletedView() {
        /*
         Function Name: createAssignmentsCompletedView
         Function Purpose: Function is to create a view for the TAssignmentsCompleted table
         */
        let createViewString = """
        CREATE VIEW IF NOT EXISTS vTAssignmentsCompleted AS
        SELECT
            name            AS AssignmentName,
            dueDate         AS DueDate,
            dueOnDate       AS DueOnDate,
            description     AS AssignmentDescription,
            grade           AS Grade,
            courseID        AS CourseID,
            status          AS AssignmentStatus
        FROM TAssignments
        WHERE status = 'Completed';
        """
        
        var createViewStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createViewString, -1, &createViewStatement, nil) == SQLITE_OK {
            if sqlite3_step(createViewStatement) == SQLITE_DONE {
                print("vTAssignmentsCompleted view created.")
            } else {
                print("vTAssignmentsCompleted view could not be created.")
            }
        } else {
            print("CREATE VIEW statement for vTAssignmentsCompleted could not be prepared.")
        }
        sqlite3_finalize(createViewStatement)
    }
    
    /* ########################################################################
     Save Content To Tables
     ######################################################################## */
    /*func saveUser(_ user: Users) {
     
     Function Name: saveUser
     Function Purpose: Function is to save the user that is pulled from the Canvas API call
     
     let insertStatementString = """
     INSERT INTO TStudents (id, token_id, first_name, last_name, login_name, login_password)
     VALUES (?, ?, ?, ?, ?, ?)
     ON CONFLICT(id) DO UPDATE SET
     token_id = excluded.token_id,
     first_name = excluded.first_name,
     last_name = excluded.last_name,
     login_name = excluded.login_name,
     login_password = excluded.login_password;
     """
     
     var insertStatement: OpaquePointer? = nil
     
     if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
     sqlite3_bind_int(insertStatement, 1, Int32(user.id))
     sqlite3_bind_text(insertStatement, 2, (user.token_id as NSString).utf8String, -1, nil)
     sqlite3_bind_text(insertStatement, 3, (user.first_name as NSString).utf8String, -1, nil)
     sqlite3_bind_text(insertStatement, 4, (user.last_name as NSString).utf8String, -1, nil)
     sqlite3_bind_text(insertStatement, 5, (user.login_name as NSString).utf8String, -1, nil)
     sqlite3_bind_text(insertStatement, 6, (user.login_password as NSString).utf8String, -1, nil)
     
     if sqlite3_step(insertStatement) == SQLITE_DONE {
     print("Successfully inserted/updated user.")
     } else {
     print("Could not insert/update user.")
     }
     } else {
     print("INSERT statement could not be prepared.")
     }
     sqlite3_finalize(insertStatement)
     }*/
    
    func saveCourse(_ course: Course) {
        /*
         Function Name: saveCourse
         Function Purpose: Function is to save the course that is pulled from the Canvas API call
         */
        let insertStatementString = """
        INSERT INTO TCourses (id, name, course_code, start_date, end_date)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
        name = excluded.name,
        course_code = excluded.course_code,
        start_date = excluded.start_date,
        end_date = excluded.end_date;
        """
        
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(course.id))
            sqlite3_bind_text(insertStatement, 2, (course.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (course.code as NSString).utf8String, -1, nil)
            
            // Convert Date to String or Timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let startDateString = dateFormatter.string(from: course.startDate)
            let endDateString = dateFormatter.string(from: course.endDate)
            
            sqlite3_bind_text(insertStatement, 4, (startDateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (endDateString as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted course.")
            } else {
                print("Could not insert course.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func saveAssignment(_ assignment: Assignment) {
        /*
         Function Name: saveAssignment
         Function Purpose: Function is to save the assignment that is pulled from the Canvas API call
         */
        let insertStatementString = """
        INSERT INTO TAssignments (id, name, dueDate, dueOnDate, description, grade, courseID, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            name = excluded.name,
            dueDate = excluded.dueDate,
            dueOnDate = excluded.dueOnDate,
            description = excluded.description,
            grade = excluded.grade,
            courseID = excluded.courseID,
            status = excluded.status;
        """
        
        var insertStatement: OpaquePointer? = nil
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(assignment.id))
            sqlite3_bind_text(insertStatement, 2, (assignment.name as NSString).utf8String, -1, nil)
            
            if let dueDate = assignment.dueDate {
                let dueDateString = dateFormatter.string(from: dueDate)
                sqlite3_bind_text(insertStatement, 3, (dueDateString as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 3)
            }
            
            if let dueOnDate = assignment.dueOnDate {
                let dueOnDateString = dateFormatter.string(from: dueOnDate)
                sqlite3_bind_text(insertStatement, 4, (dueOnDateString as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 4)
            }
            
            sqlite3_bind_text(insertStatement, 5, (assignment.description as NSString).utf8String, -1, nil)
            
            if let grade = assignment.grade {
                sqlite3_bind_double(insertStatement, 6, grade)
            } else {
                sqlite3_bind_null(insertStatement, 6)
            }
            
            sqlite3_bind_int(insertStatement, 7, Int32(assignment.courseID))
            sqlite3_bind_text(insertStatement, 8, (assignment.status.rawValue as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted assignment.")
            } else {
                print("Could not insert assignment.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    
    /* ########################################################################
     Update Content To Tables
     ######################################################################## */
    func updateStudent(id: Int, firstName: String?, lastName: String?, loginId: String?) {
        /*
         Function Name: updateStudent
         Function Purpose: Function is to update the TStudents Table
         */
        let updateStatementString = """
        UPDATE TStudents
        SET token_id = ?,
            first_name = ?,
            last_name = ?,
            login_name = ?,
            login_password = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (firstName as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (lastName as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (loginId as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 4, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated student.")
            } else {
                print("Could not update student.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateCourse(id: Int, courseName: String?, courseCode: String?, startDate: String?, endDate: String?) {
        /*
         Function Name: updateCourse
         Function Purpose: Function is to update the TCourses Table
         */
        let updateStatementString = """
        UPDATE TCourses
        SET name = ?,
            course_code = ?,
            start_date = ?,
            end_date = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (courseName as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (courseCode as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (startDate as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, (endDate as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 5, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated course.")
            } else {
                print("Could not update course.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateAssignment(id: Int, assignmentName: String?, dueDate: String?, dueOnDate: String?, description: String?, grade: Double?, courseID: Int, status: String?) {
        /*
         Function Name: updateAssignment
         Function Purpose: Function is to update the TAssignments Table
         */
        let updateStatementString = """
        UPDATE TAssignments
        SET name = ?,
            dueDate = ?,
            dueOnDate = ?,
            description = ?,
            grade = ?,
            courseID = ?,
            status = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (assignmentName as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (dueDate as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (dueOnDate as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, (description as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 5, grade ?? 0)
            sqlite3_bind_int(updateStatement, 6, Int32(courseID))
            sqlite3_bind_text(updateStatement, 7, (status as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 8, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated assignment.")
            } else {
                print("Could not update assignment.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateAssignmentDueOnDate(assignmentId: Int, dueOnDate: String) {
        /*
         Function Name: updateAssignmentDueOnDate
         Function Purpose: Function is to update the TAssignments Table with the new due on date
         */
        let updateStatementString = """
        UPDATE TAssignments
        SET dueOnDate = ?, status = 'InProgress'
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Bind the new due on date to the first placeholder
            sqlite3_bind_text(updateStatement, 1, (dueOnDate as NSString).utf8String, -1, nil)
            // Bind the assignment ID to the second placeholder
            sqlite3_bind_int(updateStatement, 2, Int32(assignmentId))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated assignment due on date.")
            } else {
                print("Could not update assignment due on date.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateAssignmentToDo(assignmentId: Int, newStatus: String = "ToDo") {
        /*
         Function Name: updateAssignmentInProgress
         Function Purpose: Function is to update the TAssignments Table with the 'ToDo' status
         */
        let updateStatementString = """
        UPDATE TAssignments
        SET status = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Bind the new status to the first placeholder
            sqlite3_bind_text(updateStatement, 1, (newStatus as NSString).utf8String, -1, nil)
            // Bind the assignment ID to the second placeholder
            sqlite3_bind_int(updateStatement, 2, Int32(assignmentId))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated assignment status to \(newStatus).")
            } else {
                print("Could not update assignment status.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateAssignmentInProgress(assignmentId: Int, newStatus: String = "InProgress") {
        /*
         Function Name: updateAssignmentInProgress
         Function Purpose: Function is to update the TAssignments Table with the 'InProgress' status
         */
        let updateStatementString = """
        UPDATE TAssignments
        SET status = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Bind the new status to the first placeholder
            sqlite3_bind_text(updateStatement, 1, (newStatus as NSString).utf8String, -1, nil)
            // Bind the assignment ID to the second placeholder
            sqlite3_bind_int(updateStatement, 2, Int32(assignmentId))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated assignment status to \(newStatus).")
            } else {
                print("Could not update assignment status.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    func updateAssignmentCompleted(assignmentId: Int, newStatus: String = "Completed") {
        /*
         Function Name: updateAssignmentCompleted
         Function Purpose: Function is to update the TAssignments Table with the 'Completed' status
         */
        let updateStatementString = """
        UPDATE TAssignments
        SET status = ?
        WHERE id = ?;
        """
        
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            // Bind the new status to the first placeholder
            sqlite3_bind_text(updateStatement, 1, (newStatus as NSString).utf8String, -1, nil)
            // Bind the assignment ID to the second placeholder
            sqlite3_bind_int(updateStatement, 2, Int32(assignmentId))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated assignment status to \(newStatus).")
            } else {
                print("Could not update assignment status.")
            }
        } else {
            print("UPDATE statement could not be prepared.")
        }
        sqlite3_finalize(updateStatement)
    }
    
    /* ########################################################################
     Delete Content From Tables
     ######################################################################## */
    func deleteStudent(id: Int) {
        /*
         Function Name: deleteStudent
         Function Purpose: Function is to delete the TStudents Table
         */
        let deleteStatementString = "DELETE FROM TStudents WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted student.")
            } else {
                print("Could not delete student.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteCourse(id: Int) {
        /*
         Function Name: deleteCourse
         Function Purpose: Function is to delete the TCourses Table
         */
        let deleteStatementString = "DELETE FROM TCourses WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted course.")
            } else {
                print("Could not delete course.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func deleteAssignment(id: Int) {
        /*
         Function Name: deleteAssignment
         Function Purpose: Function is to delete the TAssignments Table
         */
        let deleteStatementString = "DELETE FROM TAssignments WHERE id = ?;"
        
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted assignment.")
            } else {
                print("Could not delete assignment.")
            }
        } else {
            print("DELETE statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    
    /* ########################################################################
     Create Query Executable
     ######################################################################## */
    func fetchAllCoursesWithAssignments() -> [Course] {
        /*
         Function Name: fetchAllCoursesWithAssignments
         Function Purpose: Function process the opening of db by fetching courses and
         assignments. Returns an array of objects
         */
        let courses = fetchCourses(using: self.db!)
        return courses
    }
    
    func fetchCourses(using db: OpaquePointer) -> [Course] {
        /*
         Function Name: fetchCourses
         Function Purpose: Function is to fetch the courses in the db. Returns an array of objects
         */
        let query = "SELECT * FROM TCourses;"
        var queryStatement: OpaquePointer? = nil
        
        var courses: [Course] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let courseID = Int(sqlite3_column_int(queryStatement, 0))
                let courseName = String(cString: sqlite3_column_text(queryStatement, 1))
                let courseCode = String(cString: sqlite3_column_text(queryStatement, 2))
                
                // Convert date strings to Date objects using a DateFormatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                let startDateString = String(cString: sqlite3_column_text(queryStatement, 3))
                let endDateString = String(cString: sqlite3_column_text(queryStatement, 4))
                
                if let startDate = dateFormatter.date(from: startDateString),
                   let endDate = dateFormatter.date(from: endDateString) {
                    
                    let course = Course(id: courseID,
                                        name: courseName,
                                        code: courseCode,
                                        startDate: startDate,
                                        endDate: endDate,
                                        assignments: fetchAssignments(using: db, courseID: courseID))
                    
                    courses.append(course)
                } else {
                    print("Error converting date strings to Date objects.")
                }
            }
        } else {
            print("SELECT statement for TCourses could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        
        return courses
    }
    
    func fetchAssignments(using db: OpaquePointer, courseID: Int) -> [Assignment] {
        /*
         Function Name: fetchAssignments
         Function Purpose: Function is to fetch the assignments for the course ID that is
         passed in as param. Returns an array of objects
         */
        let query = "SELECT * FROM TAssignments WHERE courseID = \(courseID);"
        var queryStatement: OpaquePointer? = nil
        
        var assignments: [Assignment] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let assignmentID = Int(sqlite3_column_int(queryStatement, 0))
                let assignmentName = String(cString: sqlite3_column_text(queryStatement, 1))
                //print(assignmentID, assignmentName)
                
                // Convert date strings to Date objects using a DateFormatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                var dueDateString: String?
                var dueDate: Date?
                
                if let cString = sqlite3_column_text(queryStatement, 2) {
                    dueDateString = String(cString: cString)
                    dueDate = dueDateString!.isEmpty ? nil : dateFormatter.date(from: dueDateString!)
                }
                //print(dueDateString, dueDate)
                
                var dueOnDateString: String?
                var dueOnDate: Date?
                
                if let cString = sqlite3_column_text(queryStatement, 3) {
                    dueOnDateString = String(cString: cString)
                    dueOnDate = dueOnDateString!.isEmpty ? nil : dateFormatter.date(from: dueOnDateString!)
                }
                
                //print(dueOnDateString, dueOnDate)
                
                let assignmentDescription = String(cString: sqlite3_column_text(queryStatement, 4))
                let grade = Double(sqlite3_column_double(queryStatement, 5))
                let statusString = String(cString: sqlite3_column_text(queryStatement, 7))
                let status = AssignmentStatus(rawValue: statusString) ?? .toDo
                
                //print(statusString, status)
                
                let assignment = Assignment(id: assignmentID,
                                            name: assignmentName,
                                            dueDate: dueDate,
                                            dueOnDate: dueOnDate,
                                            description: assignmentDescription,
                                            grade: grade,
                                            courseID: courseID,
                                            status: status)
                
                assignments.append(assignment)
            }
        } else {
            print("SELECT statement for TAssignments could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        
        return assignments
    }
    
    func fetchAssignmentsStatus(using db: OpaquePointer, courseID: Int, statusFilter: String) -> [Assignment] {
        /*
         Function Name: fetchAssignmentsStatus
         Function Purpose: Function is to fetch the assignments with status passed as param.
         Returns an array of objects
         */
        let query = """
        SELECT * FROM TAssignments
        WHERE course_id = \(courseID) AND status = '\(statusFilter)';
        """
        var queryStatement: OpaquePointer? = nil
        
        var assignments: [Assignment] = []
        
        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let assignmentID = Int(sqlite3_column_int(queryStatement, 0))
                let assignmentName = String(cString: sqlite3_column_text(queryStatement, 1))
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                let dueDateString = String(cString: sqlite3_column_text(queryStatement, 2))
                let dueDate = dateFormatter.date(from: dueDateString)
                
                let dueOnDateString = String(cString: sqlite3_column_text(queryStatement, 3))
                let dueOnDate: Date? = dueOnDateString.isEmpty ? nil : dateFormatter.date(from: dueOnDateString)
                
                let assignmentDescription = String(cString: sqlite3_column_text(queryStatement, 4))
                let grade = Double(sqlite3_column_double(queryStatement, 5))
                let statusString = String(cString: sqlite3_column_text(queryStatement, 7))
                let status = AssignmentStatus(rawValue: statusString) ?? .toDo
                
                let assignment = Assignment(id: assignmentID,
                                            name: assignmentName,
                                            dueDate: dueDate,
                                            dueOnDate: dueOnDate,
                                            description: assignmentDescription,
                                            grade: grade,
                                            courseID: courseID,
                                            status: status)
                
                assignments.append(assignment)
            }
        } else {
            print("SELECT statement for TAssignments could not be prepared.")
        }
        sqlite3_finalize(queryStatement)
        
        return assignments
    }
    
    func calculateOngoingCoursesProgress(courses: [Course]) -> Float {
        /*
         Function Name: calculateOngoingCoursesProgress
         Function Purpose: Function is calculate the progress of all ongoing courses
         */
        // Get today's date
        let today = Date()
        
        // Filter out ongoing courses based on their start and end dates
        let ongoingCourses = courses.filter { course in
            return course.startDate <= today && today <= course.endDate
        }
        
        // Calculate the progress for each ongoing course
        let totalProgress = ongoingCourses.reduce(0.0) { (total, course) in
            let courseDuration = course.endDate.timeIntervalSince(course.startDate)
            let timeElapsed = today.timeIntervalSince(course.startDate)
            let courseProgress = timeElapsed / courseDuration
            return total + courseProgress
        }

        // Average progress across all ongoing courses
        let averageProgress = ongoingCourses.isEmpty ? 0.0 : totalProgress / Double(Float(ongoingCourses.count))
        
        // Round the average progress to two decimal places and return
        return Float(round(averageProgress * 100) / 100)
    }
    
    func calculateAllCoursesAssignmentsProgress(using db: OpaquePointer, courses: [Course]) -> [Int: (Float, [AssignmentStatus: Float])] {
        /*
         Function Name: calculateAllCoursesAssignmentsProgress
         Function Purpose: Function is to fetch all the course assignments in the db and calculates
         assignments in progress per course.
         */
        // Declare Local Variables
        var coursesProgress: [Int: (Float, [AssignmentStatus: Float])] = [:]
        let today = Date()  // Get today's date

        // Iterate through each course
        for course in courses {
            let assignments = fetchAssignments(using: db, courseID: course.id)
            let totalAssignments = assignments.count
            var completedCount = 0
            var inProgressCount = 0

            for assignment in assignments {
                if let dueDate = assignment.dueDate {
                    if dueDate < today {
                        completedCount += 1  // Count as completed if due date has passed
                    } else {
                        inProgressCount += 1  // Count as in progress if due date is in the future
                    }
                }
            }

            // Calculate progress based on completed and in-progress assignments
            let completedProgress = totalAssignments > 0 ? Float(completedCount) / Float(totalAssignments) : 0.0
            let inProgressProgress = totalAssignments > 0 ? Float(inProgressCount) / Float(totalAssignments) : 0.0

            // Determine overall progress
            let overallProgress = max(completedProgress, inProgressProgress)

            // Calculate status percentages for the course
            let statusPercentages = calculateAssignmentsStatusPercentage(using: db, courseID: course.id)
            
            // Combine overall progress and status percentages
            coursesProgress[course.id] = (overallProgress, statusPercentages)
        }

        // Return a dictionary mapping course IDs to their respective progress
        return coursesProgress
    }
    
    func calculateAssignmentsStatusPercentage(using db: OpaquePointer, courseID: Int) -> [AssignmentStatus: Float] {
        /*
         Function Name: calculateAssignmentsProgress
         Function Purpose: Function is to fetch all the assignments in the db and calculates
         assignments in progress.
         */
        // Fetch assignments for the given course ID
        let assignments = fetchAssignments(using: db, courseID: courseID)

        // Calculate the total number of assignments
        let totalAssignments = assignments.count

        // Initialize a dictionary to hold counts for each status
        var statusCounts: [AssignmentStatus: Int] = [
            .toDo: 0,
            .inProgress: 0,
            .completed: 0
        ]

        // Initialize a dictionary to hold percentages for each status
        var statusPercentages: [AssignmentStatus: Float] = [:]

        // Count the assignments for each status
        for assignment in assignments {
            statusCounts[assignment.status, default: 0] += 1
        }

        // Calculate and store the percentages
        for (status, count) in statusCounts {
            // Skip 'ToDo' status
            if status == .toDo {
                continue
            }

            let percentage = totalAssignments > 0 ? (Float(count) / Float(totalAssignments)) * 100 : 0
            statusPercentages[status] = round(percentage * 100) / 100
        }

        return statusPercentages
    }
}
