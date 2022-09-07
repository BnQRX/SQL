import pyodbc
connectionString = ("Driver={SQL Server Native Client 11.0};"
                                   "Server=DES\ALEX;"
                                   "Database=Test1;"
                                   "Trusted_Connection=yes;")
connection = pyodbc.connect(connectionString)
dbCursor = connection.cursor()
requestString = """SELECT * FROM book"""
dbCursor.execute(requestString)
with open('output.txt', 'w') as data:
    for result in dbCursor:
        print(result, file=data)
connection.commit()