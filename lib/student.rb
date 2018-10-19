require_relative "../config/environment.rb"

require 'pry'

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  # creates the students table with columns that match the attributes of the indiviual students
  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade INTEGER
          )
        SQL
      DB[:conn].execute(sql)
  end

  # drops the students table from the database
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
     DB[:conn].execute(sql)
  end

  # Inserts a new role into the database using the attributes of the give object.
  # Also assigns the id attribute of the object
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  # When we call this method we will pass it the array that is the row returned from the databse by the execution of a SQL query
  # create a new student object with these attributes
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(name, grade, id)
  end

# It queries the database table for a record that has a name of the name passed in as an arguments.
# Then it uses the #new_from_db method to instantiate a student object with the database row that the SQL query returns
  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM students
        WHERE name = ?
        LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end








end
