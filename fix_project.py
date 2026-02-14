import sys
import re

file_path = '/Users/lenien-tzu/Documents/Nelson/TestPrj/GeoCameraApp/GeoCameraApp.xcodeproj/project.pbxproj'

with open(file_path, 'r') as f:
    lines = f.readlines()

# IDs for Test Configurations
test_config_ids = [
    '25A3AEBA2F4029A600740ED4', # GeoCameraAppTests Debug
    '25A3AEBB2F4029A600740ED4', # GeoCameraAppTests Release
    '25A3AEBD2F4029A600740ED4', # GeoCameraAppUITests Debug
    '25A3AEBE2F4029A600740ED4'  # GeoCameraAppUITests Release
]

inside_target_block = False
current_block_id = None

new_lines = []

for line in lines:
    # Check if we are entering a config block
    # Pattern: ID /* Name */ = {
    match = re.search(r'^\s+([0-9A-F]{24}).*=\{', line)
    if match:
        current_block_id = match.group(1)
        if current_block_id in test_config_ids:
            inside_target_block = True
    
    # Check if we are leaving a block
    if inside_target_block and line.strip() == '};':
        inside_target_block = False
        current_block_id = None

    # If inside a test target block, revert the line
    if inside_target_block and 'GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = GeoCameraApp/Info.plist;' in line:
        line = line.replace('GENERATE_INFOPLIST_FILE = NO; INFOPLIST_FILE = GeoCameraApp/Info.plist;', 'GENERATE_INFOPLIST_FILE = YES;')
    
    new_lines.append(line)

with open(file_path, 'w') as f:
    f.writelines(new_lines)
