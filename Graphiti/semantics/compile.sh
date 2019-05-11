MICROC="./graphiti.native"
# Path to the LLVM compiler
LLC="llc"
# Path to the C compiler
CC="cc"

make
$MICROC -c ./tests/hello.gra > hello.ll
$LLC -relocation-model=pic hello.ll > hello.s
$CC -o hello.exe hello.s
./hello.exe > hello.out
cat hello.out
