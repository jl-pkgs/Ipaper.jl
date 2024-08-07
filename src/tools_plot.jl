using Glob
export glob

"""
    open pdf file in SumatraPDF
"""
function show_pdf(file)
  # C:/Program Files/RStudio/bin/sumatra/s
  app = "SumatraPDF.exe"
  if is_wsl()
    app = path_mnt(app)
    run(`$app $file`; wait=false)
  elseif is_windows()
    run(`$app $file`; wait=false)
  end
  nothing
end

function show_file(file, verbose=false)
  file = abspath(file)
  cmd = `cmd /c "$file"`
  verbose && @show cmd
  run(cmd; wait=false)
  if !verbose
    return nothing
  end
end


"""
    merge_pdf("*.pdf", output="Plot.pdf")

Please install [pdftk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) first.
On Linux, `sudo apt install pdftk-java`.

merge multiple pdf files by `pdftk`
"""
function merge_pdf(input, outfile="Plot.pdf"; is_del=false, show=true)
  # input = abspath(input)
  files = glob(input)
  id = str_extract(basename.(files), "\\d{1,}")
  id = parse.(Int32, id) |> sortperm
  files = files[id]

  run(`pdftk $files cat output $outfile`)
  show && show_file(outfile)
  is_del && rm.(files)
  nothing
end


# println("Please import `Plots` first!")
function write_fig end


export write_fig, show_pdf, show_file, merge_pdf
