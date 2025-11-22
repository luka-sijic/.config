if status is-interactive
    if test -d /opt/homebrew/bin
        fish_add_path /opt/homebrew/bin
    end
    # Commands to run in interactive sessions can go here
    abbr --add cx 'gcc -std=c11 -Wall *.c -o temp_bin && ./temp_bin && rm temp_bin'
    abbr --add cxx 'g++ -std=c++17 *.cpp -o temp_bin && ./temp_bin && rm temp_bin'
    abbr --add g++ 'g++ -std=c++17'
    abbr --add alpha 'ssh -i ~/Documents/keys/as_private.pem root@alpha.c'
    abbr --add beta 'ssh -i ~/Documents/keys/as_private.pem root@beta.c'
    abbr --add py python3
    starship init fish | source
end
