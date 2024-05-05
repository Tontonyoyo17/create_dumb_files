# create_dumb_files.sh

This script provides a way to create dumb files for testing purpose

## Getting Started

Instructions will show you how to run the scripts

### Installation

Download the code and set execute permissions to the script:

```
$ chown +x create_dumb_files.sh
```

## Usage

A few examples of useful commands and/or tasks.

```
# Display help
$ ./create_dumb_files.sh -h

# Create 100 files using /dev/zero of 10KB each 
$ ./create_dumb_files.sh -d /home/antoine/dev/create_dumb_files/ -i zero -s 10 -c 100  -u kb

# Create 500 files using /dev/urandom of 1MB each, writing 50 files in parallel 
$ ./create_dumb_files.sh -d /home/antoine/dev/create_dumb_files/ -i random -s 1 -c 500  -u mb -p 50 
```
