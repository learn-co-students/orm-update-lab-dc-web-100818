require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
              CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY,
                name TEXT,
                grade TEXT
              );
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = "DROP TABLE students;"
      DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name,grade) VALUES (?,?);"
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = self.new(name,grade)
    new_student.save
    new_student
  end

  def update
    sql = "UPDATE students set name = ?, grade = ? where id = ?;"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1],row[2],row[0])
    new_student
  end

  def self.find_by_name(name)
    sql = "SELECT * from students WHERE name = ? LIMIT 1;"
    row = DB[:conn].execute(sql,name)[0]
    self.new_from_db(row)
  end

end
