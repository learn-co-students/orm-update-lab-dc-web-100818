require_relative "../config/environment.rb"
require "pry"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
      DB[:conn].execute("DROP TABLE students")
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    else
      sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
        SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    student = Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    #binding.pry
    Student.new(result[0], result[1], result[2])
  end
end
