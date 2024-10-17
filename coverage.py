import os
import argparse
import glob
from matplotlib import pyplot as plt


def main():
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('dir', help='Input directory')
    arg_parser.add_argument('sample', help='Input sample')
    arg_parser.add_argument('output', default=None, help='Output file')

    args = arg_parser.parse_args()

    dir = args.dir
    sample = args.sample
    output = args.output

    if not os.path.exists(dir):
        raise ValueError('Directory does not exist')
    
    if not os.path.exists(sample):
        raise ValueError('Sample does not exist')
    
    if output is None:
        output = './img/coverage_comparison.png'

    files = glob.glob(f'{dir}/*.txt')

    # Create a list of coverage and cumulative coverage for each file
    coverage = []
    cumulative_coverage = []
    for file in files:
        with open(file, 'r') as f:
            lines = f.readlines()
            coverage.append([int(line.split()[1]) for line in lines])
            cumulative_coverage.append([int(line.split()[2]) for line in lines])
    
    # Plot the coverage and cumulative coverage
    plt.figure(figsize=(10, 5))
    plt.tight_layout()
    for i in range(len(coverage)):
        plt.plot(coverage[i], label=f'{os.path.basename(files[i])[:-4]}')
    plt.xlabel('Depth')
    plt.ylabel('Fraction of captured target bases >= depth')
    plt.legend()
    plt.savefig(output)
    plt.close()
