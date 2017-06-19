import os
import sys

def import_data(table, data_file):
    sql = "delete from {};\n".format(table)
    with open(data_file) as f:
        for l in f:
            idx = l.split('|')[0].strip()
            label = l.split('|')[1].strip()[3:-2]
            if table == "dynpoi_item":
                sql += "insert into {} (item, categ, menu) values ({}, {:d}, '\"en\"=>\"{}\"');\n".format(
                    table,
                    idx,
                    int(float(idx) / 1000 * 10),
                    label.replace('"', '""'))
            else:
                sql += "insert into {} values ({}, '\"en\"=>\"{}\"');\n".format(table, idx, label)
    return sql

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print "This script should have 1 parameter : the table name 'dynpoi_item' or 'dynpoi_categ'"
        exit()
    table = sys.argv[1]
    if table == "dynpoi_item" :
        item_menu_file = './frontend/tools/database/item_menu.txt'
        print import_data("dynpoi_item", item_menu_file)
    elif table == "dynpoi_categ" :
        categ_menu_file = './frontend/tools/database/categ_menu.txt'
        print import_data("dynpoi_categ", categ_menu_file)
    else :
        print "Table name not in allowed ones"
