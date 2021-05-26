# +
import glob
import os

class RenameFiles:
    def set_name(self, v_documento):

        # * means all if need specific format then *.csv
        list_of_files = glob.glob ('C:\\RPA\\output\\*.pdf')
        latest_file = max (list_of_files, key=os.path.getctime)

        os.rename (latest_file, 'C:\\RPA\\output\\' + v_documento)
        print (latest_file)
