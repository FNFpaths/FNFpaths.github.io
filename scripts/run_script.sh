#!/bin/bash

# Specify the full path to the onyx command
rm -rf paths
rm fnfp.fs

# Store the original directory
original_dir=$(pwd)

# Specify the parent directory to search for RB2CON files
parent_directory="."

# Create the output file with header
echo "const songs = [" > "$original_dir/fnfp.js"

# Loop through each subdirectory (excluding hidden directories)
for dir in "$parent_directory"/*/; do
    # Check if the directory contains a song.yml file
    if [ -f "$dir/song.yml" ]; then
        echo "Processing directory: $dir"

        # Extract title and artist from song.yml
        title=$(awk '/^ *title:/{gsub(/^ *title: /, ""); print}' "$dir/song.yml")
        artist=$(awk '/^ *artist:/{gsub(/^ *artist: /, ""); print}' "$dir/song.yml")

        shortname=$(basename "$dir")

        # Create the output string in the desired format
        title_artist="$title by $artist"

        # Save the formatted output to a text file in the same directory
        echo "$title_artist" > "$dir/songtitle.txt"

        echo "Extracted and saved: $title_artist"
        echo "-------------------------------------"

        # Create song.ini file
        echo "[song]" > "$dir/song.ini"
        echo "name = $title" >> "$dir/song.ini"
        echo "artist = $artist" >> "$dir/song.ini"
        echo "charter = Harmonix, Rhythm Authors" >> "$dir/song.ini"

        # Change directory to process subdirectory files
        cd "$dir" || continue

        # Read entire contents of songtitle.txt into title_artist
        title_artist=$(<songtitle.txt)

        # Create the clean title_artist string
        clean_title_artist=$(echo "$title_artist" | iconv -f utf-8 -t ascii//TRANSLIT | sed -e 's/[^[:alnum:]?[:space:]]//g' -e 's/ /_/g' | tr '[:upper:]' '[:lower:]')

        # Guitar output file name
        guitar_output="${clean_title_artist}_guitar.png"
        # Bass output file name
        bass_output="${clean_title_artist}_bass.png"

        # Drums output file name
        drums_output="${clean_title_artist}_drums.png"
        # Pad Bass output file name
        mbass_output="${clean_title_artist}_mbass.png"

        # Lead output file name
        lead_output="${clean_title_artist}_lead.png"
        # Pad Bass output file name
        vocals_output="${clean_title_artist}_vocals.png"

        #### PRO LEAD #####
        guitar_path=$( ../cli/fnf_chopt -f *_pro.mid --lazy 1000000 --squeeze 40 --early-whammy 0 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        guitar_path_image="'$guitar_output'"
        guitar_score=$( ../cli/CHOpt -f *_pro.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$guitar_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### PRO BASS #####
        bass_path=$( ../cli/fnf_chopt -f *_pro.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$bass_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        bass_path_image="'$bass_output'"
        bass_score=$( ../cli/CHOpt -f *_pro.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$bass_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### DRUMS #####
        drums_path=$( ../cli/fnf_chopt -f *_drumvox.mid --lazy 1000000 --squeeze 40 --early-whammy 0 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        drums_path_image="'$drums_output'"
        drums_score=$( ../cli/CHOpt -f *_drumvox.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$drums_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### VOCALS ####
        vocals_path=$( ../cli/fnf_chopt -f *_drumvox.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$vocals_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        vocals_path_image="'$vocals_output'"
        vocals_score=$( ../cli/CHOpt -f *_drumvox.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$vocals_output" | \
        awk '/^Total score:/ {print $NF; exit}' )    

        #### LEAD #####
        lead_path=$( ../cli/fnf_chopt -f *.mid --lazy 1000000 --early-whammy 0 --squeeze 40 --no-image --engine rb  | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        lead_path_image="'$lead_output'"
        lead_score=$( ../cli/CHOpt -f *.mid --early-whammy 0 --squeeze 40 --engine fnf -o "$lead_output" | \
        awk '/^Total score:/ {print $NF; exit}' )

        #### BASS #####
        mbass_path=$( ../cli/fnf_chopt -f *.mid -i bass --lazy 100000 --squeeze 40 --no-image --early-whammy 0 --engine rb -o "$mbass_output" | \
        grep -v "Optimising" | \
        sed -e 's/ ([^(]*)//g' | \
        awk '/^Total score:/ {next} !/^Path:|^No SP score:/ {gsub(/: /, "/", $0); gsub(/: /, ",", $0); gsub("/ ", "/", $0); if (NR > 1 && items) printf ", "; printf "%s", $0; items=1} END {if (NR > 0) printf "\n"}' )

        mbass_path_image="'$mbass_output'"
        mbass_score=$( ../cli/CHOpt -f *.mid -i bass --early-whammy 0 --squeeze 40 --engine fnf -o "$mbass_output" | \
        awk '/^Total score:/ {print $NF; exit}' )    

        ##############################################

        # Export the template using the $path and $title variables
        template='{ value : "'"$title_artist"'", 
            data : {
            shortname : "'"$shortname"'",

            dpath : "'"$drums_path"'",
            d_image : "'"${drums_path_image}"'",
            dscore : "'"$drums_score"'",

            vpath : "'"$vocals_path"'",
            v_image : "'"${vocals_path_image}"'",
            vscore : "'"$vocals_score"'",

            gpath : "'"$guitar_path"'",
            g_image : "'"${guitar_path_image}"'",
            gscore : "'"$guitar_score"'",

            bpath : "'"$mbass_path"'",
            b_image : "'"${mbass_path_image}"'",
            bscore : "'"$mbass_score"'",

            lpath : "'"$lead_path"'",
            l_image : "'"${lead_path_image}"'",
            lscore : "'"$lead_score"'",

            ppath : "'"$bass_path"'",
            p_image : "'"${bass_path_image}"'",
            pscore : "'"$bass_score"'",
            } 
        },'

        # Append the template to fnfp.fs
        echo "$template" >> "$original_dir/fnfp.js"

        # Return to the original directory
        cd "$original_dir" || exit 1
    fi
done

# Append the closing bracket to the output file
echo "];" >> "$original_dir/fnfp.js"


# Specify the parent directory to search for PNG files
parent_directory="."

# Specify the directory to move PNG files into
paths_directory="$parent_directory/paths"
mkdir -p "$paths_directory"  # Create 'paths' directory if it doesn't exist

# Move all .png files to the 'paths' directory
echo "Moving .png files to 'paths' directory..."
find "$parent_directory" -type f -name "*.png" -exec mv {} "$paths_directory" \;
echo "All .png files moved to 'paths' directory: $paths_directory"

# Remove directories ending with _import
echo "Removing directories ending with '_import'..."
find "$parent_directory" -type d -name "*_import" -exec rm -rf {} +
echo "Directories ending with '_import' removed."