@testset "KNN" begin
    @testset "Default" begin
        tester = ImputorTester(KNN)
        test_hashing(tester)
        test_equality(tester)
        test_matrix(tester)
        test_axisarray(tester)
        test_nameddimsarray(tester)
        test_keyedarray(tester)
    end
    @testset "Iris" begin
        # Reference
        # P. Schimitt, et. al
        # A comparison of six methods for missing data imputation
        iris = Impute.dataset("test/table/iris") |> DataFrame
        iris2 = filter(row -> row[:Species] == "versicolor" || row[:Species] == "virginica", iris)
        data = Array(iris2[:, [:SepalLength, :SepalWidth, :PetalLength, :PetalWidth]])
        num_tests = 100

        @testset "Iris - 0.15" begin
            X = add_missings(data, 0.15)

            knn_nrmsd, mean_nrmsd = 0.0, 0.0

            for i = 1:num_tests
                knn_imputed = impute(copy(X), Impute.KNN(; k=2); dims=:cols)
                mean_imputed = impute(copy(X), Substitute(); dims=:cols)

                knn_nrmsd = ((i - 1) * knn_nrmsd + nrmsd(data, knn_imputed)) / i
                mean_nrmsd = ((i - 1) * mean_nrmsd + nrmsd(data, mean_imputed)) / i
            end

            @test knn_nrmsd < mean_nrmsd
            # test type stability
            @test typeof(X) == typeof(impute(copy(X), Impute.KNN(; k=2); dims=:cols))
            @test typeof(X) == typeof(impute(copy(X), Substitute(); dims=:cols))
        end

        @testset "Iris - 0.25" begin
            X = add_missings(data, 0.25)

            knn_nrmsd, mean_nrmsd = 0.0, 0.0

            for i = 1:num_tests
                knn_imputed = impute(copy(X), Impute.KNN(; k=2); dims=:cols)
                mean_imputed = impute(copy(X), Substitute(); dims=:cols)

                knn_nrmsd = ((i - 1) * knn_nrmsd + nrmsd(data, knn_imputed)) / i
                mean_nrmsd = ((i - 1) * mean_nrmsd + nrmsd(data, mean_imputed)) / i
            end

            @test knn_nrmsd < mean_nrmsd
            # test type stability
            @test typeof(X) == typeof(impute(copy(X), Impute.KNN(; k=2); dims=:cols))
            @test typeof(X) == typeof(impute(copy(X), Substitute(); dims=:cols))
        end

        @testset "Iris - 0.35" begin
            X = add_missings(data, 0.35)

            knn_nrmsd, mean_nrmsd = 0.0, 0.0

            for i = 1:num_tests
                knn_imputed = impute(copy(X), Impute.KNN(; k=2); dims=:cols)
                mean_imputed = impute(copy(X), Substitute(); dims=:cols)

                knn_nrmsd = ((i - 1) * knn_nrmsd + nrmsd(data, knn_imputed)) / i
                mean_nrmsd = ((i - 1) * mean_nrmsd + nrmsd(data, mean_imputed)) / i
            end

            @test knn_nrmsd < mean_nrmsd
            # test type stability
            @test typeof(X) == typeof(impute(copy(X), Impute.KNN(; k=2); dims=:cols))
            @test typeof(X) == typeof(impute(copy(X), Substitute(); dims=:cols))
        end
    end

    # Test a case where we expect kNN to perform well (e.g., many variables, )
    @testset "Data match" begin
        data = mapreduce(hcat, 1:1000) do i
            seeds = [sin(i), cos(i), tan(i), atan(i)]
            mapreduce(vcat, combinations(seeds)) do args
                [
                    +(args...),
                    *(args...),
                    +(args...) * 100,
                    +(abs.(args)...),
                    (+(args...) * 10) ^ 2,
                    (+(abs.(args)...) * 10) ^ 2,
                    log(+(abs.(args)...) * 100),
                    +(args...) * 100 + rand(-10:0.1:10),
                ]
            end
        end

        X = add_missings(data')
        num_tests = 100

        knn_nrmsd, mean_nrmsd = 0.0, 0.0

        for i = 1:num_tests
            knn_imputed = impute(copy(X), Impute.KNN(; k=4); dims=:cols)
            mean_imputed = impute(copy(X), Substitute(); dims=:cols)

            knn_nrmsd = ((i - 1) * knn_nrmsd + nrmsd(data', knn_imputed)) / i
            mean_nrmsd = ((i - 1) * mean_nrmsd + nrmsd(data', mean_imputed)) / i
        end

        @test knn_nrmsd < mean_nrmsd
        # test type stability
        @test typeof(X) == typeof(impute(copy(X), Impute.KNN(; k=4); dims=:cols))
        @test typeof(X) == typeof(impute(copy(X), Substitute(); dims=:cols))
    end
end
