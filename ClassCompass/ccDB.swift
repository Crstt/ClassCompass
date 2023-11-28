/*
 Project Name: Class Compass Database
 Developer: David Teixeira
 Date: 11/16/2023
 Abstract: This project is vol 0.0.1 to store and retrieve data for final project SDEV260
 */

// Import Swift Libraries
import Foundation
import SQLite3
import CanvasAPIClient

// Create Class
class Database {
/*
 Class Name: Database
 Class Purpose: Class of object for the database
 */
    // Delcare Public Variables. (pointer used for C API's ie. SQLite with C library)
    var db: OpaquePointer?

    func initialize_Use_Database() {
    /*
     Function Name: initialize_Use_Database
     Function Purpose: Function is to initialize the db and insert an item
     */
        // Create the db instance
        db = openDatabase()
        
        // Create the base tables
        createStudentTable()
        createCoursesTable()
        createAssignmentsTable()
        createCourseAssignmentTable()
        createStudent_AssignmentTable()
        createStudent_Course_AssignmentTable()
        
        // Create the views
        createStudentsView()
        createCoursesView()
        createAssignmentsView()
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
            first_name TEXT,
            last_name TEXT,
            login_id TEXT,
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
            name TEXT,
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
            name TEXT,
            due_date TEXT,
            description TEXT,
            grade REAL,
            grading_type TEXT
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

    private func createCourseAssignmentTable() {
    /*
     Function Name: createCourseAssignmentTable
     Function Purpose: Function is to create CourseAssignment table if the table does not exist
     */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TCourseAssignments (
            course_id INTEGER,
            assignment_id INTEGER,
            PRIMARY KEY (course_id, assignment_id),
            FOREIGN KEY (course_id) REFERENCES TCourses(id),
            FOREIGN KEY (assignment_id) REFERENCES TAssignments(id)
        );
        """

        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TCourseAssignments table created.")
            } else {
                print("TCourseAssignments table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TCourseAssignments could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    private func createStudent_CourseTable() {
    /*
     Function Name: createStudent_CourseTable
     Function Purpose: Function is to create StudentCourse table if the table does not exist
     */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TStudentCourses (
            student_id INTEGER,
            course_id INTEGER,
            PRIMARY KEY (student_id, course_id),
            FOREIGN KEY (student_id) REFERENCES TStudents(id),
            FOREIGN KEY (course_id) REFERENCES TCourses(id),
        );
        """

        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TStudentCourses table created.")
            } else {
                print("TStudentCourses table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TStudentCourses could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }

    private func createStudent_AssignmentTable() {
    /*
     Function Name: createStudent_AssignmentTable
     Function Purpose: Function is to create StudentAssignment table if the table does not exist
     */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TStudentAssignments (
            student_id INTEGER,
            assignment_id INTEGER,
            PRIMARY KEY (student_id, assignment_id),
            FOREIGN KEY (student_id) REFERENCES TStudents(id),
            FOREIGN KEY (assignment_id) REFERENCES TAssignments(id),
        );
        """

        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TStudentCourses table created.")
            } else {
                print("TStudentCourses table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TStudentCourses could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    private func createStudent_Course_AssignmentTable() {
    /*
     Function Name: createStudent_Course_AssignmentTable
     Function Purpose: Function is to create StudentCourseAssignment table if the table does not exist
     */
        let createTableString = """
        CREATE TABLE IF NOT EXISTS TStudentCourseAssignments (
            student_id INTEGER,
            course_id INTEGER,
            assignment_id INTEGER,
            PRIMARY KEY (student_id, course_id, assignment_id),
            FOREIGN KEY (student_id) REFERENCES TStudents(id),
            FOREIGN KEY (course_id) REFERENCES TCourses(id),
            FOREIGN KEY (assignment_id) REFERENCES TAssignments(id)
        );
        """

        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("TStudentCourseAssignments table created.")
            } else {
                print("TStudentCourseAssignments table could not be created.")
            }
        } else {
            print("CREATE TABLE statement for TStudentCourseAssignments could not be prepared.")
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
            login_id        AS LoginEmail
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
            due_date        AS DueDate,
            description     AS AssignmentDescription,
            grade           AS Grade,
            grading_type    AS GradeType
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
    
    /* ########################################################################
                                Save Content To Tables
    ######################################################################## */
    func saveUser(_ user: Users) {
    /*
     Function Name: saveUser
     Function Purpose: Function is to save the user that is pulled from the Canvas API call
     */
        let insertStatementString = """
        INSERT INTO TStudents (id, first_name, last_name, login_id)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
        first_name = excluded.first_name,
        last_name = excluded.last_name,
        login_id = excluded.login_id;
        """

        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(user.id))
            sqlite3_bind_text(insertStatement, 2, (user.first_name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (user.last_name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (user.login_id as NSString).utf8String, -1, nil)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted/updated user.")
            } else {
                print("Could not insert/update user.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
    func saveCourse(_ course: Course) {
    /*
     Function Name: saveCourse
     Function Purpose: Function is to save the course that is pulled from the Canvas API call
     */
        let insertStatementString = """
        INSERT INTO Courses (id, name, course_code, start_date, end_date)
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
            sqlite3_bind_text(insertStatement, 3, (course.courseCode as NSString).utf8String, -1, nil)
            
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
        INSERT INTO Assignments (id, name, due_date, description, grade, grading_type)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
        name = excluded.name,
        due_date = excluded.due_date,
        description = excluded.description,
        grade = excluded.grade,
        grading_type = excluded.grading_type;
        """

        var insertStatement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(assignment.id))
            sqlite3_bind_text(insertStatement, 2, (assignment.name as NSString).utf8String, -1, nil)

            // Convert Date to String or Timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let dueDate = assignment.dueDate {
                let dueDateString = dateFormatter.string(from: dueDate)
                sqlite3_bind_text(insertStatement, 3, (dueDateString as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 3)
            }

            if let description = assignment.description {
                sqlite3_bind_text(insertStatement, 4, (description as NSString).utf8String, -1, nil)
            } else {
                sqlite3_bind_null(insertStatement, 4)
            }

            if let grade = assignment.grade {
                sqlite3_bind_double(insertStatement, 5, grade)
            } else {
                sqlite3_bind_null(insertStatement, 5)
            }

            sqlite3_bind_text(insertStatement, 6, (assignment.gradingType.rawValue as NSString).utf8String, -1, nil)

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
        SET first_name = ?,
            last_name = ?,
            login_id = ?
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

    func updateAssignment(id: Int, assignmentName: String?, dueDate: String?, description: String?, grade: Double?, gradeType: String?) {
    /*
     Function Name: updateAssignment
     Function Purpose: Function is to update the TAssignments Table
     */
        let updateStatementString = """
        UPDATE TAssignments
        SET name = ?,
            due_date = ?,
            description = ?,
            grade = ?,
            grading_type = ?
        WHERE id = ?;
        """

        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (assignmentName as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (dueDate as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (description as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 4, grade ?? 0)
            sqlite3_bind_text(updateStatement, 5, (gradingType as NSString?)?.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 6, Int32(id))

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
}
