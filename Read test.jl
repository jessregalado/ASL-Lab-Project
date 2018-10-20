#Notes JRR 10/17/2018
 #Issues occur in this program 
 #Either
   #Its not actually acquiring the variables needed
  #or
   #Its not interacting with the overlap program corectly 
 #Plan to figure this out next week


#v,M,A,s = read_data("SM40F_WilburLab.eaf");

## Question 1:
#tiers,ct = get_ids(v,2809,M); #2809 is the time length(tiers) gives the count
#s[tiers]; #gives the actual tiers
#A[tiers,ct] # gives the annotation

##NOTES##
# v is the time ids
# M is the adj matrix representing tiers
    #rows are tiers
    #columns are time ids
    #entries are hit or miss
# A is the adj matrix encoding annotations
    #rows are tiers
    #columns are time ids
    #entries are annotations
# s is all the tiers in this dataset



function get_ids(v,t,M)
    s = find( x->(x == t), v)
    if ~isempty(s)
        C = M[:,s]
        (rt,ct,vt) = findnz(C)
        tiers = unique(rt)
        return tiers,s
    else
        i1 = findlast( x->(x < t), v)
        i2 = findfirst( x->(x > t), v)
        C = M[:,i1] + M[:,i2]
        tiers = find(C .== 2)
        return (tiers,[i1,i2])
    end
end

function searchall(s, t, overlap::Bool=false)
     idxfcn = overlap ? first : last
     r = search(s, t)
     idxs = Array(typeof(r), 0) # Or to only count: n = 0
     while last(r) > 0
         push!(idxs, r) # n += 1
         r = search(s, t, idxfcn(r) + 1)
     end
     idxs 
    return n
 end

function count_occurences(s,t)
    r = searchindex(s, t)
    n = 0
    while last(r) > 0
        n += 1
        r = searchindex(s, t,r + 1)
    end
    return n
end


function read_data(filename)
f = open(filename)
lines = readlines(f)
close(f)

l = lines[1]
header_lines = 1
while !contains(l,"<TIME_ORDER>")
    header_lines += 1
    l = lines[header_lines]
end
header_lines += 1
i = header_lines
diff = i-1

st_id = 51
l = lines[i]

str = ""
for ln in lines
    str *= ln
end

TIMES_SLOTS_TOTAL = count_occurences(str,"TIME_SLOT_ID")
TIME_SLOT_IDS = zeros(Int64,TIMES_SLOTS_TOTAL)

while !contains(l,"</TIME_ORDER>")
    t = search(l, "TIME_VALUE=")
    st_id = t[end] + 2

    a = l[st_id:length(l)-3]
    a = parse(Int,a)
    TIME_SLOT_IDS[i-diff] = a

    i += 1
    l = lines[i]
end
TIME_SLOT_IDS = TIME_SLOT_IDS - TIME_SLOT_IDS[1] + 1


tier_number = 0
N = TIME_SLOT_IDS[end] - TIME_SLOT_IDS[1] + 1;

TIERS_NB = count_occurences(str,"<TIER")

println("TIERS NUMBER IS $TIERS_NB")

M = zeros(Int64,TIERS_NB,N)
A = Array{AbstractString}(TIERS_NB,N)
A[:,:] = " "
TIERS = Array{AbstractString}(TIERS_NB)
j = i + 1
flag = true

vunique = unique(TIME_SLOT_IDS)
M = zeros(Int64,TIERS_NB,length(vunique))
A = Array{AbstractString}(TIERS_NB,length(vunique))
A[:,:] = "&#*"
 uniqueids = map(x -> findfirst(TIME_SLOT_IDS,x),vunique)

while flag
     println("current j is $j")

    l = lines[j]
    if !contains(l,"<TIER") & !contains(l,"TIME_SLOT_REF1")
        break
    end
    while contains(l,"<TIER")
        tier_number += 1
        if contains(l,"/>")
            x = search(l, "TIER_ID=")
            st_id = x[end] + 2
            TIERS[tier_number] = l[st_id:length(l)-3]
            j = j + 1
        else
            x = search(l, "TIER_ID=")
            st_id = x[end] + 2
            TIERS[tier_number] = l[st_id:length(l)-2]
            j = j + 2
        end
    l = lines[j]
    end

    t1 = search(l, "TIME_SLOT_REF1=\"ts")
    t2 = search(l, "TIME_SLOT_REF2=\"ts")

    tstr1 = t1[end] + 1
    tend1 = t2[1] - 3

    tstr2 = t2[end] + 1
    tend2 = length(l) - 2

    time1 = l[tstr1:tend1]
    time2 = l[tstr2:tend2]

    time1 = parse(Int,time1)
    time2 = parse(Int,time2)

    time1 = TIME_SLOT_IDS[time1]
    time2 = TIME_SLOT_IDS[time2]

    time1_unique = findin(vunique,time1)[1]
    time2_unique = findin(vunique,time2)[1]

    M[tier_number,time1_unique] = 2
    M[tier_number,time2_unique] = 2
    M[tier_number,time1_unique+1:time2_unique-1] = 1

    annotation_line = lines[j+1]
    a1 = search(annotation_line, "<ANNOTATION_VALUE>")
    a2 = search(annotation_line, "</ANNOTATION_VALUE>")

    if isempty(a2)
        annotation = annotation_line[a1[end] + 1:end]
        j += 1
    else
        annotation = annotation_line[a1[end] + 1:a2[1] - 1]
    end
    if annotation == ""
        annotation = "#ANR#"
    end
    A[tier_number,time1_unique:time2_unique] = annotation
    
     if tier_number == 2
         if 6867 <= time2_unique
             if 6867 >= time1_unique
                 println("current j is $j")
                 error("EXIT")
             end
         end
     end

    j += 5
end
return (vunique,M,A,TIERS)

end
