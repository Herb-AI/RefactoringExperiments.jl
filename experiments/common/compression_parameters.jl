struct CompressionParameters
    k::Int,
    max_compression_nodes::Int, 
    time_limit_sec::Int, 
    ASP_PATH::String
end


CompressionParameters(;
    k::Int,
    max_compression_nodes::Int, 
    time_limit_sec::Int, 
    ASP_PATH::String = "compressoin.lp"
) = CompressionParameters(
    k,
    max_compression_nodes,
    time_limit_sec,
    ASP_PATH
)