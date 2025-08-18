import requests
import subprocess
import json
import os
from mido import MidiFile

# Load the JSON data from the URL
response = requests.get("https://fortnitecontent-website-prod07.ol.epicgames.com/content/api/pages/fortnite-game/spark-tracks")
data = response.json()

# Function to replace tracks in MIDI files
def replace_tracks_in_midi(midi_file, track_info):
    try:
        mid = MidiFile(midi_file)

        # First copy - create the '_pro' version with normal renaming
        pro_mid = MidiFile()
        for track in mid.tracks:
            new_track = track.copy()
            for msg in new_track:
                if msg.type == 'track_name':
                    if 'PART GUITAR' in msg.name:
                        msg.name = 'PART GUITAR_FNF'
                    elif 'PLASTIC GUITAR' in msg.name:
                        msg.name = 'PART GUITAR'
                    elif 'PART BASS' in msg.name:
                        msg.name = 'PART BASS_FNF'
                    elif 'PLASTIC BASS' in msg.name:
                        msg.name = 'PART BASS'
            pro_mid.tracks.append(new_track)

        # Save the modified MIDI file with "_pro" appended to the filename
        pro_midi_file = midi_file.replace('.mid', '_pro.mid')
        pro_mid.save(pro_midi_file)

        # Second copy - create the '_drumvox' version with custom renaming
        drumvox_mid = MidiFile()
        for track in mid.tracks:
            new_track = track.copy()
            for msg in new_track:
                if msg.type == 'track_name':
                    if 'PART DRUMS' in msg.name:
                        msg.name = 'PART GUITAR'
                    elif 'PART BASS' in msg.name:
                        msg.name = 'PART BASS_FNF'
                    elif 'PART VOCALS' in msg.name:
                        msg.name = 'PART BASS'
            drumvox_mid.tracks.append(new_track)

        # Save the modified MIDI file with "_drumvox" appended to the filename
        drumvox_midi_file = midi_file.replace('.mid', '_drumvox.mid')
        drumvox_mid.save(drumvox_midi_file)

    except Exception as e:
        print(f"Error while renaming tracks in MIDI file: {e}")

# Function to download and decrypt the .dat file
def download_and_decrypt_dat(dat_url, key):
    dat_file = dat_url.split("/")[-1]
    response = requests.get(dat_url)
    
    # Save the .dat file
    with open(dat_file, 'wb') as f:
        f.write(response.content)
    
    # Run the decryption script
    try:
        subprocess.run(['python3', 'scripts/fnf.py', '-d', dat_file], check=True)
        
        original_mid_file = dat_file.replace('.dat', '.mid')
        renamed_mid_file = f"{key}_og.mid"   # <- add suffix

        if os.path.exists(original_mid_file):
            os.rename(original_mid_file, renamed_mid_file)

            # Create a folder named after the key
            folder_name = f"{key}"
            os.makedirs(folder_name, exist_ok=True)
            moved_mid_file = os.path.join(folder_name, renamed_mid_file)
            os.rename(renamed_mid_file, moved_mid_file)

            # Process the moved .mid file to update track names
            replace_tracks_in_midi(moved_mid_file, data[key].get('track', {}))

            # Create the song.yml file
            track_info = data[key].get('track', {})
            track_title = track_info.get('tt', 'Unknown Title')
            artist_name = track_info.get('an', 'Unknown Artist')
            yml_filename = os.path.join(folder_name, "song.yml")
                
            with open(yml_filename, 'w') as yml_file:
                yml_file.write(f"title: {track_title}\n")
                yml_file.write(f"artist: {artist_name}\n")
                yml_file.write(f"charter: Harmonix, Rhythm Authors\n")

        # Remove the original .dat file
        os.remove(dat_file)

    except subprocess.CalledProcessError as e:
        print(f"Error during decryption: {e}")

# Function to process all tracks
def download_all_tracks():
    for key in data:
        if isinstance(data[key], dict) and "track" in data[key]:
            track_info = data[key].get('track', {})
            if 'mu' in track_info:
                download_and_decrypt_dat(track_info['mu'], key)

# Start the download process
download_all_tracks()