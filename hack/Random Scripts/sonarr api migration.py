import requests
import logging
import os
import shutil
import json
from tqdm import tqdm

# Configuration Section
API_KEY_MAIN = "SECRET"
API_URL_MAIN = 'https://sonarr.FQDN.com/api/v3'
API_KEY_4K = "SECRET"
API_URL_4K = 'https://sonarr-4k.FQDN.com/api/v3'
DRY_CYCLE = False  # Set to True to enable dry cycle
DELETE_4K_FILES = True  # Set to True to delete files from the 4K instance after copying
DELETE_MAIN_FILES = False # DOES NOT WORK  # Set to True to delete files from the Main instance after copying
PROMPT_AFTER_EACH_SHOW = False  # Set to True to prompt after each show is processed

BASE_PATH_MAIN = "/mnt/ceph/media/volumes/media/TV/TV Shows"
BASE_PATH_4K = "/mnt/ceph/media/volumes/media/4KTV"
# Setup Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def get_shows(api_url, api_key):
    response = requests.get(f'{api_url}/series', headers={'X-Api-Key': api_key})
    response.raise_for_status()
    return response.json()

def get_series(api_url, api_key, series_id):
    response = requests.get(f'{api_url}/series/{series_id}', headers={'X-Api-Key': api_key})
    response.raise_for_status()
    return response.json()

def find_duplicates(main_shows, four_k_shows):
    main_titles = {show['title'].lower() for show in main_shows}
    # duplicates = [show for show in four_k_shows if show['title'].lower() in main_titles]
    duplicates = []
    for show in four_k_shows:
        if show['title'].lower() in main_titles:
            for main in main_shows:
                if main['title'].lower() == show['title'].lower() :
                    y = {"mainRootPath":main['path']}
                    show.update(y)
                    y = {"mainId":main['id']}
                    show.update(y)
                    break
            show.update(y)
            duplicates.append(show)

    return duplicates

def get_episode_files(api_url, api_key, series_id):
    # Get the series details to find the root path
    series_response = requests.get(f'{api_url}/series/{series_id}', headers={'X-Api-Key': api_key})
    series_response.raise_for_status()
    series_data = series_response.json()
    root_path = series_data['path']  # Get the root path of the show

    # Get all episodes for the given series
    response = requests.get(f'{api_url}/episodefile?seriesId={series_id}', headers={'X-Api-Key': api_key})
    response.raise_for_status()
    episodes = response.json()

    # Collect full file paths for all episodes
    file_paths = []
    for episode in episodes:
        if 'path' in episode and episode['path'] is not None:
            episode_file_path = episode['path']
            full_file_path = os.path.join(root_path, episode_file_path)  # Combine root path with episode file path
            file_paths.append(full_file_path.replace("/mnt/unionfs/Media/4KTV",BASE_PATH_4K))
    
    return file_paths

def copy_file(source, destination):
    logging.info(f"Copying from {source} to {destination}")

    if not DRY_CYCLE:
        # Get the total size of the file
        total_size = os.path.getsize(source)

        # Create a tqdm progress bar
        with open(source, 'rb') as src_file, open(destination, 'wb') as dst_file, tqdm(
            total=total_size, unit='B', unit_scale=True, unit_divisor=1024
        ) as progress_bar:
            while True:
                buf = src_file.read(1024 * 1024)  # Read in 1 MB chunks
                if not buf:
                    break
                dst_file.write(buf)
                progress_bar.update(len(buf))
    else:
        logging.info("DRY CYCLE: Skipping file copy.")

def delete_file(filepath):
    logging.info(f"Deleting file: {filepath}")
    if not DRY_CYCLE:
        os.remove(filepath)
    else:
        logging.info("DRY CYCLE: Skipping file deletion.")

def process_duplicates(main_shows, four_k_shows):
    duplicates = find_duplicates(main_shows, four_k_shows)
    for duplicate in duplicates:
        logging.info(f"Processing duplicate show: {duplicate['title']}")
        
        episode_files = get_episode_files(API_URL_4K, API_KEY_4K, duplicate['id'])
        
        for source_path in episode_files:
            season_folder = os.path.basename(os.path.dirname(source_path))

            # Get proper desitnation path
            mainPath = duplicate['mainRootPath'].replace("/mnt/unionfs/Media/TV/TV Shows", BASE_PATH_MAIN)

            destination_folder = os.path.join(mainPath, season_folder)
            destination_path = os.path.join(destination_folder, os.path.basename(source_path))

            if not os.path.exists(destination_folder):
                os.makedirs(destination_folder)

            copy_file(source_path, destination_path)

            if DELETE_4K_FILES:
                delete_file(source_path)

            if DELETE_MAIN_FILES:
                delete_file(os.path.join(BASE_PATH_MAIN, source_path))

        if PROMPT_AFTER_EACH_SHOW:
            input("Press Enter to continue to the next show...")

def main():
    logging.info("Connecting to Sonarr instances...")
    main_shows = get_shows(API_URL_MAIN, API_KEY_MAIN)
    four_k_shows = get_shows(API_URL_4K, API_KEY_4K)
    
    process_duplicates(main_shows, four_k_shows)
    
    logging.info("Processing completed.")

if __name__ == "__main__":
    main()