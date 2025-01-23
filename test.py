import time
import subprocess
import argparse

def main(size_range, max_size=30):
    # create subprocess that runs 
    # time dd if=/dev/random of=/tmp/test.dat bs=1M count=100
    for e in range(*size_range):
        if e > max_size:
            print(f"Max size reached, stopping")
            break
        start = time.time()
        # run with 2^e bytes and 2^(30 - e) blocks
        command = [ 
            "dd", "if=/dev/random",
            "of=./test.dat", "bs=" + str(2**e),
            "count=" + str(2**(max_size - e))
        ]
        print(f"Testing with {2**e} bytes and {2**(max_size - e)} blocks:")
        print(f"\twrite command: {" ".join(command)}: ", end="", flush=True)
        proc = subprocess.run(command,
            shell=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        end = time.time()
        print(f"done in {end - start}s")
        command = [ 
            "dd", "if=./test.dat",
            "of=/dev/null", "bs=" + str(2**e),
            "count=" + str(2**(max_size - e))
            #"cat ./test.dat >/dev/null"
        ]
        print(f"\tread command: {" ".join(command)} ", end="", flush=True)
        start = time.time()
        proc = subprocess.run(command,
            shell=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        end = time.time()
        print(f"done in {end - start}s")


if __name__ == "__main__":
    parser = argparse.ArgumentParser() 
    # parse arguments
    # --range 4 32 2
    parser.add_argument("--range", nargs=3, type=int, default=[4, 32, 2])
    parser.add_argument("--max_size", type=int, default=30)
    args = parser.parse_args()

    main(args.range, args.max_size)