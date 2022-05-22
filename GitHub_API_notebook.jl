### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 010af338-d901-11ec-3d35-a964bb75c8bf
using GitHub, JSON, DataFrames, VegaLite, Dates

# ╔═╡ afe81112-206e-49fd-aa2f-acdb543d96cf
md"
### Load packages
---
"

# ╔═╡ 0c06977f-ead5-40c8-9e7c-ecd491508613
md"
### Make requests
---
"

# ╔═╡ 582bf436-8b7a-49f7-b81d-a676570644de
md"
##### Authentication
"

# ╔═╡ e2f92cb3-1fdc-4d2d-90a0-92c3f7b72967
begin
	access_token = JSON.parsefile("/home/vikas/Documents/Input_JSON/VNEG_github_auth.json")
	myauth = GitHub.authenticate(access_token["GITHUB_AUTH"])
end

# ╔═╡ ac855f25-d71e-42b3-bab6-16b865a46759
typeof(myauth)

# ╔═╡ 0116a5fc-b43e-4712-b0cc-8c8b729bfbd8
md"
##### Get repo data
"

# ╔═╡ a9cab907-c5d4-439e-be65-5c258daa961d
repo = "JuliaData/DataFrames.jl"

# ╔═╡ 339b249d-3636-43e1-aede-5b441917917c
begin
	contri_params = Dict("page" => 1);
	contributors(repo, params = contri_params)
end

# ╔═╡ a3bc140a-ad03-4a86-8d18-48edc00ab9d3
begin
	fork_params = Dict("page" => 1);
	forks(repo, auth = myauth, params = fork_params)
end

# ╔═╡ cf80d78c-a924-461e-a921-3a5ae95c3ead
begin
	commit_params = Dict("page" => 1);
	commits(repo, auth = myauth, params = commit_params)
end

# ╔═╡ a0e0ded3-add1-40a2-b069-112f017a289a
begin
	all_stats = String(stats(repo, auth = myauth, "participation").body)
	stats_dict = JSON.parse(all_stats)
end

# ╔═╡ d99ed742-2de2-4c40-ac73-1fb399419fd1
stats_dict["all"]

# ╔═╡ 66c9849e-2c73-4b96-bb07-c167d55b031d
md"
##### Pull requests and issues
"

# ╔═╡ 8010d155-3a4d-4238-9710-87413a9003c7
pull_requests(repo)

# ╔═╡ d4fe0cd8-00c2-4a7f-80c8-3a5457ccc952
begin
	issue_params = Dict("state" => "closed", "page" => 1);
	all_issues = issues(repo, auth = myauth, params = issue_params)[1]
end

# ╔═╡ 679da4ef-3129-4dd2-b451-0ab0856d64b8
isnothing(all_issues[2].pull_request)

# ╔═╡ db65697d-38c8-43f3-8d16-545bf88c2bbf
all_issues[180]

# ╔═╡ f3a6e003-27e1-45cb-9423-7e3b8f57bbb6
propertynames(all_issues[180])

# ╔═╡ c5d96003-8094-42aa-bbcd-01da1549072d
md"
##### Social activity
"

# ╔═╡ 379d3637-16a3-498e-bd85-e124ab9054c4
stargazers(repo, auth = myauth)

# ╔═╡ ff11835f-d3cc-4642-bc0c-af7e3e8d8918
#star("JuliaWeb/HTTP.jl", auth = myauth)

# ╔═╡ ab29b9b7-bd01-4f6d-abf6-97a5d5028412
watchers(repo, auth = myauth)

# ╔═╡ 4e8ca8d3-53d7-4e35-8cea-7d44b26b9a40
md"
### Visualize developer activity
---
"

