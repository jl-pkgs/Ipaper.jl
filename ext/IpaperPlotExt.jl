export IpaperPlotExt
module IpaperPlotExt

# @static if isdefined(Base, :get_extension) # julia < 1.9
using Plots: plot!, savefig
import Ipaper: show_fig, write_fig
# else
#   using ..Ipaper
#   using ..Plots: plot!, savefig
# end


# println("Please import `Plots` first!")
function write_fig(file="Rplot.pdf", width=10, height=5; show=true)
  plot!(size=(width * 72, height * 72))
  savefig(file)
  if show
    @show file
    show_file(file)
  end
end


end
