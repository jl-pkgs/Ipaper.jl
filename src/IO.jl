using Serialization

export deserialize, serialize
export writelines


"""
    $(TYPEDSIGNATURES)

# Arguments

- `mode`: 

 Mode Description Keywords                 
  –––– ––––––––––– –––––––––––––––––––––––––
  r    read        none                     
  w    write       write = true             
  r+   read, write read = true, write = true
  w+   read, write read = true, write = true

# @seealso readlines

! `x` 需要是string，不然文件错误
"""
function writelines(x::AbstractVector{<:AbstractString}, f; mode="w", eof="\n")
  fid = open(f, mode)
  @inbounds for _x in x
    write(fid, _x)
    write(fid, eof)
  end
  close(fid)
end
