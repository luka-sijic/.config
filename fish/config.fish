if status is-interactive
    switch (uname)
        case Darwin
            if test -d /opt/homebrew/bin
                fish_add_path /opt/homebrew/bin
            end
    end

    # Commands to run in interactive sessions can go here
    abbr --add cx 'gcc -std=c11 -Wall *.c -o temp_bin && ./temp_bin && rm temp_bin'
    abbr --add g++ 'g++ -std=c++17'
    abbr --add alpha 'ssh -i ~/Documents/keys/as_private.pem root@alpha.c'
    abbr --add beta 'ssh -i ~/Documents/keys/as_private.pem root@beta.c'
    abbr --add co 'codium .'
    abbr --add ga 'git add'
    abbr --add gc 'git commit -m'
    abbr --add gl 'git pull'
    abbr --add gp 'git push'
    abbr --add gs 'git status'
    abbr --add as "cd ~/Documents/repos/astro && hx ."
    abbr --add leet 'cp ~/Documents/repos/astro/leet/template.cpp ./main.cpp'
    abbr --add py python3
    starship init fish | source
end

function cxx --description "Compile+run C++ quickly (default: -std=c++17, version=release)"
    # Defaults
    set -l std c++17
    set -l variant release
    set -l compiler g++

    # If user passes no files, compile all .cpp in cwd
    set -l files

    # Parse args:
    #   --std c++20
    #   --variant debug|release|asan|tsan
    #   --cc clang++|g++
    #   -- (end of options) then files...
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --std
                set i (math $i + 1)
                test $i -le (count $argv); or begin
                    echo "cxx: --std requires a value (e.g., c++17, c++20)"
                    return 2
                end
                set std $argv[$i]
            case --variant --ver --version
                set i (math $i + 1)
                test $i -le (count $argv); or begin
                    echo "cxx: --variant requires a value (debug|release|asan|tsan)"
                    return 2
                end
                set variant $argv[$i]
            case --cc
                set i (math $i + 1)
                test $i -le (count $argv); or begin
                    echo "cxx: --cc requires a value (g++ or clang++)"
                    return 2
                end
                set compiler $argv[$i]
            case --help -h
                echo "Usage:"
                echo "  cxx [--std c++17|c++20|c++23] [--variant release|debug|asan|tsan] [--cc g++|clang++] [--] [files...]"
                echo ""
                echo "Examples:"
                echo "  cxx                          # g++ -std=c++17 *.cpp  (release) compile+run+rm"
                echo "  cxx --std c++20              # c++20"
                echo "  cxx --variant debug          # -O0 -g"
                echo "  cxx --variant asan --cc clang++"
                echo "  cxx main.cpp foo.cpp         # compile specified files"
                return 0
            case --
                # Remaining args are files
                set i (math $i + 1)
                while test $i -le (count $argv)
                    set -a files $argv[$i]
                    set i (math $i + 1)
                end
                break
            case '*'
                # Treat unknown tokens as filenames
                set -a files $argv[$i]
        end
        set i (math $i + 1)
    end

    if test (count $files) -eq 0
        set files *.cpp
    end

    # Variant flags
    set -l cflags
    switch $variant
        case release
            set cflags -O2 -DNDEBUG
        case debug
            set cflags -O0 -g -DDEBUG
        case asan
            set cflags -O1 -g -fno-omit-frame-pointer -fsanitize=address,undefined
        case tsan
            set cflags -O1 -g -fno-omit-frame-pointer -fsanitize=thread
        case profile
            set cflags -O2 -g -fno-omit-frame-pointer
        case '*'
            echo "cxx: unknown variant '$variant' (use release|debug|asan|tsan|profile)"
            return 2
    end

    # Build temp binary name (unique-ish per dir to avoid collisions)
    set -l bin ./temp_bin

    echo "$compiler -std=$std $cflags $files -o $bin"
    $compiler -std=$std $cflags $files -o $bin
    or return $status

    $bin
    set -l run_status $status

    rm -f $bin
    return $run_status
end

function cxxi --description "Compile *.cpp, run with stdin from a file (e.g., cxxin input.txt)"
    if test (count $argv) -lt 1
        echo "usage: cxxin <input_file>"
        return 1
    end

    set -l infile $argv[1]
    if not test -f "$infile"
        echo "cxxin: file not found: $infile"
        return 1
    end

    g++ -std=c++17 *.cpp -o temp_bin; or return $status
    ./temp_bin <"$infile"
    set -l rc $status
    rm -f temp_bin
    return $rc
end

function cfg
    cmake -S . -B build/debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    if test -f build/debug/compile_commands.json
        ln -sf build/debug/compile_commands.json compile_commands.json
    end
end

function cfg-rel
    cmake -S . -B build/release -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_TRACE=OFF \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON

    if test -f build/release/compile_commands.json
        ln -sf build/release/compile_commands.json compile_commands.json
    end
end

function ccx
    cmake --build build/debug -j && ./build/debug/app $argv
end
