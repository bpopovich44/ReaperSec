## Python script to create a file 

from os.path import join

def write():
    print('Creating a new file')
    path = "/root/TEST_keylogeer"
    name = raw_input('Enter a name for your file: ') + '.txt'

    try:
        file = open(join(path, name), 'w')
        file.close

    except:
        print('Something went wrong, file did not create')
        sys.exit(0)



write()
