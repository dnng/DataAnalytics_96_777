"""
Simple python script to convert XLSX sheets to CSV

Usage:
    python xls2csv.py <excelfile.xlsx>

Restrictions:
    Requires xlrd module:
        sudo pip install xlrd

    Sheet name hardcoded: EKO_NEFTDetailsAuto
"""
import xlrd
import csv
import sys
import os

def csv_from_excel(xlsx_file):
    print("Reading Excel spreadsheet data..."),
    wb = xlrd.open_workbook(xlsx_file)
    print("Done!")

    file_name, file_extension = os.path.splitext(xlsx_file)
    file_name = os.path.basename(file_name)

    # All spreadsheets have only a single sheet
    sh_names = wb.sheet_names()
    # sh = wb.sheet_by_name('EKO_NEFTDetailsAuto')
    sh = wb.sheet_by_name(sh_names[0])

    print("Writing csv file..."),
    f = open(file_name + '.csv', 'wb')
    wr = csv.writer(f, quoting=csv.QUOTE_ALL)

    for row in xrange(sh.nrows):
        wr.writerow(sh.row_values(row))

    f.close()
    print("Done!")

def main():
    try:
        csv_from_excel(sys.argv[1])
    except Exception as e:
        print('Something might have gone wrong. Did you called the program correctly?')
        print('Usage:')
        print('    python xls2csv.py <excelfile.xlsx>')
        print("Here is the error, in any case:")

if __name__ == "__main__":
    main()