# ╔═╡ e162070e-10bb-4da5-8bc2-2988c2466406
julia_list = ["JuliaWeb/HTTP.jl",
              "JuliaWeb/GitHub.jl",
	          "JuliaData/DataFrames.jl",
	          "JuliaData/CSV.jl",
	          "JuliaData/YAML.jl",
	          "JuliaData/RData.jl",
	          "queryverse/VegaLite.jl",
	          "queryverse/Query.jl",
              "JuliaPlots/Plots.jl",
              "JuliaPlots/StatsPlots.jl",
              "JuliaPlots/Makie.jl",
              "JuliaPlots/PlotlyJS.jl"]

# ╔═╡ e12171f2-a769-4f74-9bf9-c4ee77b5a568
julia_list_data = ["JuliaData/DataFrames.jl",
			       "JuliaData/CSV.jl",
			       "JuliaData/YAML.jl",
			       "JuliaData/RData.jl"]	         

# ╔═╡ 81c44409-06e4-4d23-9c5d-61897c988c7b
julia_list_plotting = ["JuliaPlots/Plots.jl",
              		   "JuliaPlots/StatsPlots.jl",
              		   "JuliaPlots/Makie.jl",
                       "JuliaPlots/PlotlyJS.jl"]

# ╔═╡ cbed0197-caec-4b0b-a802-663fbe0236a0
md"
##### Number of contributors
"

# ╔═╡ 3904aaf0-630c-4b91-b35d-a2f4d1b48373
function get_num_contributors(repo::String, myauth::GitHub.OAuth2)

	contri_params = Dict("page" => 1);
	num_contri    = contributors(repo, auth = myauth, 
		                         params = contri_params)[1] |> length

	return num_contri
end	

# ╔═╡ 867ad62f-ce00-4ee0-ae1d-5dd9b3b9b465
function plot_num_contributors(repo_list::Vector{String}, 
	                            myauth::GitHub.OAuth2)

	contris    = Int64[]
	repo_names = String[]

	for repo in repo_list
		try
			contri = get_num_contributors(repo, myauth)
			push!(contris, contri)
			push!(repo_names, splitpath(repo)[2])
		catch
			continue
		end
	end

	df_contri = DataFrame(repo_names = repo_names, num_contri = contris)

	figure = df_contri |>

	@vlplot(:bar, 
	        x = {"repo_names:o", "axis" = {"title" = "Repository name", "labelFontSize" = 12, "titleFontSize" = 14}},
	        y = {:num_contri, "axis" = {"title" = "Number of contributors", "labelFontSize" = 12, "titleFontSize" = 14}},
	        width = 750, height = 500, 
			"title" = {"text" = "Open source contribution activity", "fontSize" = 16})

	return figure
end	

# ╔═╡ 6612d86f-81a4-45a0-b321-4d57b8ececed
plot_num_contributors(julia_list, myauth)

# ╔═╡ f50b06df-c843-4d26-8389-f7888920bb11
md"
##### Number of forks
"

# ╔═╡ 52a38c06-25c5-4a61-90cf-a7bf4a4fbbf5
function get_num_forks(repo::String, myauth::GitHub.OAuth2)

	fork_params = Dict("page" => 1);
	num_forks = forks(repo, auth = myauth, params = fork_params)[1] |> length

	return num_forks
end	

# ╔═╡ d2ec2e7a-57db-478d-9d79-7e8d8459f655
function plot_num_forks(repo_list::Vector{String}, 
	                    myauth::GitHub.OAuth2)

	forks      = Int64[]
	repo_names = String[]

	for repo in repo_list
		try
			fork = get_num_forks(repo, myauth)
			push!(forks, fork)
			push!(repo_names, splitpath(repo)[2])
		catch
			continue
		end
	end

	df_fork = DataFrame(repo_names = repo_names, num_forks = forks)

	figure = df_fork |>

	@vlplot(:bar, 
	        x = {"repo_names:o", "axis" = {"title" = "Repository name", "labelFontSize" = 12, "titleFontSize" = 14}},
	        y = {:num_forks, "axis" = {"title" = "Number of forks", "labelFontSize" = 12, "titleFontSize" = 14}},
	        width = 750, height = 500, 
			"title" = {"text" = "Open source forking activity", "fontSize" = 16})

	return figure
