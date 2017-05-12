MATLAB="/Applications/MATLAB_R2017a.app"
Arch=maci64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/Users/andreibosco/Library/Application Support/MathWorks/MATLAB/R2017a"
OPTSFILE_NAME="./setEnv.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for kalman02" > kalman02_mex.mki
echo "CC=$CC" >> kalman02_mex.mki
echo "CFLAGS=$CFLAGS" >> kalman02_mex.mki
echo "CLIBS=$CLIBS" >> kalman02_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> kalman02_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> kalman02_mex.mki
echo "CXX=$CXX" >> kalman02_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> kalman02_mex.mki
echo "CXXLIBS=$CXXLIBS" >> kalman02_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> kalman02_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> kalman02_mex.mki
echo "LDFLAGS=$LDFLAGS" >> kalman02_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> kalman02_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> kalman02_mex.mki
echo "Arch=$Arch" >> kalman02_mex.mki
echo "LD=$LD" >> kalman02_mex.mki
echo OMPFLAGS= >> kalman02_mex.mki
echo OMPLINKFLAGS= >> kalman02_mex.mki
echo "EMC_COMPILER=clang" >> kalman02_mex.mki
echo "EMC_CONFIG=optim" >> kalman02_mex.mki
"/Applications/MATLAB_R2017a.app/bin/maci64/gmake" -B -f kalman02_mex.mk
