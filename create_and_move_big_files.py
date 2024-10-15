import os
import random
import string
import shutil
import time

def generate_random_content(size):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=size))

def create_random_file(directory, min_size, max_size):
    size = random.randint(min_size, max_size)
    filename = f"file_{int(time.time())}_{size}b.txt"
    filepath = os.path.join(directory, filename)
    
    with open(filepath, 'w') as f:
        f.write(generate_random_content(size))
    
    return filepath

def process_file(filepath, tmp_dir):
    filename = os.path.basename(filepath)
    tmp_path = os.path.join(tmp_dir, filename)
    
    times = {
        'copy_to_tmp': 0,
        'delete_original': 0,
        'copy_from_tmp': 0,
        'delete_tmp': 0
    }
    
    # Copy to /tmp/
    start = time.time()
    shutil.copy2(filepath, tmp_path)
    times['copy_to_tmp'] = time.time() - start
    
    # Delete original
    start = time.time()
    os.remove(filepath)
    times['delete_original'] = time.time() - start
    
    # Copy back from /tmp/
    start = time.time()
    shutil.copy2(tmp_path, filepath)
    times['copy_from_tmp'] = time.time() - start
    
    # Clean up /tmp/
    start = time.time()
    os.remove(tmp_path)
    times['delete_tmp'] = time.time() - start
    
    return times

def main():
    efs_dir = input("Enter the EFS directory path: ").strip()
    num_files = int(input("Enter the number of files to create: "))
    min_size = int(input("Enter the minimum file size in bytes: "))
    max_size = int(input("Enter the maximum file size in bytes: "))
    
    tmp_dir = "/tmp"
    
    if not os.path.exists(efs_dir):
        os.makedirs(efs_dir)
    
    print(f"Creating and processing {num_files} files in {efs_dir}...")
    
    total_times = {
        'creation': 0,
        'copy_to_tmp': 0,
        'delete_original': 0,
        'copy_from_tmp': 0,
        'delete_tmp': 0
    }
    
    global_start_time = time.time()
    
    for i in range(num_files):
        start = time.time()
        filepath = create_random_file(efs_dir, min_size, max_size)
        total_times['creation'] += time.time() - start
        
        file_times = process_file(filepath, tmp_dir)
        for key in file_times:
            total_times[key] += file_times[key]
        
        if (i + 1) % 100 == 0:
            print(f"Processed {i + 1} files...")
    
    global_end_time = time.time()
    global_total_time = global_end_time - global_start_time
    
    print("\nOperation completed!")
    print(f"Total files processed: {num_files}")
    print(f"Global operation time: {global_total_time:.2f} seconds")
    print(f"Average time per file: {(global_total_time / num_files) * 1000:.2f} milliseconds")
    print("\nBreakdown of operations:")
    for operation, total_time in total_times.items():
        avg_time = (total_time / num_files) * 1000
        print(f"  {operation.replace('_', ' ').capitalize()}:")
        print(f"    Total time: {total_time:.2f} seconds")
        print(f"    Average time: {avg_time:.2f} milliseconds")

if __name__ == "__main__":
    main()
