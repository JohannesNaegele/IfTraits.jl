abstract type Musician end
struct OperaSinger <: Musician end
struct ChartsSinger <: Musician end
struct BadSinger <: Musician end
struct Composer <: Musician end

@traitdef CanSing, CanCompose

@traitimpl CanSing(OperaSinger, ChartsSinger)
@traitimpl CanCompose(Composer, ChartsSinger)

function test()
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

test()

@code_native compose_for(Composer(), OperaSinger())