end	

# ╔═╡ fe3edcea-d3b2-45b6-b5b6-412f10a79ee4
plot_num_forks(julia_list, myauth)

# ╔═╡ c9753306-7c06-4154-9d9a-466a75e6e667
md"
##### Weekly commit count
"

# ╔═╡ 49fb3222-c1fb-400c-8a0f-ee9fd9b1b9f2
function get_weekly_commit_count(repo::String, myauth::GitHub.OAuth2)

	stats_dict = stats(repo, auth = myauth, "participation").body |> String |> JSON.parse

	commits  = stats_dict["all"]
	df_count = DataFrame(week = collect(1:length(commits)),
		                 commits = commits)
	
	repo_name = splitpath(repo)[2]
	rename!(df_count, Dict(:commits => repo_name))

	return df_count
end

# ╔═╡ d418aacc-f7a4-4a04-bd4c-f1b0cd46bf63
function plot_weekly_commits(repo_list::Vector{String}, 
	                         myauth::GitHub.OAuth2)

	df_all_counts, df_count = [DataFrame() for i = 1:2]

	for repo in repo_list

		try
			df_count = get_weekly_commit_count(repo, myauth)
		catch
			continue
		end

		if isempty(df_all_counts)
			df_all_counts = df_count
		else
			try
				df_all_counts = innerjoin(df_all_counts, df_count, on = :week)
			catch
				continue
			end
		end
	end

	if isempty(df_all_counts)
		@error "Could not fetch data, try again later!"
	end

	sdf_all_counts = stack(df_all_counts, Not([:week]), 
		                   variable_name = :repo_names)	

	figure = sdf_all_counts |>

	@vlplot(mark = {:bar, "width" = 10}, 
	        x = {:week, "type" = "quantitative", "axis" = {"title" = "Week number", "labelFontSize" = 12,
			     "titleFontSize" = 14}},
	        y = {:value, "type" = "quantitative", "axis" = {"title" = "Number of weekly commits",
			     "labelFontSize" = 12, "titleFontSize" = 14}},
	        width = 750, height = 500, 
			"title" = {"text" = "Weekly commit activity for last 52 weeks ",
			           "fontSize" = 16},
			color = {"field" = "repo_names", "type" = "nominal"})

	return figure
end	

# ╔═╡ a9c733a1-576b-4f8d-975d-dd3bb7fcd21a
plot_weekly_commits(julia_list_data, myauth)

# ╔═╡ e04e568e-452c-4ac9-8738-84f8d69c72b6
plot_weekly_commits(julia_list_plotting, myauth)

# ╔═╡ 3b7ee27e-a171-49c1-acf2-b6dac57a98d8
md"
##### Open and closed issues
"

# ╔═╡ 9a14c556-6619-42e9-bdea-a7becd1ebb2f
function get_closed_issues(repo::String, myauth::GitHub.OAuth2)

	# Pull requests are also returned as "closed" issues
	issue_params = Dict("state" => "closed", "page" => 1)
	all_issues = issues(repo, auth = myauth, params = issue_params)[1]

	num_closed_issues = 0

	for issue in all_issues
		if isnothing(issue.pull_request)
			num_closed_issues += 1
		end
	end

	return num_closed_issues
end

# ╔═╡ fb347218-25bf-4369-abe1-671786e400f1
function get_open_issues(repo::String, myauth::GitHub.OAuth2)

	issue_params = Dict("state" => "open", "page" => 1);
	open_issues = issues(repo, auth = myauth, params = issue_params)[1]

	return length(open_issues)	
end

