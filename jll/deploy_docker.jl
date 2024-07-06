import Git: git

run(`$(git()) config --global user.name "Johnathan Bizzano"`)
run(`$(git()) config --global user.email "bizzanoj@my.erau.edu"`)

const repo_user = "HyperSphereStudio"
const mousetrap_commit = "74507a0bffcfa29d11bd2b5e68268651f36afe7a"
const mousetrap_julia_binding_commit = "7a9dc111ae1c0dde187e8d0386082af9b46d0e1d"

const VERSION = "0.4.0"
const deploy_local = false
const skip_build = true

# if local, files will be written to ~/.julia/dev/mousetrap_jll

if deploy_local
    @info "Deployment: local"
    repo = "local"
else
    @info "Deployment: github"
    repo = "$repo_user/mousetrap_jll"
end

## Configure

function configure_file(path_in::String, path_out::String)
    file_in = open(path_in, "r")
    file_out = open(path_out, "w+")

    for line in eachline(file_in)
        write(file_out, replace(line,
			"@MOUSETRAP_REPO_USER@" => repo_user,
            "@MOUSETRAP_COMMIT@" => mousetrap_commit,
            "@MOUSETRAP_JULIA_BINDING_COMMIT@" => mousetrap_julia_binding_commit,
            "@MOUSETRAP_VERSION@" => VERSION
        ) * "\n")
    end

    close(file_in)
    close(file_out)
end

@info "Configuring `build_tarballs.jl.in`"
configure_file("./build_tarballs.jl.in", "./build_tarballs.jl")

path = joinpath(Sys.BINDIR, "../dev/mousetrap_jll")
if isfile(path)
    run(`rm -r $path`)
end

run(`julia -t 8 build_tarballs.jl --debug --verbose --deploy=$repo`)