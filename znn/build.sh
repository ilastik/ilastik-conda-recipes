# Build (just one source file: main.cpp)
${PREFIX}/bin/g++ -o bin/znn src/main.cpp -g \
    -I. -I./src -I./zi -I${PREFIX}/include \
    -DNDEBUG -O3 -std=c++11 \
    -Wall -Wextra -Wno-unused-result -Wno-unused-local-typedefs \
    -L${PREFIX}/lib \
    -lfftw3 -lpthread -lrt -lfftw3_threads \
    -lboost_program_options -lboost_regex -lboost_filesystem -lboost_system \

# Install
mv bin/znn ${PREFIX}/bin/znn
