macro methods(func)
  :(methods($func))
end

# is_wsl() = Sys.islinux() && isfile("/mnt/c/Windows/System32/cmd.exe")
is_wsl() = Sys.islinux() && isdir("/mnt/z")
is_windows() = Sys.iswindows()
is_linux() = Sys.islinux()

"""
    path_mnt(path = ".")

Relative path will kept the original format.
"""
function path_mnt(path=".")
  is_wsl() && return win2mnt(path)
  is_windows() && return mnt2win(path)
  path
end


function win2mnt(path)
  length(path) >= 2 && path[2] == ':' || return path # false return
  "/mnt/$(lowercase(path[1]))$(path[3:end])"
end

function mnt2win(path)
  length(path) >= 5 && path[1:5] == "/mnt/" || return path # false return
  "$(uppercase(path[6])):$(path[7:end])"
end

export @methods, is_wsl, is_windows, is_linux, path_mnt, win2mnt, mnt2win
