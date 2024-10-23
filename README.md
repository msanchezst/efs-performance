EFS Performance Test Script
==========================

This script is designed to test the performance of an EFS mount point using the `fio` I/O benchmarking tool and `ioping` for latency measurement. It runs a series of tests with different block sizes, I/O patterns, write modes, and I/O engines, and generates a set of output files that can be used to analyze the results.

Prerequisites
-------------

* The `fio` I/O benchmarking tool must be installed on the system.
* The `ioping` latency measurement tool must be installed on the system.
* The EFS mount point must be mounted at the specified location (`EFS_MOUNT` variable in the script).

Usage
-----

1. Save the script as `run_checks.sh`.
2. Modify the `EFS_MOUNT` variable in the script to specify the location of the EFS mount point.
3. Run the script using the following command:

```
./run_checks.sh
```

The script will start by running `ioping` in the background to measure the latency of the EFS mount point. It will then run a series of tests using `fio` with different block sizes, I/O patterns, write modes, and I/O engines.

The output files for each test will be saved in the current directory, with the following naming convention:

* `ioping_results.txt`: The output file for `ioping`.
* `fio_results_<pattern>_<bs>_<mode>_<engine>.txt`: The output file for `fio`, where `<pattern>` is the I/O pattern, `<bs>` is the block size, `<mode>` is the write mode, and `<engine>` is the I/O engine.
* `total_time.txt`: The total time taken to run all the tests and create the custom kernel.

Analysis
--------

The output files can be analyzed using various tools, such as `fio_analyze` or `fio_postprocess`. The `fio_results_<pattern>_<bs>_<mode>_<engine>.txt` files contain detailed information about the I/O performance of the EFS mount point, including throughput, latency, and IOPS.

The `ioping_results.txt` file contains the latency measurements for the EFS mount point, which can be used to analyze the responsiveness of the file system.

The `total_time.txt` file contains the total time taken to run all the tests and create the custom kernel. This can be used to estimate the time required to run the entire suite of tests.

Notes and limitations
-----------

* The script assumes that the `fio` and `ioping` tools are installed on the system.
* The script may take a long time to run, depending on the number of tests being performed.
* The script may generate a large number of output files
* This script is provided as-is, without any warranty or support. It is intended to be used as a starting point for testing the performance of an EFS mount point, and may need to be modified to suit your specific needs.
