# Thank you to Doctor Laurent Pagnier for the GridWorld environment code.

# You are not allowed to modify what is in this file.
# p.s. These functions are not foolproof.

struct World
    reward::Matrix{Float64}
    blocked::Matrix{Int64}
    start::Vector{Int64}
    goal::Vector{Int64}
    size::Tuple{Int64,Int64}
end

function plot_world(world)
    map = repeat(['\u25A1'],world.size[1],world.size[2])
    
    for i = 1:size(world.blocked,1)
        map[world.blocked[i,1],world.blocked[i,2]] = '\u25A0'
    end
    map[world.start[1],world.start[2]] = '\u24E2' 
    map[world.goal[1],world.goal[2]] = '\u24BC'
    for i=1:world.size[1]
        println(map[i,:])
    end
    
    
end

function plot_optimal_action(Q, world; tol = 1E-6)
    # here Q is assumed to be 10x10x4
    leftarrow = '\u2190'
    uparrow = '\u2191'
    rightarrow = '\u2192'
    downarrow = '\u2193'
    bullet = '\u2022'
    map = repeat([bullet],world.size[1],world.size[2])
    for i=1:world.size[1]
        for j=1:world.size[2]
            idsort = sortperm(Q[i,j,:])
            dq_rel = (Q[i,j,idsort[end]] - Q[i,j,idsort[end-1]]) / min(1E-9,Q[i,j,idsort[end]])
            if(abs(dq_rel) > tol)
                if(idsort[end] == 1)
                    map[i,j] = downarrow
                elseif(idsort[end]  == 2)
                    map[i,j] = uparrow
                elseif(idsort[end] == 3)
                    map[i,j] = rightarrow
                else
                    map[i,j] = leftarrow
                end
            end
        end
    end
    
    for i = 1:size(world.blocked,1)
        map[world.blocked[i,1],world.blocked[i,2]] = '\u25A0'
    end
    map[world.goal[1],world.goal[2]] = '\u24BC'
    for i=1:world.size[1]
        println(map[i,:])
    end
end

function plot_policy(policy, world)
    # here Q is assumed to be 10x10x4
    leftarrow = '\u2190'
    uparrow = '\u2191'
    rightarrow = '\u2192'
    downarrow = '\u2193'
    bullet = '\u2022'
    map = repeat([bullet],world.size[1],world.size[1])
    if(length(size(policy)) == 2)
        for i=1:world.size[1]
            for j=1:world.size[2]
                if(policy[i,j] == 1)
                    map[i,j] = downarrow
                elseif(policy[i,j] == 2)
                    map[i,j] = uparrow
                elseif(policy[i,j] == 3)
                    map[i,j] = rightarrow
                else
                    map[i,j] = leftarrow
                end
            end
        end
    else
    
        for i=1:world.size[1]
            for j=1:world.size[2]
                temp = findmax(policy[i,j,:])[2]
                if(temp == 1)
                    map[i,j] = downarrow
                elseif(temp == 2)
                    map[i,j] = uparrow
                elseif(temp == 3)
                    map[i,j] = rightarrow
                else
                    map[i,j] = leftarrow
                end
            end
        end
    end
    for i = 1:size(world.blocked,1)
        map[world.blocked[i,1],world.blocked[i,2]] = '\u25A0'
    end
    map[world.goal[1],world.goal[2]] = '\u24BC'
    for i=1:world.size[1]
        println(map[i,:])
    end
end

function add_to_obs_state_action_pairs!(obs, s, a)
    k = 1
    is_new = true
    while((k <= length(obs)) & is_new)
        (obs[k] == (s ,a)) ? is_new = false : nothing
        k += 1
    end
    is_new ? push!(obs, (s,a)) : nothing
end

function transition(s, a, world)
    if(a == 1)
        s_new = [min(world.size[1],s[1]+1); s[2]]
    elseif(a == 2)
        s_new = [max(1,s[1]-1); s[2]]
    elseif(a == 3)
        s_new = [s[1]; min(world.size[2],s[2]+1)]
    else
        s_new = [s[1]; max(1,s[2]-1)]
    end
    rew=world.reward[s_new[1],s_new[2]]
    if(is_blocked(s_new, world))
        s_new = copy(s)
    end
    return s_new, world.reward[s_new[1],s_new[2]]
end

function is_blocked(s, world)
    return any((world.blocked[:,1] .== s[1]) .& (world.blocked[:,2] .== s[2]))
end
