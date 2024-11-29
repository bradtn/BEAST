#!/bin/bash

#######################################################################
## NOTE: This script originates from here but I tweaked the pull     ##
## command, changed default location for backup, and added a comment ##
## for reference later.                                              ##
#######################################################################

#####################################################################
### Please set the paths accordingly. In case you don't have all  ###
### the listed folders, just keep that line commented out.        ###
#####################################################################
### Path to your config folder you want to backup
config_folder=~/printer_data/config

# NOTE: The above should work for just about everyone, but a somewhat
# recent update to moonraker changed paths, etc. You can run the 
# provided moonraker script 'data-path-fix.sh' to fix/update
# older installs

### Path to your Klipper folder, by default that is '~/klipper'
klipper_folder=~/klipper

### Path to your Moonraker folder, by default that is '~/moonraker'
moonraker_folder=~/moonraker

### Path to your Mainsail folder, by default that is '~/mainsail'
mainsail_folder=~/mainsail

### Path to your Fluidd folder, by default that is '~/fluidd'
#fluidd_folder=~/fluidd

### The branch of the repository that you want to save your config
### By default that is 'main'
branch=main

db_file=~/printer_data/database/moonraker-sql.db

#####################################################################
#####################################################################



#####################################################################
################ !!! DO NOT EDIT BELOW THIS LINE !!! ################
#####################################################################

# Function to exclude specific files (e.g., .zip and dated configs)
exclude_files(){
  echo "Excluding unwanted files..."
  find "$config_folder" -type f \( -name "*.zip" -o -name "printer-*.cfg" \) -exec rm -v {} \;
}

grab_version(){
  if [ ! -z "$klipper_folder" ]; then
    klipper_commit=$(git -C $klipper_folder describe --always --tags --long | awk '{gsub(/^ +| +$/,"")} {print $0}')
    m1="Klipper version: $klipper_commit"
  fi
  if [ ! -z "$moonraker_folder" ]; then
    moonraker_commit=$(git -C $moonraker_folder describe --always --tags --long | awk '{gsub(/^ +| +$/,"")} {print $0}')
    m2="Moonraker version: $moonraker_commit"
  fi
  if [ ! -z "$mainsail_folder" ]; then
    mainsail_ver=$(head -n 1 $mainsail_folder/.version)
    m3="Mainsail version: $mainsail_ver"
  fi
  if [ ! -z "$fluidd_folder" ]; then
    fluidd_ver=$(head -n 1 $fluidd_folder/.version)
    m4="Fluidd version: $fluidd_ver"
  fi
}

# Backup the SQLite database file
if [ -f $db_file ]; then
   echo "sqlite based history database found! Copying..."
   cp "$db_file" "$config_folder/"
else
   echo "sqlite based history database not found"
fi

# Exclude unwanted files before pushing to Git
exclude_files

# Push configuration files to Git
push_config(){
  cd "$config_folder"
  git pull origin $branch --no-rebase
  git add .
  current_date=$(date +"%Y-%m-%d %T")
  git commit -m "Autocommit from $current_date" -m "$m1" -m "$m2" -m "$m3" -m "$m4"
  git push origin $branch
}

grab_version
push_config

