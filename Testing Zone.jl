#Notes: 
# line 11 - issues with read_data.jl not here
#response to 
#  include("Read test.jl")
#  include("Testing Zone.jl")
#  v, M, A,s = read_data("Test Case.eaf")
#  tiers_of_interest = ["Brows","Gloss"]
#
#LoadError: BoundsError: attempt to access 0-element UnitRange{Int64} at index [0] JRR 10/17/18
#while loading /mnt/juliabox/Testing Zone.jl, in expression starting on line 11    JRR 10/17/18
#Stacktrace:                             
# [1] throw_boundserror(::UnitRange{Int64}, ::Int64) at ./abstractarray.jl:434     JRR 10/17/18
# [2] getindex at ./range.jl:477 [inlined]                                         JRR 10/17/18
# [4] include_from_node1(::String) at ./loading.jl:576                             JRR 10/17/18
# [5] include(::String) at ./sysimg.jl:14                                          JRR 10/17/18



TIERS NUMBER IS 13
include("read_data.jl")
include("overlap_of_tiers.jl")

function input(prompt::AbstractString="")
    print(prompt)
    return chomp(readline())
end

fn = input("What is the filename you would like to process?\n")
v,M,A,s = read_data(fn)  #issues with read_data.jl not here JR 10/17/18
println("Tiers available in this file are $s") 
x = parse(Int,input("How many tiers are you looking for?\n"))
input_tiers = AbstractString[]
for i = 1:x
    ques = join(["Please enter tier number ", i, "\n"])
    t = input(ques)
    push!(input_tiers,t)
end
println("We are working on your request, please wait a moment...")


tiers_of_interest = zeros(Int64,length(input_tiers))
for i = 1:length(input_tiers)
    tiers_of_interest[i] = get_tier_number(input_tiers[i],s)
end
# validate:
tiers_of_interest = sort(tiers_of_interest)
s[tiers_of_interest]

c = length(input_tiers) ####INPUT 3: OVERLAP SIZE
(tiers_final, tiers_unique, tiers_counts, annotations_final, annotations_unique,
annotations_counts,overlap_times,overlap_times_end) =
overlap_of_tiers(tiers_of_interest,c,A,M);

# this is the time of the overlap
# v[overlap_times_end] - v[overlap_times]
# v[overlap_times]

if isempty(annotations_unique)
    println("Sorry! There was no overlap.")
else
println("The annotations of these tiers are:")
for i = 1:size(annotations_unique,2)
       v = annotations_unique[:,i]
       st = ""
       for j = 1:length(v)-1
           st = st * v[j] * "\t+\t"
       end
       st = st * v[end] * "\t --> \t"
       st = join([st,annotations_counts[i]])
       println("$st")
end
end
TOTAL = vcat(annotations_unique,annotations_counts)
fn = input("What is the filename you would like the output to be printed to?\n")
savevalue(TOTAL,fn)
#Baby-FE 1 Mom-FE 1 103
#
#julia> close(outfile)
#
# println("The unique tiers that occurred are $tiers_unique")
# println("The total number of occurrences is $tiers_counts")
# println("The respective annotations are $annotations_final")
# println("The unique annotations are $annotations_unique")
# println("The respective unique annotations counts are $annotations_counts")