# ╔═╡ 0abc2a1f-1c77-4138-b4b3-29c3e0b5e4f9
function plot_all_issues(repo_list::Vector{String}, 
	                     myauth::GitHub.OAuth2)

	num_open, num_closed = Int64[], Int64[]
	repo_names = String[]

	for repo in repo_list
		try
			num_open_issues   = get_open_issues(repo, myauth)
			num_closed_issues = get_closed_issues(repo, myauth)
			
			push!(num_open, num_open_issues)
			push!(num_closed, num_closed_issues)
			push!(repo_names, splitpath(repo)[2])
		catch
			continue
		end
	end

	df_issues = DataFrame(repo_names = repo_names, 
		                  open = num_open, 
		                  closed = num_closed)

	sdf_issues = stack(df_issues, Not([:repo_names]), variable_name = :issue_state)

	figure = sdf_issues |>

	@vlplot(:bar, 
	        x = {"repo_names:o", "axis" = {"title" = "Repository name", 
			"labelFontSize" = 12, "titleFontSize" = 14}},
	        y = {:value, "axis" = {"title" = "Number of issues", "labelFontSize" =
				12, "titleFontSize" = 14}},
	        width = 750, height = 500, 
			"title" = {"text" = "Issue resolution", "fontSize" = 16},
			color = :issue_state)

	return figure
end	

# ╔═╡ f0413e1b-ce8b-424b-890d-530d4dc2c1b2
plot_all_issues(julia_list, myauth)

# ╔═╡ 93af6d71-128d-48cc-872f-68351a3bbeed


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
GitHub = "bc5e4493-9b4d-5f90-b8aa-2b2bcaad7a26"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
VegaLite = "112f6efa-9a02-5b7d-90c0-432ed331239a"

