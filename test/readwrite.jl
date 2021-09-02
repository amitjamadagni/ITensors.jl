using ITensors, HDF5, Test

include("util.jl")

@testset "HDF5 Read and Write" begin
  i = Index(2, "i")
  j = Index(3, "j")
  k = Index(4, "k")

  @testset "TagSet" begin
    ts = TagSet("A,Site,n=2")
    fo = h5open("data.h5", "w")
    write(fo, "tags", ts)
    close(fo)

    fi = h5open("data.h5", "r")
    rts = read(fi, "tags", TagSet)
    close(fi)
    @test rts == ts

    # save/load
    ITensors.save("data.h5", "tags", ts)
    rts = ITensors.load("data.h5", "tags")
    @test rts == ts
  end

  @testset "Index" begin
    i = Index(3, "Site,S=1")
    fo = h5open("data.h5", "w")
    write(fo, "index", i)
    close(fo)

    fi = h5open("data.h5", "r")
    ri = read(fi, "index", Index)
    close(fi)
    @test ri == i

    # primed Index
    i = Index(3, "Site,S=1")
    i = prime(i, 2)
    fo = h5open("data.h5", "w")
    write(fo, "index", i)
    close(fo)

    fi = h5open("data.h5", "r")
    ri = read(fi, "index", Index)
    close(fi)
    @test ri == i

    # save/load
    ITensors.save("data.h5", "index", i)
    ri = ITensors.load("data.h5", "index")
    @test ri == i
  end

  @testset "IndexSet" begin
    is = IndexSet(i, j, k)

    fo = h5open("data.h5", "w")
    write(fo, "inds", is)
    close(fo)

    fi = h5open("data.h5", "r")
    ris = read(fi, "inds", IndexSet)
    close(fi)
    @test ris == is

    # save/load
    ITensors.save("data.h5", "inds", is)
    ris = ITensors.load("data.h5", "inds")
    @test ris == is
  end

  @testset "Dense ITensor" begin

    # default constructed case
    T = ITensor()

    fo = h5open("data.h5", "w")
    write(fo, "defaultT", T)
    close(fo)

    fi = h5open("data.h5", "r")
    rT = read(fi, "defaultT", ITensor)
    close(fi)
    @test typeof(storage(T)) == typeof(storage(ITensor()))

    # real case
    T = randomITensor(i, j, k)

    fo = h5open("data.h5", "w")
    write(fo, "T", T)
    close(fo)

    fi = h5open("data.h5", "r")
    rT = read(fi, "T", ITensor)
    close(fi)
    @test norm(rT - T) / norm(T) < 1E-10

    # save/load
    ITensors.save("data.h5", "T", T)
    rT = ITensors.load("data.h5", "T")
    @test rT ≈ T

    # complex case
    T = randomITensor(ComplexF64, i, j, k)

    fo = h5open("data.h5", "w")
    write(fo, "complexT", T)
    close(fo)

    fi = h5open("data.h5", "r")
    rT = read(fi, "complexT", ITensor)
    close(fi)
    @test norm(rT - T) / norm(T) < 1E-10

    # save/load
    ITensors.save("data.h5", "T", T)
    rT = ITensors.load("data.h5", "T")
    @test rT ≈ T
  end

  @testset "QN ITensor" begin
    i = Index(QN("A", -1) => 3, QN("A", 0) => 4, QN("A", +1) => 3; tags="i")
    j = Index(QN("A", -2) => 2, QN("A", 0) => 3, QN("A", +2) => 2; tags="j")
    k = Index(QN("A", -1) => 1, QN("A", 0) => 1, QN("A", +1) => 1; tags="k")

    # real case
    T = randomITensor(QN("A", 1), i, j, k)

    fo = h5open("data.h5", "w")
    write(fo, "T", T)
    close(fo)

    fi = h5open("data.h5", "r")
    rT = read(fi, "T", ITensor)
    close(fi)
    @test rT ≈ T

    # save/load
    ITensors.save("data.h5", "T", T)
    rT = ITensors.load("data.h5", "T")

    @test rT ≈ T
    # complex case
    T = randomITensor(ComplexF64, i, j, k)

    fo = h5open("data.h5", "w")
    write(fo, "complexT", T)
    close(fo)

    fi = h5open("data.h5", "r")
    rT = read(fi, "complexT", ITensor)
    close(fi)
    @test rT ≈ T

    # save/load
    ITensors.save("data.h5", "T", T)
    rT = ITensors.load("data.h5", "T")
    @test rT ≈ T
  end

  @testset "MPO/MPS" begin
    N = 6
    sites = siteinds("S=1/2", N)

    # MPO
    mpo = makeRandomMPO(sites)

    fo = h5open("data.h5", "w")
    write(fo, "mpo", mpo)
    close(fo)

    fi = h5open("data.h5", "r")
    rmpo = read(fi, "mpo", MPO)
    close(fi)
    @test prod([norm(rmpo[i] - mpo[i]) / norm(mpo[i]) < 1E-10 for i in 1:N])

    # save/load
    ITensors.save("data.h5", "mpo", mpo)
    rmpo = ITensors.load("data.h5", "mpo")
    @test all(rmpo .≈ mpo)

    # MPS
    mps = makeRandomMPS(sites)
    fo = h5open("data.h5", "w")
    write(fo, "mps", mps)
    close(fo)

    fi = h5open("data.h5", "r")
    rmps = read(fi, "mps", MPS)
    close(fi)
    @test prod([norm(rmps[i] - mps[i]) / norm(mps[i]) < 1E-10 for i in 1:N])

    # save/load
    ITensors.save("data.h5", "mps", mps)
    rmps = ITensors.load("data.h5", "mps")
    @test all(rmps .≈ mps)
  end

  @testset "DownwardCompat" begin
    fi = h5open("testfilev0.1.41.h5", "r")

    ITensorName = "ITensorv0.1.41"

    # ITensor version <= v0.1.41 uses the `store` key for ITensor data storage
    # whereas v >= 0.2 uses `storage` as key
    @test haskey(read(fi, ITensorName), "store")
    @test read(fi, ITensorName, ITensor) isa ITensor
    close(fi)
  end

  @testset "Arrays containing ITensor objects" begin
    i = Index(2)
    A = randomITensor(i)
    B = randomITensor(i)
    C = randomITensor(i)
    D = randomITensor(i)

    X = [A B; C D]
    h5open("data.h5", "w") do file
      @write file X
    end
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", Array{ITensor})
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", ITensors.AutoType)
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      ITensors.read(file, "X")
    end
    @test all(X .== X̃)

    # save/load
    ITensors.save("data.h5", "X", X)
    X̃ = ITensors.load("data.h5", "X")
    @test all(X .== X̃)

    X = [i i'; i'' i''']
    h5open("data.h5", "w") do file
      @write file X
    end
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", Array{Index})
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", ITensors.AutoType)
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      ITensors.read(file, "X")
    end
    @test all(X .== X̃)

    # save/load
    ITensors.save("data.h5", "X", X)
    X̃ = ITensors.load("data.h5", "X")
    @test all(X .== X̃)

    X = [ts"a" ts"b"; ts"c" ts"d"]
    h5open("data.h5", "w") do file
      @write file X
    end
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", Array{TagSet})
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      read(file, "X", ITensors.AutoType)
    end
    @test all(X .== X̃)
    X̃ = h5open("data.h5", "r") do file
      ITensors.read(file, "X")
    end
    @test all(X .== X̃)

    # save/load
    ITensors.save("data.h5", "X", X)
    X̃ = ITensors.load("data.h5", "X")
    @test all(X .== X̃)
  end

  #
  # Clean up the test hdf5 file
  #
  rm("data.h5"; force=true)
end

nothing
