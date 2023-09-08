abstract type Musician end
struct OperaSinger <: Musician end
struct ChartsSinger <: Musician end
struct BadSinger <: Musician end
struct Composer <: Musician end

@traitdef CanSing, CanCompose

@traitimpl CanSing(OperaSinger, ChartsSinger)
@traitimpl CanCompose(Composer, ChartsSinger)

@iftraits function compose_for(a, b)
    if CanCompose(a)
        if CanSing(b)
            println("works")
        else
            println("compose for someone else")
        end
    elseif CanCompose(b)
        if CanSing(b)
            println("compose for yourself and save the money")
        else
            println("maybe you should change your job?")
        end
    else
        if CanSing(b)
            println("play Puccini then!")
        else
            println("wtf is this bullshit")
        end
    end
end

# prints out all combinations
function all_pairs()
    types = [Composer(), OperaSinger(), ChartsSinger(), BadSinger()]
    count = 1
    for i in types
        for j in types
            println("($count)\n$i, $j:")
            compose_for(i, j)
            println()
            count += 1
        end
    end
end

all_pairs()