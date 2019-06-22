from configparser import ConfigParser


def read_db_config(database):
    
    filename = '/etc/my.cnf'

    # create parser and read ini configuration file
    parser = ConfigParser()
    parser.read(filename)

    # get section, default to mysql
    db = {}
    if parser.has_section(database):
        items = parser.items(database)
        for item in items:
            db[item[0]] = item[1]
    else:
        raise Exception('{0} not found in the {1} file'.format(database, filename))

    return db
