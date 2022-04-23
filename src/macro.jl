"""
    open pdf file in SumatraPDF
"""
function show_pdf(file)
    app = "C:/Program Files/RStudio/bin/sumatra/SumatraPDF.exe"
    if is_wsl()
        app = path_mnt(app)
        run(`$app $file`; wait=false)
    elseif is_windows()
        run(`$app $file`; wait=false)
    end
    nothing
end

function show_file(file)
    run(`cmd /c $file`; wait=false)
    nothing
end

macro methods(func)
    :(methods($func))
end

export @methods, show_pdf, show_file
