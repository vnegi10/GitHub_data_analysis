## GitHub_data_analysis

In this Pluto notebook, we will analyze software development activity within the 
Julia ecosystem by making use of the GitHub API. Information such as number of 
contributors, forks, commits, open and closed issues is collected, and visualized for 
various popular packages. [GitHub.jl](https://github.com/JuliaWeb/GitHub.jl) provides 
the Julia interface to the API.

## Access token

You will need to create a personal access token for API authentication. Instructions to
do so can be found [here.](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

## How to use?

Install Pluto.jl (if not done already) by executing the following commands in your Julia REPL:

    using Pkg
    Pkg.add("Pluto")
    using Pluto
    Pluto.run() 

Clone this repository and open **GitHub_API_notebook.jl** in your Pluto browser window. That's it!
You are good to go.