[compat]
DataFrames = "~1.3.4"
GitHub = "~5.7.2"
JSON = "~0.21.3"
VegaLite = "~2.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cc1a8e22627f33c789ab60b36a9132ac050bbf75"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.12"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "9267e5f50b0e12fdfd5a2455534345c4cf2c7f7a"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.14.0"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GitHub]]
deps = ["Base64", "Dates", "HTTP", "JSON", "MbedTLS", "Sockets", "SodiumSeal", "URIs"]
git-tree-sha1 = "056781ae7b953289778408b136f8708a46837979"
uuid = "bc5e4493-9b4d-5f90-b8aa-2b2bcaad7a26"
version = "5.7.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "2f49f7f86762a0fbbeef84912265a1ae61c4ef80"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "0.3.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.NodeJS]]
deps = ["Pkg"]
git-tree-sha1 = "905224bbdd4b555c69bb964514cfa387616f0d3a"
uuid = "2bd173c7-0d6d-553b-b6af-13a54713934c"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SodiumSeal]]
deps = ["Base64", "Libdl", "libsodium_jll"]
git-tree-sha1 = "80cef67d2953e33935b41c6ab0a178b9987b1c99"
uuid = "2133526b-2bfb-4018-ac12-889fb3908a75"
version = "0.1.1"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Vega]]
deps = ["DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "JSONSchema", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "Setfield", "TableTraits", "TableTraitsUtils", "URIParser"]
git-tree-sha1 = "43f83d3119a868874d18da6bca0f4b5b6aae53f7"
uuid = "239c3e63-733f-47ad-beb7-a12fde22c578"
version = "2.3.0"

[[deps.VegaLite]]
deps = ["Base64", "DataStructures", "DataValues", "Dates", "FileIO", "FilePaths", "IteratorInterfaceExtensions", "JSON", "MacroTools", "NodeJS", "Pkg", "REPL", "Random", "TableTraits", "TableTraitsUtils", "URIParser", "Vega"]
git-tree-sha1 = "3e23f28af36da21bfb4acef08b144f92ad205660"
uuid = "112f6efa-9a02-5b7d-90c0-432ed331239a"
version = "2.6.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libsodium_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "848ab3d00fe39d6fbc2a8641048f8f272af1c51e"
uuid = "a9144af2-ca23-56d9-984f-0d03f7b5ccf8"
version = "1.0.20+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─afe81112-206e-49fd-aa2f-acdb543d96cf
# ╠═010af338-d901-11ec-3d35-a964bb75c8bf
# ╟─0c06977f-ead5-40c8-9e7c-ecd491508613
# ╟─582bf436-8b7a-49f7-b81d-a676570644de
# ╟─e2f92cb3-1fdc-4d2d-90a0-92c3f7b72967
# ╠═ac855f25-d71e-42b3-bab6-16b865a46759
# ╟─0116a5fc-b43e-4712-b0cc-8c8b729bfbd8
# ╠═a9cab907-c5d4-439e-be65-5c258daa961d
# ╠═339b249d-3636-43e1-aede-5b441917917c
# ╠═a3bc140a-ad03-4a86-8d18-48edc00ab9d3
# ╠═cf80d78c-a924-461e-a921-3a5ae95c3ead
# ╠═a0e0ded3-add1-40a2-b069-112f017a289a
# ╠═d99ed742-2de2-4c40-ac73-1fb399419fd1
# ╟─66c9849e-2c73-4b96-bb07-c167d55b031d
# ╠═8010d155-3a4d-4238-9710-87413a9003c7
# ╠═d4fe0cd8-00c2-4a7f-80c8-3a5457ccc952
# ╠═679da4ef-3129-4dd2-b451-0ab0856d64b8
# ╠═db65697d-38c8-43f3-8d16-545bf88c2bbf
# ╠═f3a6e003-27e1-45cb-9423-7e3b8f57bbb6
# ╟─c5d96003-8094-42aa-bbcd-01da1549072d
# ╠═379d3637-16a3-498e-bd85-e124ab9054c4
# ╠═ff11835f-d3cc-4642-bc0c-af7e3e8d8918
# ╠═ab29b9b7-bd01-4f6d-abf6-97a5d5028412
# ╟─4e8ca8d3-53d7-4e35-8cea-7d44b26b9a40
# ╟─e162070e-10bb-4da5-8bc2-2988c2466406
# ╠═e12171f2-a769-4f74-9bf9-c4ee77b5a568
# ╠═81c44409-06e4-4d23-9c5d-61897c988c7b
# ╟─cbed0197-caec-4b0b-a802-663fbe0236a0
# ╟─3904aaf0-630c-4b91-b35d-a2f4d1b48373
# ╟─867ad62f-ce00-4ee0-ae1d-5dd9b3b9b465
# ╠═6612d86f-81a4-45a0-b321-4d57b8ececed
# ╟─f50b06df-c843-4d26-8389-f7888920bb11
# ╟─52a38c06-25c5-4a61-90cf-a7bf4a4fbbf5
# ╟─d2ec2e7a-57db-478d-9d79-7e8d8459f655
# ╠═fe3edcea-d3b2-45b6-b5b6-412f10a79ee4
# ╟─c9753306-7c06-4154-9d9a-466a75e6e667
# ╟─49fb3222-c1fb-400c-8a0f-ee9fd9b1b9f2
# ╟─d418aacc-f7a4-4a04-bd4c-f1b0cd46bf63
# ╠═a9c733a1-576b-4f8d-975d-dd3bb7fcd21a
# ╠═e04e568e-452c-4ac9-8738-84f8d69c72b6
# ╟─3b7ee27e-a171-49c1-acf2-b6dac57a98d8
# ╟─9a14c556-6619-42e9-bdea-a7becd1ebb2f
# ╟─fb347218-25bf-4369-abe1-671786e400f1
# ╟─0abc2a1f-1c77-4138-b4b3-29c3e0b5e4f9
# ╠═f0413e1b-ce8b-424b-890d-530d4dc2c1b2
# ╠═93af6d71-128d-48cc-872f-68351a3bbeed
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
