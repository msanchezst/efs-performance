import os
import random
import string
import time

def generate_random_content(size):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=size))

def create_nested_directory(base_path, depth):
    if depth == 0:
        return base_path
    
    new_dir = ''.join(random.choices(string.ascii_lowercase, k=5))
    path = os.path.join(base_path, new_dir)
    os.makedirs(path, exist_ok=True)
    return create_nested_directory(path, depth - 1)

def generate_files(base_path, num_files):
    start_time = time.time()
    for i in range(num_files):
        dir_path = create_nested_directory(base_path, random.randint(1, 5))
        file_size = random.randint(1, 1024)  # 1 byte to 1KB
        file_name = f"file_{i}_{file_size}b.txt"
        file_path = os.path.join(dir_path, file_name)
        
        with open(file_path, 'w') as f:
            f.write(generate_random_content(file_size))
        
        if i % 100 == 0:
            elapsed_time = time.time() - start_time
            print(f"Generated {i} files in {elapsed_time:.2f} seconds")
    
    total_time = time.time() - start_time
    return total_time

def get_valid_directory():
    while True:
        directory = input("Enter the directory path to create files and folders: ").strip()
        if os.path.isdir(directory):
            return directory
        elif os.path.exists(directory):
            print("The path exists but is not a directory. Please enter a valid directory path.")
        else:
            create = input("The directory doesn't exist. Do you want to create it? (y/n): ").lower()
            if create == 'y':
                try:
                    os.makedirs(directory)
                    return directory
                except OSError as e:
                    print(f"Error creating directory: {e}")
            else:
                print("Please enter a valid directory path.")

if __name__ == "__main__":
    base_directory = get_valid_directory()
    num_files = int(input("Enter the number of files to generate: "))
    
    print(f"Generating {num_files} files in nested directories under {base_directory}")
    print("Starting file generation...")
    
    total_time = generate_files(base_directory, num_files)
    
    print(f"\nGeneration complete!")
    print(f"Total time taken: {total_time:.2f} seconds")
    print(f"Average time per file: {(total_time / num_files) * 1000:.2f} milliseconds")
