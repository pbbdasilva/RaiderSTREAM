#!/bin/bash


# -------------------------------------------------
#  Set true only for implementations you want to run
# -------------------------------------------------
export RUN_ORIGINAL=false
export RUN_OMP=false
export RUN_MPI=false
export RUN_SHMEM=false
export RUN_CUDA=false

# Problem Size
export STREAM_ARRAY_SIZE=10000000

# Don't forget to set OMP_NUM_THREADS if you are using OpenMP
# NOTE: OpenMP is enabled/disbled in the Makefile
export OMP_NUM_THREADS=

# Set the number of PEs/ranks if using MPI and/or OpenSHMEM implementations
export NPES=

# Set this to true if you want this script to recompile the executables
export COMPILE=true

# Set this to true if you want to be prompted to cat your output file. Good for a single 
# run, not so good if you're running several runs at once
export PROMPT_OUTPUT=false

# -------------------------------------------------
#   Setting up directory to dump benchmark output
# -------------------------------------------------
export STREAM_DIR=$(pwd)
export OUTPUT_DIR=$STREAM_DIR/outputs
if [[ ! -d $OUTPUT_DIR ]] ; then
    mkdir $OUTPUT_DIR
fi

export BUILD_DIR=$STREAM_DIR/build

export OUTPUT_FILE=$OUTPUT_DIR/raiderstream_output_$(date +"%d-%m-%y")_$(date +"%T").txt
if [[ -f $OUTPUT_FILE ]] ; then
    rm $OUTPUT_FILE
    touch $OUTPUT_FILE
else
    touch $OUTPUT_FILE
fi

# -------------------------------------------------
#   Compile each desired implementation
# -------------------------------------------------
if [[ $COMPILE == true ]] ; then
    if [[ $RUN_ORIGINAL == true ]] ; then
        make stream_original
    fi

    if [[ $RUN_OMP == true ]] ; then
        make stream_omp
    fi

    if [[ $RUN_MPI == true ]] ; then
        make stream_mpi
    fi

    if [[ $RUN_SHMEM == true ]] ; then
        make stream_oshmem
    fi
    if [[ $RUN_CUDA == true ]] ; then
        make stream_cuda
    fi
fi

echo "==========================================================================" >> $OUTPUT_FILE
echo "      RaiderSTREAM Run On "$(date +"%d-%m-%y")" AT "$(date +"%T")           >> $OUTPUT_FILE
echo "==========================================================================" >> $OUTPUT_FILE
if [[ $RUN_ORIGINAL == true ]] ; then
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "         'Original' STREAM"           >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    if $BUILD_DIR/stream_original.exe >> $OUTPUT_FILE; then
        echo "Original implementation finished."
    else
        echo "Original implementation failed to run!" >> $OUTPUT_FILE
        echo "Original implementation failed to run!"
    fi
    echo >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
fi

if [[ $RUN_OMP == true ]] ; then
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "              OpenMP"                 >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    if $BUILD_DIR/stream_omp.exe -n $STREAM_ARRAY_SIZE >> $OUTPUT_FILE; then
        echo "OpenMP implementation finished."
    else
        echo "OpenMP implementation failed to run!" >> $OUTPUT_FILE
        echo "OpenMP implementation failed to run!"
    fi
    echo >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
fi

if [[ $RUN_MPI == true ]] ; then
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "                MPI"                  >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    if mpirun -np $NPES $BUILD_DIR/stream_mpi.exe -n $STREAM_ARRAY_SIZE >> $OUTPUT_FILE; then
        echo "MPI implementation finished."
    else
        echo "MPI implementation failed to run!" >> $OUTPUT_FILE
        echo "MPI implementation failed to run!"
    fi
    echo >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
fi

if [[ $RUN_SHMEM == true ]] ; then
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "            OpenSHMEM"                >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    if oshrun -np $NPES $BUILD_DIR/stream_oshmem.exe -n $STREAM_ARRAY_SIZE >> $OUTPUT_FILE; then
        echo "OpenSHMEM implementation finished."
    else
        echo "OpenSHMEM implementation failed to run!" >> $OUTPUT_FILE
        echo "OpenSHMEM implementation failed to run!"
    fi
    echo >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
fi

if [[ $RUN_CUDA == true ]] ; then
    echo "------------------------------------" >> $OUTPUT_FILE
    echo "         CUDA (SINGLE GPU)"                  >> $OUTPUT_FILE
    echo "------------------------------------" >> $OUTPUT_FILE
    if $BUILD_DIR/stream_cuda.exe -n $STREAM_ARRAY_SIZE >> $OUTPUT_FILE; then
        echo "CUDA implementation finished."
    else
        echo "CUDA implementation failed to run!" >> $OUTPUT_FILE
        echo "CUDA implementation failed to run!"
    fi
    echo >> $OUTPUT_FILE
    echo >> $OUTPUT_FILE
fi


echo "Done! Output was directed to $OUTPUT_FILE"

if [[ $PROMPT_OUTPUT == true ]] ; then
    echo "Would you like to see the results? (y/n)"
    read RESPONSE
    if [[ $RESPONSE == "y" || $RESPONSE == "Y" ]] ; then
        cat $OUTPUT_FILE
        echo ""
        echo ""
    else
        echo ""
        echo ""
    fi
else
    cat $OUTPUT_FILE
fi


