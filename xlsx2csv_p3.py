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
import pandas as pd

def csv_from_excel(xlsx_file):
    print("Reading Excel spreadsheet data..."),
    xls = pd.ExcelFile(xlsx_file)
    print("Done!")

    file_name, file_extension = os.path.splitext(xlsx_file)
    df = xls.parse(index_col=None, na_values=['NA'])
    print("Writing csv file..."),
    df.to_csv(file_name+'.csv')
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

