import psycopg2, os, shutil, sys, logging, time
from psycopg2 import sql

basePath = "/mnt/ceph/media/volumes/media"
replacePath = "/mnt/unionfs/Media"
dry_run = False
qualityProfile = 8

fakePath = '/foo/bar'

# Setup logging
logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S')

# Database connection parameters
db_params_target = {
    'dbname': 'radarr_main',                                       # Replace with your database name
    'user': 'radarr',                                       # Replace with your database username
    'password': 'SECRET',                                   # Replace with your database password
    'host': '10.42.13.157',                  # Replace with your database host
    'port': '5432'                                                 # Replace with your database port (default is 5432)
}

db_params_source = {
    'dbname': 'radarr_4k_main',                                    # Replace with your database name
    'user': 'radarr-4k',                                       # Replace with your database username
    'password': 'SECRET',                                   # Replace with your database password
    'host': '10.42.13.157',                  # Replace with your database host
    'port': '5432'                                                 # Replace with your database port (default is 5432)
}

class postgreConnection():

    # Initialize variables
    dbParams = {}

    class videoFiles():
        def __init__(self,data):
            self.MovieFileId = data[0]
            self.Path = data[1].replace(replacePath,basePath)
            if data[2] is None:
                self.RelativePath = fakePath
            else:    
                self.RelativePath = data[2]
            self.QualityProfileId = data[3]
            self.Title = data[4]
            self.TmdbId = data[5]
            self.ImdbId = data[6]
            self.FullPath = self.Path + "/" + self.RelativePath

        def checkForFile(self):
            return os.path.exists(self.FullPath)
        
        def removeFile(self):
            if self.checkForFile:
                # print("Removing movie %s" % (self.Title))
                logging.info("Removing movie %s" % (self.Title))
                if not dry_run:
                    os.remove(self.FullPath)
                else:
                    logging.info("DRY RUN: No files were modified")
            else:
                raise ValueError('Source file does not exist.')

    def __init__(self,params):
        self.params = params
        self.connection = psycopg2.connect(**self.params)
        self.connection.set_client_encoding("UTF8")
        self.cursor = self.connection.cursor()

    def __enter__(self):
        return self

    def __exit__(self, err_type, err_value, traceback):
        if err_type and err_value:
            logging.info("Rollback Database?")
        self.cursor.close()
        self.connection.close()
        return False
    
    def commit(self):
        self.connection.commit()

    def getVersion(self):
        self.cursor.execute("SELECT version();")
        db_version = self.cursor.fetchone()
        return db_version

    def getAllVideoIds(self):
        sql = '''
            SELECT t1."MovieFileId", t1."Path", t2."RelativePath", t1."QualityProfileId", t3."Title", t3."TmdbId", t3."ImdbId"
            FROM "Movies" t1
            LEFT JOIN "MovieFiles" t2 ON t1."MovieFileId" = t2."Id"
            JOIN "MovieMetadata" t3 ON t1."MovieMetadataId" = t3."Id"
            ORDER BY "TmdbId" ASC
        '''
        fileInfo = []
        self.cursor.execute(sql)
        data = self.cursor.fetchall()
        for item in data:
            # logging.info(item)
            fileInfo.append(self.videoFiles(item))
        return fileInfo

    def checkForQualityProfile(self,qualityProfile):
        sql = '''
            SELECT *
            FROM "QualityProfiles"
            WHERE "Id" = %s;
        '''
        self.cursor.execute(sql,(qualityProfile,))          # Dont remove the last ",". It is apparently extra important
        value = self.cursor.fetchone() 
        if value is None:
            raise ValueError('Quality Profile not found in target database.')
        else:
            return value is not None
        
    def updateQualityProfile(self,qualityProfile: int, videoFiles: videoFiles):  
        if self.checkForQualityProfile(qualityProfile) == True:
          logging.info("Updating %s quality profile to %s" % (videoFiles.Title,qualityProfile))
          if not dry_run:
              logging.info("Updating...")
              sql = '''
                  UPDATE "Movies"
                  SET "QualityProfileId" = %s
                  WHERE "Path" = %s
              '''
              # Must undo the base path replacement since SQL database using the original path
              self.cursor.execute(sql,(qualityProfile,videoFiles.Path.replace(basePath,replacePath),))          # Dont remove the last ",". It is apparently extra important
              self.commit()
          else:
              logging.info("DRY RUN: No files modified")

def moveFile(sourceItem: postgreConnection.videoFiles, targetItem: postgreConnection.videoFiles):
    logging.info("Moving movie %s" % (sourceItem.Title))
    targetPath = str(targetItem.Path) + "/"
    if not os.path.exists(targetPath):
        logging.info("Directory not found. Creating %s" % (targetPath))
        os.makedirs(targetPath)
    logging.info("%s --> %s" % (sourceItem.FullPath,targetPath))
    if not dry_run:
        logging.info("Moving...")
        start_time = time.time()
        shutil.copy2(sourceItem.FullPath, targetPath)
        end_time = time.time()

        elapsed_time = end_time - start_time
        file_size = os.path.getsize(sourceItem.FullPath)
        speed = file_size / elapsed_time  # Speed in bytes per second

        logging.info(f"File moved successfully in {elapsed_time:.2f} seconds.")
        logging.info(f"Transfer speed: {speed / 1024:.2f} KB/s")
    else:
        logging.info("DRY RUN: No files modified")

if __name__ == "__main__":    

    with postgreConnection(db_params_target) as targetDb:
       with postgreConnection(db_params_source) as sourceDb:
            sourceItems = sourceDb.getAllVideoIds()
            targetItems = targetDb.getAllVideoIds()
            for sourceItem in sourceItems:
                for targetItem in targetItems:
                    if sourceItem.TmdbId == targetItem.TmdbId:
                        ### At this point, we have duplicate movies in both databases
                        logging.info("Found %s" % sourceItem.Title)
                        moveFile(sourceItem=sourceItem, targetItem=targetItem)
                        # Check if file has successfully been copied
                        if (os.path.exists((targetItem.Path + "/" + sourceItem.RelativePath)) & (not dry_run)):
                            sourceItem.removeFile()
                            if targetItem.RelativePath != fakePath:
                              targetItem.removeFile()
                            else:
                              logging.info("No target files to remove for %s" % (targetItem.Title))
                            targetDb.updateQualityProfile(qualityProfile=qualityProfile,videoFiles=targetItem)
                        elif (not dry_run):
                            raise ValueError('File copy has failed.')
                        else:
                            logging.info("Dry Run Enabled")
                        break
                    else:
                        logging.info("%s not found in target database" % (sourceItem.Title))
