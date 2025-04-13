# import Ipaper.sf: read_sf, write_sf

"""
    watershed(flowdir, pour; fout="./OUTPUT/watershed.tif", basin_id="./OUTPUT/basinId.txt")

```bash
gagewatershed -p fflowdir -o f_pour -gw watershed.tif -id basinId_十堰.txt
```

```julia
using Ipaper, Ipaper.sf, Shapefile, ArchGDAL
watershed(flowdir, pour; fout="./OUTPUT/watershed.tif", basin_id="./OUTPUT/basinId.txt")
watershed_rast2poly("")
```
"""
function watershed(flowdir, pour; fout="./OUTPUT/watershed.tif", basin_id="./OUTPUT/basinId.txt")
  check_dir(dirname(fout))
  check_dir(dirname(basin_id))
  
  run(`gagewatershed -p $flowdir -o $pour -gw $fout -id $basin_id`)
  nothing
end


function watershed_rast2poly(tif::String, basin::String)
  gdal_polygonize(tif, basin)

  shp = read_sf(basin)
  shp2 = shp[shp.data.grid.>=0, :]

  if size(shp) != size(shp2)
    write_sf(basin, shp2; force=true)
  end
end


export watershed, watershed_rast2poly
# gdal_polygonize.py watershed_${region}.tif shed_${region}.shp shape
